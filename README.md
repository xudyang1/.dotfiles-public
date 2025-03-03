<!-- markdownlint-disable MD013 -->

# Public Dotfiles (Windows)

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

### 0. Install `Git-Bash` by `scoop`

```powershell
# run in Windows PowerShell or pwsh
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install git
git-bash
```

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

### 2. **CHECKOUT** the actual content from the bare repository to your `$HOME`

```bash
alias config='git --git-dir=$HOME/.dotfiles-public/ --work-tree=$HOME';
# WARN: the following command WITHOUT branch name will checkout the default branch
config checkout # or `config checkout <os-branch>`
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
> config checkout # or `config checkout <os-branch>`
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

### 4. Post installation

- After dotfiles are checkout to new system, run `scoop install ...`
- Copy Windows Terminal `settings.json` to portable Windows Terminal settings directory:

```bash
cp ~/.config/wt/settings.json ~/scoop/apps/windows-terminal/settings/settings.json
```

- Check `pwsh` `$PROFILE` file can be read successfully

## System Settings (Windows)

### Performance

- `Win+I` => System => Display => Turn off `Show animations in Windows`
- `Win+S` and typing keyboard for keyboard panel, change the following settings
  - keyboard repeat key delay: short
  - keyboard repeat key rate: fast

### Security

- `Win+I` => Devices => Autoplay => Turn off `Autoplay`, set `Removable drive`
and `Memory card` to `Take no action` or `Ask me every time`

### Third party

- `Win+S`
  - Set user environment variable `$XDG_CONFIG_HOME=$USERPROFILE/.config` for neovim configuration path
  - Set user environment variable `$WSLENV=USERPROFILE/p:` to let WSL access Windows host `$USERPROFILE` env

- Chrome: disable [smooth-scrolling](chrome://flags/#smooth-scrolling)
  - this prevents Vimium to scroll slowly in search using `n` or `N`

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

## Tools

## Package Managers

- Winget (native package manager)
- Scoop (no UAC popup)

## Fonts

- [FiraCode NF](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode)
- [Comic Shanns Mono](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/ComicShannsMono)

```bash
# download .tar.xz (requires xz)
FONT_FILE="FiraCode.tar.xz"
# FONT_FILE="ComicShannsMono.tar.xz"
curl -LO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FONT_FILE"
tar -xvJf "./$FONT_FILE"

# or download .zip (requires unzip)
FONT_FILE="FiraCode.zip"
# FONT_FILE="ComicShannsMono.zip"
curl -LO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FONT_FILE"
tar -xvzf "./$FONT_FILE" # requires unzip
```

## Scoop apps

```txt
git
pwsh
starship
extras/windows-terminal
versions/windows-terminal-preview
fd
ripgrep
gcc
pyenv
make
neovim
fzf
kanata
extras/glazewm

delta
nvm
cmake
gh
gitui
wget
7zip
hyperfine
tree-sitter
extras/keyviz
extras/obs-studio
extras/musicplayer2
```

### Shell related

- `pwsh` (by winget or Microsoft Store)
  - `z`, `PSReadLine`

```pwsh
# run in pwsh, not Windows PowerShell
Install-Module -Name z
Install-Module PSReadLine # may be already installed natively 
# pre-release
# Install-Module PSReadLine -AllowPrerelease -Force
```

- terminal recorders:
  - `yarn global add terminalizer`
  - `asciinema`
  - `vhs`

### Editors

- `extras/vscode`
  - keymap, settings.json, extensions, snippets
- `neovim`

### Languages

- nodejs: `nvm` (node version manager)
- python: `miniconda` or `pyenv` (python version manager)
- cpp/c: `gcc`/`clang` (for neovim TreeSitter), `cmake`, `gdb`

## GUIs

### Browsers

- Chrome/Firefox with plugins:
  - `Vimium`
    - [remove global mark](https://github.com/philc/vimium/issues/3181#issuecomment-1013613015)
  - uBlock origin
  - react dev tools
  - storage area explorer

### DEV tools

- `versions/windows-terminal-preview` (or from Microsoft Store)
  - `extras/wezterm`
  - `extras/alacritty`
- `extras/postman`
- Podman in WSL (alternatives to docker), kubernetes
- VirtualBox, VM, qemu
- Wireshark, Pingplotter
- PowerToys Preview
  - key mappings

### Misc

- Kit [github](https://github.com/johnlindquist/kit)
- GIMP: image manipulation program
- audacity: audio editor
- `extras/keyviz` / `extras/carnac`: show keystoke on screen
- Sigil: epub/ebook editor
- video editor?
- Obsidian: note taking (markdown)
  - keymaps, settings, appearance
- ShellExView (NirSoft): fix file explorer right click hanging issues

# Shrink WSL2 Virtual Disk

```powershell
# shutdown all wsl instances
wsl --shutdown

# open window Diskpart
diskpart

# fill with path to file `ext4.vhdx`, for example
select vdisk file="$YOUR_HOME\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu22.04LTS_79rhkp1fndgsc\LocalState\ext4.vhdx"

attach vdisk readonly
compact vdisk
detach vdisk

exit
```
