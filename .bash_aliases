# shellcheck shell=bash
# === dotfiles ===
config() {
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

# === git ===
alias g='git'
alias gl='git log --oneline --graph'
alias gs='git status --short --branch'
ga() {
  if [[ "$#" -gt 0 ]]; then
    git add "$@"
    return
  fi
  local files
  files=$(git ls-files -m | fzf --multi \
    --preview='git diff --color=always -- {}')
  [[ -z "$files" ]] && return 1
  printf '%s' "$files" | xargs -d '\n' -r git add --
}

# === colors ===
alias ll='ls -atrhlF --color=auto --show-control-chars'
alias la='ls -AF --color=auto --show-control-chars'
alias l='ls -trhlF --color=auto --show-control-chars'
alias ls='ls -F --color=auto --show-control-chars'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

# === podman ===
alias p='podman'
alias pc='podman ps -a'
alias pi='podman images -a'
alias pst='podman stop'
alias prm='podman rm'
alias prma='podman rm -a'
alias prmi='podman rmi'
pstrm() {
  if [[ ! -d "$1" ]]; then
    podman stop "$1" && podman rm "$1"
  else
    echo "Please specify a container"
  fi
}
_fzf_complete_podman() {
  # Get the current command context
  # $1 is the command (podman), $2 is the word being completed
  local subcommand="${COMP_WORDS[1]}"
  case "$subcommand" in
  # Commands that require Image IDs
  rmi | push | tag | inspect | history | save)
    _fzf_complete --multi --header-lines=1 -- "$@" < <(
      podman images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Created}}\t{{.Size}}"
    )
    ;;
  # Commands that require Container IDs (default)
  *)
    _fzf_complete --multi --header-lines=1 --preview='podman inspect {1}' -- "$@" < <(
      podman ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"
    )
    ;;
  esac
}
_fzf_complete_podman_post() {
  awk '{print $1}'
}
complete -F _fzf_complete_podman -o default -o bashdefault podman
complete -F _fzf_complete_podman -o default -o bashdefault p

# === neovim ===
alias n='nvim'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias vv='nvim --cmd "cd ~/.config/nvim"'

# === fzf ===
alias f='fzf'
t() {
  if [[ $# -gt 0 ]]; then
    _z 2>&1 "$@"
    return
  fi
  local dir
  dir=$(_z -l 2>&1 | fzf --accept-nth='2..' +s --tac)
  if [[ -n "$dir" ]]; then
    cd -- "$dir" || return 1
  fi
}
fv() {
  # spread among tabs
  #fzf --multi --print0 | xargs -0 -r nvim -p
  # buffer list in single tab
  fzf --multi --bind 'enter:become(nvim {+})'
}
fkill() {
  local pid
  if [ "$UID" -ne 0 ]; then
    # list only user processes if not root
    pid=$(ps -f -u "$USER" | sed 1d |
      fzf -m --header='[kill:process]' | awk '{print $2}')
  else
    # list all processes if root
    pid=$(ps -ef | sed 1d |
      fzf --multi --header='[kill:all-process]' | awk '{print $2}')
  fi
  if [ -n "$pid" ]; then
    echo "$pid" | xargs kill -9
    echo "Process $pid terminated."
  fi
}

# === npm ===
# top level installed
alias npm-installed="npm ls --depth=0."
# top level outdated
alias npm-outdated="npm outdated --depth=0."

# === clipboard ===
# set clipboard: echo "hi" | scb; scb < file.txt
scb() {
  local input
  input=$(</dev/stdin)
  [[ -z "$input" ]] && return
  if command -v xclip >/dev/null; then
    printf '%s' "$input" | xclip -selection clipboard -i -loops 1 -quiet
  else
    if [[ -n "$TMUX" ]]; then
      printf '%s' "$input" | tmux load-buffer -w -
    else
      local b64
      b64=$(printf '%s' "$input" | base64 | tr -d '\n')
      # shellcheck disable=1003
      printf '\033]52;c;%s\033\\' "$b64"
    fi
  fi
  echo '(Copied to clipboard.)' >&2
}
# get clipboard: gcb > file.txt; gcb | grep 'pattern'
gcb() {
  if command -v xclip >/dev/null; then
    xclip -selection clipboard -o
  elif [[ -n "$WSL_DISTRO_NAME" ]]; then
    /mnt/c/Windows/System32/WindowsPowershell/v1.0/powershell.exe \
      -NonInteractive -NoProfile -Command \
      "[Console]::OutputEncoding=[System.Text.Encoding]::UTF8; \
      \$text=(Get-Clipboard -Raw).Replace(\"\`r\`n\", \"\`n\"); \
      [Console]::Out.Write(\$text)"
  else
    echo "Error: No 'get' clipboard utility found." >&2
    return 1
  fi
}

# === misc ===
alias m='man'
alias todo='nvim ~/dev/TODO.md'
mkcd() {
  [[ "$#" -eq 1 && -n "$1" ]] || return 1
  mkdir -p -- "$1" || return
  cd -- "$1" || return
}
