#!/bin/bash

SET_NAME="${CERTBOT_DOMAIN/$ZONE_NAME/}"
SET_NAME="_acme-challenge.${SET_NAME%?}"

az network dns record-set txt remove-record \
    --resource-group "$RESOURCE_GROUP" \
    --zone-name "$ZONE_NAME" \
    --record-set-name "$SET_NAME" \
    --value "$CERTBOT_VALIDATION"