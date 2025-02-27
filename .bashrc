# shellcheck disable=SC2148
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=5000

# %F –> shows Date in the format ‘YYYY-M-D’ (Year-Month-Day)
# %T –> shows Time in the format ‘HH:MM:S’ (Hour:Minute:Seconds)
HISTTIMEFORMAT="%F %T "

# add current session command to $HISTFILE
# if enabled, multiple session command will intervene with each other
# PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob
# Autocorrect typos in path names when using `cd`
shopt -s cdspell
# arguments ignore case when typing tab (already enabled)
bind 'set completion-ignore-case on'

# ctrl+x,ctrl+y to copy command line input to system clipboard
bind '"\C-x\C-y":"\C-e\C-u /mnt/c/Windows/System32/clip.exe<<"EOF"\n\C-y\nEOF\n"'

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
if [[ -x /usr/bin/lesspipe ]]; then eval "$(SHELL=/bin/sh lesspipe)"; fi

# set variable identifying the chroot you work in (used in the prompt below)
if [[ -z "${debian_chroot:-}" && -r /etc/debian_chroot ]]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# enable color support of ls and also add handy aliases
if [[ -x /usr/bin/dircolors ]]; then
  if [[ -r ~/.dircolors ]]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='ls -F --color=auto --show-control-chars'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [[ -s ~/.bash_aliases ]]; then
  source ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [[ -s /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ -s /etc/bash_completion ]]; then
    source /etc/bash_completion
  fi
fi

# === STARSHIP ===
function set_win_title() {
  local win_title
  if [[ "${PWD}" == "${HOME}" ]]; then
    win_title="~"
  else
    win_title=$(basename "${PWD}")
  fi
  echo -ne "\033]0; ${win_title} \007"
  # enable windows terminal duplicate pane or tab
  # PROMPT_COMMAND=${PROMPT_COMMAND:+"$PROMPT_COMMAND "}'printf "\e]9;9;%s\e\\" "`wslpath -w "$PWD"`"'
}
# shellcheck disable=SC2034
starship_precmd_user_func="set_win_title"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init bash)"

# === FZF ===
# if [[ -s ~/.fzf.bash ]]; then source ~/.fzf.bash; fi
if [[ -s /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.bash
fi
if [[ -s /usr/share/bash-completion/completions/fzf ]]; then
  source /usr/share/bash-completion/completions/fzf
fi
if [[ -s ~/.config/fzf/.fzfrc ]]; then
  source ~/.config/fzf/.fzfrc
fi

# === LESS ===
# Have less display colours
# from: https://wiki.archlinux.org/index.php/Color_output_in_console#man
export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;33m'     # begin blink
export LESS_TERMCAP_so=$'\e[01;44;37m' # begin reverse video
export LESS_TERMCAP_us=$'\e[01;37m'    # begin underline
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline
export GROFF_NO_SGR=1                  # for konsole and gnome-terminal

# export LESSHISTFILE="$HOME/.config/less/history"
# disable .lesshst
export LESSHISTFILE=-

# === MAN ===
# export MANPAGER='less -s -M +Gg'
export MANPAGER='nvim -c "Man!" -'

# === INFO ===
# info: use vi-key bindings
alias info='info --vi-keys'

# === Z ===
# use z.sh for quick cd
if [[ -s ~/.config/z/z.sh ]]; then
  export _Z_CMD="j"
  export _Z_DATA="$HOME/.config/z/.z"
  source ~/.config/z/z.sh
fi

# === EDITOR ===
# ctrl+x ctrl+e opens a text editor in which you can edit the current command.
# Emacs by default, change the default to nvim
export EDITOR=nvim

# === REPL LOG ===
# disble node repl history log
export NODE_REPL_HISTORY=''
# suppress python repl history file write
export PYTHONSTARTUP="$HOME/.config/python/.pythonrc"

# === terraform ===
complete -C /usr/bin/terraform terraform

# === NVM ===
export NVM_DIR="$HOME/.local/share/nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh" # This loads nvm
fi
if [[ -s "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion" # This loads nvm bash_completion
fi

# === NPM ===
export npm_config_userconfig="$HOME/.config/npm/.npmrc"

# === GPG ===
# enable-ssh-support
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  export SSH_AUTH_SOCK
fi
GPG_TTY=$(tty)
export GPG_TTY
# gpg-connect-agent updatestartuptty /bye >/dev/null
