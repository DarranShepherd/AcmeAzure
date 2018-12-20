#!/bin/bash

az login --identity --output table

if [ -f /mnt/letsencrypt/etc.tar.gz ]; then
    tar -xvzf /mnt/letsencrypt/etc.tar.gz -C /
    ls -Rla /etc/letsencrypt
fi

certbotargs=(
    "certonly"
    "--manual"
    "--noninteractive"
    "--preferred-challenges" "dns-01"
    "--manual-auth-hook" "//acmeazure//azurednsauthenticator.sh"
    "--manual-cleanup-hook" "//acmeazure//azurednscleanup.sh"
    "--deploy-hook" "//acmeazure//azurewebappbind.sh"
    "--agree-tos"
    "--manual-public-ip-logging-ok"
    "--server" "$ACME_SERVER"
    "--email" "$EMAIL"
    "-d" "$DOMAIN"
)
shopt -s nocasematch
if [[ "$WILDCARD" == "true" ]]; then
    certbotargs+=("-d" "*.$DOMAIN")
fi

certbot "${certbotargs[@]}"

ls -Rla /etc/letsencrypt
tar -cpvzf /mnt/letsencrypt/etc.tar.gz /etc/letsencrypt/
tar -tvzf /mnt/letsencrypt/etc.tar.gz

cp /var/log/letsencrypt/letsencrypt.log /mnt/letsencrypt/
