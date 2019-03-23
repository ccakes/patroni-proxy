#!/bin/ash
set -euo pipefail
IFS='
'

target=$1
for res in $(dig -t srv $PATRONI_API +short); do
  name=$(echo $res | awk '{print $4}')
  api_host=$(dig -t a $name +short)

  if [ "$api_host" == "$target" ]; then
    api_port=$(echo $res | awk '{print $3}')

    curl "http://${api_host}:${api_port}" | jq -rj '.role'
  fi
done