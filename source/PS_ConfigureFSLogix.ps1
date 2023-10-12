param(
    [String]$StorageAccountPath
)

New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'DeleteLocalProfileWhenVHDShouldApply' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'Enabled' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'IsDynamic' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'FlipFlopProfileDirectoryName' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'KeepLocalDir' -Value 0 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'OutlookCachedMode' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'ProfileType' -Value 0 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'RemoveOrphanedOSTFilesOnLogoff' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'RoamSearch' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'SIDDirNameMatch' -Value "%username%%sid%"
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'SIDDirNamePattern' -Value "%username%%sid%"
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'VHDNameMatch' -Value "Profile_%username%"
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'VHDNamePattern' -Value "Profile_%username%"
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'VHDLocations' -Value $StorageAccountPath
New-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'VolumeType' -Value "vhdx"

## ODFC
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'VHDLocations' -Value $StorageAccountPath
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'SIDDirNameMatch' -Value "%username%%sid%"
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'SIDDirNamePattern' -Value "%username%%sid%"
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'VHDNameMatch' -Value "Profile_M365_%username%"
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'VHDNamePattern' -Value "Profile_M365_%username%"
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'Enabled' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'IncludeOfficeActivation' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'IncludeOneDrive' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'IncludeOneNote' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'IncludeOutlook' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'IncludeOutlookPersonalization' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'IncludeTeams' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'IsDynamic' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'OutlookCachedMode' -Value 1 -PropertyType DWORD
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name 'PreventLoginWithTempProfile' -Value 1 -PropertyType DWORD

New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters' -Name 'CloudKerberosTicketRetrievalEnabled' -Value 1 -PropertyType DWORD