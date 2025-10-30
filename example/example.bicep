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

var keyVaultName = '${service}-kv-${locationShortCode[location]}-${environmentShortCode[environment]}'

module keyVault '../main.bicep' = {
  params: {
    keyVaultName: keyVaultName
    location: location
    sku: sku
    protectionConfiguration: protectionConfiguration
    allowPublicAccess: allowPublicAccess
    tags: tags
  }
}
