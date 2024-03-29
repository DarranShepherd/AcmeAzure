Param(
    $Email,
    $ResourceGroup,
    $Location,
    $IdentityName,
    $StorageAccount,
    $StorageKey,
    $StorageShare,
    $Domain,
    $DnsResourceGroup,
    $ZoneName,
    $AppResourceGroup,
    $AppService,
    $KeyVault,
    $Wildcard="false",
    $AciName="letsencrypt",
    $AcmeServer="https://acme-v02.api.letsencrypt.org/directory"
)

$resourceID=$(az identity show --resource-group $ResourceGroup --name $IdentityName --query id --output tsv)

if ($null -eq $DnsResourceGroup) { $DnsResourceGroup = $ResourceGroup }
if ($null -eq $AppResourceGroup) { $AppResourceGroup = $ResourceGroup }

az container create `
    --resource-group $ResourceGroup `
    --name $AciName `
    --image darranshepherd/acmeazure:latest `
    --location $Location `
    --assign-identity $resourceID `
    --restart-policy Never `
    --azure-file-volume-account-name $StorageAccount `
    --azure-file-volume-account-key $StorageKey `
    --azure-file-volume-share-name $StorageShare `
    --azure-file-volume-mount-path '/mnt/letsencrypt' `
    --environment-variables EMAIL="$Email" DOMAIN="$Domain" WILDCARD=$Wildcard RESOURCE_GROUP=$AppResourceGroup DNS_RESOURCE_GROUP=$DnsResourceGroup ZONE_NAME=$ZoneName APP_SERVICE=$AppService KEY_VAULT=$KeyVault ACME_SERVER=$AcmeServer `
    --output table

do {
    Start-Sleep -Seconds 5
    $status=$(az container show --resource-group $ResourceGroup --name $AciName --query instanceView.state --output tsv)
} until ($status -eq "Succeeded" -or $status -eq "Failed")

az container logs --resource-group $ResourceGroup --name $AciName 
az container delete --resource-group $ResourceGroup --name $AciName --yes --output table
