# Russian Server (Control Server)

This is the main control server that accepts connections from Russian users and routes all traffic through the EU server via VLESS protocol.

## Architecture

```
Users (VLESS/VMess/SS/Trojan) → Russian Server → EU Server (VLESS) → Internet
```

## Setup

### 1. Generate Credentials

```bash
chmod +x scripts/generate-credentials.sh
./scripts/generate-credentials.sh
```

### 2. Configure Environment

```bash
cp .env.example .env
nano .env
```

Fill in the following:
- **EU Server Details**: `EU_SERVER_ADDRESS`, `EU_SERVER_PORT`, `EU_SERVER_UUID` (get these from your EU server)
- **User Credentials**: Copy generated credentials from step 1

### 3. Start the Server

```bash
docker-compose up -d
```

### 4. Check Logs

```bash
docker-compose logs -f
```

## Switching EU Servers

To switch to a different EU server:

```bash
chmod +x scripts/switch-eu-server.sh
./scripts/switch-eu-server.sh <new_eu_ip> <new_eu_port> <new_uuid>
```

Example:
```bash
./scripts/switch-eu-server.sh 185.123.45.67 443 12345678-1234-1234-1234-123456789abc
```

The script will:
1. Backup your current configuration
2. Update the EU server settings
3. Restart the Xray service automatically

## Supported Protocols

### 1. VLESS (Port 443)
- Best performance
- Modern protocol
- Recommended for most users

### 2. VMess over WebSocket (Port 8443)
- Good for bypassing DPI
- Works well with CDN

### 3. Shadowsocks (Port 9443)
- Simple and fast
- Wide client support
- Method: chacha20-ietf-poly1305

### 4. Trojan (Port 10443)
- Mimics HTTPS traffic
- Good for strict firewalls

## Firewall Configuration

Open the required ports:

```bash
# Ubuntu/Debian with ufw
sudo ufw allow 443/tcp   # VLESS
sudo ufw allow 8443/tcp  # VMess
sudo ufw allow 9443/tcp  # Shadowsocks
sudo ufw allow 9443/udp  # Shadowsocks UDP
sudo ufw allow 10443/tcp # Trojan

# CentOS/RHEL with firewalld
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --permanent --add-port=9443/tcp
sudo firewall-cmd --permanent --add-port=9443/udp
sudo firewall-cmd --permanent --add-port=10443/tcp
sudo firewall-cmd --reload
```

## Providing Access to Users

Share the appropriate connection details based on the protocol:

### VLESS
- Server: `<your-server-ip>`
- Port: `443`
- UUID: `<VLESS_UUID from .env>`
- Encryption: `none`

### VMess
- Server: `<your-server-ip>`
- Port: `8443`
- UUID: `<VMESS_UUID from .env>`
- AlterID: `0`
- Path: `/vmess`

### Shadowsocks
- Server: `<your-server-ip>`
- Port: `9443`
- Password: `<SS_PASSWORD from .env>`
- Method: `chacha20-ietf-poly1305`

### Trojan
- Server: `<your-server-ip>`
- Port: `10443`
- Password: `<TROJAN_PASSWORD from .env>`

## Maintenance

### Update Xray
```bash
docker-compose pull
docker-compose up -d
```

### View Logs
```bash
docker-compose logs -f
```

### Restart Service
```bash
docker-compose restart
```

### Stop Service
```bash
docker-compose down
```

## Troubleshooting

1. **Container won't start**: Check logs with `docker-compose logs`
2. **Connection refused**: Verify firewall rules and port availability
3. **Can't reach EU server**: Check `EU_SERVER_ADDRESS` and network connectivity
4. **UUID mismatch**: Ensure EU server UUID matches `EU_SERVER_UUID` in .env
