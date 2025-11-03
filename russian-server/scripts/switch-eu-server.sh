#!/bin/bash

# Script to switch EU server configuration
# Usage: ./switch-eu-server.sh <eu_ip> <eu_port> <eu_uuid>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -ne 3 ]; then
    echo -e "${RED}Error: Invalid number of arguments${NC}"
    echo "Usage: $0 <eu_server_ip> <eu_server_port> <eu_server_uuid>"
    echo ""
    echo "Example:"
    echo "  $0 185.123.45.67 443 12345678-1234-1234-1234-123456789abc"
    exit 1
fi

EU_IP=$1
EU_PORT=$2
EU_UUID=$3

# Validate UUID format (basic check)
if ! [[ $EU_UUID =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
    echo -e "${YELLOW}Warning: UUID format may be incorrect${NC}"
    echo "Expected format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}Error: .env file not found at $ENV_FILE${NC}"
    echo "Please copy .env.example to .env first"
    exit 1
fi

# Backup current .env
BACKUP_FILE="$PROJECT_DIR/.env.backup.$(date +%Y%m%d_%H%M%S)"
cp "$ENV_FILE" "$BACKUP_FILE"
echo -e "${GREEN}✓${NC} Backed up current configuration to $BACKUP_FILE"

# Update EU server settings in .env
sed -i "s/^EU_SERVER_ADDRESS=.*/EU_SERVER_ADDRESS=$EU_IP/" "$ENV_FILE"
sed -i "s/^EU_SERVER_PORT=.*/EU_SERVER_PORT=$EU_PORT/" "$ENV_FILE"
sed -i "s/^EU_SERVER_UUID=.*/EU_SERVER_UUID=$EU_UUID/" "$ENV_FILE"

echo -e "${GREEN}✓${NC} Updated .env file with new EU server configuration:"
echo "  - Address: $EU_IP"
echo "  - Port: $EU_PORT"
echo "  - UUID: $EU_UUID"

# Restart the service if it's running
if docker ps | grep -q "russian-xray-server"; then
    echo ""
    echo -e "${YELLOW}Restarting Xray service...${NC}"
    cd "$PROJECT_DIR"
    docker-compose down
    docker-compose up -d
    echo -e "${GREEN}✓${NC} Service restarted successfully"
    
    # Wait a bit and check if container is running
    sleep 3
    if docker ps | grep -q "russian-xray-server"; then
        echo -e "${GREEN}✓${NC} Container is running"
    else
        echo -e "${RED}✗${NC} Container failed to start. Check logs:"
        echo "  docker-compose logs"
        exit 1
    fi
else
    echo ""
    echo -e "${YELLOW}Note: Xray service is not running${NC}"
    echo "Start it with: cd $PROJECT_DIR && docker-compose up -d"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}EU server configuration updated successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
