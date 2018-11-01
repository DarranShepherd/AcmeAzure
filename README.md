AcmeAzure
=

A Docker container used to request an SSL certificate from LetsEncrypt and install onto an Azure WebApp. For example:

```
az container create \
  --resource-group myResourceGroup \
  --name acmeazure \
  --image darranshepherd/acmeazure \
  --assign-identity $resourceID \
  --restart-policy Never \
  --environment-variables EMAIL="foo@bar.com" DOMAIN=bar.com RESOURCE_GROUP=myResourceGroup ZONE_NAME=bar.com APP_SERVICE=appservice
```

When run in Azure Container Instance, the container will login to the Azure CLI using Managed Service Identity. It initiates a certificate request using [certbot](https://certbot.eff.org/), using the DNS challenge; automatically creating the required challenge TXT record in an Azure DNS Zone. Once created, the certificate is uploaded to an Azure WebApp and the binding configured.

Environment Variables
-
* `EMAIL` Email address passed to LetsEncrypt
* `DOMAIN` Domain name for the certificate
* `RESOURCE_GROUP` Resource group containing the web app and DNS zone
* `ZONE_NAME` Azure DNS Zone name
* `APP_SERVICE` Azure App Service name
* `ACME_SERVER` Optional: ACME Server URL (if you want to override with the staging URL)

Running
-
* Create a Managed Service Identity `az identity create --resource-group myResourceGroup --name letsencrypt`
* Retrieve the Service Principal ID `resourceID=$(az identity show --resource-group myResourceGroup --name myACIId --query id --output tsv)`
* Assign the Contributor role to the resource group containing the DNS zone and web app.
* Run container instance `az container create --resource-group myResourceGroup --name acmeazure --image darranshepherd/acmeazure --assign-identity $resourceID --restart-policy Never --environment-variables EMAIL="foo@bar.com" DOMAIN=bar.com RESOURCE_GROUP=myResourceGroup ZONE_NAME=bar.com APP_SERVICE=appservice`
* Delete ACI instance once complete. `az container delete --resource-group myResourceGroup --name acmeazure`

Instead of running manually, it is recommended to schedule the running of the container instance with Azure Automation.

Planned Improvements
-
* Install latest version of certbot (apk add certbot is installing 0.19.0 which doesn't support ACME V2)
* Make the script idempotent by only renewing if the certificate expires in < 30 days
* Enable optionally mounting a persistent volume for /etc/letsencrypt
* Support wildcard certificates
* Support multiple domains per certificate
* Support multiple web apps per certificate
* Investigate using KeyVault to deploy the certificate to web apps [Web App Certificate](https://blogs.msdn.microsoft.com/appserviceteam/2016/05/24/deploying-azure-web-app-certificate-through-key-vault/)
* Try to find a more limited permission scope than Contributor on the entire resource group