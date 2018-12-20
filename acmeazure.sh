#!/bin/bash

az login --identity --output table

sudo mount -t cifs //$STORAGE_ACCOUNT.file.core.windows.net/$STORAGE_SHARE /etc/letsencrypt -o vers=3,username=$STORAGE_ACCOUNT,password=$STORAGE_KEY,dir_mode=0777,file_mode=0777,serverino,mfsymlinks

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

cp /var/log/letsencrypt/letsencrypt.log /etc/letsencrypt/log/letsencrypt.log

cat /etc/letsencrypt/log/letsencrypt.log
