# --------------------------------------------------------
# Script: Match-EntraAD.ps1
# Author: Dyson Parkes, ClarityIT
# Date: 12/05/2025 09:00:00
# Keywords: Configuration Scripts
# Comments: 
# Description: This script matches the Entra ID with the local Active Directory.
# It ensures that the local Active Directory user accounts are in sync with the Entra ID.
# --------------------------------------------------------
<#
.SYNOPSIS
    This script takes the ImmutableId of local AD objects and attaches them to the matching object in Entra ID.
    .NOTES
    This script requires the Microsoft.Graph.Users and ActiveDirectory modules to be installed.
#>
# Specify the additional UPN suffix to be added to local AD
[Parameter(Mandatory=$false, HelpMessage="What UPN suffix do you want to add to local AD?")][string]$upn
[Parameter(Mandatory=$true, HelpMessage="What OU do you want to search for local AD users? (ie OU=Users_Staff, DC=domain,DC=local)")][string]$OU
[Parameter(Mandatory=$false, HelpMessage="Should the script only update enabled users? (true/false)")][bool]$EnabledOnly = $true
[Parameter(Mandatory=$false, HelpMessage="Where do you want to export the local AD users to?")][string]$csvpath = "C:\Testing\ImmutableIDs.txt"

#region check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrative privileges. Please run it as an administrator."
    exit
}
#endregion
#region check if the Microsoft.Graph.Users module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Users)) {
    Write-Host "Microsoft.Graph.Users module is not installed. Installing..."
    Install-Module -Name Microsoft.Graph.Users -Force -AllowClobber
    Import-Module Microsoft.Graph.Users
} else {
    Import-Module Microsoft.Graph.Users
}
#endregion
#region check if the ActiveDirectory module is installed
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "ActiveDirectory module is not installed. Installing..."
    Install-Module -Name ActiveDirectory -Force -AllowClobber
    Import-Module ActiveDirectory
} else {
    Import-Module ActiveDirectory
}
#endregion
#region check if the CSV file path exists
if (-not (Test-Path -Path $csvpath)) {
    Write-Host "CSV file path does not exist. Creating directory..."
    New-Item -ItemType Directory -Path (Split-Path -Path $csvpath) -Force
}
#endregion
#region Add UPN suffix to local AD if specified
if ($upn) {
    $localupn = (Get-ADForest).UPNSuffixes[0]
    Write-Host "Local AD UPN suffix is $localupn"
    $localAD = Get-ADForest
    $localAD | Set-ADForest -UPNSuffixes @{Add=$upn}
    Write-Host "Added UPN suffix $upn to local AD"
    Write-Host "Local AD UPN suffixes are now $($localAD.UPNSuffixes)"
    # Update local AD users with the new UPN suffix
    if ($EnabledOnly) {
        Write-Host "Updating UPN for enabled users only in OU $OU"
        $ADusers = Get-ADUser -Filter 'enabled -eq "true"' -SearchBase $OU -properties *
    } else {
        Write-Host "Updating UPN for all users in OU $OU"
        $ADusers = Get-ADUser -Filter * -SearchBase $OU -properties *
    }
    foreach ($ADuser in $ADusers) {
        $newUPN = "$($ADuser.SamAccountName)@$upn"
        Set-ADUser -Identity $ADuser -UserPrincipalName $newUPN
        Write-Host "Updated UPN for user $($ADuser.SamAccountName) to $newUPN"
    }
} else {
    Write-Host "No UPN suffix specified. Skipping UPN suffix addition."
}
#endregion
#region check if the Microsoft.Graph.Users module is installed
#region connect to Entra ID via Microsoft.Graph.Users
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All", "User.ManageIdentities.All"
if (-not (Get-MgContext)) {
    Write-Host "Failed to connect to Entra ID. Please check your credentials and try again."
    exit
} else {
    Write-Host "Connected to Entra ID successfully."
}
#endregion
# region ListLocalADUsers
# This will export all local AS Users to C:\Testing\ImmutableIDs.csv,
# to be used to match the local AD users with the Entra ID users
# The ImmutableId is the ObjectGUID of the local AD user, converted to a base64 string
# The ObjectGUID is the unique identifier for the user in local AD
# A powershell version of ldifde -f export.txt -r "(Userprincipalname=*)" -l "objectGuid, userPrincipalName"

if ($EnabledOnly) {
    Write-Host "Exporting enabled users only from OU $OU"
    Get-ADUser -Filter 'enabled -eq "true"' -SearchBase $OU -properties * | Select-Object UserPrincipalName,ObjectGUID,@{n="ImmutableID";e={[System.Convert]::ToBase64String($_.ObjectGUID.tobytearray())} },EmailAddress | Export-CSV $csvpath -NoClobber -NoTypeInformation
} else {
    Get-ADUser -Filter * -SearchBase $OU -properties * | Select-Object UserPrincipalName,ObjectGUID,@{n="ImmutableID";e={[System.Convert]::ToBase64String($_.ObjectGUID.tobytearray())} },EmailAddress | Export-CSV $csvpath -NoClobber -NoTypeInformation
}
#endregion
#region Import the CSV file
$localusers = Import-Csv $csvpath
#endregion
#region Loop through each local AD user and match it with the Entra ID user
foreach ($localuser in $localusers) {
    # Get the Entra ID user with the same UserPrincipalName
    # The UserPrincipalName is the email address of the user in Entra ID
    # Note that all users in Active Directory must have a matching email address in Entra ID
    $entrauser = Get-MgUserByUserPrincipalName -UserPrincipalName $localuser.EmailAddress
    if ($entrauser) {
        # If the Entra ID user exists, update the ImmutableId
        Write-Host "Entra ID for $($entrauser.UserPrincipalName) is $entrauser.Id"
        Set-MgUser -UserId $entrauser.Id -ImmutableId $localuser.ImmutableID
        Write-Host "Updated ImmutableId for user $($entrauser.UserPrincipalName)"
    } else {
        Write-Host "No matching Entra ID user found for local AD user $($localuser.UserPrincipalName)"
    }
}
#endregion
#region Disconnect from Entra ID
Disconnect-MgGraph
#endregion