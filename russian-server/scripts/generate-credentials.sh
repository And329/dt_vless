#!/bin/bash

# Script to generate random credentials for the VPN setup

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}VPN Credentials Generator${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Generate UUIDs
VLESS_UUID=$(cat /proc/sys/kernel/random/uuid)
VMESS_UUID=$(cat /proc/sys/kernel/random/uuid)

# Generate random passwords
SS_PASSWORD=$(openssl rand -base64 24)
TROJAN_PASSWORD=$(openssl rand -base64 32)

echo -e "${GREEN}Generated credentials for Russian Server:${NC}"
echo ""
echo -e "${YELLOW}VLESS Configuration:${NC}"
echo "VLESS_UUID=$VLESS_UUID"
echo ""
echo -e "${YELLOW}VMess Configuration:${NC}"
echo "VMESS_UUID=$VMESS_UUID"
echo ""
echo -e "${YELLOW}Shadowsocks Configuration:${NC}"
echo "SS_PASSWORD=$SS_PASSWORD"
echo "SS_METHOD=chacha20-ietf-poly1305"
echo ""
echo -e "${YELLOW}Trojan Configuration:${NC}"
echo "TROJAN_PASSWORD=$TROJAN_PASSWORD"
echo ""
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${GREEN}Copy these values to your .env file!${NC}"
echo ""
