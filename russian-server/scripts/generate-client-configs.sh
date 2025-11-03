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

# SSH Tunnel (Maximum Stealth)
echo ""
echo -e "${GREEN}✓${NC} SSH Tunnel commands: $OUTPUT_DIR/ssh-tunnel.txt"

cat > "$OUTPUT_DIR/ssh-tunnel.txt" <<EOF
SSH Tunnel Connection (Maximum Stealth)
========================================

Server: $SERVER_IP
Port: 22 (SSH)

OPTION 1: SOCKS5 Proxy (Easiest - works with all apps)
-------------------------------------------------------
Linux/Mac:
  ssh -D 1080 -f -C -q -N vpnuser@$SERVER_IP

Windows (Command Prompt):
  plink.exe -D 1080 -C -N vpnuser@$SERVER_IP

Then configure your browser/apps to use SOCKS5 proxy:
  Address: 127.0.0.1
  Port: 1080


OPTION 2: Port Forward + VLESS Client
--------------------------------------
Forward VLESS port through SSH tunnel:

Linux/Mac:
  ssh -L 8443:localhost:443 -f -C -q -N vpnuser@$SERVER_IP

Windows (Command Prompt):
  plink.exe -L 8443:localhost:443 -C -N vpnuser@$SERVER_IP

Then configure your VLESS client to connect to:
  Address: localhost (or 127.0.0.1)
  Port: 8443
  UUID: $VLESS_UUID


OPTION 3: Port Forward + Shadowsocks Client
--------------------------------------------
Forward Shadowsocks port through SSH tunnel:

Linux/Mac:
  ssh -L 9943:localhost:9443 -f -C -q -N vpnuser@$SERVER_IP

Windows (Command Prompt):
  plink.exe -L 9943:localhost:9443 -C -N vpnuser@$SERVER_IP

Then configure your Shadowsocks client to connect to:
  Address: localhost
  Port: 9943
  Password: $SS_PASSWORD
  Method: ${SS_METHOD:-chacha20-ietf-poly1305}


What Your ISP Sees:
-------------------
✓ Normal SSH connection on port 22 (looks like server administration)
✓ Cannot see VPN usage
✓ Cannot see browsing activity


To Stop Tunnel:
---------------
Linux/Mac:
  pkill -f "ssh -D"
  # or
  pkill -f "ssh -L"

Windows:
  Close the PuTTY/plink window


Full Setup Guide:
-----------------
See: SSH-TUNNEL-SETUP.md in the documentation
EOF

# Generate QR codes if qrencode available
if command -v qrencode &> /dev/null; then
    echo "Generating QR codes..."
    [ -f "$OUTPUT_DIR/vless.txt" ] && qrencode -o "$OUTPUT_DIR/vless-qr.png" -r "$OUTPUT_DIR/vless.txt"
    [ -f "$OUTPUT_DIR/vmess.txt" ] && qrencode -o "$OUTPUT_DIR/vmess-qr.png" -r "$OUTPUT_DIR/vmess.txt"
    [ -f "$OUTPUT_DIR/shadowsocks.txt" ] && qrencode -o "$OUTPUT_DIR/shadowsocks-qr.png" -r "$OUTPUT_DIR/shadowsocks.txt"
    [ -f "$OUTPUT_DIR/trojan.txt" ] && qrencode -o "$OUTPUT_DIR/trojan-qr.png" -r "$OUTPUT_DIR/trojan.txt"
fi

echo ""
echo "=========================================="
echo "All configs generated in: $OUTPUT_DIR"
echo "=========================================="
echo ""
echo "Available connection methods:"
echo "  1. vless.txt - Direct VLESS (fast)"
echo "  2. vmess.txt - VMess over WebSocket"
echo "  3. shadowsocks.txt - Shadowsocks (simple)"
echo "  4. trojan.txt - Trojan (HTTPS-like)"
echo "  5. ssh-tunnel.txt - SSH Tunnel (maximum stealth)"
echo ""
echo "For maximum stealth, use SSH tunnel!"
echo "See ssh-tunnel.txt for commands"
