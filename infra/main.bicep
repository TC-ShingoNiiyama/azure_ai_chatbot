targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Enable private network access to the backend service')
param isPrivateNetworkEnabled bool

param appServicePlanName string = ''
param backendServiceName string = ''
param backendServiceSlotName string = ''
param resourceGroupName string = ''

param ipAddressRange array = []
param ipAddressRangeSlot array = []

@secure()
param clientSecret string
@secure()
param clientId string
@secure()
param authUrl string

param applicationInsightsName string = ''
param workspaceName string = ''

param searchServiceName string = ''
param searchServiceResourceGroupName string = ''
param searchServiceResourceGroupLocation string = location

param searchServiceSkuName string = 'standard'
param searchIndexName string = 'chatbotindex'

param resourceSuffix string = ''

param storageAccountName string = ''
param storageResourceGroupName string = ''
param storageResourceGroupLocation string = location
param storageContainerName string = 'content'

param openAiServiceName string = ''
param openAiResourceGroupName string = ''
// param openAiResourceGroupLocation string = location

// param openAiSkuName string = 'S0'
param isAuthEnabled bool = true
param openAiApiKey string = ''

param openAiGpt35TurboDeploymentName string = 'gpt35-4k'
param openAiGpt35Turbo16kDeploymentName string = 'gpt35-16k'
param openAiGpt4DeploymentName string = 'gpt4-8k'
param openAiGpt432kDeploymentName string = 'gpt4-32k'
param openAiGpt4TurboDeploymentName string = 'gpt4-turbo'
param openAiEmbDeploymentName string = ''
param openAiEmbEndPoint string = ''
param openAiEmbModelName string = ''
@secure()
param openAiEmbApiKey string = ''
param openAiApiVersion string = '2023-05-15'

// param formRecognizerServiceName string = ''
// param formRecognizerResourceGroupName string = ''
// param formRecognizerResourceGroupLocation string = location

// param formRecognizerSkuName string = 'S0'

param cosmosDbDatabaseName string = 'ChatHistory'
param cosmosDbContainerName string = 'Prompts'
param cosmondbAccountName string = 'cosmosdb'

param vnetLocation string = location
param vnetAddressPrefix string = '10.0.0.0/16'

param subnetAddressPrefix1 string = '10.0.0.0/24'
// param subnetAddressPrefix2 string = '10.0.1.0/24'
param subnetAddressPrefix3 string = '10.0.2.0/24'

param privateEndpointLocation string = location

// param vmLoginName string = 'azureuser'
// @secure()
// param vmLoginPassword string

@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('Use Application Insights for monitoring and performance tracing')
param useApplicationInsights bool = true

var abbrs = loadJsonContent('abbreviations.json')
var tags = { 'azd-env-name': environmentName }

// Organize resources in a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

resource openAiResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!empty(openAiResourceGroupName)) {
  name: !empty(openAiResourceGroupName) ? openAiResourceGroupName : resourceGroup.name
}

// resource formRecognizerResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!empty(formRecognizerResourceGroupName)) {
//   name: !empty(formRecognizerResourceGroupName) ? formRecognizerResourceGroupName : resourceGroup.name
// }

resource searchServiceResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!empty(searchServiceResourceGroupName)) {
  name: !empty(searchServiceResourceGroupName) ? searchServiceResourceGroupName : resourceGroup.name
}

resource storageResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!empty(storageResourceGroupName)) {
  name: !empty(storageResourceGroupName) ? storageResourceGroupName : resourceGroup.name
}

module cosmosDb 'core/db/cosmosdb.bicep' = {
  name: 'cosmosdb'
  scope: resourceGroup
  params: {
    name: !empty(cosmondbAccountName) ? cosmondbAccountName :'${abbrs.documentDBDatabaseAccounts}${resourceSuffix}'
    location: location
    tags: union(tags, { 'azd-service-name': 'cosmosdb' })
    cosmosDbDatabaseName: cosmosDbDatabaseName
    cosmosDbContainerName: cosmosDbContainerName
    ipAddressRange: ipAddressRange
    publicNetworkAccess: 'Enabled'
  }
}

// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan 'core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: resourceGroup
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceSuffix}'
    location: location
    tags: tags
    sku: {
      name: 'S1'
      capacity: 1
    }
    kind: 'linux'
  }
}

// Monitor application with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = if (useApplicationInsights) {
  name: 'monitoring'
  scope: resourceGroup
  params: {
    workspaceName: !empty(workspaceName) ? workspaceName : '${abbrs.insightsComponents}${resourceSuffix}-workspace'
    location: location
    tags: tags
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceSuffix}'
  }
}

// module openAi 'core/ai/cognitiveservices.bicep' = {
//   name: 'openai'
//   scope: openAiResourceGroup
//   params: {
//     name: !empty(openAiServiceName) ? openAiServiceName : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
//     location: openAiResourceGroupLocation
//     tags: tags
//     sku: {
//       name: openAiSkuName
//     }
//     deployments: [
//       {
//         name: openAiGpt35TurboDeploymentName
//         model: {
//           format: 'OpenAI'
//           name: 'gpt-35-turbo'
//           version: '0613'
//         }
//         sku: {
//           name: 'Standard'
//           capacity: 180
//         }
//       }
//       {
//         name: openAiGpt35Turbo16kDeploymentName
//         model: {
//           format: 'OpenAI'
//           name: 'gpt-35-turbo-16k'
//           version: '0613'
//         }
//         sku: {
//           name: 'Standard'
//           capacity: 180
//         }
//       }
//       {
//         name: openAiGpt4DeploymentName
//         model: {
//           format: 'OpenAI'
//           name: 'gpt-4'
//           version: '0613'
//         }
//         sku: {
//           name: 'Standard'
//           capacity: 40
//         }
//       }
//       {
//         name:  openAiGpt432kDeploymentName
//         model: {
//           format: 'OpenAI'
//           name: 'gpt-4-32k'
//           version: '0613'
//         }
//         sku: {
//           name: 'Standard'
//           capacity: 80
//         }
//       }
//       {
//         name:  openAiEmbDeploymentName
//         model: {
//           format: 'OpenAI'
//           name: 'text-embedding-ada-002'
//           version: '0613'
//         }
//         sku: {
//           name: 'Standard'
//           capacity: 350
//         }
//       }
//     ]
//     publicNetworkAccess: isPrivateNetworkEnabled ? 'Disabled' : 'Enabled'
//   }
// }

// module formRecognizer 'core/ai/form.bicep' = {
//   name: 'formrecognizer'
//   scope: formRecognizerResourceGroup
//   params: {
//     name: !empty(formRecognizerServiceName) ? '${formRecognizerServiceName}' : '${abbrs.cognitiveServicesFormRecognizer}${resourceSuffix}'
//     kind: 'FormRecognizer'
//     ipAddressRange: ipAddressRange
//     location: formRecognizerResourceGroupLocation
//     tags: tags
//     sku: {
//       name: formRecognizerSkuName
//     }
//   }
// }

module searchService 'core/search/search-services.bicep' = {
  name: 'search-service'
  scope: searchServiceResourceGroup
  params: {
    name: !empty(searchServiceName) ? '${searchServiceName}' : 'gptkb-${resourceSuffix}'
    location: searchServiceResourceGroupLocation
    ipAddressRange: ipAddressRange
    tags: tags
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
    sku: {
      name: searchServiceSkuName
    }
    semanticSearch: 'free'
  }
}

