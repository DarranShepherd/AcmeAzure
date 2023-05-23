#!/bin/bash

az login --identity --output table

if [ -f /mnt/letsencrypt/etc.tar.gz ]; then
    tar -xzf /mnt/letsencrypt/etc.tar.gz -C /
fi

if [ $KEY_VAULT ]; then
    export DEPLOY_HOOK="//acmeazure//azurekeyvaultimport.sh"
else
    export DEPLOY_HOOK="//acmeazure//azurewebappbind.sh"
fi

certbot --version

certbotargs=(
    "certonly"
    "--manual"
    "--noninteractive"
    "--key-type" "rsa"
    "--rsa-key-size" "2048"
    "--preferred-challenges" "dns-01"
    "--manual-auth-hook" "//acmeazure//azurednsauthenticator.sh"
    "--manual-cleanup-hook" "//acmeazure//azurednscleanup.sh"
    "--deploy-hook" $DEPLOY_HOOK
    "--agree-tos"
    "--server" "$ACME_SERVER"
    "--email" "$EMAIL"
    "-d" "$DOMAIN"
)
shopt -s nocasematch
if [[ "$WILDCARD" == "true" ]]; then
    certbotargs+=("-d" "*.$DOMAIN")
fi

certbot "${certbotargs[@]}"

if [ -d /mnt/letsencrypt ]; then
    tar -cpzf /mnt/letsencrypt/etc.tar.gz -C / etc/letsencrypt/
    cp /var/log/letsencrypt/letsencrypt.log /mnt/letsencrypt/
fi
