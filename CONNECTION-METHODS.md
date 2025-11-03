# Connection Methods Comparison

This document compares all available methods for connecting to the Russian VPN server.

## Visual Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      CLIENT DEVICE                              │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │  Choose Connection:    │
        ├────────────────────────┤
        │ 1. Direct VLESS        │──────┐
        │ 2. Direct VMess        │──────┤
        │ 3. Direct Shadowsocks  │──────┤  Direct Connection
        │ 4. Direct Trojan       │──────┤
        │                        │      │
        │ 5. SSH Tunnel + Any    │──────┘  Tunneled (More Stealth)
        └────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   RUSSIAN ISP SEES:    │
        ├────────────────────────┤
        │ Direct: VPN Protocol   │
        │ SSH: Normal SSH (Port 22)│
        └────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   RUSSIAN SERVER       │
        │   (Control Server)     │
        └────────────────────────┘
                     │
                     ▼ VLESS
        ┌────────────────────────┐
        │     EU SERVER          │
        │   (Exit Server)        │
        └────────────────────────┘
                     │
                     ▼
                 INTERNET
```

## Connection Methods

### 1. VLESS (Direct)

**Best for:** Performance and simplicity

```
Client ──[VLESS/TCP]──> Russian Server ──[VLESS]──> EU Server ──> Internet
       Port 443
```

**Setup:**
- Import VLESS URI into client
- Connect directly to port 443

**Visibility:** ISP sees VLESS protocol on port 443

**Speed:** ⭐⭐⭐⭐⭐ (Fastest)  
**Stealth:** ⭐⭐⭐☆☆ (Medium)  
**Setup:** ⭐⭐⭐⭐⭐ (Easiest)

---

### 2. VMess over WebSocket (Direct)

**Best for:** Bypassing DPI (Deep Packet Inspection)

```
Client ──[VMess/WS]──> Russian Server ──[VLESS]──> EU Server ──> Internet
       Port 8443
```

**Setup:**
- Import VMess URI into client
- WebSocket path: `/vmess`

**Visibility:** ISP sees WebSocket traffic on port 8443

**Speed:** ⭐⭐⭐⭐☆ (Fast)  
**Stealth:** ⭐⭐⭐⭐☆ (Good)  
**Setup:** ⭐⭐⭐⭐⭐ (Easy)

---

### 3. Shadowsocks (Direct)

**Best for:** Simple setup, wide compatibility

```
Client ──[Shadowsocks]──> Russian Server ──[VLESS]──> EU Server ──> Internet
       Port 9443
```

**Setup:**
- Configure SS client with server IP and password
- Method: chacha20-ietf-poly1305

**Visibility:** ISP sees Shadowsocks protocol on port 9443

**Speed:** ⭐⭐⭐⭐⭐ (Very Fast)  
**Stealth:** ⭐⭐⭐☆☆ (Medium)  
**Setup:** ⭐⭐⭐⭐⭐ (Very Easy)

---

### 4. Trojan (Direct)

**Best for:** Mimicking HTTPS traffic

```
Client ──[Trojan]──> Russian Server ──[VLESS]──> EU Server ──> Internet
       Port 10443
```

**Setup:**
- Import Trojan URI into client
- Password-based authentication

**Visibility:** ISP sees HTTPS-like traffic on port 10443

**Speed:** ⭐⭐⭐⭐☆ (Fast)  
**Stealth:** ⭐⭐⭐⭐☆ (Good)  
**Setup:** ⭐⭐⭐⭐☆ (Easy)

---

### 5. SSH Tunnel + Any Protocol (Recommended for Maximum Stealth)

**Best for:** Maximum obfuscation and stealth

```
Client ──[SSH Tunnel]──> Russian Server ──[VLESS]──> EU Server ──> Internet
       Port 22              [VPN inside]
