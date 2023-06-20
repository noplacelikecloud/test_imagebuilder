/*
  * This is a Bicep file for deploying a VM Image to a Shared Image Gallery using Azure Image Builder

  * Author: Bernhard Fluer
  * Date: 2023-06-13
  * Version: 1.0.0

  * Company: Axians ICT Austria GmbH
  * Website: https://www.axians.at
  * All rights reserved
*/

//
//PARAMETER DECLARATION
//

@description('Name of the Image to be created')
param par_NameOfImage string
@description('Location of the Image to be created')
param par_Location string

@description('Deploy Shared Image Gallery')
param par_deploySharedImageGallery bool = true
@description('Name of the Shared Image Gallery')
param par_sharedImageGalleryName string = 'sig${par_NameOfImage}'

//
//VARIABLE DECLARATION
//

#disable-next-line no-hardcoded-env-urls //is a Blob URL
var var_BackgroundImage = 'https://raw.githubusercontent.com/noplacelikecloud/test_imagebuilder/master/source/Teams_Backgrounds_1920x1080px_BigData.jpg'

#disable-next-line no-hardcoded-env-urls //is a Blob URL
var var_ScriptLockscreenWallpaper = 'https://raw.githubusercontent.com/noplacelikecloud/test_imagebuilder/master/source/Set-LockWallpaper.ps1'

var var_sourceImage = {
  type: 'PlatformImage'
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2022-Datacenter'
  version: 'latest'
}

var var_sigImageIdentifier = {
  publisher: 'NoPlaceLikeCloud'
  offer: 'VMImage'
  sku: par_NameOfImage
}

//
//DEPLOYMENT
//

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'uaid_${par_NameOfImage}'
  location: par_Location
}

module SIGDeployment 'modules/SIG.bicep' = {
  name: 'deploy-SIG'
  params: {
    sigName: par_sharedImageGalleryName
    sigLocation: par_Location
    sigExists: !par_deploySharedImageGallery
    sigImageName: par_NameOfImage
    uaidPrincipalId: managedIdentity.properties.principalId
    sigImageIdentifier: var_sigImageIdentifier
  }
}

module vnet 'modules/vNet.bicep' = {
  name: 'deploy-VNET'
  params: {
    imageName: par_NameOfImage
    location: par_Location
    vnetPrefix: '10.0.0.0/28'
    subnetPrefix: '10.0.0.0/28'
    uaidId: managedIdentity.properties.principalId
  }
}


resource res_Image 'Microsoft.VirtualMachineImages/imageTemplates@2022-07-01' = {
  name: par_NameOfImage
  location: par_Location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    source: var_sourceImage
    customize: [
      {
        name: 'Install Windows Updates'
        type: 'WindowsUpdate'
      }
      {
        name: 'Restart after Windows Updates'
        type: 'WindowsRestart'
      }
      {
        name: 'Create Working Dir for AIB'
        type: 'PowerShell'
        runElevated: true
        inline: [
          'New-Item -Path "C:\\AIB" -ItemType "directory"'
        ]
      }
      {
        name: 'Download Lockscreen Wallpaper'
        type: 'File'
        destination: 'C:\\AIB\\Teams_Backgrounds_1920x1080px_BigData.jpg'
        sourceUri: var_BackgroundImage
      }
      {
        name: 'Download Script for setting Wallpaper'
        type: 'File'
        destination: 'C:\\AIB\\Set-LockWallpaper.ps1'
        sourceUri: var_ScriptLockscreenWallpaper
      }
      {
        name: 'Set Lockscreen Wallpaper'
        type: 'PowerShell'
        runElevated: true
        inline: [
          'C:\\AIB\\Set-LockWallpaper.ps1 -LockScreenSource "C:\\AIB\\Teams_Backgrounds_1920x1080px_BigData.jpg" -BackgroundSource "C:\\AIB\\Teams_Backgrounds_1920x1080px_BigData.jpg"'
        ]
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: SIGDeployment.outputs.imageId
        replicationRegions: [
          'westeurope'
          'northeurope'
        ]
        runOutputName: par_NameOfImage
      }
  ]
    vmProfile: {
      vmSize: 'Standard_D2s_v3'
      vnetConfig: {
        subnetId: vnet.outputs.snetId
      }
    }
  }
}
