# Bicep Module for Azure Key Vault
The following docmentation assumes knowledge in:
- Azure
- Bicep

An example deployment can be found within the `./example` directory.

## Parameters
| Name | Type | Description | Required |
|------|------|-------------|----------|
| keyVaultName | `string` | The name of the key vault to be deployed. | Y |
| location | `string` | The location to deploy the key vault to i.e. uksouth | Y |
| sku | `string` | The SKU of the key vault, either `standard` or `premium`, defaults to `standard` | N |
| networkConfiguration | `object` | An object containing the configuration of allowed IPs and Allowed Virtual Networks with Service Endpoints to Azure Key Vault. Defaults to allow bypass to Azure Services,  an empty list of allowedIPs and Virtual Networks. This is ignored if allowPublicAccess is disabled | N | 
| allowPublicAccess | `string` | Either `Disabled` or `Enabled`. | N |
| protectionConfiguration | `object` | An object detailing the protection details for the key vault i.e. Soft Delete, Soft Delete Retention and Purge Protection | N |

## Resources Created
- 1x Azure Key Vault