# SSH Tunnel Connection Method

SSH tunneling provides an additional layer of obfuscation by wrapping your VPN connection in SSH protocol, which looks like normal server administration traffic.

## Architecture

```
Client → SSH Tunnel → Russian Server → EU Server → Internet
         (Port 22)     (VPN services)
```

## Benefits

✅ **Looks like normal SSH traffic** - Hard to distinguish from server administration  
✅ **Additional encryption layer** - SSH + VPN encryption  
✅ **Port 22 rarely blocked** - Standard SSH port is usually allowed  
✅ **Easy to setup** - SSH client available on all platforms  

---

## Setup on Russian Server

### 1. Ensure SSH is Running

```bash
# Check SSH status
sudo systemctl status sshd

# If not running, start it
sudo systemctl enable sshd
sudo systemctl start sshd

# Allow SSH through firewall
sudo ufw allow 22/tcp
```

### 2. Create VPN User (Recommended)

Create a dedicated user for VPN tunneling:

```bash
# Create user
sudo useradd -m -s /bin/bash vpnuser

# Set password
sudo passwd vpnuser

# Or use SSH key (more secure)
sudo mkdir -p /home/vpnuser/.ssh
sudo nano /home/vpnuser/.ssh/authorized_keys
# Paste client's public key
sudo chown -R vpnuser:vpnuser /home/vpnuser/.ssh
sudo chmod 700 /home/vpnuser/.ssh
sudo chmod 600 /home/vpnuser/.ssh/authorized_keys
```

### 3. Configure SSH for Tunneling

Edit SSH config:

```bash
sudo nano /etc/ssh/sshd_config
```

Ensure these settings are enabled:

```
# Allow TCP forwarding
AllowTcpForwarding yes

# Allow tunneling
PermitTunnel yes

# Optional: Restrict vpnuser to tunneling only
Match User vpnuser
    AllowTcpForwarding yes
    X11Forwarding no
    PermitTunnel yes
    ForceCommand echo 'This account is for VPN tunneling only'
```

Restart SSH:

```bash
sudo systemctl restart sshd
```

---

## Client Setup

### Method 1: SSH Tunnel + SOCKS Proxy (Easiest)

This creates a SOCKS5 proxy through SSH tunnel.

#### **Windows (PuTTY)**

1. Download PuTTY from https://www.putty.org/

2. Configure PuTTY:
   - **Host Name**: Your Russian server IP
   - **Port**: 22
   - Go to **Connection → SSH → Tunnels**
   - **Source port**: 1080
   - **Destination**: localhost:1080
   - Select **Dynamic**
   - Click **Add**
   - Go back to **Session**, save the configuration

3. Connect (login with vpnuser credentials)

4. Configure your browser/apps to use SOCKS5 proxy:
   - **Proxy**: 127.0.0.1
   - **Port**: 1080

#### **Linux/Mac**

```bash
# Create SSH tunnel with SOCKS5 proxy
ssh -D 1080 -f -C -q -N vpnuser@YOUR_RUSSIAN_SERVER_IP

# Explanation:
# -D 1080    : Create SOCKS5 proxy on port 1080
# -f         : Run in background
# -C         : Compress data
# -q         : Quiet mode
# -N         : Don't execute remote command
```

Configure browser/apps to use SOCKS5 proxy at `127.0.0.1:1080`

### Method 2: SSH Tunnel to Specific VPN Port

This tunnels a specific VPN protocol through SSH.

#### **Tunnel VLESS through SSH**

```bash
# Linux/Mac
ssh -L 8443:localhost:443 -f -C -q -N vpnuser@YOUR_RUSSIAN_SERVER_IP

# Windows (PuTTY Tunnel settings):
# Source port: 8443
# Destination: localhost:443
# Select: Local
```

Then configure your VLESS client to connect to `localhost:8443` instead of the server directly.

#### **Tunnel Shadowsocks through SSH**

```bash
# Linux/Mac
ssh -L 9943:localhost:9443 -f -C -q -N vpnuser@YOUR_RUSSIAN_SERVER_IP
```

Configure Shadowsocks client to connect to `localhost:9943`

---

## Auto-Connect Scripts

### Linux/Mac Auto-Tunnel Script

Create `~/vpn-ssh-tunnel.sh`:

