# shellcheck shell=bash
# If not running interactively, don't do anything
# case $- in
# *i*) ;;
# *) return ;;
# esac
[[ $- != *i* ]] && return

# @see bash(1) for setting history length
HISTSIZE=1000
HISTFILESIZE=10000
# ignore duplicate lines or lines starting with space
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# %F -> 'YYYY-M-D'
# %T -> 'HH:MM:S'
HISTTIMEFORMAT='%F %T '

# check the window size after each command and,
# if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize
# case-insensitive globbing (pathname expansion)
shopt -s nocaseglob
# autocorrect typos in path names when `cd`
shopt -s cdspell
# if set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar
# arguments ignore case when typing tab
bind 'set completion-ignore-case on'
# ctrl+x,ctrl+y: copy command line to system clipboard
_copy_osc52() {
  local content="$READLINE_LINE"
  [[ -z "$content" ]] && return

  local b64_content
  b64_content=$(printf '%s' "$content" | base64 | tr -d '\n')

  if [[ -n "$TMUX" ]]; then
    # Tmux wrap: \ePtmux;\e [SEQUENCE] \e\\
    # Note: We must double the escapes inside the wrap for some tmux versions
    printf "\033Ptmux;\033\033]52;c;%s\007\033\134" "$b64_content"
  else
    # Standard OSC 52
    # printf "\e]52;c;%s\e\134" "$b64_content"
    printf "\033]52;c;%s\007" "$b64_content"
  fi

  echo '(Copied to clipboard.)' >&2
}
bind -x '"\C-x\C-y": _copy_osc52'
# fix git bash flickering
bind 'set bell-style none'

# make less more friendly for non-text input files, @see lesspipe(1)
# if [[ -x /usr/bin/lesspipe ]]; then eval "$(SHELL=/bin/sh lesspipe)"; fi
#
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
# if ! shopt -oq posix; then
#   if [[ -f /usr/share/bash-completion/bash_completion ]]; then
#     . /usr/share/bash-completion/bash_completion
#   elif [[ -f /etc/bash_completion ]]; then
#     . /etc/bash_completion
#   fi
# fi

is_in_path() {
  [[ ":$PATH:" == *":$1:"* ]]
}
prepend_path() {
  if [[ -d "$1" ]] && ! is_in_path "$1"; then
    export PATH="$1:$PATH"
  fi
}
try_source() {
  if [[ -f "$1" ]]; then \. "$1"; fi
}

# user's private bin
prepend_path "$HOME/bin"
prepend_path "$HOME/.local/bin"
# === go ===
prepend_path '/usr/local/go/bin'
# === rust ===
export CARGO_HOME="$HOME/.local/share/cargo"
export RUSTUP_HOME="$HOME/.local/share/rustup"
prepend_path "$CARGO_HOME/bin"
# === fzf ===
prepend_path "$HOME/.local/share/fzf/bin"
if command -v fzf >/dev/null; then
  eval "$(fzf --bash)"
  try_source "$HOME/.config/fzf/.fzfrc"
fi
# === terraform ===
if [[ -x /usr/bin/terraform ]]; then
  complete -C /usr/bin/terraform terraform
fi
# === NVM ===
export NVM_DIR="$HOME/.local/share/nvm"
try_source "$NVM_DIR/nvm.sh"
try_source "$NVM_DIR/bash_completion"

# === misc ===
# disable .lesshst
export LESSHISTFILE=-
# ctrl+x ctrl+e opens nvim to edit the current command
export EDITOR=nvim
# neovim gx, gh-cli, xdg-open
export BROWSER=/usr/bin/firefox
export MANPAGER='nvim +Man!'
# === REPL & logs ===
# disable node repl history log
export NODE_REPL_HISTORY=''
# suppress distro python repl history file write
export PYTHONSTARTUP="$HOME/.config/python/.pythonrc" # < 3.13
# export PYTHON_HISTORY=/dev/null # >= 3.13
# === npm ===
export NPM_CONFIG_USERCONFIG="$HOME/.config/npm/.npmrc"
# === z ===
export _Z_DATA="$HOME/.config/z/.z"
# handle z's PROMPT_COMMAND hook inside custom prompt
export _Z_NO_PROMPT_COMMAND=1
try_source "$HOME/.config/z/z.sh"
# === ssh ===
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/openssh_agent"
# === gpg ===
GPG_TTY="$(tty)"
export GPG_TTY
#gpg-connect-agent updatestartuptty /bye >/dev/null

