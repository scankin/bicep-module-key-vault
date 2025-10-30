//INFO: Parameters
@description('The name of the key vault to be deployed.')
param keyVaultName string
@description('The location to deploy the key vault to.')
param location string
@allowed([
  'premium'
  'standard'
])
@description('The SKU of the key vault.')
param sku string = 'standard'
@description('The network ACLs for the key vault, this is ignored if allowedPublicAccess is Disabled')
param networkConfiguration object = {
  bypass: 'AzureServices'
  allowedIp: []
  allowedVirtualNetworks: []
}
@allowed([
  'Disabled'
  'Enabled'
])
@description('Whether public access is allowed to the key vault, either "disabled" or "allowed". Recommended is "disabled"')
param allowPublicAccess string = 'Disabled'
@description('The configuration of protection for the key vault, including soft delete, soft delete retention periods and purge protection')
param protectionConfiguration object = {
  enableSoftDelete: true
  softDeleteRetentionInDays: 14
  enablePurgeProtection: true
}
@description('The subnet ID for the private endpoint deployment')
param privateEndpointSubnetId string = 'null'
param tags object = {
  bicep: true 
}

//INFO: Variables
var privateEndpointName = 'pe-${keyVaultName}'

//INFO: Resources
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

    publicNetworkAccess: (privateEndpointSubnetId != 'null') ? 'Disabled' : allowPublicAccess
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

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-10-01' = if (privateEndpointSubnetId != 'null') { 
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [{
      name: privateEndpointName
      properties: {
        privateLinkServiceId: keyVault.id
        groupIds: [
          'vault'
        ]
      }
    }]
    subnet: {
      id: privateEndpointSubnetId
    }
  }
}

//INFO: Outputs
output keyVaultProperties object = {
  name: keyVault.name
  properties: keyVault.properties
}

output privateEndpointProperties object = privateEndpointSubnetId != 'null' ? {
  name: privateEndpoint.name
} : {}
