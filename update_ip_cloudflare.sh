#!/usr/bin/bash

exec > /home/maduma/dynamic-dns/update_ip_cloudflare.log 2>&1

date
set -x

source  /home/maduma/dynamic-dns/credential

curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
     -H "Authorization: Bearer $AUTH" \
     -H "Content-Type: application/json" \
     > /tmp/dns_records.json

OLD_IP=$( cat /tmp/dns_records.json | jq -r '.result[] | select(.name == "zotac.maduma.org") | .content' )
echo $OLD_IP

NEW_IP=$( curl -s http://api.ipify.org )
if [ "$OLD_IP" == "$NEW_IP" ]; then
    exit
fi

RECORD_ID=$( cat /tmp/dns_records.json | jq -r '.result[] | select(.name == "zotac.maduma.org") | .id' )
echo $RECORD_ID

curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "Authorization: Bearer $AUTH" \
     -H "Content-Type: application/json" \
     --data "{\"type\":\"A\",\"name\":\"zotac.maduma.org\",\"content\":\"$NEW_IP\",\"ttl\":1,\"proxied\":false}" \
     | jq .
