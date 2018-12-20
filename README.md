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
  --azure-file-volume-account-name storageaccountname
  --azure-file-volume-account-key storageaccountkey
  --azure-file-volume-share-name certbot
  --azure-file-volume-mount-path /etc/letsencrypt
  --environment-variables EMAIL="foo@bar.com" DOMAIN=bar.com RESOURCE_GROUP=myResourceGroup ZONE_NAME=bar.com APP_SERVICE=appservice
```

When run in Azure Container Instance, the container will login to the Azure CLI using Managed Service Identity. It initiates a certificate request using [certbot](https://certbot.eff.org/), using the DNS challenge; automatically creating the required challenge TXT record in an Azure DNS Zone. Once created, the certificate is uploaded to an Azure WebApp and the binding configured. By mounting /etc/letsencrypt to an Azure Files share, running the container is idempotent and will only request new certificates if close to expiry.

Environment Variables
-
* `EMAIL` Email address passed to LetsEncrypt
* `DOMAIN` Domain name for the certificate
* `RESOURCE_GROUP` Resource group containing the web app and DNS zone
* `ZONE_NAME` Azure DNS Zone name
* `APP_SERVICE` Azure App Service name
* `WILDCARD` Optional: true if you want to create a wildcard certificate - in this case, set DOMAIN to the bare domain (e.g. example.com to generate a certificate for domains example.com and *.example.com)
* `ACME_SERVER` Optional: ACME Server URL (if you want to override with the staging URL)

Running Manually
-
* Start a command prompt with the Azure CLI installed
* Create a Managed Service Identity `az identity create --resource-group myResourceGroup --name letsencrypt`
* Retrieve the Service Principal ID `resourceID=$(az identity show --resource-group myResourceGroup --name myACIId --query id --output tsv)`
* Assign the Contributor role to the resource group containing the DNS zone and web app.
* Run container instance `az container create --resource-group myResourceGroup --name acmeazure --image darranshepherd/acmeazure --assign-identity $resourceID --restart-policy Never --azure-file-volume-account-name storageaccountname --azure-file-volume-account-key storageaccountkey --azure-file-volume-share-name certbot --azure-file-volume-mount-path /etc/letsencrypt --environment-variables EMAIL="foo@bar.com" DOMAIN=bar.com RESOURCE_GROUP=myResourceGroup ZONE_NAME=bar.com APP_SERVICE=appservice`
* Delete ACI instance once complete. `az container delete --resource-group myResourceGroup --name acmeazure`

Running Automatically
-
The Logic Apps connector and Azure RM Powershell commandlet (that can be used in Automation) do not yet support enabling MSI on container groups. When these are supported this documentation will be updated with details of how to automate running the container.

How It Works
-
When the container is run, the [acmeazure.sh](acmeazure.sh) script is run. This logs into the Azure CLI using managed service identity. The LetsEncrypt client [Certbot](https://certbot.eff.org/) is then executed passing in the desired domain, requesting the DNS challenge and passing in paths to hook scripts to handle the DNS challenge and deployment of the certificate upon issue or renewal.

The DNS challenge is handled by [azurednsauthenticator.sh](azurednsauthenticator.sh) which creates the required TXT record in an Azure DNS Zone. This is then cleaned up and removed by [azurednscleanup.sh](azurednscleanup.sh).

If the certificate has been issued or renewed, Certbot calls [azurewebappbind.sh](azurewebappbind.sh) which generates a PKCS#12 .pfx file from the certificate chain, uploads it to the web app and creates the SSL binding. If the certificate does not need to be renewed (by checking the mapped Azure Files share, not by checking the certificate on the webapp), this script is not called.

Planned Improvements
-
* ~~Install latest version of certbot (apk add certbot is installing 0.19.0 which doesn't support ACME V2)~~
* ~~Make the script idempotent by only renewing if the certificate expires in < 30 days~~
* ~~Enable optionally mounting a persistent volume for /etc/letsencrypt~~
* ~~Support wildcard certificates~~
* Support multiple domains per certificate
* Support multiple web apps per certificate
* Investigate using KeyVault to deploy the certificate to web apps [Web App Certificate](https://blogs.msdn.microsoft.com/appserviceteam/2016/05/24/deploying-azure-web-app-certificate-through-key-vault/)
* Try to find a more limited permission scope than Contributor on the entire resource group