# === aliases ===
try_source "$HOME/.bash_aliases"

# === prompt ===
if ! declare -F "__git_ps1" >/dev/null; then
  try_source "/usr/lib/git-core/git-sh-prompt"
fi
export GIT_PS1_SHOW{DIRTYSTATE,STASHSTATE,UNTRACKEDFILES,COLORHINTS}=1
export GIT_PS1_SHOWUPSTREAM='auto git'
export GIT_PS1_DESCRIBE_STYLE='branch' # relative to newer tag/branch (main~4)
export GIT_PS1_SHOWCONFLICTSTATE='yes'
if [[ -z "${debian_chroot:-}" && -r /etc/debian_chroot ]]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi
# disable standard venv prompt hijacking
export VIRTUAL_ENV_DISABLE_PROMPT=1
_set_bash_prompt() {
  local EXIT="$?"

  # append new session command to $HISTFILE, will intervene with other sessions
  # history -a
  # sync command across multiple open terminals
  #history -n

  if declare -f _z >/dev/null; then
    # shellcheck disable=SC2086
    (_z --add "$(command pwd $_Z_RESOLVE_SYMLINKS 2>/dev/null)" 2>/dev/null &)
  fi

  # local BOLD='\[\033[01m\]'
  local BGREEN='\[\033[01;32m\]'
  local GREEN='\[\033[0;32m\]'
  # local BBLUE='\[\033[01;34m\]'
  local BLUE='\[\033[0;34m\]'
  # local BRED='\[\033[01;31m\]'
  local RED='\[\033[0;31m\]'
  local RESET='\[\033[00m\]'
  #    󰣭    󰍲 
  # local C_ICON='\[\033[38;2;233;84;32;1m\]'
  # local ICON="${C_ICON} ${RESET}"

  local CHROOT="${debian_chroot:+($debian_chroot)}"

  local USER_HOST=""
  # if on root or on an SSH connection, show username and hostname
  if [[ "$EUID" -eq 0 || -n "$SSH_CONNECTION" ]]; then
    USER_HOST='\u@\h:'
  fi

  local DIR="$PWD"
  if [[ "$DIR" == "$HOME" ]]; then
    DIR='~'
  elif [[ "$DIR" == "$HOME"/* ]]; then
    local BASENAME="${DIR##*/}"
    local PARENT_DIR="${DIR%/*}"
    if [[ "$PARENT_DIR" == "$HOME" ]]; then
      # shellcheck disable=SC2088
      DIR="~/$BASENAME"
    else
      DIR="${PARENT_DIR##*/}/$BASENAME"
    fi
  fi
  # sets terminal tab title
  printf '\033]0;%s%s\007' "${USER_HOST}" "${DIR}" # also supports legacy terminals
  # printf '\033]0;%s%s\033\134' "${USER_HOST}" "${DIR}" # for modern terminals

  USER_HOST="${USER_HOST:+${GREEN}${USER_HOST}${RESET}}"
  DIR="${BGREEN}${DIR}${RESET}"

  local VENV=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local VENV_NAME="${VIRTUAL_ENV##*/}"

    # for generic (.venv, venv, .env, env), use project directory name instead
    if [[ "$VENV_NAME" =~ ^(\.venv|venv|\.env|env)$ ]]; then
      local PARENT_DIR="${VIRTUAL_ENV%/*}"
      VENV_NAME="${PARENT_DIR##*/}"
    fi

    VENV="${BLUE}(${VENV_NAME})${RESET}"
  fi
  local SIGN='$' # "\n$"
  if [[ $EXIT -ne 0 ]]; then
    SIGN="${RED}\$${RESET}${RED}(${EXIT})${RESET}"
  fi

  PS1="\A ${CHROOT}${USER_HOST}${DIR} $(__git_ps1 '(%s)')${VENV}${SIGN} "
  # __git_ps1 "\A ${CHROOT}${USER_HOST}${DIR} " "${VENV}${SIGN} " '(%s)'
}
PROMPT_COMMAND='_set_bash_prompt'

unset -f is_in_path prepend_path try_source
