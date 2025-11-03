#!/bin/bash
# Generate client configurations from .env

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"
OUTPUT_DIR="$PROJECT_DIR/client-configs-generated"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}Client Configuration Generator${NC}"

[ ! -f "$ENV_FILE" ] && echo "Error: .env not found" && exit 1
source "$ENV_FILE"

# Get server IP
SERVER_IP=${SERVER_IP:-$(curl -s https://ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")}
echo "Server IP: $SERVER_IP"

mkdir -p "$OUTPUT_DIR"

# VLESS
if [ ! -z "$VLESS_UUID" ]; then
    echo "vless://${VLESS_UUID}@${SERVER_IP}:${VLESS_PORT:-443}?encryption=none&type=tcp#RU-VPN-VLESS" > "$OUTPUT_DIR/vless.txt"
    echo -e "${GREEN}✓${NC} VLESS: $OUTPUT_DIR/vless.txt"
fi

# VMess
if [ ! -z "$VMESS_UUID" ]; then
    VMESS_JSON='{"v":"2","ps":"RU-VPN-VMess","add":"'$SERVER_IP'","port":"'${VMESS_PORT:-8443}'","id":"'$VMESS_UUID'","aid":"0","net":"ws","path":"/vmess","tls":""}'
    echo "vmess://$(echo -n "$VMESS_JSON" | base64 -w 0)" > "$OUTPUT_DIR/vmess.txt"
    echo -e "${GREEN}✓${NC} VMess: $OUTPUT_DIR/vmess.txt"
fi

# Shadowsocks
if [ ! -z "$SS_PASSWORD" ]; then
    SS_METHOD="${SS_METHOD:-chacha20-ietf-poly1305}"
    SS_USER=$(echo -n "${SS_METHOD}:${SS_PASSWORD}" | base64 -w 0)
    echo "ss://${SS_USER}@${SERVER_IP}:${SS_PORT:-9443}#RU-VPN-SS" > "$OUTPUT_DIR/shadowsocks.txt"
    echo -e "${GREEN}✓${NC} Shadowsocks: $OUTPUT_DIR/shadowsocks.txt"
fi

# Trojan
if [ ! -z "$TROJAN_PASSWORD" ]; then
    echo "trojan://${TROJAN_PASSWORD}@${SERVER_IP}:${TROJAN_PORT:-10443}#RU-VPN-Trojan" > "$OUTPUT_DIR/trojan.txt"
    echo -e "${GREEN}✓${NC} Trojan: $OUTPUT_DIR/trojan.txt"
fi

# Generate QR codes if qrencode available
if command -v qrencode &> /dev/null; then
    echo "Generating QR codes..."
    [ -f "$OUTPUT_DIR/vless.txt" ] && qrencode -o "$OUTPUT_DIR/vless-qr.png" -r "$OUTPUT_DIR/vless.txt"
    [ -f "$OUTPUT_DIR/vmess.txt" ] && qrencode -o "$OUTPUT_DIR/vmess-qr.png" -r "$OUTPUT_DIR/vmess.txt"
    [ -f "$OUTPUT_DIR/shadowsocks.txt" ] && qrencode -o "$OUTPUT_DIR/shadowsocks-qr.png" -r "$OUTPUT_DIR/shadowsocks.txt"
    [ -f "$OUTPUT_DIR/trojan.txt" ] && qrencode -o "$OUTPUT_DIR/trojan-qr.png" -r "$OUTPUT_DIR/trojan.txt"
fi

echo ""
echo "All configs generated in: $OUTPUT_DIR"
echo "Share the .txt files or QR codes with clients"
