#!/bin/sh
set -e

# Substitute environment variables in config
sed -e "s/\${VLESS_UUID}/$VLESS_UUID/g" \
    /etc/xray/config.json > /tmp/config.json

# Start Xray
exec xray run -c /tmp/config.json
