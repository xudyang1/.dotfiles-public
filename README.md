<!-- markdownlint-disable MD013 -->

# Public Dotfiles for Linux

## To track dotfiles in current system

```bash
# Create bare repo at $HOME directory
cd "$HOME" && git init --bare "$HOME/.dotfiles"
# Create alias for convenience
config() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }
# Make alias available in `.bashrc`
echo 'config() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }' >> "$HOME/.bashrc"
# Hide untracked files
config config --local status.showUntrackedFiles no

# Now, you can do
config add .bashrc
config commit -m 'Add .bashrc'
config remote add origin <remote-repo-url>
config push -u origin main
```

## To clone dotfiles repository to a new system

### 1. Clone as a bare repo

```bash
# Clone from remote
cd "$HOME"; git clone --bare <remote-repo-url> "$HOME/.dotfiles"
```

> [!NOTE]
> Permission denied error may occur when cloning a repository that requires ssh
> key athentication, you can either:
>
> - generate a new ssh key and upload it to the github account
> - use a public dotfile repository and clone it by `https`

### 2. *CHECKOUT* the actual content from the bare repository to your `$HOME`

```bash
# Create alias for convenience
config() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }
# Hide untracked files
config config --local status.showUntrackedFiles no
# WARN: WITHOUT a branch name, default branch is checked out
config checkout <os-branch>
```

> [!NOTE]
> Git will prevent you overwrite files that already present in current system:
>
> ```txt
> error: The following untracked working tree files would be overwritten by checkout:
>     .bashrc
>     .gitignore
> Please move or remove them before you can switch branches.
> Aborting
> ```
>
> Try back up the files or remove them:
>
> ```bash
> # WARN: should always check the output from awk first!!!
> config checkout <os-branch> 2>&1 | awk '/^[ \t]+/ {print $1}'
> # Move existing dotfiles into $HOME/.dotfiles-backup/
> config checkout <os-branch> 2>&1 | awk '/^[ \t]+/ {print $1}' | xargs -I{} bash -c 'BKD="$HOME/.dotfiles-backup"; mkdir -p "$BKD/$(dirname "{}")" && mv -nv "{}" "$BKD/{}"'
> # Re-run the check out if your previous checkout failed
> config checkout <os-branch>
> ```

### 3. Post installation