```

**Setup:**
- Create SSH tunnel: `ssh -D 1080 vpnuser@server`
- Configure apps to use SOCKS5 proxy at localhost:1080
- OR: Tunnel specific VPN port through SSH

**Visibility:** ISP sees **normal SSH traffic** (looks like server administration)

**Speed:** ⭐⭐⭐⭐☆ (Good, slight overhead)  
**Stealth:** ⭐⭐⭐⭐⭐ (Maximum - looks like normal SSH)  
**Setup:** ⭐⭐⭐☆☆ (Moderate)

**Two modes:**

#### Mode A: SSH SOCKS Proxy (Simplest)
```bash
ssh -D 1080 vpnuser@server
# Use SOCKS5 127.0.0.1:1080 in browser/apps
```

#### Mode B: SSH Port Forward + VPN Client
```bash
ssh -L 8443:localhost:443 vpnuser@server
# Configure VLESS to connect to localhost:8443
```

---

## Comparison Table

| Method | Port | Speed | Stealth | Setup | Use Case |
|--------|------|-------|---------|-------|----------|
| **VLESS** | 443 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐☆☆ | ⭐⭐⭐⭐⭐ | Daily use, best performance |
| **VMess** | 8443 | ⭐⭐⭐⭐☆ | ⭐⭐⭐⭐☆ | ⭐⭐⭐⭐⭐ | DPI bypass |
| **Shadowsocks** | 9443 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐☆☆ | ⭐⭐⭐⭐⭐ | Mobile, simple clients |
| **Trojan** | 10443 | ⭐⭐⭐⭐☆ | ⭐⭐⭐⭐☆ | ⭐⭐⭐⭐☆ | HTTPS mimicry |
| **SSH Tunnel** | 22 | ⭐⭐⭐⭐☆ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐☆☆ | **Maximum stealth** |

---

## What Russian ISP Sees

### Direct Connection (VLESS/VMess/SS/Trojan)
```
ISP Logs:
- User IP: 192.168.1.100
- Destination: 185.123.45.67:443 (or 8443/9443/10443)
- Protocol: Encrypted VPN traffic
- Duration: Active connection
- Can detect: VPN usage (but not content)
```

### SSH Tunnel Connection
```
ISP Logs:
- User IP: 192.168.1.100
- Destination: 185.123.45.67:22
- Protocol: SSH (Secure Shell)
- Duration: Active SSH session
- Appears as: Normal server administration
- Can detect: SSH connection (common, not suspicious)
```

**Key Difference:** SSH on port 22 looks like normal server management, while other ports may indicate VPN usage.

---

## Recommended Setups by Scenario

### 🏠 Home/Safe Network
**Use:** VLESS or Shadowsocks (direct)
- Fastest performance
- Simple setup
- No extra overhead

### 🏢 Work/Monitored Network
**Use:** VMess over WebSocket or Trojan
- Better DPI bypass
- Looks more like web traffic
- Good balance of speed and stealth

### 🔒 High-Scrutiny Environment
**Use:** SSH Tunnel
- Maximum stealth
- Looks like normal SSH usage
- Slightly more complex but worth it

### 📱 Mobile Device
**Use:** Shadowsocks or VLESS
- Simple apps available
- Good battery efficiency
- Easy to switch on/off

---

## Quick Start Commands

### Direct VLESS
```bash
# Import this in your client:
vless://UUID@SERVER_IP:443?encryption=none&type=tcp#RU-VPN
```

### SSH Tunnel + Browser
```bash
# Create tunnel
ssh -D 1080 vpnuser@SERVER_IP

# Configure browser SOCKS5: 127.0.0.1:1080
```

### SSH Tunnel + VLESS Client
```bash
# Tunnel VLESS port
ssh -L 8443:localhost:443 vpnuser@SERVER_IP

# Configure VLESS client to: localhost:8443
```

---

## Switching Methods

You can easily switch between methods:

1. **Try VLESS first** - If it works well, stick with it
2. **If blocked/throttled** - Try VMess or Trojan
3. **If VPN detected** - Switch to SSH tunnel
4. **For mobile** - Use Shadowsocks

All methods route through the same infrastructure:
```
Your Method → Russian Server → EU Server → Internet
```

---

## Documentation Links

- **VLESS/VMess/SS/Trojan**: See `client-configs/README.md`
- **SSH Tunnel Setup**: See `SSH-TUNNEL-SETUP.md`
- **Auto Config Generator**: Run `russian-server/scripts/generate-client-configs.sh`

---

## Testing Your Connection

After connecting, verify:

```bash
# Check your IP (should show EU server IP)
curl https://ifconfig.me

# Check DNS leak
curl https://api.ipify.org
```

Both should show your EU server's IP address, not your real IP.
