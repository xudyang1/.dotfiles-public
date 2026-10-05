<!-- markdownlint-disable MD013 -->

# Public Dotfiles Instructions

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

### 0. Windows-only: install `scoop` and portable `git`

- Run in Windows PowerShell or `pwsh`

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

- Switch to the OS-specific branch and follow the post-installation instructions in its README.

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
