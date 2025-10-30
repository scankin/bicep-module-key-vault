@maxLength(3)
@description('Three character service code for resource naming convention.')
param service string
@allowed([
  'development'
  'staging'
  'production'
])
@description('The environment being deployed to, allowed "development", "staging" or "production"')
param environment string
@allowed([
  'uksouth'
  'ukwest'
])
@description('The location to be deployed to, allowed "uksouth" and "ukwest"')
param location string 
@allowed([
  'standard'
  'premium'
])
@description('The SKU of the Key Vault, either "standard" or "premium"')
param sku string
@description('Object detailing the protection for the key vault, i.e. purge protection & soft delete')
param protectionConfiguration object = {
  enableSoftDelete: false
  softDeleteRetentionInDays: 0
  enablePurgeProtection: false
}
@allowed([
  'Disabled'
  'Enabled'
])
param allowPublicAccess string
param tags object

var environmentShortCode = {
  development: 'dev'
  staging: 'sta'
  production: 'prd'
}

var locationShortCode = {
  uksouth: 'uks'
  ukwest: 'ukw'
}
// Variables for Resource Deployment
var keyVaultName = '${service}-kv-${locationShortCode[location]}-${environmentShortCode[environment]}'
var virtualNetworkName = '${service}-vnet-${locationShortCode[location]}-${environmentShortCode[environment]}'
var virtualNetworkCidr = '10.0.0.0/24'
var privateEndpointSubnetName = 'pe-subnet'
var privateEndpointSubnetCidr = '10.0.0.0/25'

//Temporary Resources for Private Endpoint Deployment
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-10-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [virtualNetworkCidr]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-10-01' = { 
  parent: virtualNetwork
  name: privateEndpointSubnetName
  properties: {
    addressPrefix: privateEndpointSubnetCidr
  }
}

// Module Call
module keyVault '../main.bicep' = {
  params: {
    keyVaultName: keyVaultName
    location: location
    sku: sku
    protectionConfiguration: protectionConfiguration
    allowPublicAccess: allowPublicAccess
    //privateEndpointSubnetId: subnet.id # Commenting out
    tags: tags
  }
}

//Outputs 
output keyVault object = keyVault.outputs.keyVaultProperties
output privateEndpoint object = keyVault.outputs.privateEndpointProperties
