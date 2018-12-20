Param(
    $Email,
    $ResourceGroup,
    $Location,
    $IdentityName,
    $StorageAccount,
    $StorageKey,
    $StorageShare,
    $Domain,
    $ZoneName,
    $AppService,
    $Wildcard="false",
    $AciName="letsencrypt"
)

$resourceID=$(az identity show --resource-group $ResourceGroup --name $IdentityName --query id --output tsv)

az container create `
    --resource-group $ResourceGroup `
    --name $AciName `
    --image darranshepherd/acmeazure:debug `
    --location $Location `
    --assign-identity $resourceID `
    --restart-policy Never `
    --azure-file-volume-account-name $StorageAccount `
    --azure-file-volume-account-key $StorageKey `
    --azure-file-volume-share-name $StorageShare `
    --azure-file-volume-mount-path '/mnt/letsencrypt' `
    --environment-variables EMAIL="$Email" DOMAIN="$Domain" WILDCARD=$Wildcard RESOURCE_GROUP=$ResourceGroup ZONE_NAME=$ZoneName APP_SERVICE=$AppService `
    --output table

do {
    Start-Sleep -Seconds 5
    $status=$(az container show --resource-group $ResourceGroup --name $AciName --query provisioningState --output tsv)
    Write-Host $status
} until ($status -eq "Succeeded" -or $status -eq "Failed")

az container logs --resource-group $ResourceGroup --name $AciName 
az container delete --resource-group $ResourceGroup --name $AciName --yes --output table
