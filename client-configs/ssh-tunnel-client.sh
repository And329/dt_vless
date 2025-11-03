#!/bin/bash
# SSH Tunnel Manager for VPN Connection

SERVER_IP="${1:-YOUR_SERVER_IP}"
SSH_USER="${2:-vpnuser}"
TUNNEL_TYPE="${3:-socks}"  # socks or forward
LOCAL_PORT="${4:-1080}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_usage() {
    echo "Usage: $0 <server_ip> [ssh_user] [tunnel_type] [local_port]"
    echo ""
    echo "Examples:"
    echo "  $0 185.123.45.67                          # SOCKS5 on port 1080"
    echo "  $0 185.123.45.67 vpnuser socks 1080       # SOCKS5 proxy"
    echo "  $0 185.123.45.67 vpnuser forward 8443     # Port forward VLESS"
    echo ""
    echo "Tunnel types:"
    echo "  socks   - SOCKS5 proxy (general purpose)"
    echo "  forward - Port forwarding (for specific VPN protocol)"
}

check_running() {
    if ps aux | grep "ssh.*$SERVER_IP" | grep -v grep > /dev/null; then
        return 0
    else
        return 1
    fi
}

start_socks_tunnel() {
    echo -e "${YELLOW}Starting SOCKS5 tunnel...${NC}"
    ssh -D $LOCAL_PORT -f -C -q -N $SSH_USER@$SERVER_IP
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} SSH SOCKS5 tunnel established"
        echo ""
        echo "Configure your applications to use:"
        echo "  Proxy Type: SOCKS5"
        echo "  Address: 127.0.0.1"
        echo "  Port: $LOCAL_PORT"
    else
        echo -e "${RED}✗${NC} Failed to create tunnel"
        exit 1
    fi
}

start_forward_tunnel() {
    REMOTE_PORT=443  # VLESS port on server
    echo -e "${YELLOW}Starting port forward tunnel...${NC}"
    ssh -L ${LOCAL_PORT}:localhost:${REMOTE_PORT} -f -C -q -N $SSH_USER@$SERVER_IP
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} SSH port forward established"
        echo ""
        echo "Configure your VPN client to connect to:"
        echo "  Address: localhost (or 127.0.0.1)"
        echo "  Port: $LOCAL_PORT"
    else
        echo -e "${RED}✗${NC} Failed to create tunnel"
        exit 1
    fi
}

# Main
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_usage
    exit 0
fi

if [ "$SERVER_IP" = "YOUR_SERVER_IP" ]; then
    echo -e "${RED}Error: Please specify server IP${NC}"
    echo ""
    show_usage
    exit 1
fi

echo "==================================="
echo "SSH Tunnel Manager"
echo "==================================="
echo ""

if check_running; then
    echo -e "${YELLOW}⚠${NC} Tunnel already running to $SERVER_IP"
    echo ""
    echo "To kill existing tunnel:"
    echo "  pkill -f 'ssh.*$SERVER_IP'"
    exit 0
fi

if [ "$TUNNEL_TYPE" = "socks" ]; then
    start_socks_tunnel
elif [ "$TUNNEL_TYPE" = "forward" ]; then
    start_forward_tunnel
else
    echo -e "${RED}Invalid tunnel type: $TUNNEL_TYPE${NC}"
    show_usage
    exit 1
fi

echo ""
echo "To stop tunnel:"
echo "  pkill -f 'ssh.*$SERVER_IP'"
