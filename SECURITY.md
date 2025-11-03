# Security Guide

This document outlines security best practices for your VPN infrastructure.

## Credential Management

### 1. Generate Strong Credentials

Always use cryptographically secure random generation:

```bash
# UUIDs
cat /proc/sys/kernel/random/uuid
# or: uuidgen

# Passwords
openssl rand -base64 32
```

### 2. Protect Configuration Files

```bash
# Set appropriate permissions
chmod 600 .env
chmod 700 config/

# Never commit sensitive files to version control
# (already handled by .gitignore)
```

### 3. Rotate Credentials Regularly

- Change UUIDs and passwords every 3-6 months
- Update client configurations after rotation
- Keep a secure record of old credentials during transition

## Server Hardening

### 1. Firewall Configuration

Only open necessary ports:

```bash
# Russian Server
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 443/tcp
sudo ufw allow 8443/tcp
sudo ufw allow 9443/tcp
sudo ufw allow 9443/udp
sudo ufw allow 10443/tcp
sudo ufw enable

# EU Server
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 443/tcp
sudo ufw enable
```

### 2. SSH Security

```bash
# Disable password authentication
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
# Set: PubkeyAuthentication yes

# Restart SSH
sudo systemctl restart sshd
```

### 3. Fail2Ban

Install and configure fail2ban to prevent brute-force attacks:

```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 4. Regular Updates

```bash
# System updates
sudo apt update && sudo apt upgrade -y

# Docker image updates
cd /opt/dt_vpn/russian-server
docker-compose pull
docker-compose up -d

cd /opt/dt_vpn/eu-server
docker-compose pull
docker-compose up -d
```

## TLS/SSL Configuration (Optional but Recommended)

For production use, add TLS encryption:

### 1. Get SSL Certificates

Using Let's Encrypt (free):

```bash
sudo apt install certbot
sudo certbot certonly --standalone -d your-domain.com
```

### 2. Configure Xray with TLS

Update your configuration to use certificates. Example for VLESS:

```json
"streamSettings": {
  "network": "tcp",
  "security": "tls",
  "tlsSettings": {
    "certificates": [
      {
        "certificateFile": "/etc/letsencrypt/live/your-domain.com/fullchain.pem",
        "keyFile": "/etc/letsencrypt/live/your-domain.com/privkey.pem"
      }
    ]
  }
}
```

## Network Security

### 1. Rate Limiting

Consider implementing rate limiting to prevent abuse:

```bash
# Using iptables
sudo iptables -A INPUT -p tcp --dport 443 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j DROP
```

### 2. Monitor Traffic

```bash
# Install monitoring tools
sudo apt install iftop nethogs

# Monitor real-time traffic
sudo iftop -i eth0
```

### 3. Log Analysis

Regularly check logs for suspicious activity:

```bash
# Russian server logs
docker-compose -f /opt/dt_vpn/russian-server/docker-compose.yml logs --since 24h | grep -i error

# EU server logs
docker-compose -f /opt/dt_vpn/eu-server/docker-compose.yml logs --since 24h | grep -i error
```

## Access Control

### 1. Limit Client Access

- Only provide credentials to trusted users
- Keep a record of who has access
- Revoke credentials when no longer needed

### 2. Geographic Restrictions (Optional)

You can add geo-blocking rules in Xray configuration:

```json
"routing": {
  "rules": [
    {
      "type": "field",
      "ip": [
        "geoip:cn",
        "geoip:ru"
      ],
      "outboundTag": "block"
    }
  ]
}
```

## Backup and Recovery

### 1. Backup Configuration

```bash
# Create backup script
#!/bin/bash
DATE=$(date +%Y%m%d)
tar -czf vpn-backup-$DATE.tar.gz \
  /opt/dt_vpn/russian-server/.env \
  /opt/dt_vpn/eu-server/.env \
  /opt/dt_vpn/russian-server/config/ \
  /opt/dt_vpn/eu-server/config/

# Store backup securely (encrypted)
gpg -c vpn-backup-$DATE.tar.gz
rm vpn-backup-$DATE.tar.gz
```

### 2. Recovery Plan

Document your recovery procedure:
1. Server IP addresses
2. Credential location
3. Configuration backup location
4. Client notification procedure

## Monitoring and Alerting

### 1. Setup Monitoring

Use the provided monitor script:

```bash
# Run manually
cd /opt/dt_vpn/russian-server
./scripts/monitor.sh

# Or setup cron job for alerts
crontab -e
# Add: */15 * * * * /opt/dt_vpn/russian-server/scripts/monitor.sh | grep -i error && mail -s "VPN Alert" admin@example.com
```

### 2. Log Rotation

Prevent logs from filling disk:

```bash
# Docker logs are rotated automatically
# Check docker daemon.json for settings
cat /etc/docker/daemon.json
```

## Incident Response

### If Credentials are Compromised:

1. **Immediately** change all UUIDs and passwords
2. Update Russian server configuration
3. Restart services
4. Notify legitimate users with new credentials
5. Review logs for unauthorized access
6. Consider rotating the EU server

### If Server is Compromised:

1. Disconnect from network
2. Analyze logs and system state
3. Rebuild from clean backup
4. Change all credentials
5. Review security measures
6. Notify users of potential exposure

## Compliance and Legal

### Data Privacy

- Minimize logging of user data
- Comply with local data protection laws
- Have a clear privacy policy for users

### Usage Policy

Create clear terms of service:
- Prohibited activities
- Bandwidth limits
- Legal responsibilities
- Account termination conditions

## Security Checklist

- [ ] Strong UUIDs and passwords generated
- [ ] Firewall configured on both servers
- [ ] SSH hardened (key-only authentication)
- [ ] Regular update schedule established
- [ ] Monitoring script configured
- [ ] Backup strategy implemented
- [ ] Incident response plan documented
- [ ] TLS certificates configured (production)
- [ ] Fail2ban installed
- [ ] Log rotation configured
- [ ] Access control list maintained
- [ ] Terms of service created

## Additional Resources

- [Xray Documentation](https://xtls.github.io/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Linux Server Hardening](https://www.cisecurity.org/cis-benchmarks/)
- [OWASP Security Guidelines](https://owasp.org/)

## Reporting Security Issues

If you discover a security vulnerability:
1. Do not disclose publicly
2. Document the issue
3. Contact the administrator
4. Provide steps to reproduce