module storage 'core/storage/storage-account.bicep' = {
  name: 'storage'
  scope: storageResourceGroup
  params: {
    name: !empty(storageAccountName) ? '${storageAccountName}' : '${abbrs.storageStorageAccounts}${resourceSuffix}'
    location: storageResourceGroupLocation
    ipAddressRange: ipAddressRange
    tags: tags
    sku: {
      name: 'Standard_ZRS'
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 2
    }
    containers: [
      {
        name: storageContainerName
        publicAccess: 'None'
      }
    ]
    publicNetworkAccess: 'Enabled'
  }
}

var cosmosDbKey = cosmosDb.outputs.primaryKey
var cosmosDbString = cosmosDb.outputs.connectionString
// The application frontend
module backend 'core/host/appservice.bicep' = {
  name: 'web'
  scope: resourceGroup
  params: {
    // name: !empty(backendServiceName) ? backendServiceName : '${abbrs.webSitesAppService}backend-${resourceSuffix}-remote'
    // slotName: !empty(backendServiceSlotName) ? backendServiceSlotName : '${abbrs.webSitesAppService}backend-${resourceSuffix}-office'
    name: '${abbrs.webSitesAppService}backend-${resourceSuffix}-remote'
    slotName: '${abbrs.webSitesAppService}backend-${resourceSuffix}-office'
    location: location
    tags: union(tags, { 'azd-service-name': 'backend' })
    slotTags: union(tags, { 'azd-service-name': 'backendSlot' })
    appServicePlanId: appServicePlan.outputs.id
    ipAddressRange: ipAddressRange
    ipAddressRangeSlot: ipAddressRangeSlot
    runtimeName: 'python'
    runtimeVersion: '3.10'
    scmDoBuildDuringDeployment: true
    managedIdentity: true
    managedIdentitySlot: true
    applicationInsightsName: useApplicationInsights ? monitoring.outputs.applicationInsightsName : ''
    virtualNetworkSubnetId: isPrivateNetworkEnabled ? appServiceSubnet.outputs.id : ''
    clientId: clientId
    authUrl: authUrl
    isAuthEnabled: isAuthEnabled
    appSettings: {
      AZURE_APPLICATIONINSIGHTS_CONNECTION_STRING: useApplicationInsights ? monitoring.outputs.applicationInsightsConnectionString : ''
      AZURE_APP_CLIENT_SECRET: clientSecret
      AZURE_STORAGE_ACCOUNT: storage.outputs.name
      AZURE_STORAGE_CONTAINER: storageContainerName
      AZURE_OPENAI_SERVICE: openAiServiceName
      AZURE_OPENAI_EMB_API_KEY: openAiEmbApiKey
      AZURE_OPENAI_EMB_DEPLOYMENT: openAiEmbDeploymentName
      AZURE_OPENAI_EMB_ENDPONT: openAiEmbEndPoint
      AZURE_OPENAI_API_KEY: openAiApiKey
      AZURE_OPENAI_EMB_MODEL_NAME: openAiEmbModelName
      AZURE_SEARCH_INDEX: searchIndexName
      AZURE_SEARCH_SERVICE: searchService.outputs.name
      AZURE_OPENAI_GPT_35_TURBO_DEPLOYMENT: openAiGpt35TurboDeploymentName
      AZURE_OPENAI_GPT_35_TURBO_16K_DEPLOYMENT: openAiGpt35Turbo16kDeploymentName
      AZURE_OPENAI_GPT_4_DEPLOYMENT: openAiGpt4DeploymentName
      AZURE_OPENAI_GPT_4_32K_DEPLOYMENT: openAiGpt432kDeploymentName
      AZURE_OPENAI_GPT_4_TURBO_DEPLOYMENT: openAiGpt4TurboDeploymentName
      AZURE_OPENAI_API_VERSION: openAiApiVersion
      AZURE_COSMOSDB_CONTAINER: cosmosDbContainerName
      AZURE_COSMOSDB_DATABASE: cosmosDbDatabaseName
      AZURE_COSMOSDB_ENDPOINT: cosmosDb.outputs.endpoint
      AZURE_COSMOSDB_KEY: cosmosDbKey
      AZURE_COSMOSDB_STRING: cosmosDbString
    }
  }
}



