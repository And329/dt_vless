# Client Configuration Examples

These are example configurations for connecting to the Russian VPN server.

## Available Protocols

1. **VLESS** (Recommended) - `vless-example.json`
2. **VMess** - `vmess-example.json`
3. **Shadowsocks** - `shadowsocks-example.json`
4. **Trojan** - See connection details below

## Setup Instructions

### 1. Choose Your Client

#### Desktop/Mobile (All Protocols)
- **V2rayN** (Windows) - Supports VLESS, VMess, Shadowsocks, Trojan
- **V2rayNG** (Android) - Supports VLESS, VMess, Shadowsocks, Trojan
- **Shadowrocket** (iOS) - Supports all protocols
- **Clash** (Windows/Mac/Linux/Android) - Supports VMess, Shadowsocks, Trojan

#### Shadowsocks Only
- **Shadowsocks Client** (All platforms)
- Available at: https://shadowsocks.org/

#### Command Line (Linux/Mac)
- **Xray-core** - Supports all protocols
- Install: `bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install`

### 2. Configure Your Client

#### For VLESS:
1. Open your client
2. Add a new server
3. Fill in:
   - Protocol: `VLESS`
   - Address: `<Russian Server IP>`
   - Port: `443`
   - UUID: `<Your VLESS UUID>`
   - Encryption: `none`
   - Network: `tcp`

#### For VMess:
1. Open your client
2. Add a new server
3. Fill in:
   - Protocol: `VMess`
   - Address: `<Russian Server IP>`
   - Port: `8443`
   - UUID: `<Your VMess UUID>`
   - AlterID: `0`
   - Network: `ws` (WebSocket)
   - Path: `/vmess`

#### For Shadowsocks:
1. Open Shadowsocks client
2. Add a new server
3. Fill in:
   - Server: `<Russian Server IP>`
   - Port: `9443`
   - Password: `<Your SS Password>`
   - Method: `chacha20-ietf-poly1305`

#### For Trojan:
1. Open your client
2. Add a new server
3. Fill in:
   - Protocol: `Trojan`
   - Address: `<Russian Server IP>`
   - Port: `10443`
   - Password: `<Your Trojan Password>`

### 3. Using Configuration Files

For command-line clients:

```bash
# VLESS
xray run -c vless-example.json

# VMess
xray run -c vmess-example.json

# Shadowsocks
ss-local -c shadowsocks-example.json
```

## QR Code Generation

For mobile devices, you can generate QR codes:

### VLESS
```
vless://<UUID>@<SERVER_IP>:443?encryption=none&type=tcp#Russian-VPN-VLESS
```

### VMess
```
vmess://<base64_encoded_config>
```

VMess config to encode:
```json
{
  "v": "2",
  "ps": "Russian-VPN-VMess",
  "add": "<SERVER_IP>",
  "port": "8443",
  "id": "<UUID>",
  "aid": "0",
  "net": "ws",
  "type": "none",
  "host": "",
  "path": "/vmess",
  "tls": ""
}
```

### Shadowsocks
```
ss://<base64_method:password>@<SERVER_IP>:9443#Russian-VPN-SS
```

Example:
```
ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpZT1VSX1BBU1NXT1JE@1.2.3.4:9443#Russian-VPN-SS
```

### Trojan
```
trojan://<PASSWORD>@<SERVER_IP>:10443#Russian-VPN-Trojan
```

## Proxy Settings

After connecting, configure your applications to use the local proxy:

- **SOCKS5 Proxy**: `127.0.0.1:1080`
- **HTTP Proxy**: `127.0.0.1:1081`

## Testing Connection

Test your connection:

```bash
# Test with curl (through SOCKS5)
curl --socks5 127.0.0.1:1080 https://ifconfig.me

# Test with curl (through HTTP)
curl --proxy http://127.0.0.1:1081 https://ifconfig.me
```

You should see your EU server's IP address.

## Troubleshooting

1. **Cannot connect**: Check server IP and port
2. **UUID/Password incorrect**: Verify credentials with server admin
3. **Connection drops**: Try a different protocol
4. **Slow speed**: VLESS usually offers the best performance

## Security Notes

- Keep your credentials secure
- Do not share your UUID/password
- Use strong, unique passwords
- Enable encryption when available
