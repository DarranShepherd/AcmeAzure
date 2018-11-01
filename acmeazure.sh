#!/bin/bash

# Short circuit if certificate is still valid for > 30 days

az login --identity

certbot certonly \
   --manual \
   --noninteractive \
   --preferred-challenges=dns \
   --manual-auth-hook /acmeazure/azurednsauthenticator.sh \
   --manual-cleanup-hook /acmeazure/azurednscleanup.sh \
   --agree-tos \
   --manual-public-ip-logging-ok \
   --server $ACME_SERVER \
   --email "$EMAIL" \
   -d "$DOMAIN"

openssl pkcs12 \
    -export \
    -out "/etc/letsencrypt/live/$DOMAIN/certificate.pfx" \
    -password "pass:abc123" \
    -inkey "/etc/letsencrypt/live/$DOMAIN/privkey.pem" \
    -in "/etc/letsencrypt/live/$DOMAIN/cert.pem" \
    -certfile "/etc/letsencrypt/live/$DOMAIN/chain.pem"

THUMBPRINT=$(az webapp config ssl upload \
    -n "$APP_SERVICE" \
    -g "$RESOURCE_GROUP" \
    --certificate-file "/etc/letsencrypt/live/$DOMAIN/certificate.pfx" \
    --certificate-password "abc123" \
    --query thumbprint \
    --output tsv)

az webapp config ssl bind \
    -n "$APP_SERVICE" \
    -g "$RESOURCE_GROUP" \
    --certificate-thumbprint "$THUMBPRINT" \
    --ssl-type "SNI"