# DDNS Automation Display

A containerized DDNS (Dynamic DNS) automation solution for Cloudflare using Docker and cron jobs.

## Overview

This project automates the process of updating Cloudflare DNS records when your public IP address changes. It runs as a Docker container with a cron scheduler.

## Scripts

### `update-cloudflare-dns.sh`

This script checks if your external IP has changed and updates Cloudflare DNS records accordingly.

**What it does:**
1. Fetches your current external IP from `https://checkip.amazonaws.com`
2. Validates the IP is in proper IPv4 format
3. Compares it to the last known IP stored in `saved-ip.txt`
4. If the IP has changed, uses the Cloudflare API to update the DNS record for `kobo-interns.xyz`
5. Updates `saved-ip.txt` with the new IP

**Requirements:**
- `CLOUDFLARE_API_TOKEN` environment variable (Cloudflare API token)
- `ZONE_ID` environment variable (Cloudflare zone ID)

### `check-new-image.sh`

This script checks for updates to the Docker image and restarts the container if a new version is available.

**What it does:**
1. Pulls the latest Docker image: `juggin123/kobo-interns-ddns-automation:main`
2. Checks if a new version is available
3. If an update is found:
   - Stops the running container
   - Removes the old container
   - Starts a new container with the updated image
4. Verifies the new container is running

**Usage:**
Typically run via cron job to check for updates periodically.

## Setup

1. Set your Cloudflare credentials:
   ```bash
   export CLOUDFLARE_API_TOKEN=your_token_here
   export ZONE_ID=your_zone_id_here
   ```

2. Build the Docker image:
   ```bash
   docker build -t kobo-interns-ddns-automation .
   ```

3. Run the container with environment variables:
   ```bash
   docker run -d \
     --env-file .env.local \
     --mount type=bind,src="$(pwd)/saved-ip.txt",dst=/saved-ip.txt \
     --name autodns \
     kobo-interns-ddns-automation
   ```

## Configuration

- `crontab` - Defines the schedule for running the DDNS update script
- `saved-ip.txt` - Stores the last known public IP address
- `.env.local` - Contains your Cloudflare credentials (not committed to repo)

## Docker

The included `Dockerfile` creates a lightweight Alpine-based image that includes:
- Bash, curl, and jq for scripting
- Supercronic for cron job scheduling
- Your DDNS update script

## Related Projects

- [@JustinM12345/my-personal-webserver-sitepages](https://github.com/JustinM12345/my-personal-webserver-sitepages) - Site pages for the personal web server that this DDNS automation serves
