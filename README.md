<!-- markdownlint-disable MD013 -->

# Dotfiles for Linux/WSL

## Create a new bare repository to track dotfiles in local system

```bash
cd $HOME
# create bare repo at `$HOME` directory
git init --bare $HOME/.dotfiles-public
# set alias
alias config='git --git-dir=$HOME/.dotfiles-public/ --work-tree=$HOME'
# make alias available in `.bashrc`
echo "alias config='git --git-dir=$HOME/.dotfiles-public/ --work-tree=$HOME'" >> $HOME/.bashrc
# hide untracked files
config config --local status.showUntrackedFiles no

# now, you can do
config status
config add .vimrc
config commit -m "Add .vimrc"
config remote add origin GIT_REPO
config push -u origin main
```

## Clone dotfiles from remote repository to new PC or system

### 1. Clone as a bare repo

```bash
# clone from remote
cd $HOME; git clone --bare <remote-repo-url> $HOME/.dotfiles-public
```

> [!NOTE]
> Permission denied error may occur when cloning a private repo or when cloning
> by ssh, you can either:
>
> - generate a new ssh key and add it to github account
> - clone by `https`

### 2. *CHECKOUT* the actual content from the bare repository to your `$HOME`

```bash
alias config='git --git-dir=$HOME/.dotfiles-public/ --work-tree=$HOME';
# WARN: the following command WITHOUT branch name will checkout the default branch
config checkout linux # checkout this branch, not the main
# do not show unrelevant files in `git status`
config config --local status.showUntrackedFiles no
```

> [!NOTE]
>
> - Git may prevent you overwrite files that already present in current system:
>
> ```txt
> error: The following untracked working tree files would be overwritten by checkout:
>     .bashrc
>     .gitignore
> Please move or remove them before you can switch branches.
> Aborting
> ```
>
> - try back up the files or remove them:
>
> ```bash
> # move existing dotfiles into `$HOME/.dotfiles-backup/`
> # WARN: should always check the output from awk first!!!
> config checkout 2>&1 | head -n -2 | tail -n +2 | awk {'print $1'} | xargs -I{} bash -c 'mkdir -p $HOME/.dotfiles-backup/$(dirname {}) && mv -nv {} $HOME/.dotfiles-backup/{}'
> # Re-run the check out if your previous checkout failed
> # WARN: the following command WITHOUT branch name will checkout the default branch
> config checkout linux # checkout this branch, not the main
> # do not show unrelevant files in `git status`
> config config --local status.showUntrackedFiles no
> ```

### 3. Clone submodules in dotfiles

> [!TIP]
> Submodules may help tracking tightly coupled files
>
> - [make a tracked directory to git submodule](https://stackoverflow.com/questions/36386667/how-to-make-an-existing-directory-within-a-git-repository-a-git-submodule)

```bash
# update submodules to tracked commits
git submodule update --init --recursive
# update submodules to latest
config submodule update --init --recursive --remote
```

## Generate SSH key

```bash
# check for existing ssh keys
ls -al ~/.ssh

# generate a new ssh key
ssh-keygen -t ed25519 -C "your_email@example.com"
# configure filename, passphrase...

# add the new ssh public key to github account (no additional whitespace or newline)
clip.exe < ~/.ssh/id_ed25519.pub

# go to github.com > settings > SSH and GPG keys > paste the content
```

## Generate GPG key

```bash
# check for existing gpg keys
gpg --list-secret-keys --keyid-format=long

# generate a new gpg key
# `gpg --default-new-key-algo rsa4096 --gen-key # gpg --version < 2.1.17`
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

# generate GPG Public Key Block, and copy it
gpg --export --armor YOUR_KEY

# Paste the content to github account
```

## GPG Renew or Extend Expiration

> [!NOTE]
>
> GPG will fail to sign data if the key expires
>
> ```txt
> error: gpg failed to sign the data fatal: failed to write commit object
> ```

- [reference guide](https://gist.github.com/TheSherlockHomie/a91d3ecdce8d0ea2bfa38b67c0355d00)

```bash
gpg --list-secret-keys --keyid-format LONG
# ---------------------------------
# sec   rsa4096/HJ6582DC8B78GTU 2020-12-09 [SC] [expires: 2025-05-01]
#       15JHUG1D325F458624HF7521B3F5D82DC458H
# uid                 [ultimate] TheSherlockHomie (Key to sign git commits) <email@gmail.com>
# ssb   rsa4096/11HGTH5483DD0A 2020-12-09 [E] [expires: 2025-05-01]

gpg --edit-key KEYID # HJ6582DC8B78GTU in this case

# gpg> expire
# gpg> 1y

# also update subkey
# gpg> key1
# ...

# Since the key has changed, we now need to trust it.
# We might get a warning `There is no assurance this key belongs to the named user` otherwise.
# gpg> trust

# save your work
# gpg> save

# upload to github
gpg --armor --export KEYID
```

## System settings (WSL)

- remove `snap`
  - [instructions](https://www.debugpoint.com/remove-snap-ubuntu/)
  - `sudo apt-mark hold snapd` [reference](https://askubuntu.com/questions/1345385/how-can-i-stop-apt-from-installing-snap-packages)

```bash
# remove package cleanly
sudo apt remove --purge PACKAGE_NAME
sudo apt autoremove --purge
# remove configuration files of packages that were already removed
# WARN: check first
dpkg -l | grep '^rc' | awk '{print $2}' | sudo xargs dpkg --purge
```

- enable `systemd` in file `/etc/wsl.conf`

```txt
[boot]
systemd=true
cmd="mount --make-rshared /"
# disable append windows $PATH
[interop]
appendWindowsPath=false
# disable WSL auto generates `/etc/resolv.conf` if you choose to use your own DNS lookup
# [network]
# generateResolvConf=false
```

- change DNS lookup that generated by WSL to your choice in `/etc/resolv.conf`

```txt
nameserver = 1.1.1.1
```

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

### Misc

- disable `~/.sudo_as_admin_successful`

```config
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

### Tools

- gcc, rust, gdb, cmake, go
- tree
- hyperfine
- kanata
- neovim: need xclip or `:h clipboard-wsl` or [this](https://mitchellt.com/2022/05/15/WSL-Neovim-Lua-and-the-Windows-Clipboard.html)
  - `Telescope`: `ripgrep`, `fd-find`
  - `unzip` for `mason.nvim`
  - `sshfs` for remote
- git, gh, gitui/lazygit, delta
- zsh, starship, tmux, fzf
- nvm (node version manager)
- pyenv (python version manager)
- Container: podman (buildah, runC), skopeo
  - podman [warnings](https://github.com/containers/podman/issues/12983)
- Devop: terraform
- terminal recorders: terminizer, asciinema, vhs

- screenkey
- obs studio
- gimp
- audacity
- video editor?

## Some manual installed packages

```txt
unzip
wslu
ripgrep
base-files
base-passwd
bash
bsdutils
build-essential
cmake
dash
diffutils
fd-find
findutils
gdb
gh
grep
gzip
hostname
hyperfine
init
libdebconfclient0
libfuse2 # for neovim if necessary
login
ncurses-base
ncurses-bin
podman
sshfs
sysvinit-utils
terraform
tree
ubuntu-minimal
ubuntu-standard
ubuntu-wsl
```
