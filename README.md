<!-- markdownlint-disable MD013 -->

# Public Dotfiles for Windows

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

### 0. Install `scoop` and portable `git`

Run in Windows PowerShell or `pwsh`
 
```ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install git
```

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

- Install `scoop` packages:

```ps1
scoop import $HOME/.config/scoop/scoopfile.json
```

- Copy Windows Terminal `settings.json` to portable Windows Terminal settings directory:

```bash
cp $HOME/.config/wt/settings.json $HOME/scoop/apps/windows-terminal/settings/settings.json
```

- Check `pwsh` `$PROFILE` file can be read successfully

- Open `pwsh` as an **Administrator**, enable `ssh-agent`:

```pwsh
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
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
>
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

### Fonts

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

- Chrome: disable [smooth-scrolling](chrome://flags/#smooth-scrolling)
  - this prevents Vimium to scroll slowly in search using `n` or `N`

- Firefox: use elevated powershell session to add `AutoConfig` files

```ps1
Copy-Item -Path "$HOME/.config/browsers/firefox/firefox.js" -Destination "C:/Program Files/Mozilla Firefox/firefox.js"
Copy-Item -Path "$HOME/.config/browsers/firefox/autoconfig.js" -Destination "C:/Program Files/Mozilla Firefox/defaults/pref/autoconfig.js"
```

## Packages/Tools

- package managers: winget, scoop
- pwsh
  - `z`, `PSReadLine`
- git, gh, delta
- neovim
  - tree-sitter-cli, ripgrep, fdfind, fzf
  - curl, wget, gzip, unzip
  - gcc, make, cmake, (llvm, gdb)
- uv or pyenv, nvm
- hyperfine, 7zip

```ps1
# WARN: run in pwsh, NOT Windows PowerShell
Install-Module -Name z

# pwsh may have native install of PSReadLine
Get-Module PSReadLine -ListAvailable
Install-Module PSReadLine -Repository PSGallery -Scope CurrentUser -Force
# pre-release
# Install-Module PSReadLine -Repository PSGallery -Scope CurrentUser -AllowPrerelease -Force
```

### Misc

- Terminal:
  - `versions/windows-terminal-preview`
  - `extras/wezterm`
  - `extras/alacritty`
- Virtual machine: VirtualBox, `qemu`
- Network: `extras/wireshark`, pingplotter, `extras/postman`
- Terminal recorder: `vhs`, terminalizer, asciinema
- Video recorder: `extras/obs-studio`
- Image editing/design: `extras/gimp`, `extras/inkscape`
- Audio editor: `extras/audacity`
- Keystroke visualizer: `extras/keyviz`, `extras/carnac`
- Keyboard mapper: `extras/kanata`
- Window manager: `extras/glazewm`, `extras/komorebi`
- Text editor:
  - code: `neovim`, `extras/vscode`
  - notes: `extras/obsidian`
  - epub: `extras/sigil`
- Video editor: DaVinci, `extras/kdenlive`
- `nirsoft/shexview`: fix file explorer right click hanging issues
- `extras/ventoy`: create bootable usb
- `extras/crystaldiskinfo`, `extras/crystaldiskmark`
- `extras/musicplayer2`
- [Kit](https://github.com/johnlindquist/kit)
- ~~`extras/powertoys`~~

### Browsers

- `extras/googlechrome` or `extras/firefox` plugins:
  - vimium or surfingkeys [remove global mark](https://github.com/philc/vimium/issues/3181#issuecomment-1013613015)
  - uBlock origin
  - react dev tools
  - storage area explorer

## Shrink WSL2 Virtual Disk

```ps1
# shutdown all wsl instances
wsl --shutdown

# open window Diskpart
diskpart

# fill with path to file `ext4.vhdx`, for example
# default $HOME/AppData/Local/Packages/CanonicalGroupLimited.Ubuntu22.04LTS_79rhkp1fndgsc/LocalState/ext4.vhdx
# can be moved by `wsl --manage <distro_name> --move <new_location>`
select vdisk file="path_to_ext4.vhdx"

attach vdisk readonly
compact vdisk
detach vdisk

exit
```
