# shellcheck disable=SC2148
# === DOTFILES ===
alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# === HELPERS ===
mkcd() {
  if [[ ! -d "$1" ]]; then mkdir -p "$1"; fi
  cd "$1" || return 1
}
alias m='man'
alias g='git'
complete -F _fzf_path_completion -o default -o bashdefault g
alias gs='git status'
alias gl='git lo'
alias diff='diff --color=auto'
alias p='podman'
alias pc='podman ps -a'
alias pst='podman stop'
alias prm='podman rm'
alias prma='podman rm -a'
alias pi='podman images -a'
alias prmi='podman rmi'
pstrm() {
  if [[ ! -d "$1" ]]; then podman stop "$1" && podman rm "$1"; else echo "Please specify a contianer"; fi
}

# === CLIPBOARD ===
# Usage:
# echo "text" | scb;
# scb << EOF
# hello, world
# EOF
# gcb > file.txt
# 1. xclip
# alias scb='xclip -i -selection clipboard'
# alias gcb='xclip -o -selection clipboard'

# 2. windows native
# shellcheck disable=SC2154
# @link: https://stackoverflow.com/questions/48016113/how-to-pass-utf-8-characters-to-clip-exe-with-powershell-without-conversion-to-a
alias scb='/mnt/c/Windows/System32/WindowsPowershell/v1.0/powershell.exe -NonInteractive -NoProfile -NoLogo -c '"'"'$OutputEncoding=[console]::InputEncoding=[console]::OutputEncoding=New-Object System.Text.UTF8Encoding;clip.exe'"'"
# shellcheck disable=SC2154
# @neovim: with fix for empty output
alias gcb='/mnt/c/Windows/System32/WindowsPowershell/v1.0/powershell.exe -NonInteractive -NoProfile -NoLogo -c '"'"'$OutputEncoding=[console]::InputEncoding=[console]::OutputEncoding=New-Object System.Text.UTF8Encoding;$_buf=Get-Clipboard -Raw;if($null -ne $_buf){[Console]::Out.Write($_buf.tostring().replace("`r", ""))}'"'"

# 3. win32yank
# NOTE: Windows Host: set environment variable
# name: WSLENV
# value: USERPROFILE/p:
# alias scb='$USERPROFILE/scoop/apps/neovim/current/bin/win32yank.exe -i --crlf'
# alias gcb='$USERPROFILE/scoop/apps/neovim/current/bin/win32yank.exe -o --lf'

# === NVIM ===
alias v='nvim'
complete -F _fzf_path_completion -o default -o bashdefault v
alias vi='nvim'
alias vim='nvim'
alias vv='nvim --cmd "cd ~/.config/nvim"'
alias vd='cd ~/.local/state/nvim/'
alias vs='cd ~/.local/share/nvim/'

# === FZF ===
alias f='fzf'
jf() {
  if [[ $# -gt 0 ]]; then
    _z "$*"
    return
  fi
  local dir
  dir=$(_z -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9]* *//')
  if [[ -n "$dir" ]]; then
    cd "$dir" || return 1
  fi
}
alias vf='nvim $(fzf)'

# === LS ===
alias ll='ls -atrhlF --color=auto'
complete -F _fzf_path_completion -o default -o bashdefault ll
alias la='ls -AF --color=auto'
complete -F _fzf_path_completion -o default -o bashdefault la
alias l='ls -trhlF --color=auto'
complete -F _fzf_path_completion -o default -o bashdefault l

# === ALERT ===
# Add an "alert" alias for long running commands. Use like so: `sleep 10; alert`
alias alert='notify-send --urgency=low -i "$([[ $? = 0 ]] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# === NPM ===
# List what (top level) packages are installed
alias npm-list-installed-packages="npm ls --depth=0."
# List what installed packages are outdated
alias npm-list-outdated-packages="npm outdated --depth=0."

# === MISC ===
alias todo='nvim ~/dev/TODO.md'
alias tl='nvim ~/dev/TODO.md'
alias t='tree'
