# Quick Start Guide

This guide will help you set up your VPN infrastructure quickly.

## Overview

You'll be setting up two servers:
1. **EU Server** - Exit node for internet traffic
2. **Russian Server** - Control server that users connect to

## Prerequisites

- Two servers (one in EU, one in Russia)
- Docker and Docker Compose installed on both
- SSH access to both servers
- Basic command-line knowledge

## Step-by-Step Setup

### Part 1: Setup EU Server (Exit Node)

SSH into your EU server and run:

```bash
# Clone or upload this repository
cd /opt
git clone <your-repo> dt_vpn
cd dt_vpn/eu-server

# Generate UUID for the connection
cat /proc/sys/kernel/random/uuid
# Save this UUID! You'll need it for the Russian server

# Create configuration
cp .env.example .env
nano .env
# Set VLESS_UUID to the UUID you just generated

# Start the service
docker-compose up -d

# Check if it's running
docker-compose logs
```

**Open firewall port 443:**
```bash
sudo ufw allow 443/tcp
```

**Note down:**
- ✅ EU Server IP address
- ✅ EU Server Port (443)
- ✅ EU Server UUID

### Part 2: Setup Russian Server (Control Server)

SSH into your Russian server and run:

```bash
# Clone or upload this repository
cd /opt
git clone <your-repo> dt_vpn
cd dt_vpn/russian-server

# Generate credentials for users
chmod +x scripts/generate-credentials.sh
./scripts/generate-credentials.sh
# Save the output!

# Create configuration
cp .env.example .env
nano .env
```

**Fill in the .env file with:**

1. EU Server details (from Part 1):
```
EU_SERVER_ADDRESS=<EU_SERVER_IP>
EU_SERVER_PORT=443
EU_SERVER_UUID=<EU_SERVER_UUID>
```

2. User credentials (from generate-credentials.sh output):
```
VLESS_UUID=<generated_vless_uuid>
VMESS_UUID=<generated_vmess_uuid>
SS_PASSWORD=<generated_ss_password>
TROJAN_PASSWORD=<generated_trojan_password>
```

**Start the service:**
```bash
docker-compose up -d
docker-compose logs
```

**Open firewall ports:**
```bash
sudo ufw allow 443/tcp    # VLESS
sudo ufw allow 8443/tcp   # VMess
sudo ufw allow 9443/tcp   # Shadowsocks
sudo ufw allow 9443/udp   # Shadowsocks UDP
sudo ufw allow 10443/tcp  # Trojan
```

### Part 3: Test the Connection

From your Russian server, test connectivity to EU server:

```bash
# Check if EU server is reachable
nc -zv <EU_SERVER_IP> 443

# Check logs for any connection issues
docker-compose logs -f
```

### Part 4: Connect a Client

Choose one protocol and configure your client:

#### Option 1: VLESS (Recommended)
```
Server: <RUSSIAN_SERVER_IP>
Port: 443
UUID: <VLESS_UUID from russian-server/.env>
Encryption: none
```

#### Option 2: Shadowsocks (Simplest)
```
Server: <RUSSIAN_SERVER_IP>
Port: 9443
Password: <SS_PASSWORD from russian-server/.env>
Method: chacha20-ietf-poly1305
```

Download a client:
- Windows: V2rayN or Shadowsocks-Windows
- Android: V2rayNG or Shadowsocks-Android
- iOS: Shadowrocket
- Mac/Linux: Xray-core or Shadowsocks-libev

## Verification

After connecting through your client:

```bash
# Check your IP (should show EU server IP)
curl https://ifconfig.me
```

## Switching EU Servers

To switch to a different EU server:

```bash
cd /opt/dt_vpn/russian-server
./scripts/switch-eu-server.sh <NEW_EU_IP> 443 <NEW_EU_UUID>
```

## Common Issues

### EU Server Not Starting
```bash
cd /opt/dt_vpn/eu-server
docker-compose logs
# Check for port conflicts or UUID format errors
```

### Russian Server Not Starting
```bash
cd /opt/dt_vpn/russian-server
docker-compose logs
# Common issues: EU server not reachable, invalid UUID format
```

### Client Cannot Connect
1. Check firewall rules on Russian server
2. Verify UUID/password matches
3. Try a different protocol
4. Check Russian server logs: `docker-compose logs -f`

### No Internet Through VPN
1. Check EU server is running: `docker ps`
2. Check EU server logs: `cd /opt/dt_vpn/eu-server && docker-compose logs`
3. Verify Russian→EU connection in Russian server logs

## Security Recommendations

1. ✅ Use strong, unique UUIDs and passwords
2. ✅ Keep `.env` files secure (never commit to git)
3. ✅ Consider adding TLS for production use
4. ✅ Regularly update Xray: `docker-compose pull && docker-compose up -d`
5. ✅ Monitor logs for suspicious activity

## Next Steps

- Read `README.md` for detailed architecture information
- Check `client-configs/README.md` for more client setup options
- Review `russian-server/README.md` for advanced configuration
- Setup monitoring and alerting (optional)

## Support

For issues or questions:
1. Check the logs first: `docker-compose logs`
2. Review the detailed README files in each directory
3. Verify firewall and network connectivity
