#!/bin/bash

# Simple monitoring script for the Russian VPN server

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Russian VPN Server Monitor${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if container is running
echo -e "${YELLOW}Checking container status...${NC}"
if docker ps | grep -q "russian-xray-server"; then
    echo -e "${GREEN}✓${NC} Container is running"
    
    # Get container stats
    echo ""
    echo -e "${YELLOW}Container statistics:${NC}"
    docker stats --no-stream russian-xray-server --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    
    # Show recent logs
    echo ""
    echo -e "${YELLOW}Recent logs (last 20 lines):${NC}"
    docker logs --tail 20 russian-xray-server 2>&1
    
    # Check EU server connectivity
    echo ""
    echo -e "${YELLOW}Checking EU server connectivity...${NC}"
    
    # Load .env to get EU server details
    if [ -f "$PROJECT_DIR/.env" ]; then
        source "$PROJECT_DIR/.env"
        
        if command -v nc &> /dev/null; then
            if nc -z -w5 "$EU_SERVER_ADDRESS" "$EU_SERVER_PORT" 2>/dev/null; then
                echo -e "${GREEN}✓${NC} EU server is reachable at $EU_SERVER_ADDRESS:$EU_SERVER_PORT"
            else
                echo -e "${RED}✗${NC} Cannot reach EU server at $EU_SERVER_ADDRESS:$EU_SERVER_PORT"
            fi
        else
            echo -e "${YELLOW}⚠${NC} netcat (nc) not installed, cannot test connectivity"
        fi
    else
        echo -e "${RED}✗${NC} .env file not found"
    fi
    
else
    echo -e "${RED}✗${NC} Container is not running!"
    echo ""
    echo "To start the container:"
    echo "  cd $PROJECT_DIR"
    echo "  docker-compose up -d"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