// ================================================================================================
// PRIVATE NETWORK VM
// ================================================================================================
// module vm 'core/vm/vm.bicep' = {
//   name: 'vm${resourceToken}'
//   scope: resourceGroup
//   params: {
//     name: 'vm${resourceToken}'
//     location: location
//     adminUsername: vmLoginName
//     adminPasswordOrKey: vmLoginPassword
//     nicId: nic.outputs.nicId
//     isPrivateNetworkEnabled: isPrivateNetworkEnabled
//   }
//   dependsOn: [
//     nic
//   ]
// }

// ================================================================================================
// NETWORK
// ================================================================================================
// module publicIP 'core/network/pip.bicep' = {
//   name: 'publicIP'
//   scope: resourceGroup
//   params: {
//     name: 'publicIP'
//     location: location
//     isPrivateNetworkEnabled: isPrivateNetworkEnabled
//   }
// }

// module appNsg 'core/network/appNsg.bicep' = {
//   name: 'appNsg'
//   scope: resourceGroup
//   params: {
//     name: 'appNsg'
//     location: location
//     isPrivateNetworkEnabled: isPrivateNetworkEnabled
//   }
// }

// module nic 'core/network/nic.bicep' = {
//   name: 'vm-nic'
//   scope: resourceGroup
//   params: {
//     name: 'vm-nic'
//     location: location
//     subnetId: vmSubnet.outputs.id
//     publicIPId: publicIP.outputs.publicIPId
//     nsgId: nsg.outputs.id
//     isPrivateNetworkEnabled: isPrivateNetworkEnabled
//   }
//   dependsOn: [
//     vmSubnet
//     publicIP
//     nsg
//   ]
// }

module vnet 'core/network/vnet.bicep' = {
  name: 'vnet'
  scope: resourceGroup
  params: {
    name: 'vnet'
    location: vnetLocation
    addressPrefixes: [vnetAddressPrefix]
    isPrivateNetworkEnabled: isPrivateNetworkEnabled
  }
}

module nsg 'core/network/nsg.bicep' = {
  name: 'nsg'
  scope: resourceGroup
  params: {
    name: 'nsg'
    location: location
    isPrivateNetworkEnabled: isPrivateNetworkEnabled
  }
}

module privateEndpointSubnet 'core/network/subnet.bicep' = {
  name: '${abbrs.networkVirtualNetworksSubnets}private-endpoint-${resourceSuffix}'
  scope: resourceGroup
  params: {
    existVnetName: vnet.outputs.name
    name: '${abbrs.networkVirtualNetworksSubnets}private-endpoint-${resourceSuffix}'
    addressPrefix: subnetAddressPrefix1
    networkSecurityGroup: {
      id: nsg.outputs.id
    }
    isPrivateNetworkEnabled: isPrivateNetworkEnabled
  }
  dependsOn: [
    vnet
    nsg
  ]
}

// module vmSubnet 'core/network/subnet.bicep' = {
//   name: '${abbrs.networkVirtualNetworksSubnets}vm-${resourceToken}'
//   scope: resourceGroup
//   params: {
//     existVnetName: vnet.outputs.name
//     name: '${abbrs.networkVirtualNetworksSubnets}vm-${resourceToken}'
//     addressPrefix: subnetAddressPrefix2
//     networkSecurityGroup: {
//       id: nsg.outputs.id
//     }
//     isPrivateNetworkEnabled: isPrivateNetworkEnabled
//   }
//   dependsOn: [
//     vnet
//     nsg
//     privateEndpointSubnet
//   ]
// }

