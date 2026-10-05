#!/usr/bin/env sh
# shellcheck shell=sh disable=SC1091,SC2015
set -eu

script_dir=$(dirname -- "$(realpath -- "$0")")
[ -f "$script_dir/msg.sh" ] && . "$script_dir/msg.sh" || msg() { echo "$@"; }

APPIMAGE_NAME="nvim-linux-x86_64.appimage"
dest_dir=$(pwd)

usage() {
  cat <<EOF
Usage: $(basename -- "$0") [options] <VERSION>

Arguments:
  <VERSION>  Target version to install ('stable', 'nightly', or a git tag like v0.12.3)

Options:
  -d <dir>   Destination directory for installation (default: current directory)
  -h         Show this help
EOF
}

while getopts "d:h" opt; do
  case "$opt" in
  d) dest_dir=$(realpath "$OPTARG") ;;
  h)
    usage
    exit 0
    ;;
  *)
    usage
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

if [ $# -ne 1 ]; then
  msg -b red "Error: Missing required argument <VERSION>."
  usage
  exit 1
fi

version="$1"

case "$version" in
stable | nightly | v[0-9]*.[0-9]*.[0-9]*) ;;
*)
  msg -b red "Error: <VERSION> must be 'stable', 'nightly', or in the form of git tag 'v0.12.3'"
  exit 1
  ;;
esac

asset_path="$dest_dir/$APPIMAGE_NAME"
api_url="https://api.github.com/repos/neovim/neovim/releases/tags/$version"
asset_url="https://github.com/neovim/neovim/releases/download/$version/$APPIMAGE_NAME"

# Fetch Metadata and Download
msg -b blue "Fetching metadata for Neovim ($version)..."
json_data=$(curl -sSfL -H "Accept: application/vnd.github+json" "$api_url")
if [ -z "$json_data" ]; then
  msg -b red "Error: Unable to resolve release at $api_url. Check your input <VERSION>."
  exit 1
fi

asset_status_code=$(curl -sL -o /dev/null -w "%{http_code}" -H "Accept: application/vnd.github+json" "$asset_url")
msg -b blue "Downloading Neovim ($version) to $asset_path..."
if [ "$asset_status_code" = "404" ]; then
  msg -b red "Error: $version release exists but unable to resolve asset url: $asset_url. Please update the asset name: $APPIMAGE_NAME."
  exit 1
fi

if [ ! -w "$dest_dir" ]; then
  msg -b red "Error: Cannot write to $dest_dir. Re-try with sudo."
  exit 1
fi
curl --output-dir "$dest_dir" -LOs "$asset_url"

# Verify Checksum
REMOTE_DIGEST=$(echo "$json_data" | sed -n "/\"name\": \"$APPIMAGE_NAME\"/,/\"digest\"/p" | sed -n 's/.*"digest": "\(.*\)".*/\1/p')
if [ -z "$REMOTE_DIGEST" ]; then
  msg -b red "Unable to download sha256 checksum."
fi
LOCAL_DIGEST="sha256:$(sha256sum "$asset_path" | awk '{print $1}')"
if [ "$LOCAL_DIGEST" != "$REMOTE_DIGEST" ]; then
  msg yellow "ASSET digest: $REMOTE_DIGEST"
  msg yellow "LOCAL digest: $LOCAL_DIGEST"
  msg -b red "Error: Checksum mismatch detected."
  msg -b red "Installation aborted."
  exit 1
else
  msg -b green "Checksum verified successfully:"
  msg "$LOCAL_DIGEST"
fi

# Extract Locally
msg blue "Extracting $asset_path..."
if [ -d "$dest_dir/squashfs-root" ]; then
  rm -r "$dest_dir/squashfs-root"
fi

cd "$dest_dir" # appimage extract always to CWD
chmod +x "$asset_path"
"$asset_path" --appimage-extract >/dev/null

squashfs_dir="$dest_dir/squashfs-root-$version"
if [ -d "$squashfs_dir" ]; then
  rm -r "$squashfs_dir"
fi
if [ -d "$dest_dir/squashfs-root" ]; then
  mv "$dest_dir/squashfs-root" "$squashfs_dir"
else
  msg -b red "No squashfs-root found. Appimage extract failed."
  exit 1
fi

# Install to Destination
nvim_link="$dest_dir/nvim-$version"
msg blue "Creating softlink: $nvim_link..."
ln -sf "$squashfs_dir/AppRun" "$nvim_link"

# Cleanup and Verify
msg blue "Removing $asset_path..."
rm -f "$asset_path"
msg -b green "Installation complete!"
"$nvim_link" --version | head -n 1
