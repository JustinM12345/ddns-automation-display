#!/usr/bin/env bash

set -exo pipefail

echo "=== [ $(date '+%Y-%m-%d %H:%M:%S') ] ==="

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.docker/bin"

image_pull=$(docker image pull juggin123/kobo-interns-ddns-automation:main)

if [[ ${image_pull} == *"Status: Image is up to date for juggin123/kobo-interns-ddns-automation:main"* ]]; then
    echo "Image is up to date"
    exit 0
fi

docker stop autodns

docker rm autodns

docker_run=$(docker run -d --mount type=bind,src="/Users/justinmui/DDNS/saved-ip.txt",dst=/saved-ip.txt --env-file /Users/justinmui/DDNS/.env.local --name autodns juggin123/kobo-interns-ddns-automation:main)

echo "$docker_run";

docker_inspect=$(docker inspect autodns)

if [[ ${docker_inspect} == *"\"Status\": \"running\""* ]]; then
    echo "New container is up and running"
else
    echo "Container is NOT running"
    exit 0
fi

# /Users/justinmui/DDNS/check-new-image.sh
# log show --process cron