module appServiceSubnet 'core/network/subnet.bicep' = {
  name: '${abbrs.networkVirtualNetworksSubnets}${abbrs.webSitesAppService}${resourceSuffix}'
  scope: resourceGroup
  params: {
    existVnetName: vnet.outputs.name
    name: '${abbrs.networkVirtualNetworksSubnets}${abbrs.webSitesAppService}${resourceSuffix}'
    addressPrefix: subnetAddressPrefix3
    networkSecurityGroup: {
      id: nsg.outputs.id
    }
    delegations: [
      {
        name: 'Microsoft.Web/serverFarms'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
    isPrivateNetworkEnabled: isPrivateNetworkEnabled
  }
  dependsOn: [
    privateEndpointSubnet
    vnet
    nsg
  ]
}

module cosmosDBPrivateEndpoint 'core/network/privateEndpoint.bicep' = {
  name: 'cosmos-private-endpoint'
  scope: resourceGroup
  params: {
    location: privateEndpointLocation
    name: cosmosDb.outputs.name
    subnetId: privateEndpointSubnet.outputs.id
    privateLinkServiceId: cosmosDb.outputs.id
    privateLinkServiceGroupIds: ['SQL']
    dnsZoneName: 'documents.azure.com'
    linkVnetId: vnet.outputs.id
    isPrivateNetworkEnabled: isPrivateNetworkEnabled
  }
  dependsOn: [
    privateEndpointSubnet
  ]
}

// module oepnaiPrivateEndopoint 'core/network/privateEndpoint.bicep' = {
//   name: 'openai-service-private-endpoint'
//   scope: resourceGroup
//   params: {
//     location: privateEndpointLocation
//     name: openAiServiceName
//     subnetId: privateEndpointSubnet.outputs.id
//     privateLinkServiceId: openAiServiceId
//     privateLinkServiceGroupIds: ['account']
//     dnsZoneName: 'openai.azure.com'
//     linkVnetId: vnet.outputs.id
//     isPrivateNetworkEnabled: isPrivateNetworkEnabled
//   }
//   dependsOn: [
//     privateEndpointSubnet
//   ]
// }

// module formRecognizerPrivateEndopoint 'core/network/privateEndpoint.bicep' = {
//   name: 'form-recognizer-private-endpoint'
//   scope: resourceGroup
//   params: {
//     location: privateEndpointLocation
//     name: formRecognizer.outputs.name
//     subnetId: privateEndpointSubnet.outputs.id
//     privateLinkServiceId: formRecognizer.outputs.id
//     privateLinkServiceGroupIds: ['account']
//     dnsZoneName: 'cognitiveservices.azure.com'
//     linkVnetId: vnet.outputs.id
//     isPrivateNetworkEnabled: isPrivateNetworkEnabled
//   }
//   dependsOn: [
//     privateEndpointSubnet
//   ]
// }

module storagePrivateEndopoint 'core/network/privateEndpoint.bicep' = {
  name: 'storage-private-endpoint'
  scope: resourceGroup
  params: {
    location: privateEndpointLocation
    name: storage.outputs.name
    subnetId: privateEndpointSubnet.outputs.id
    privateLinkServiceId: storage.outputs.id
    privateLinkServiceGroupIds: ['Blob']
    dnsZoneName: 'blob.core.windows.net'
    linkVnetId: vnet.outputs.id
    isPrivateNetworkEnabled: isPrivateNetworkEnabled
  }
  dependsOn: [
    privateEndpointSubnet
  ]
}

module searchServicePrivateEndopoint 'core/network/privateEndpoint.bicep' = {
  name: 'search-service-private-endpoint'
  scope: resourceGroup
  params: {
    location: privateEndpointLocation
    name: searchService.outputs.name
    subnetId: privateEndpointSubnet.outputs.id
    privateLinkServiceId: searchService.outputs.id
    privateLinkServiceGroupIds: ['searchService']
    dnsZoneName: 'search.windows.net'
    linkVnetId: vnet.outputs.id
    isPrivateNetworkEnabled: isPrivateNetworkEnabled
  }
  dependsOn: [
    privateEndpointSubnet
  ]
}

// ================================================================================================
// USER ROLES
// ================================================================================================
module openAiRoleUser 'core/security/role.bicep' = {
  scope: openAiResourceGroup
  name: 'openai-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    principalType: 'User'
  }
}

// module formRecognizerRoleUser 'core/security/role.bicep' = {
//   scope: formRecognizerResourceGroup
//   name: 'formrecognizer-role-user'
//   params: {
//     principalId: principalId
//     roleDefinitionId: 'a97b65f3-24c7-4388-baec-2e87135dc908'
//     principalType: 'User'
//   }
// }

module storageRoleUser 'core/security/role.bicep' = {
  scope: storageResourceGroup
  name: 'storage-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
    principalType: 'User'
  }
}

