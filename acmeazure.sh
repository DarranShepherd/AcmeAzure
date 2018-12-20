#!/bin/bash

az login --identity --output table

cp -r /mnt/letsencrypt/ /etc/letsencrypt

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

cp -r -L /etc/letsencrypt/ /mnt/letsencrypt

ls /var/log/letsencrypt
cat /var/log/letsencrypt/letsencrypt.log
