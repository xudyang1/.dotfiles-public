#!/usr/bin/bash -e

# === REQUIRE SUDO ===
readonly NVIM_INSTALL_DIR="/usr/local/bin"
readonly NVIM_PATH="$NVIM_INSTALL_DIR/nvim"
readonly SQUASHFS_ROOT_PATH="$NVIM_INSTALL_DIR/squashfs-root"
readonly APPRUN_PATH="$SQUASHFS_ROOT_PATH/AppRun"

readonly NVIM_APPIMAGE="nvim-linux-x86_64.appimage"
readonly NVIM_CHECKSUM="shasum.txt"
readonly NVIM_LATEST_APPIMAGE_URL="https://github.com/neovim/neovim/releases/latest/download/$NVIM_APPIMAGE"
readonly NVIM_NIGHTLY_APPIMAGE_URL="https://github.com/neovim/neovim/releases/download/nightly/$NVIM_APPIMAGE"
readonly NVIM_LATEST_CHECKSUM_URL="https://github.com/neovim/neovim/releases/latest/download/$NVIM_CHECKSUM"
readonly NVIM_NIGHTLY_CHECKSUM_URL="https://github.com/neovim/neovim/releases/download/nightly/$NVIM_CHECKSUM"

read -r -p "Download nightly neovim [yY/n]? (default no) " nightly

case ${nightly:0:1} in
y | Y)
  echo -e "\033[1mDownloading Nightly appimage...\033[0m"
  curl -LO "$NVIM_NIGHTLY_APPIMAGE_URL"
  echo -e "\033[1mDownloading Nightly checksum...\033[0m"
  curl -LO "$NVIM_NIGHTLY_CHECKSUM_URL"
  ;;
*)
  echo -e "\033[1mDownloading LATEST appimage...\033[0m"
  curl -LO "$NVIM_LATEST_APPIMAGE_URL"
  echo -e "\033[1mDownloading LATEST checksum...\033[0m"
  curl -LO "$NVIM_LATEST_CHECKSUM_URL"
  ;;
esac

# display commands running
set -x
chmod u+x "./$NVIM_APPIMAGE"

# do not display commands running
set +x
"./$NVIM_APPIMAGE" --appimage-extract >/dev/null

# if upgrade, remove existing
if [[ -s "$NVIM_PATH" ]]; then
  set -x
  rm "$NVIM_PATH"
  set +x
fi
if [[ -s "$SQUASHFS_ROOT_PATH" ]]; then
  set -x
  rm -r "$SQUASHFS_ROOT_PATH"
  set +x
fi

set -x
# move to `/usr/local/bin/` and create a symlink for it
mv squashfs-root "$SQUASHFS_ROOT_PATH"
ln -s "$APPRUN_PATH" "$NVIM_PATH"
set +x

echo -e "\033[1mCheck sha256sum...\033[0m"
set -x
# test checksum and version
(grep -e "$NVIM_APPIMAGE\$" "$NVIM_CHECKSUM" | sha256sum --check) && nvim --version
sha256sum --check "./$NVIM_CHECKSUM" && nvim --version

# cleanup
rm "./$NVIM_APPIMAGE" "./$NVIM_CHECKSUM"
