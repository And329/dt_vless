# Deployment Checklist

Use this checklist to ensure your VPN infrastructure is properly deployed.

## Pre-Deployment

### Requirements
- [ ] Two servers available (one in EU, one in Russia)
- [ ] Docker installed on both servers (v20.10+)
- [ ] Docker Compose installed on both servers (v2.0+)
- [ ] SSH access configured for both servers
- [ ] Root or sudo access on both servers

### Verification Commands
```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Check Docker is running
docker ps
```

## EU Server Deployment

### 1. Upload Files
- [ ] Upload `eu-server/` directory to `/opt/dt_vpn/eu-server/`
- [ ] Verify all files are present:
  - `docker-compose.yml`
  - `config/config.json`
  - `.env.example`
  - `README.md`

### 2. Generate Credentials
```bash
# Generate UUID for EU server
cat /proc/sys/kernel/random/uuid
```
- [ ] UUID generated and saved: `_______________________`

### 3. Configure Environment
```bash
cd /opt/dt_vpn/eu-server
cp .env.example .env
nano .env
```
- [ ] `VLESS_UUID` set in `.env`
- [ ] `VLESS_PORT` configured (default: 443)

### 4. Configure Firewall
```bash
sudo ufw allow 443/tcp
sudo ufw status
```
- [ ] Port 443/tcp is open

### 5. Start Service
```bash
docker-compose up -d
```
- [ ] Container started successfully
- [ ] Check logs: `docker-compose logs`
- [ ] No errors in logs

### 6. Verify Service
```bash
# Check container is running
docker ps | grep eu-xray-server

# Check port is listening
ss -tuln | grep :443
```
- [ ] Container is running
- [ ] Port 443 is listening

### 7. Save Connection Details
```
EU_SERVER_ADDRESS: _______________________
EU_SERVER_PORT: 443
EU_SERVER_UUID: _______________________
```

## Russian Server Deployment

### 1. Upload Files
- [ ] Upload `russian-server/` directory to `/opt/dt_vpn/russian-server/`
- [ ] Verify all files are present
- [ ] Scripts are executable (`chmod +x scripts/*.sh`)

### 2. Generate User Credentials
```bash
cd /opt/dt_vpn/russian-server
./scripts/generate-credentials.sh
```
- [ ] Credentials generated and saved

### 3. Configure Environment
```bash
cp .env.example .env
nano .env
```
- [ ] `EU_SERVER_ADDRESS` set (from EU server)
- [ ] `EU_SERVER_PORT` set (443)
- [ ] `EU_SERVER_UUID` set (from EU server)
- [ ] `VLESS_UUID` set (for users)
- [ ] `VMESS_UUID` set (for users)
- [ ] `SS_PASSWORD` set (for users)
- [ ] `TROJAN_PASSWORD` set (for users)
- [ ] All port numbers configured

### 4. Configure Firewall
```bash
sudo ufw allow 443/tcp    # VLESS
sudo ufw allow 8443/tcp   # VMess
sudo ufw allow 9443/tcp   # Shadowsocks TCP
sudo ufw allow 9443/udp   # Shadowsocks UDP
sudo ufw allow 10443/tcp  # Trojan
sudo ufw status
```
- [ ] All required ports are open

### 5. Start Service
```bash
docker-compose up -d
```
- [ ] Container started successfully
- [ ] Check logs: `docker-compose logs`
- [ ] No errors in logs

### 6. Verify Service
```bash
# Check container is running
docker ps | grep russian-xray-server

# Check all ports are listening
ss -tuln | grep -E '(443|8443|9443|10443)'
```
- [ ] Container is running
- [ ] All ports are listening

### 7. Test Connection
```bash
./scripts/test-connection.sh
```
- [ ] All tests passed
- [ ] Can reach EU server
- [ ] No configuration errors

## Post-Deployment Testing

### 1. Server-to-Server Connection
From Russian server:
```bash
# Test connectivity to EU server
nc -zv <EU_SERVER_IP> 443
```
- [ ] Connection successful

### 2. Monitor Services
```bash
cd /opt/dt_vpn/russian-server
./scripts/monitor.sh
```
- [ ] Both containers running
- [ ] No errors in logs
- [ ] EU server reachable

### 3. Client Connection Test
- [ ] Configure one test client (recommended: Shadowsocks for simplicity)
- [ ] Client successfully connects
- [ ] Can browse internet through VPN
- [ ] IP check shows EU server location: `curl https://ifconfig.me`

## Security Hardening (Recommended)

- [ ] SSH password authentication disabled
- [ ] SSH key-only authentication enabled
- [ ] Fail2ban installed and configured
- [ ] System updates applied
- [ ] `.env` files have restricted permissions (600)
- [ ] Regular backup schedule established
- [ ] Monitoring/alerting configured

## Documentation

- [ ] Connection details documented for users
- [ ] Credentials stored securely
- [ ] Recovery procedures documented
- [ ] Backup location recorded
- [ ] Contact information for support established

## Client Distribution

Create client packages with:
- [ ] Server IP address
- [ ] Connection credentials (protocol-specific)
- [ ] Client software recommendations
- [ ] Setup instructions (from `client-configs/README.md`)
- [ ] Support contact information

## Maintenance Schedule

Set up regular maintenance:
- [ ] Weekly: Check logs for errors
- [ ] Weekly: Monitor resource usage
- [ ] Monthly: Update Docker images
- [ ] Monthly: Review firewall rules
- [ ] Quarterly: Rotate credentials
- [ ] Quarterly: Test backup restoration

## Rollback Plan

If issues occur:
1. [ ] Backup current configuration
2. [ ] Document the issue
3. [ ] Stop services: `docker-compose down`
4. [ ] Restore previous configuration
5. [ ] Restart services: `docker-compose up -d`
6. [ ] Verify functionality

## Final Verification

- [ ] EU server is running and accessible
- [ ] Russian server is running and accessible
- [ ] Russian → EU connection established via VLESS
- [ ] At least one client can connect successfully
- [ ] Traffic routes through EU server
- [ ] Logs show no errors
- [ ] All documentation is complete
- [ ] Users have been provided with credentials

## Support Resources

- Main README: `/home/zen/dev/dt_vpn/README.md`
- Quick Start: `/home/zen/dev/dt_vpn/QUICKSTART.md`
- Security Guide: `/home/zen/dev/dt_vpn/SECURITY.md`
- Client Setup: `/home/zen/dev/dt_vpn/client-configs/README.md`
- Russian Server: `/home/zen/dev/dt_vpn/russian-server/README.md`
- EU Server: `/home/zen/dev/dt_vpn/eu-server/README.md`

---

## Deployment Status

**Date Started:** _______________  
**Date Completed:** _______________  
**Deployed By:** _______________  
**Status:** ☐ In Progress  ☐ Completed  ☐ Issues Found

**Notes:**