module storageContribRoleUser 'core/security/role.bicep' = {
  scope: storageResourceGroup
  name: 'storage-contribrole-user'
  params: {
    principalId: principalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: 'User'
  }
}

module searchRoleUser 'core/security/role.bicep' = {
  scope: searchServiceResourceGroup
  name: 'search-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
    principalType: 'User'
  }
}

module searchContribRoleUser 'core/security/role.bicep' = {
  scope: searchServiceResourceGroup
  name: 'search-contrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
    principalType: 'User'
  }
}

// ================================================================================================
// SYSTEM IDENTITIES
// ================================================================================================
module openAiRoleBackend 'core/security/role.bicep' = {
  scope: openAiResourceGroup
  name: 'openai-role-backend'
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    principalType: 'ServicePrincipal'
  }
}

module storageRoleBackend 'core/security/role.bicep' = {
  scope: storageResourceGroup
  name: 'storage-role-backend'
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
    principalType: 'ServicePrincipal'
  }
}

module storageRoleSearch 'core/security/role.bicep' = {
  scope: storageResourceGroup
  name: 'storage-role-search'
  params: {
    principalId: searchService.outputs.identityPrincipalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: 'ServicePrincipal'
  }
}

module searchRoleBackend 'core/security/role.bicep' = {
  scope: searchServiceResourceGroup
  name: 'search-role-backend'
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
    principalType: 'ServicePrincipal'
  }
}

// output AZURE_FORMRECOGNIZER_SERVICE string = formRecognizer.outputs.name
// output AZURE_FORMRECOGNIZER_RESOURCE_GROUP string = formRecognizerResourceGroup.name

output AZURE_SEARCH_SERVICE string = searchService.outputs.name
output AZURE_SEARCH_ENDPOINT string = searchService.outputs.endpoint

output AZURE_STORAGE_ACCOUNT string = storage.outputs.name
output AZURE_STORAGE_CONTAINER string = storageContainerName
output AZURE_STORAGE_RESOURCE_GROUP string = storageResourceGroup.name

output AZURE_COSMOSDB_ENDPOINT string = cosmosDb.outputs.endpoint
output AZURE_COSMOSDB_DATABASE string = cosmosDb.outputs.databaseName
output AZURE_COSMOSDB_CONTAINER string = cosmosDb.outputs.containerName
output AZURE_COSMOSDB_STRING string = cosmosDbString
output AZURE_COSMOSDB_KEY string = cosmosDbKey
output AZURE_COSMOSDB_ACCOUNT string = cosmosDb.outputs.accountName
output AZURE_COSMOSDB_RESOURCE_GROUP string = resourceGroup.name

output AZURE_APP_BACKEND_IDENTITY_PRINCIPAL_ID string = backend.outputs.identityPrincipalId
output AZURE_APP_BACKEND_SLOT_IDENTITY_PRINCIPAL_ID string = backend.outputs.slotIdentityPrincipalId
output APP_BACKEND_URI string = backend.outputs.uri
output APP_BACKEND_SLOT_URI string = backend.outputs.slotUri

output AZURE_APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output AZURE_APPLICATIONINSIGHTS_INSTRUMENTATION_KEY string = monitoring.outputs.applicationInsightsInstrumentationKey
