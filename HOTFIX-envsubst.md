# HOTFIX: envsubst not found

## Problem
The Docker image doesn't include `envsubst` command, causing containers to fail to start.

## Solution
Updated docker-compose files to use `sed` instead via entrypoint scripts.

## Apply the Fix

### On EU Server:

```bash
cd ~/dt_vless/eu-server  # or wherever your eu-server folder is

# Stop the container
docker-compose down

# Upload/copy the new files:
# - entrypoint.sh (new file)
# - docker-compose.yml (updated)

# Make entrypoint executable
chmod +x entrypoint.sh

# Start the container
docker-compose up -d

# Check logs
docker-compose logs
```

### On Russian Server:

```bash
cd ~/dt_vless/russian-server  # or wherever your russian-server folder is

# Stop the container
docker-compose down

# Upload/copy the new files:
# - entrypoint.sh (new file)
# - docker-compose.yml (updated)

# Make entrypoint executable
chmod +x entrypoint.sh

# Start the container
docker-compose up -d

# Check logs
docker-compose logs
```

## Files to Upload

From `/home/zen/dev/dt_vpn/`:

**EU Server:**
- `eu-server/entrypoint.sh` (NEW)
- `eu-server/docker-compose.yml` (UPDATED)

**Russian Server:**
- `russian-server/entrypoint.sh` (NEW)
- `russian-server/docker-compose.yml` (UPDATED)

## Verify Fix

After restarting, you should see Xray starting successfully:

```bash
docker-compose logs
```

Look for messages like:
- `Xray started`
- No more "envsubst: not found" errors

## Quick Upload Command

If you have the updated files locally:

```bash
# EU Server
scp eu-server/entrypoint.sh root@<EU_IP>:~/dt_vless/eu-server/
scp eu-server/docker-compose.yml root@<EU_IP>:~/dt_vless/eu-server/

# Russian Server  
scp russian-server/entrypoint.sh root@<RUSSIAN_IP>:~/dt_vless/russian-server/
scp russian-server/docker-compose.yml root@<RUSSIAN_IP>:~/dt_vless/russian-server/
```

Then SSH in and run the commands above to restart.
