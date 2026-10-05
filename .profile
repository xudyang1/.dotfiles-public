# shellcheck shell=sh
# load bash interactive configuration for login shells
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
