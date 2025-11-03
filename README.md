# VPN Architecture: Russian Control Server → EU Server

## Architecture Overview

```
Russian Users → Russian Server (Control/Main) → EU Server → Internet
                   (Xray-core)                   (Xray-core)
                                  VLESS Protocol
```

### Components

1. **Russian Server (Control Server)**
   - Acts as the main entry point for Russian users
   - Accepts connections via multiple protocols (VLESS, VMess, Shadowsocks, Trojan)
   - Optional SSH tunneling for additional obfuscation
   - Routes all traffic through EU server via VLESS outbound
   - Easily configurable to switch EU servers

2. **EU Server (Exit Server)**
   - Receives traffic from Russian server via VLESS
   - Acts as the final exit point to the internet
   - Can be easily replaced/changed

## Features

- **Easy EU Server Switching**: Change EU server configuration without rebuilding
- **Multiple Inbound Protocols**: Support for VLESS, VMess, Shadowsocks, Trojan
- **SSH Tunneling Support**: Optional SSH tunnel wrapping for maximum stealth
- **Docker-based Deployment**: Easy setup and management
- **Automatic Certificate Management**: TLS support for secure connections
- **Configuration Management**: Environment-based configuration for easy updates

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Domain names (optional but recommended for TLS)
- Open ports on both servers

### 1. Setup EU Server

```bash
cd eu-server
cp .env.example .env
# Edit .env with your configuration
docker-compose up -d
```

### 2. Setup Russian Server

```bash
cd russian-server
cp .env.example .env
# Edit .env with your EU server details
docker-compose up -d
```

### 3. Switch EU Server

To change to a different EU server:

```bash
cd russian-server
./scripts/switch-eu-server.sh <new_eu_ip> <new_eu_port> <new_uuid>
```

## Directory Structure

```
.
├── README.md
├── russian-server/          # Main control server configuration
│   ├── docker-compose.yml
│   ├── config/
│   │   └── config.json     # Xray configuration
│   ├── .env.example
│   └── scripts/
│       └── switch-eu-server.sh
├── eu-server/              # Exit server configuration
│   ├── docker-compose.yml
│   ├── config/
│   │   └── config.json     # Xray configuration
│   └── .env.example
└── client-configs/         # Client configuration examples
    ├── vless-example.json
    ├── vmess-example.json
    └── shadowsocks-example.json
```

## Configuration Details

### Russian Server Ports

- **443**: VLESS over TLS
- **8443**: VMess over WebSocket
- **9443**: Shadowsocks
- **10443**: Trojan

### Security Notes

- Always use strong UUIDs (generate with `uuidgen` or similar)
- Keep your configuration files secure
- Use TLS certificates for production
- Change default passwords and UUIDs

## Monitoring

Check logs:
```bash
# Russian server
docker-compose -f russian-server/docker-compose.yml logs -f

# EU server
docker-compose -f eu-server/docker-compose.yml logs -f
```

## Troubleshooting

1. **Connection refused**: Check firewall rules and port availability
2. **UUID mismatch**: Ensure client and server UUIDs match
3. **TLS errors**: Verify domain names and certificates

## License

MIT
