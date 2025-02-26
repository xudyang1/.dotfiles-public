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

# === CLIPBOARD ===
# alias scb='xclip -i -selection clipboard'
# alias gcb='xclip -o -selection clipboard'
# echo "text" | scb
alias scb='clip.exe'
# gcb > file.txt
alias gcb='powershell.exe -NonInteractive -NoProfile -NoLogo -c '\''[Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))'\'''

# === NVIM ===
alias v='nvim'
complete -F _fzf_path_completion -o default -o bashdefault v
alias vi='nvim'
alias vim='nvim'
alias vv='nvim --cmd "cd ~/.config/nvim"'
alias vd='cd $HOME/AppData/Local/nvim-data/'

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
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# === NPM ===
# List what (top level) packages are installed
alias npm-list-installed-packages="npm ls --depth=0."
# List what installed packages are outdated
alias npm-list-outdated-packages="npm outdated --depth=0."

# === MISC ===
alias todo='nvim ~/dev/TODO.md'
alias tl='nvim ~/dev/TODO.md'
# === Windows git-bash ===
alias t='tree.com //f'
alias tree='tree.com //f'
