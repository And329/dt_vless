#!/bin/sh
set -e

# Substitute environment variables in config
sed -e "s/\${VLESS_UUID}/$VLESS_UUID/g" \
    -e "s/\${VLESS_PORT}/$VLESS_PORT/g" \
    -e "s/\${VMESS_UUID}/$VMESS_UUID/g" \
    -e "s/\${VMESS_PORT}/$VMESS_PORT/g" \
    -e "s/\${SS_PASSWORD}/$SS_PASSWORD/g" \
    -e "s/\${SS_PORT}/$SS_PORT/g" \
    -e "s/\${SS_METHOD}/$SS_METHOD/g" \
    -e "s/\${TROJAN_PASSWORD}/$TROJAN_PASSWORD/g" \
    -e "s/\${TROJAN_PORT}/$TROJAN_PORT/g" \
    -e "s/\${EU_SERVER_ADDRESS}/$EU_SERVER_ADDRESS/g" \
    -e "s/\${EU_SERVER_PORT}/$EU_SERVER_PORT/g" \
    -e "s/\${EU_SERVER_UUID}/$EU_SERVER_UUID/g" \
    /etc/xray/config.json > /tmp/config.json

# Start Xray
exec xray run -c /tmp/config.json
