param imageName string
param location string
param vnetPrefix string
param subnetPrefix string

param uaidId string

resource res_BuildVirtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'build-${imageName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
    subnets: [
      {
        name: 'ImageCreator'
        properties: {
          addressPrefix: subnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource roleAssignmentVNET 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: res_BuildVirtualNetwork
  name: guid(res_BuildVirtualNetwork.id, uaidId)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions','b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: uaidId
  }
}

output snetId string = res_BuildVirtualNetwork.properties.subnets[0].id
