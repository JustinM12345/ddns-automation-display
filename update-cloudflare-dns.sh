#!/usr/bin/env bash
set -eo pipefail
# x is debugger

echo "=== [ $(date '+%Y-%m-%d %H:%M:%S') ] ==="

### Valid IPv4 Regex
REIP='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

### Get external ip from https://checkip.amazonaws.com
ip=$(curl -4 -s -X GET https://checkip.amazonaws.com --max-time 10)

# Check if output was empty
if [ -z "$ip" ]; then
    echo "Error! Can't get external ip from https://checkip.amazonaws.com"
    exit 0
fi

# Check that output matches IPv4 Format
if ! [[ "$ip" =~ $REIP ]]; then
    echo "Error! IP Address grabbed was NOT in IPv4 format!"
    exit 0
fi

# -n makes it single line no-new-line
echo -n "External IP is --> $ip"

INFILE=$(cat "saved-ip.txt")
echo " Currently in saved-ip.txt --> $INFILE"

if [[ "$ip" == "$INFILE" ]]; then
  echo "IP matches the one saved in saved-ip.txt"
  exit 0
else
  echo "IP does NOT match the one saved in saved-ip.txt"
fi

# Now that the IP is saved in saved-ip.txt we use cloudflare tokens to update cloudflare IP

recordsoutput=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" -H "Content-Type: application/json")

# As of right NOW since we only have one domain this DDNS script will only update the IP of that one domain
Record_Name=$(echo "$recordsoutput" | jq -r '.result[] | select(.name == "kobo-interns.xyz").name')
DNS_RECORD_ID=$(echo "$recordsoutput" | jq -r '.result[] | select(.name == "kobo-interns.xyz").id')
Record_IP=$(echo "$recordsoutput" | jq -r '.result[] | select(.name == "kobo-interns.xyz").content')

# This updates the DNS record
update_dns_record=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"kobo-interns.xyz\",\"content\":\"$ip\",\"ttl\":3600,\"proxied\":true}")

# Check if the update failed 
if [[ ${update_dns_record} == *"\"success\":false"* ]]; then
    echo ${update_dns_record}
    echo "Error! Update failed! (The curl failed somehow)"
    exit 0
fi

echo "$ip" > saved-ip.txt
echo "==> Success! CloudFlare IP has been successfully updated"