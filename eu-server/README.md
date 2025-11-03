# EU Server (Exit Server)

This server acts as the final exit point for the VPN traffic.

## Setup

1. **Generate UUID**:
```bash
cat /proc/sys/kernel/random/uuid
# Or use: uuidgen
```

2. **Configure environment**:
```bash
cp .env.example .env
nano .env  # Edit with your UUID
```

3. **Start the server**:
```bash
docker-compose up -d
```

4. **Check logs**:
```bash
docker-compose logs -f
```

## Firewall Configuration

Make sure to open the VLESS port (default 443):

```bash
# Ubuntu/Debian with ufw
sudo ufw allow 443/tcp

# CentOS/RHEL with firewalld
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

## Important Information

- **UUID**: Save this UUID - you'll need it for the Russian server configuration
- **IP Address**: Note your server's public IP address
- **Port**: Default is 443, but can be changed in .env

Share these details with the Russian server administrator:
- EU Server IP: `<your-ip>`
- EU Server Port: `443`
- VLESS UUID: `<your-uuid>`
