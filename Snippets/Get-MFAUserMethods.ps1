# --------------------------------------------------------
# Script:Get-MFAUserMethods.ps1
# Author: Dyson Parkes, ClarityIT
# Date: 30/05/2025 14:00:00
# Keywords: Information Gathering
# Comments: 
# Description: This script queries Microsoft Graph to confirm what MFA methods
# each user in the connected Azure Tenant has active.
# --------------------------------------------------------
<#
.SYNOPSIS
    This script queries Microsoft Graph to retrieve all users and their Multi-Factor Authentication (MFA) methods.
.NOTES
    This script requires the Microsoft.Graph.Users and Microsoft.Graph.Authentication modules to be installed.
#>
# Specify the location for the CSV file to export MFA methods
[Parameter(Mandatory=$false, HelpMessage="Where do you want to export the MFA Methods to?")][string]$CSVFile = "C:\tools\MFAUsers_$LogDate.csv"

# Ensure the Microsoft Graph Users PowerShell module is installed and imported
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Users)) {
    Write-Host "Microsoft Graph PowerShell module is not installed. Installing now..."
    Install-Module -Name Microsoft.Graph.Users -Scope CurrentUser -Force -AllowClobber
    Import-Module Microsoft.Graph.Users
} else {
    Import-Module Microsoft.Graph.Users
}
# Ensure the Microsoft Graph Authentication PowerShell module is installed and imported
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
    Write-Host "Microsoft Graph Authentication PowerShell module is not installed. Installing now..."
    Install-Module -Name Microsoft.Graph.Authentication -Scope CurrentUser -Force -AllowClobber
    Import-Module Microsoft.Graph.Authentication
} else {
    Import-Module Microsoft.Graph.Authentication
}

# Connect to Microsoft Graph with necessary scopes
Connect-MgGraph -Scopes "User.Read.All", "UserAuthenticationMethod.Read.All" -NoWelcome

# Create variable for the date stamp
$LogDate = Get-Date -Date ([DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")) -Format "yyyyMMddHHmm"

# Check if the CSV file already exists and remove it if it does
If (Test-Path -Path $CSVFile) { Remove-Item -Path $CSVFile -Force}

# Get all Microsoft Entra ID users
$users = Get-MgUser -All

foreach ($user in $users) {
    $MFAMethods = Get-MgUserAuthenticationMethod -UserId $user.id
    [System.Collections.ArrayList]$MFAMethodCollection = $user.DisplayName, $user.mail
    foreach($key in $MFAMethods.AdditionalProperties.keys){
        $MFAMethodCollection.add([string]$MFAMethods.AdditionalProperties.$key)
    }
    [string]$Entry = $MFAMethodCollection -join ","
    $MFAMethodCollection.Clear()
    write-host $Entry

    Add-Content -path $CSVFile -Value $Entry
}