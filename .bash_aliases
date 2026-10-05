# shellcheck shell=bash
# === dotfiles ===
config() {
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

alias m='man'
alias info='info --vi-keys'
alias g='git'
alias gs='git status --short --branch'
alias gl='git l'
ga() {
  if [[ -n "$*" ]]; then
    git add "$@"
  else
    files=$(git ls-files -m | fzf --multi \
      --preview='git diff --color=always -- {}')

    if [[ -n "$files" ]]; then
      echo "$files" | xargs -d '\n' git add
      echo "$files"
    fi
  fi
}
gco() {
  if [[ -n "$*" ]]; then
    git checkout "$@"
  else
    local br
    br=$(git branch --list --sort=-committerdate --format='%(refname:short)' |
      fzf --no-multi \
        --preview='git log --oneline --graph --color=always -n 5 {}')
    if [[ -n "$br" ]]; then
      git checkout "$br"
    fi
  fi
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
# when .fzfrc is not available
# if [[ -z "$FZF_DEFAULT_OPTS" ]]; then
#   export FZF_DEFAULT_OPTS="--reverse --cycle --height='40%' --info='inline' --no-separator"
# fi
t() {
  if [[ $# -gt 0 ]]; then
    _z 2>&1 "$@"
    return
  fi
  local dir
  dir=$(_z -l 2>&1 | fzf --accept-nth='2..' +s --tac)
  if [[ -n "$dir" ]]; then
    cd "$dir" || return 1
  fi
}
fv() {
  # using 'mapfile' is the safest way to handle spaces in filenames
  mapfile -t files < <(fzf --multi)

  if [ ${#files[@]} -gt 0 ]; then
    nvim -p "${files[@]}"
  fi
}
fkill() {
  local pid
  if [ "$UID" -ne 0 ]; then
    # List only user processes if not root
    pid=$(ps -f -u "$USER" | sed 1d |
      fzf -m --header='[kill:process]' | awk '{print $2}')
  else
    # List all processes if root
    pid=$(ps -ef | sed 1d |
      fzf --multi --header='[kill:all-process]' | awk '{print $2}')
  fi

  if [ -n "$pid" ]; then
    echo "$pid" | xargs kill -9
    echo "Process $pid terminated."
  fi
}

# === NPM ===
# top level installed
alias npm-installed="npm ls --depth=0."
# top level outdated
alias npm-outdated="npm outdated --depth=0."

# === system clipboard ===
# Set Clipboard (OSC 52, xclip, powershell)
# Usage: echo "hi" | scb OR scb < file.txt
# scb << 'EOF'
# > lines of text...
# > EOF
scb() {
  local input
  input=$(</dev/stdin)
  [[ -z "$input" ]] && return

  # optimized WSL: use Windows native powershell
  if [[ -n "$WSL_DISTRO_NAME" ]]; then
    printf '%s' "$input" |
      /mnt/c/Windows/System32/WindowsPowershell/v1.0/powershell.exe \
        -NonInteractive -NoProfile -Command \
        "[Console]::InputEncoding=[System.Text.Encoding]::UTF8; \
        Set-Clipboard -Value ([Console]::In.ReadToEnd() -replace \"\`r\", \"\")"
  # xclip
  elif command -v xclip >/dev/null; then
    printf '%s' "$input" | xclip -selection clipboard -i -loops 1 -quiet
  # OSC52
  else
    local b64
    b64=$(printf "%s" "$input" | base64 | tr -d '\n')

    if [[ -n "$TMUX" ]]; then
      # Tmux pass-through
      printf "\ePtmux;\e\e]52;c;%s\a\e\\" "$b64"
    else
      printf "\e]52;c;%s\a" "$b64"
    fi
  fi

  echo "(Copied to clipboard.)" >&2
}

# Get Clipboard
# Usage: gcb > file.txt OR gcb | grep 'pattern'
gcb() {
  # optimized WSL: use Windows native powershell
  if [[ -n "$WSL_DISTRO_NAME" ]]; then
    /mnt/c/Windows/System32/WindowsPowershell/v1.0/powershell.exe \
      -NonInteractive -NoProfile -Command \
      "[Console]::OutputEncoding=[System.Text.Encoding]::UTF8; \
      [Console]::Out.Write((Get-Clipboard -Raw) -replace \"\`r\", \"\")"
  elif command -v xclip >/dev/null; then
    xclip -selection clipboard -o
  else
    echo "Error: No 'get' clipboard utility found." >&2
    return 1
  fi
}

# === MISC ===
alias todo='nvim ~/dev/TODO.md'

mkcd() {
  [[ -z "$1" ]] && return
  mkdir -p -- "$1" && cd -- "$1" || return 1
}
