param sigName string
param sigExists bool
param sigLocation string
param sigImageName string

param sigImageIdentifier object

param uaidPrincipalId string


resource sharedImageGallery 'Microsoft.Compute/galleries@2020-09-30' = if(!sigExists) {
  name: sigName
  location: sigLocation
  properties: {
    description: 'SharedImageGallery for ${sigImageName}'
  }
}

resource sharedImageGalleryExisting 'Microsoft.Compute/galleries@2020-09-30' existing = if(sigExists) {
  name: sigName
}

resource sharedImageGalleryImage 'Microsoft.Compute/galleries/images@2020-09-30' = if(!sigExists) {
  parent: sharedImageGallery
  name: sigImageName
  location: sigLocation
  properties: {
    description: 'SharedImageGalleryImage for ${sigImageName}'
    osType: 'Windows'
    identifier: sigImageIdentifier
    osState: 'Generalized'
  }
}

resource sharedImageGalleryImage_ExistingSIG 'Microsoft.Compute/galleries/images@2020-09-30' = if(sigExists) {
  parent: sharedImageGalleryExisting
  name: sigImageName
  location: sigLocation
  properties: {
    description: 'SharedImageGalleryImage for ${sigImageName}'
    osType: 'Windows'
    identifier: {
      publisher: 'NoPlaceLikeCloud'
      offer: 'VMImage'
      sku: sigImageName
    }
    osState: 'Generalized'
  }
}

resource roleAssignmentSIG 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: sharedImageGallery
  name: guid(sharedImageGallery.id, uaidPrincipalId)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions','b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: uaidPrincipalId
  }
}

output imageId string = sharedImageGalleryImage.id
