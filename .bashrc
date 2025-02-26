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

# add current session command to $HISTFILE, if enabled, multiple session command will intervene with each other
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob
# Autocorrect typos in path names when using `cd`
shopt -s cdspell
# arguments ignore case when typing tab (already enabled)
bind 'set completion-ignore-case on'

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# enable color support of ls and also add handy aliases
if [[ -x /usr/bin/dircolors ]]; then
  if [[ -r ~/.dircolors ]]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='ls -F --color=auto --show-control-chars'
  #alias vdir='vdir --color=auto'
  #alias dir='dir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

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
# if ! shopt -oq posix; then
#   if [ -f /usr/share/bash-completion/bash_completion ]; then
#     . /usr/share/bash-completion/bash_completion
#   elif [ -f /etc/bash_completion ]; then
#     . /etc/bash_completion
#   fi
# fi
# export PATH=$PATH:$HOME/.local/bin

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
  PROMPT_COMMAND=${PROMPT_COMMAND:+"$PROMPT_COMMAND "}'printf "\e]9;9;%s\e\\" "`cygpath -w "$PWD"`"'
}
# shellcheck disable=SC2034
starship_precmd_user_func="set_win_title"
export STARSHIP_CONFIG="$HOME/.config/starship/gitbash_starship.toml"
eval "$(starship init bash)"

# git bash flikers in windows terminal:
# https://github.com/microsoft/terminal/issues/7200
bind 'set bell-style audible'

# === FZF ===
#[ -s ~/.fzf.bash ] && source ~/.fzf.bash
if [[ -s "$HOME/.config/fzf/key-bindings.bash" ]]; then
  source "$HOME/.config/fzf/key-bindings.bash"
fi
if [[ -s "$HOME/.config/fzf/completions.bash" ]]; then
  source "$HOME/.config/fzf/completions.bash"
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
# ctrl+x ctrl+e opens a text editor in which you can edit the current command. Emacs by default, change the default to nvim
export EDITOR=nvim

# === REPL LOG ===
# disble node repl history log
export NODE_REPL_HISTORY=''
# suppress python repl history file write
export PYTHONSTARTUP="$HOME/.config/python/.pythonrc"

# === NPM ===
export npm_config_userconfig="$HOME"/.config/npm/.npmrc

# === NVIM CONFIG ===
# set $XDG_CONFIG_HOME to $HOME/.config for portable neovim config (now, set system env globally in Windows)
# export XDG_CONFIG_HOME="$HOME/.config"

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

# === SSH ===
# do not use agent, manually enter passphrase instead
# https://docs.github.com/en/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases#auto-launching-ssh-agent-on-git-for-windows
# ssh_agent_env=~/.ssh/agent.env
#
# agent_load_env() { test -f "$ssh_agent_env" && . "$ssh_agent_env" >|/dev/null; }
#
# agent_start() {
#   (
#     umask 077
#     ssh-agent >|"$ssh_agent_env"
#   )
#   . "$ssh_agent_env" >|/dev/null
# }
#
# agent_load_env
#
# # agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
# agent_run_state=$(
#   ssh-add -l >|/dev/null 2>&1
#   echo $?
# )
#
# if [ ! "$SSH_AUTH_SOCK" ] || [ "$agent_run_state" = 2 ]; then
#   agent_start
#   ssh-add
# elif [ "$SSH_AUTH_SOCK" ] && [ "$agent_run_state" = 1 ]; then
#   ssh-add
# fi
#
# unset ssh_agent_env
