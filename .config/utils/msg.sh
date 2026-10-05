#!/usr/bin/env sh

RESET='\033[0m'
BOLD='\033[1m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[36m'

_msg_usage() {
  cat <<EOF
Usage: msg [-nbiuh] [color] "text"

Options:
  -n    No newline at the end
  -b    Bold text
  -i    Italic text
  -u    Underline text
  -h    Display this help message

Colors:
  red, green, yellow, blue

Example:
  msg -bn red "Error: "
  msg -i "This is italicized"
EOF
}

msg() {
  # reset variables to ensure fresh state per call
  _opts=""
  _suffix="\n"
  OPTIND=1 # required for getopts to reset its internal counter

  # parse flags
  while getopts "nbiuh" _opt; do
    case "$_opt" in
    n) _suffix="" ;;
    b) _opts="${_opts}${BOLD}" ;;
    i) _opts="${_opts}${ITALIC}" ;;
    u) _opts="${_opts}${UNDERLINE}" ;;
    h)
      _msg_usage
      return 0
      ;;
    *)
      _msg_usage
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1)) # remove the flags from the argument list

  if [ "$#" -eq 0 ]; then
    return 0
  fi

  # remaining arguments are: color (optional) and text
  # if there are 2 arguments left, $1 is color, $2 is text.
  # if only 1 remains, $1 is the text.
  if [ "$#" -ge 2 ]; then
    case "$1" in
    red) _opts="${_opts}${RED}" ;;
    green) _opts="${_opts}${GREEN}" ;;
    yellow) _opts="${_opts}${YELLOW}" ;;
    blue) _opts="${_opts}${BLUE}" ;;
    esac
    _text="$2"
  else
    _text="$1"
  fi

  printf "%b%s%b%b" "$_opts" "$_text" "$RESET" "$_suffix"
}
