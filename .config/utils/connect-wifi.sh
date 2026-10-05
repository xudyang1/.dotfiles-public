#!/usr/bin/env sh
# shellcheck shell=sh disable=SC1091,SC2015
set -eu

script_dir=$(dirname -- "$(realpath -- "$0")")
[ -f "$script_dir/msg.sh" ] && . "$script_dir/msg.sh" || msg() { echo "$@"; }

input_url="${1:-$(
  printf '%s\n' \
    'http://198.18.44.1' \
    'http://192.168.0.1' |
    fzf --prompt='Select captive portal URL: '
)}"
msg -b blue "Testing captive portal at: $input_url"

raw_url=$(curl --connect-timeout 5 --max-time 10 \
  -s "${input_url}" | sed -n "s/^redirURL = '\(.*\):80\(.*\)';/\1\2/p")
if [ -z "$raw_url" ]; then
  msg -b yellow "No redirect URL found. You might already be connected."
else
  origin=$(echo "${raw_url}" | sed 's/\(http:\/\/.*\)\/.*/\1/')
  url_hash=$(echo "${raw_url}" | sed 's/.*url=\(.*\)/\1/')

  msg blue "curl '${input_url}'"
  msg blue "RAW_URL:  '${raw_url}'"
  msg blue "ORIGIN:   '${origin}'"
  msg blue "URL_HASH: '${url_hash}'"
  msg -b "================================================="
  msg -b blue "Attempting NYPL WiFi registration..."

  curl -s "${origin}/reg.php" \
    -X POST \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:130.0) Gecko/20100101 Firefox/130.0' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8' \
    -H 'Accept-Language: en-US,en;q=0.5' \
    -H 'Accept-Encoding: gzip, deflate' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H "Origin: ${origin}" \
    -H 'Connection: keep-alive' \
    -H "Referer: ${raw_url}" \
    -H 'Upgrade-Insecure-Requests: 1' \
    -H 'Priority: u=0, i' \
    --data-raw "url=${url_hash}&auth_user=&auth_pass=&redir_url=https%3A%2F%2Fcaptiveportal.nypl.org&accept=Continue&checkbox=checkbox"
fi

if status_code=$(curl -sIL --connect-timeout 5 -o /dev/null -w '%{http_code}' example.com) && [ "$status_code" = "200" ]; then
  msg -b green "Success! Internet is connected."
  exit 0
else
  msg -b red "Error: Failed to access internet. Portal may still be active."
  exit 1
fi
