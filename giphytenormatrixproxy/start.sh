#!/bin/sh
set -eu

mkdir -p /data /storage
printf '%s\n' "$CONFIG_TEMPLATE" > /data/config.yaml

exec /usr/bin/giphyproxy
