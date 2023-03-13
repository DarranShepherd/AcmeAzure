#!/bin/bash

PASSWORD=$(date | md5sum)

openssl pkcs12 \
    -export \
    -out "/etc/letsencrypt/live/$DOMAIN/certificate.pfx" \
    -password "pass:$PASSWORD" \
    -inkey "/etc/letsencrypt/live/$DOMAIN/privkey.pem" \
    -in "/etc/letsencrypt/live/$DOMAIN/cert.pem" \
    -certfile "/etc/letsencrypt/live/$DOMAIN/chain.pem"

az keyvault certificate import \
    --vault-name $KEY_VAULT \
    --name "${DOMAIN//./}" \
    --file "/etc/letsencrypt/live/$DOMAIN/certificate.pfx" \
    --password "$PASSWORD"