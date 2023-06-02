param par_NameOfImage string
param par_Location string

param par_deploySharedImageGallery bool = true
param par_sharedImageGalleryName string = 'sig_${par_NameOfImage}'

#disable-next-line no-hardcoded-env-urls //is a Blob URL
var var_BackgroundImage = 'https://axiansvdscripts.blob.core.windows.net/images/Teams_Backgrounds_1920x1080px_BigData.jpg'

#disable-next-line no-hardcoded-env-urls //is a Blob URL
var var_ScriptLockscreenWallpaper = 'https://axiansvdscripts.blob.core.windows.net/scripts/Set-LockWallpaper.ps1'


resource sharedImageGallery 'Microsoft.Compute/galleries@2020-09-30' = if(par_deploySharedImageGallery) {
  name: par_sharedImageGalleryName
  location: par_Location
  properties: {
    description: 'SharedImageGallery for ${par_NameOfImage}'
  }
}

var var_sharedImageGalleryResourceId = par_deploySharedImageGallery ? sharedImageGallery.id : resourceId('Microsoft.Compute/galleries', par_sharedImageGalleryName)

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'uaid_${par_NameOfImage}'
  location: par_Location
}

resource res_BuildVirtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'build-${par_NameOfImage}'
  location: par_Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/28'
      ]
    }
    subnets: [
      {
        name: 'ImageCreator'
        properties: {
          addressPrefix: '10.0.0.0/28'
        }
      }
    ]
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
    source: {
      type: 'PlatformImage'
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-Datacenter'
      version: 'latest'
    }
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
        name: 'Copy Lockscreen Wallpaper'
        type: 'File'
        destination: 'C:\\Windows\\Temp'
        sourceUri: var_BackgroundImage
      }
      {
        name: 'Upload Script for setting Wallpaper'
        type: 'File'
        destination: 'C:\\Windows\\Temp'
        sourceUri: var_ScriptLockscreenWallpaper
      }
      {
        name: 'Set Lockscreen Wallpaper'
        type: 'PowerShell'
        runElevated: true
        inline: [
          'C:\\Windows\\Temp\\Set-LockWallpaper.ps1 -LockScreenSource "C:\\Windows\\Temp\\Teams_Backgrounds_1920x1080px_BigData.jpg" -BackgroundSource "C:\\Windows\\Temp\\Teams_Backgrounds_1920x1080px_BigData.jpg"'
        ]
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: var_sharedImageGalleryResourceId
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
        subnetId: res_BuildVirtualNetwork.properties.subnets[0].id
      }
    }
  }
}
