#!/bin/bash
certbot renew --quiet
openssl pkcs12 -export -out /home/user/homelab/networking/dns/certs/cert.pfx \
-inkey /etc/letsencrypt/live/example.com/privkey.pem \
-in /etc/letsencrypt/live/example.com/fullchain.pem \
-passout pass:
systemctl --machine=user@.host --user restart technitium.service
