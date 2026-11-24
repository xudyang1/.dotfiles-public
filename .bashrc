# shellcheck shell=bash
# if not running interactively, don't do anything
[[ $- != *i* ]] && return

HISTSIZE=20000
HISTFILESIZE=20000
# ignore duplicate lines or lines starting with space
HISTCONTROL='ignoreboth:erasedups'
HISTIGNORE='exit:pwd:ls:ll:la:l:fg:bg:cd:cd *:t:t *:n:v:vv:m *:man *:gs'
shopt -s histappend
# 'YYYY-MM-DD HH:MM:SS {CMD}'
HISTTIMEFORMAT='%F %T '
# '**': enable recursive glob instead of only current directory
#shopt -s globstar
# arguments ignore case at tab press
bind 'set completion-ignore-case on'
# display matches for ambiguous pattern at first tab press
bind 'set show-all-if-ambiguous on'
bind 'set bell-style none'
# ctrl+x,ctrl+y: copy command line to system clipboard
bind -x "\"\\C-x\\C-y\": ( \
if [[ -n \"\$READLINE_LINE\" ]]; then \
  if [[ -n \"\$TMUX\" ]]; then \
    printf '%s' \"\$READLINE_LINE\" | tmux load-buffer -w -; \
  else \
    b64=\$(printf '%s' \"\$READLINE_LINE\" | base64 | tr -d '\\n'); \
    printf '\\033]52;c;%s\\033\\\\' \"\$b64\"; \
  fi; \
  printf '%s\\n' '(Copied to clipboard.)' >&2; \
fi)"

prepend_path() {
  if [[ -d "$1" ]] && ! [[ ":$PATH:" == *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}
try_source() {
  if [[ -f "$1" ]]; then source "$1"; fi
}

# user's private bin
prepend_path "$HOME/.local/bin"

prepend_path '/usr/local/go/bin'

export CARGO_HOME="$HOME/.local/share/cargo"
export RUSTUP_HOME="$HOME/.local/share/rustup"
prepend_path "$CARGO_HOME/bin"

prepend_path "$HOME/.local/share/fzf/bin"
if command -v fzf >/dev/null; then
  eval "$(fzf --bash)"
  try_source "$HOME/.config/fzf/.fzfrc"
fi

if [[ -x /usr/bin/terraform ]]; then
  complete -C /usr/bin/terraform terraform
fi

command -v mise >/dev/null && eval "$(mise activate bash)"

# ctrl+x, ctrl+e
export EDITOR=nvim
# neovim gx, gh-cli
export BROWSER=/usr/bin/firefox
export MANPAGER='nvim +Man!'

# disable .lesshst
export LESSHISTFILE=-
# disable REPL history & logs
export NODE_REPL_HISTORY=''
export PYTHONSTARTUP="$HOME/.config/python/.pythonrc" # < 3.13
# export PYTHON_HISTORY=/dev/null # >= 3.13
export NPM_CONFIG_USERCONFIG="$HOME/.config/npm/.npmrc"

export _Z_DATA="$HOME/.config/utils/.z"
try_source "$HOME/.config/utils/z.sh"

export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/openssh_agent"
GPG_TTY="$(tty)"
export GPG_TTY
#gpg-connect-agent updatestartuptty /bye >/dev/null

try_source "$HOME/.bash_aliases"

# prompt
if ! declare -F '__git_ps1' >/dev/null; then
  try_source '/usr/lib/git-core/git-sh-prompt'
fi
export GIT_PS1_SHOW{DIRTYSTATE,STASHSTATE,UNTRACKEDFILES,COLORHINTS}=1
export GIT_PS1_SHOWUPSTREAM='auto git'
export GIT_PS1_DESCRIBE_STYLE='branch' # relative to newer tag/branch (main~4)
export GIT_PS1_SHOWCONFLICTSTATE='yes'
export PROMPT_DIRTRIM=4
user_host="${SSH_CONNECTION:+\[\033[0;32m\]\u@\H:\[\033[0m\]}" # green
# osc0: sets terminal tab title
# osc7: sets current directory for duplicate splits
# osc133A: sets start of each prompt
osc0='\[\033]0;\w\033\\\]'
# shellcheck disable=2016
osc7='\[\033]7;file://\H$PWD\033\\\]'
osc133A='\[\033]133;A\033\\\]'
time='\[\033[0;37m\]\A\[\033[0m\]' # white
dir='\[\033[1;32m\]\w\[\033[0m\]'  # bold green
# shellcheck disable=2016
git='$(__git_ps1 "(%s)")'
# shellcheck disable=2016
exit_code='$(s=$?;(( s )) && printf "\001\033[0;31m\002(%s)\001\033[0m\002" "$s")' # red
PS1="${osc0}${osc7}${osc133A}${time} ${user_host}${dir} ${git}"'\$'"${exit_code} "

unset user_host osc0 osc7 osc133A time dir git exit_code
unset -f prepend_path try_source