```bash
#!/bin/bash

SERVER="YOUR_RUSSIAN_SERVER_IP"
USER="vpnuser"
LOCAL_PORT=1080

# Check if tunnel is already running
if ps aux | grep "ssh -D $LOCAL_PORT" | grep -v grep > /dev/null; then
    echo "Tunnel already running"
    exit 0
fi

# Create SSH tunnel
echo "Creating SSH tunnel..."
ssh -D $LOCAL_PORT -f -C -q -N $USER@$SERVER

if [ $? -eq 0 ]; then
    echo "✓ SSH tunnel established"
    echo "Configure apps to use SOCKS5 proxy: 127.0.0.1:$LOCAL_PORT"
else
    echo "✗ Failed to create tunnel"
    exit 1
fi
```

Make executable and run:

```bash
chmod +x ~/vpn-ssh-tunnel.sh
~/vpn-ssh-tunnel.sh
```

### Windows Auto-Tunnel (PowerShell)

Create `vpn-tunnel.ps1`:

```powershell
$server = "YOUR_RUSSIAN_SERVER_IP"
$user = "vpnuser"
$puttyPath = "C:\Program Files\PuTTY\plink.exe"

& $puttyPath -D 1080 -C -N "$user@$server"
```

---

## Using with VPN Clients

### Configure VLESS through SSH Tunnel

1. **Start SSH tunnel** to forward port 8443 → 443
2. **Edit VLESS config** to connect to `localhost:8443`

Example VLESS config:
```json
{
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "localhost",
            "port": 8443,
            "users": [{"id": "YOUR_UUID", "encryption": "none"}]
          }
        ]
      }
    }
  ]
}
```

---

## Browser Configuration

### Firefox

1. Settings → Network Settings → Manual proxy configuration
2. **SOCKS Host**: 127.0.0.1
3. **Port**: 1080
4. Select: **SOCKS v5**
5. Check: **Proxy DNS when using SOCKS v5**

### Chrome/Edge (with extension)

Install **Proxy SwitchyOmega** extension:
1. Create new profile → SOCKS5
2. Server: 127.0.0.1
3. Port: 1080

---

## Management Scripts

### Check Tunnel Status

```bash
#!/bin/bash
# Save as: check-ssh-tunnel.sh

if ps aux | grep "ssh -D" | grep -v grep > /dev/null; then
    echo "✓ SSH tunnel is running"
    ps aux | grep "ssh -D" | grep -v grep
else
    echo "✗ SSH tunnel is not running"
fi
```

### Kill Tunnel

```bash
#!/bin/bash
# Save as: kill-ssh-tunnel.sh

pkill -f "ssh -D"
echo "SSH tunnels killed"
```

---

## Troubleshooting

### Tunnel Won't Start

```bash
# Check if port is already in use
netstat -tulpn | grep 1080

# Check SSH connection manually
ssh vpnuser@YOUR_SERVER_IP

# Check SSH logs on server
sudo tail -f /var/log/auth.log
```

### Connection Drops

Add to `~/.ssh/config`:

```
Host vpn-server
    HostName YOUR_RUSSIAN_SERVER_IP
    User vpnuser
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
```

Then connect with: `ssh -D 1080 -f -C -q -N vpn-server`

### Authentication Issues

```bash
# Use SSH key instead of password
ssh-keygen -t ed25519 -C "vpn-tunnel"
ssh-copy-id vpnuser@YOUR_RUSSIAN_SERVER_IP
```

---

## Security Notes

🔒 **Use SSH keys** instead of passwords  
🔒 **Restrict vpnuser** to tunneling only  
🔒 **Monitor SSH logs** for suspicious activity  
🔒 **Change default SSH port** (optional): Edit `/etc/ssh/sshd_config` → `Port 2222`  

---

## Comparison with Direct Connection

| Feature | Direct VPN | SSH Tunnel + VPN |
|---------|-----------|------------------|
| **Stealth** | Medium | High (looks like SSH) |
| **Complexity** | Simple | Moderate |
| **Speed** | Faster | Slightly slower |
| **Compatibility** | VPN client only | SSH + VPN client |
| **Port** | 443, 8443, etc. | 22 (SSH) |

---

## Quick Reference

### Start SSH SOCKS Tunnel
```bash
ssh -D 1080 -f -C -q -N vpnuser@SERVER_IP
```

### Start SSH Port Forward (VLESS)
```bash
ssh -L 8443:localhost:443 -f -C -q -N vpnuser@SERVER_IP
```

### Configure Browser
- SOCKS5: 127.0.0.1:1080

### Stop All Tunnels
```bash
pkill -f "ssh -D"
pkill -f "ssh -L"
```
