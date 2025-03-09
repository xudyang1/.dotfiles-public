#!/usr/bin/sh -e

# or http://198.18.44.1
INPUT_URL=${1-'http://192.168.0.1'}
RAW_URL=$(curl "${INPUT_URL}" | sed -n "s/^redirURL = '\(.*\):80\(.*\)';/\1\2/p")
ORIGIN=$(echo "${RAW_URL}" | sed 's/\(http:\/\/.*\)\/.*/\1/')
URL_HASH=$(echo "${RAW_URL}" | sed 's/.*url=\(.*\)/\1/')

echo "curl '${INPUT_URL}'"
echo "RAW_URL='${RAW_URL}'"
echo "ORIGIN='${ORIGIN}'"
echo "URL_HASH='${URL_HASH}'"
echo "================================================="

if [ -n "$RAW_URL" ]; then
  echo "Trying to connect to nypl wifi ..."
  cat <<-EOF
curl "${ORIGIN}/reg.php" \\
  -X POST \\
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:130.0) Gecko/20100101 Firefox/130.0' \\
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8' \\
  -H 'Accept-Language: en-US,en;q=0.5' \\
  -H 'Accept-Encoding: gzip, deflate' \\
  -H 'Content-Type: application/x-www-form-urlencoded' \\
  -H "Origin: ${ORIGIN}" \\
  -H 'Connection: keep-alive' \\
  -H "Referer: ${RAW_URL}" \\
  -H 'Upgrade-Insecure-Requests: 1' \\
  -H 'Priority: u=0, i' \\
  --data-raw "url=${URL_HASH}&auth_user=&auth_pass=&redir_url=https%3A%2F%2Fcaptiveportal.nypl.org&accept=Continue&checkbox=checkbox"
EOF

  curl "${ORIGIN}/reg.php" \
    -X POST \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:130.0) Gecko/20100101 Firefox/130.0' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8' \
    -H 'Accept-Language: en-US,en;q=0.5' \
    -H 'Accept-Encoding: gzip, deflate' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H "Origin: ${ORIGIN}" \
    -H 'Connection: keep-alive' \
    -H "Referer: ${RAW_URL}" \
    -H 'Upgrade-Insecure-Requests: 1' \
    -H 'Priority: u=0, i' \
    --data-raw "url=${URL_HASH}&auth_user=&auth_pass=&redir_url=https%3A%2F%2Fcaptiveportal.nypl.org&accept=Continue&checkbox=checkbox"
fi

BOLD='\033[1m'
RED='\033[31m'
GREEN='\033[32m'
NC='\033[0m' # No Color

if curl -s -X GET --head www.example.com | grep "200 OK" >/dev/null; then
  printf "\n${BOLD}${GREEN}%s${NC}\n" "Ok. Internet is connected."
  exit 0
else
  printf "\n${BOLD}${RED}%s${NC}\n" "Error. Failed to access internet."
  exit 1
fi
