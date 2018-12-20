#!/bin/bash

PASSWORD=$(date | md5sum)

openssl pkcs12 \
    -export \
    -out "/etc/letsencrypt/live/$DOMAIN/certificate.pfx" \
    -password "pass:$PASSWORD" \
    -inkey "/etc/letsencrypt/live/$DOMAIN/privkey.pem" \
    -in "/etc/letsencrypt/live/$DOMAIN/cert.pem" \
    -certfile "/etc/letsencrypt/live/$DOMAIN/chain.pem"

THUMBPRINT=$(az webapp config ssl upload \
    -n "$APP_SERVICE" \
    -g "$RESOURCE_GROUP" \
    --certificate-file "/etc/letsencrypt/live/$DOMAIN/certificate.pfx" \
    --certificate-password "$PASSWORD" \
    --query thumbprint \
    --output tsv)

az webapp config ssl bind \
    -n "$APP_SERVICE" \
    -g "$RESOURCE_GROUP" \
    --certificate-thumbprint "$THUMBPRINT" \
    --ssl-type "SNI"

rm "/etc/letsencrypt/live/$DOMAIN/certificate.pfx"
