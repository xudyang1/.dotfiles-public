<!-- markdownlint-disable MD013 -->

# Public Dotfiles (Windows)

## Create a bare repository for version control and upload to remote

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

## Pull dotfiles from remote repository to new PC or system

```bash
# set alias
alias config='git --git-dir=$HOME/.dotfiles-public/ --work-tree=$HOME'
# make alias available in `.bashrc`
echo "alias config='git --git-dir=$HOME/.dotfiles-public/ --work-tree=$HOME'" >> $HOME/.bashrc
# your source repository ignores the folder where you'll clone it, so that you don't create weird recursion problems:
echo ".dotfiles-public" >> .gitignore

# clone from remote
git clone --bare <git-remote-repo-url> $HOME/.dotfiles-public
```

- You may encounter the following permission error during first time setup, you can either
  - generate new ssh key and add it to github account (if the repo is private or clone by ssh)
  - or clone by `https`

```txt
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
```

- **CHECKOUT** the actual content from the bare repository to your `$HOME`:

```bash
config checkout
```

- The above step may fail with an error message like:

```textile
error: The following untracked working tree files would be overwritten by checkout:
    .bashrc
    .gitignore
Please move or remove them before you can switch branches.
Aborting
```

- This error warns you that in your `$HOME` folder, some old configuration files would be overwritten by Git. Try back up the files or remove them. The following command shortcut moves all the offending files automatically to a backup folder:

```bash
# move existing dotfiles into `$HOME/.dotfiles-backup/`
# WARN: check the output from awk first!!
config checkout 2>&1 | head -n -2 | tail -n +2 | awk {'print $1'} | xargs -I{} bash -c 'mkdir -p $HOME/.dotfiles-backup/$(dirname {}) && mv -nv {} $HOME/.dotfiles-backup/{}'
# Re-run the check out if your previous checkout failed
# WARN: the following command WITHOUT branch name will checkout the default branch
config checkout
# Set the flag showUntrackedFiles to no on this specific (local) repository:
config config --local status.showUntrackedFiles no
```

## Use submodule in dotfiles

- tracking all indivisual files may be tedius, for example:
  - `~/.gitconfig` and `~/.bashrc` should be tracked by `config` to avoid home directory pollution
  - but `~/.config/nvim` should be tracked by itself, as those files are tightly coupled as neovim configuration
  - now, we can make `~/.config/nvim` as a git directory, and then make `config` add `~/.config/nvim` as submodule
- [Ref](https://stackoverflow.com/questions/36386667/how-to-make-an-existing-directory-within-a-git-repository-a-git-submodule)

# System Settings (Windows)

- `Win+I` => System => Display => Turn off `Show animations in Windows`

- `Win+I` => Devices => Autoplay => Turn off `Autoplay`, set `Removable drive`
and `Memory card` to `Take no action` or `Ask me every time`

- `Win+S` and typing keyboard for keyboard panel, change the following settings
  - keyboard repeat key delay: short
  - keyboard repeat key rate: fast

- `Win+S`
  - Add user environment variable `$XDG_CONFIG_HOME=$USERPROFILE/.config` for neovim configuration path
  - Set user environment variable `$WSLENV=USERPROFILE/p:` to let wsl access windows host `$USERPROFILE` env

- Chrome: disable [smooth-scrolling](chrome://flags/#smooth-scrolling)
  - this prevents Vimium to scroll in search using `n` or `N`

## Generate SSH key

```bash
# check for existing ssh keys
ls -al ~/.ssh

# generate a new ssh key
ssh-keygen -t ed25519 -C "your_email@example.com"
# configure filename, passphrase...

# add the new ssh key to github account (no additional whitespace or newline)
clip < ~/.ssh/id_ed25519.pub

# go to github.com > settings > SSH and GPG keys > paste the content
```

## Generate GPG key

```bash
# check for existing gpg keys
gpg --list-secret-keys --keyid-format=long

# generate a new gpg key
gpg --version # gpg versin >=2.1.17

gpg --full-generate-key
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

- An error like this one might be a sign of an expired GPG key.

```txt
error: gpg failed to sign the data fatal: failed to write commit object
```

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
# We might get a warning There is no assurance this key belongs to the named user otherwise.
# gpg> trust

# save your work
# gpg> save

# upload to github
gpg --armor --export KEYID
```

# Tools

## Package Managers

- Winget (native package manager)
- Scoop (windows package manager)

## Fonts

- [FiraCode NF](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode)
- [Comic Shanns Mono](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/ComicShannsMono)

## Scoop apps (most TUIs)

```txt
7zip
cacert
cmake
delta
fd
fzf
gcc
gh
git
gitui
hyperfine
make
# if microsoft keyboard layout creator is blank, change windows scaling factor to 100% in Taskbar setting
# also check `.klc` file for the `VK_` values mapped
msklc
# keyboard configuration
kanata
glazewm
musicplayer2
neovim
nvm
pyenv
ripgrep
starship
tree-sitter
wget
```

### Editors

- Visual Studio Code
  - keymap, settings.json, extensions, snippets
- Neovim
  - config

### Shell related

- Powershell Core (by winget or Microsoft Store)
  - fzf, z, PSReadLine (Powershell Modules)
- starship
- hyperfine (performance measure cli-tool)
- ripgrep, fd-find (for neovim Telescope)
- terminal recorders: terminizer, asciinema, vhs

### Git related

- Git
  - cz-cli, git-lfs, vim-fugitive
- Delta (git diff)
- gitui (lazygit?)
- gh

### Languages

- nodejs: NVM (node version manager)
- python: Miniconda or Pyenv-win (python version manager)
- cpp/c: gcc/clang (for neovim TreeSitter), cmake, gdb

## GUIs

### Browsers

- Chrome/Firefox with plugins:
  - vimium
    - [remove global mark](https://github.com/philc/vimium/issues/3181#issuecomment-1013613015)
  - uBlock origin
  - react dev tools
  - storage area explorer

### DEV tools

- Windows Terminal Preview (from Microsoft Store)
- Postman
- Podman in WSL (alternatives to docker), kubernetes
- VirtualBox, VM
- Wireshark, Pingplotter
- PowerToys Preview
  - key mappings
  - settings BACKUP (TODO: version controll)

### Misc

- Kit [github](https://github.com/johnlindquist/kit)
- GIMP: image manipulation program
- audacity: audio editor
- keyviz / carnac: show keystoke on screen
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
