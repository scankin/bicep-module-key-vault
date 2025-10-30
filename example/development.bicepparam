using './example.bicep'

param service = 'sja'
param environment = 'development'
param location = 'uksouth'
param allowPublicAccess = 'allowed'
param sku = 'standard'
param protectionConfiguration = {
  enableSoftDelete: false
  softDeleteRetentionInDays: 7
  enablePurgeProtection: null
}
param tags = {
  bicep: true
}
