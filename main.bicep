@description('The name of the key vault to be deployed.')
param keyVaultName string
@description('The location to deploy the key vault to.')
param location string
@description('The SKU of the key vault.')
@allowed([
  'premium'
  'standard'
])
param sku string = 'standard'
param networkConfiguration object = {
  bypass: 'AzureServices'
  allowedIp: []
  allowedVirtualNetworks: []
}
@description('Whether public access is allowed to the key vault, either "disabled" or "allowed". Recommended is "disabled"')
@allowed([
  'Disabled'
  'Enabled'
])
param allowPublicAccess string = 'Disabled'
param protectionConfiguration object = {
  enableSoftDelete: true
  softDeleteRetentionInDays: 14
  enablePurgeProtection: true
}
param tags object = {
  bicep: true 
}

resource keyVault 'Microsoft.KeyVault/vaults@2025-05-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: deployer().tenantId
    createMode: 'default'
    sku: {
      family: 'A'
      name: sku
    }

    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true

    enablePurgeProtection: protectionConfiguration.enablePurgeProtection
    enableSoftDelete: protectionConfiguration.enableSoftDelete
    softDeleteRetentionInDays: protectionConfiguration.softDeleteRetentionInDays

    publicNetworkAccess: allowPublicAccess
    networkAcls: {
      bypass: networkConfiguration.bypass
      defaultAction: 'Deny'
      ipRules: [
        for i in range(0, length(networkConfiguration.allowedIp)): {
          value: networkConfiguration.allowedIp[i]
        }
      ]
      virtualNetworkRules: [
        for i in range(0, length(networkConfiguration.allowedVirtualNetworks)): {
          id: networkConfiguration.allowedVirtualNetworks[i]
          ignoreMissingVnetServiceEndpoint: false
        }
      ]
    }
  }
}
