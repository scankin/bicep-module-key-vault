@description('The name of the key vault to be deployed.')
param keyVaultName string
@description('The location to deploy the key vault to.')
param location string
@description('The SKU of the key vault.')
@allowed([
  'premium'
  'standard'
])
param sku string
param networkConfiguration object = {
  bypass: false
  allowedIp: []
  allowedVirtualNetworks: []
}
param allowPublicAccess bool = false 


resource keyVault 'Microsoft.KeyVault/vaults@2025-05-01' = {
  name: keyVaultName
  location: location
  properties: {
    createMode: 'default'
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enablePurgeProtection: true
    enableSoftDelete: true
    enableRbacAuthorization: true
    publicNetworkAccess: allowPublicAccess
    sku: {
      family: 'A'
      name: sku
    }
    networkAcls: {
      bypass: networkConfiguration.bypass
      defaultAction: 'Deny'
      ipRules: [for i in range(0, length(networkConfiguration.allowedIp)): {
        value: networkConfiguration.allowedIp[i]
      }]
      virtualNetworkRules: [for i in range(0, length(networkConfiguration.allowedVirtualNetworks)): {
        id: networkConfiguration.allowedVirtualNetworks[i]
        ignoreMissingVnetServiceEndpoint: false
      }]
    }
  }

}
