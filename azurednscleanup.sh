#!/bin/bash

SET_NAME="${CERTBOT_DOMAIN/$ZONE_NAME/}"
if [[ "$SET_NAME" == "" ]]; then
    SET_NAME="_acme-challenge"
else
    SET_NAME="_acme-challenge.${SET_NAME%?}"
fi

az network dns record-set txt remove-record \
    --resource-group "$DNS_RESOURCE_GROUP" \
    --zone-name "$ZONE_NAME" \
    --record-set-name "$SET_NAME" \
    --value "$CERTBOT_VALIDATION" \
    --output table
