#!/bin/bash

# Script to test connectivity between Russian and EU servers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}VPN Connection Tester${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if .env exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}✗${NC} .env file not found at $ENV_FILE"
    echo "Please create .env from .env.example"
    exit 1
fi

# Load environment variables
source "$ENV_FILE"

# Test 1: Check if required variables are set
echo -e "${YELLOW}Test 1: Configuration Check${NC}"
if [ -z "$EU_SERVER_ADDRESS" ] || [ -z "$EU_SERVER_PORT" ] || [ -z "$EU_SERVER_UUID" ]; then
    echo -e "${RED}✗${NC} EU server configuration incomplete"
    echo "  Required: EU_SERVER_ADDRESS, EU_SERVER_PORT, EU_SERVER_UUID"
    exit 1
else
    echo -e "${GREEN}✓${NC} Configuration is set"
    echo "  EU Server: $EU_SERVER_ADDRESS:$EU_SERVER_PORT"
fi
echo ""

# Test 2: DNS Resolution
echo -e "${YELLOW}Test 2: DNS Resolution${NC}"
if host "$EU_SERVER_ADDRESS" > /dev/null 2>&1 || [[ $EU_SERVER_ADDRESS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${GREEN}✓${NC} EU server address is valid"
else
    echo -e "${RED}✗${NC} Cannot resolve EU server address: $EU_SERVER_ADDRESS"
fi
echo ""

# Test 3: Port connectivity
echo -e "${YELLOW}Test 3: Port Connectivity${NC}"
if command -v nc &> /dev/null; then
    if timeout 5 nc -z "$EU_SERVER_ADDRESS" "$EU_SERVER_PORT" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Can connect to EU server on port $EU_SERVER_PORT"
    else
        echo -e "${RED}✗${NC} Cannot connect to EU server on port $EU_SERVER_PORT"
        echo "  Possible issues:"
        echo "    - EU server is not running"
        echo "    - Firewall blocking the port"
        echo "    - Incorrect port number"
    fi
else
    echo -e "${YELLOW}⚠${NC} netcat (nc) not installed, skipping connectivity test"
fi
echo ""

# Test 4: Docker container status
echo -e "${YELLOW}Test 4: Docker Container Status${NC}"
if docker ps | grep -q "russian-xray-server"; then
    echo -e "${GREEN}✓${NC} Russian server container is running"
    
    # Check logs for errors
    if docker logs --tail 50 russian-xray-server 2>&1 | grep -qi error; then
        echo -e "${YELLOW}⚠${NC} Found errors in container logs"
        echo "  Run 'docker-compose logs' to view details"
    else
        echo -e "${GREEN}✓${NC} No errors found in recent logs"
    fi
else
    echo -e "${RED}✗${NC} Russian server container is not running"
    echo "  Start it with: cd $PROJECT_DIR && docker-compose up -d"
fi
echo ""

# Test 5: Listening ports
echo -e "${YELLOW}Test 5: Listening Ports${NC}"
PORTS=($VLESS_PORT $VMESS_PORT $SS_PORT $TROJAN_PORT)
PORT_NAMES=("VLESS" "VMess" "Shadowsocks" "Trojan")

for i in "${!PORTS[@]}"; do
    PORT="${PORTS[$i]}"
    NAME="${PORT_NAMES[$i]}"
    
    if [ ! -z "$PORT" ] && ss -tuln | grep -q ":$PORT "; then
        echo -e "${GREEN}✓${NC} $NAME port $PORT is listening"
    else
        echo -e "${RED}✗${NC} $NAME port $PORT is not listening"
    fi
done
echo ""

# Test 6: UUID format validation
echo -e "${YELLOW}Test 6: UUID Format Validation${NC}"
UUID_REGEX='^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'

if [[ $EU_SERVER_UUID =~ $UUID_REGEX ]]; then
    echo -e "${GREEN}✓${NC} EU_SERVER_UUID format is valid"
else
    echo -e "${RED}✗${NC} EU_SERVER_UUID format is invalid"
fi

if [[ $VLESS_UUID =~ $UUID_REGEX ]]; then
    echo -e "${GREEN}✓${NC} VLESS_UUID format is valid"
else
    echo -e "${RED}✗${NC} VLESS_UUID format is invalid"
fi

if [[ $VMESS_UUID =~ $UUID_REGEX ]]; then
    echo -e "${GREEN}✓${NC} VMESS_UUID format is valid"
else
    echo -e "${RED}✗${NC} VMESS_UUID format is invalid"
fi
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "If all tests passed, your VPN should be operational."
echo "If some tests failed, review the output above for details."
echo ""
echo "Next steps:"
echo "  1. Configure a client with the credentials from .env"
echo "  2. Test connection from client"
echo "  3. Verify your IP shows the EU server location"
echo ""