- Update tracked submodule:
  - [make a tracked directory to git submodule](https://stackoverflow.com/questions/36386667/how-to-make-an-existing-directory-within-a-git-repository-a-git-submodule)

```bash
# Update submodules to tracked commits
config submodule update --init --recursive
# Update submodules to latest
config submodule update --init --recursive --remote
```

- Enable custom systemd services:

```bash
# Reload systemd user manager
systemctl --user daemon-reload

# Loop through and enable all service files found in the directory
for service in ~/.config/systemd/user/*.service; do
    if [ -f "$service" ]; then
        service_name=$(basename "$service")
        echo "Activating $service_name..."
        systemctl --user enable --now "$service_name"
    fi
done
```

## Generate SSH key

```bash
# Check for existing ssh keys
ls -al ~/.ssh
# Generate a new ssh key
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "your_email@example.com"
# Configure passphrase...

# Add the new ssh public key to github account (no additional whitespace or newline)
scb < ~/.ssh/id_ed25519.pub

# Go to github.com > settings > SSH and GPG keys > paste the content
```

## Generate GPG key

```bash
# 1. Check for existing gpg keys
gpg --list-secret-keys --keyid-format=long # gpg -K

# 2. Generate a new gpg key
# gpg --default-new-key-algo rsa4096 --gen-key # gpg --version < 2.1.17
gpg --full-generate-key # gpg --version > 2.1.17
# select the algorithm (Enter for default `RSA and RSA`)
# select the key length (4096)
# select validity period (1y)
# confirm information (y)

# user ID (github username)
# email (github noreply email)
# comment (any, i.e., machine or OS name)
# confirm OK (O)
# enter passphrase ...

# 3. Generate GPG public key block, and copy it
gpg --armor --export YOUR_KEY

# 4. Paste the content to github account
```

## GPG Renew or Extend Expiration

> [!NOTE]
> GPG will fail to sign data if the key expires
>
> ```txt
> error: gpg failed to sign the data fatal: failed to write commit object
> ```

- [reference guide](https://gist.github.com/TheSherlockHomie/a91d3ecdce8d0ea2bfa38b67c0355d00)

```bash
gpg -K
# ---------------------------------
# sec   rsa4096/HJ6582DC8B78GTU 2020-12-09 [SC] [expires: 2025-05-01]
#       15JHUG1D325F458624HF7521B3F5D82DC458H
# uid                 [ultimate] TheSherlockHomie (Key to sign git commits) <email@gmail.com>
# ssb   rsa4096/11HGTH5483DD0A 2020-12-09 [E] [expires: 2025-05-01]

gpg --edit-key KEYID # HJ6582DC8B78GTU in this case

# gpg> expire
# gpg> 1y

# Also update subkey
# gpg> key1
# ...

# Since the key has changed, we now need to trust it.
# We might get a warning `There is no assurance this key belongs to the named user` otherwise.
# gpg> trust

# Save your work
# gpg> save

# Upload to github
gpg --armor --export KEYID
```

## Fonts

- [FiraCode NF](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode)
- [Comic Shanns Mono](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/ComicShannsMono)

```bash
# Download .tar.xz (requires xz)
FONT_FILE="FiraCode.tar.xz"
# FONT_FILE="ComicShannsMono.tar.xz"
curl -LO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FONT_FILE"
tar -xvJf "./$FONT_FILE"

# Or download .zip (requires unzip)
FONT_FILE="FiraCode.zip"
# FONT_FILE="ComicShannsMono.zip"
curl -LO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FONT_FILE"
tar -xvzf "./$FONT_FILE"
```

### Tools

- git, gh, delta
- neovim
  - tree-sitter-cli, ripgrep, fdfind, fzf, rustup (cargo)
  - curl, wget, gzip, unzip
  - gcc, gdb, cmake
- tmux, kanata, hyperfine, tree
- package manager: uv or pyenv, nvm
- container: podman (buildah, runC), skopeo
- devop: terraform, ansible
- qemu

- terminal recorders: terminizer, asciinema, vhs
- keystroke visualizer: screenkey
- video recorder: obs-studio
- image editor: gimp
- audio editor: audacity
- video editor: DaVinci, `extras/kdenlive`
- [Kit](https://github.com/johnlindquist/kit)

### Browsers

- `extras/googlechrome` or `extras/firefox` plugins:
  - vimium or surfingkeys
    - [remove global mark](https://github.com/philc/vimium/issues/3181#issuecomment-1013613015)
  - uBlock origin
  - react dev tools
  - storage area explorer

## System settings

### General

- disable `~/.sudo_as_admin_successful`

```txt
# https://github.com/sudo-project/sudo/issues/56#issuecomment-984925944
# /etc/sudoers.d/local_config
# Disable ~/.sudo_as_admin_successful file
Defaults !admin_flag
```

- disable `sudo` message on startup

```bash
# https://askubuntu.com/a/22646
sudo vim /etc/bash.bashrc
```

Then comment out the following lines in `/etc/bash.bashrc`:

```bash
# sudo hint
# if [ ! -e "$HOME/.sudo_as_admin_successful" ]; then
#     case " $(groups) " in *\ admin\ *)
#     if [ -x /usr/bin/sudo ]; then
#     cat <<-EOF
#     To run a command as administrator (user "root"), use "sudo <command>".
#     See "man sudo_root" for details.
#
#     EOF
#     fi
#     esac
# fi
```

### Ubuntu

- remove `snap`
  - [instructions](https://www.debugpoint.com/remove-snap-ubuntu/)
  - `sudo apt-mark hold snapd` [reference](https://askubuntu.com/questions/1345385/how-can-i-stop-apt-from-installing-snap-packages)

```bash
# Remove package cleanly
sudo apt remove --purge PACKAGE_NAME
sudo apt autoremove --purge
# Remove configuration files of packages that were already removed
# WARN: check packages listed before sudo purge
dpkg -l | grep '^rc' | awk '{print $2}' | sudo xargs dpkg --purge
```

### WSL

- enable `systemd` in file `/etc/wsl.conf`

```txt
[boot]
systemd=true
cmd="mount --make-rshared /"
# disable append windows $PATH
[interop]
enabled=true
appendWindowsPath=false
# disable WSL auto generates `/etc/resolv.conf` if you choose to use your own DNS lookup
[network]
generateResolvConf=false
```

- change DNS lookup that generated by WSL to your choice in `/etc/resolv.conf`

```txt
nameserver = 1.1.1.1
```

- Symlink for `$BROWSER`: `sudo ln -s "/mnt/c/Program Files/Mozilla Firefox/firefox.exe" /usr/bin/firefox`

- Fixes
  - use `dmesg` to show startup profile
  - some possible [fixes](https://github.com/arkane-systems/genie/wiki/Systemd-units-known-to-be-problematic-under-WSL)
  - `systemctl status -l systemd-remount-fs.service` examine status -> `sudo e2label /dev/sdb cloudimg-rootfs` or delete the line for `/` from `/etc/fstab` entirely
  - `multipathd.service` -> either use `systemctl` to turn off or mask `multipathd.service`
  - `$XDG_RUNTIME_DIR` not user accessible [issue](https://github.com/microsoft/WSL/issues/10846)
    - `/run/user/1000` owned by `root` => solved by `sudo chown $USER:usergroup /run/user/1000` where `usergroup` can be found by `id -gn`
- Harmless
  - [Failed to connect to bus: No such file or directory](https://github.com/microsoft/WSL/issues/2941)
  - `PCI: Fatal: No config space access function found`
  - `kvm: no hardware support`
