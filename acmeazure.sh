#!/bin/bash

az login --identity --output table

if [ -f /mnt/letsencrypt/letsencrypt.log ]; then
    rm /mnt/letsencrypt/letsencrypt.log
fi
if [ -f /mnt/letsencrypt/etc.tar.gz ]; then
    mkdir /etc/letsencrypt
    tar -xvfz /mnt/letsencrypt/etc.tar.gz -C /etc/letsencrypt
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

tar -cpvzf /mnt/letsencrypt/etc.tar.gz /etc/letsencrypt/*

cp /var/log/letsencrypt/letsencrypt.log /mnt/letsencrypt/
