# --------------------------------------------------------
# Script: Replace-PrimaryAddress.ps1
# Author: Dyson Parkes, ClarityIT
# Date: 30/01/2026 12:00:00
# Keywords: Exchange, Primary SMTP Address
# Version: 1.0
# Comments: 
# Description: This script replaces the primary SMTP address of all users in Exchange Online.
# --------------------------------------------------------
<#
.SYNOPSIS
    This script replaces the primary SMTP address of all users in Exchange Online.
#>
[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true, HelpMessage="What is the domain for the new primary addresses?")][string]$NewDomain = "example.com"
)

#region Import ExchangeOnlineManagement module if available, install if not
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "Exchange Online Management module is not installed. Installing..."
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
    Import-Module ExchangeOnlineManagement
} else {
    Import-Module ExchangeOnlineManagement
}
#endregion
#region Connect to Exchange Online
Connect-ExchangeOnline
#endregion
#region Check if the connection was successful and update primary SMTP addresses
if (-not (Get-ExchangeOnlineConnection)) {
    Write-Host "Failed to connect to Exchange Online. Please check your credentials and try again."
    exit
} else {
    Write-Host "Connected to Exchange Online successfully."
    Write-Host "Getting all existing users..."
    $users = Get-Mailbox -ResultSize Unlimited
    Write-Host "Retrieved $($users.Count) users."
    ForEach ($user in $users) {
        Write-Host "User: $($user.UserPrincipalName) - Primary SMTP: $($user.PrimarySmtpAddress)"
        Set-Mailbox -Identity $user.UserPrincipalName -EmailAddresses @{Add="$($user.Alias)@$NewDomain"}
        Set-Mailbox -Identity $user.UserPrincipalName -PrimarySmtpAddress "$($user.Alias)@$NewDomain"
        Write-Host "Updated Primary SMTP to: $($user.Alias)@$NewDomain"
    }
}
#endregion


Import-Csv $UserstoChange | ForEach-Object {
  $upn = $_.UserPrincipalName
  $new = $_.NewPrimarySmtpAddress
  Set-Mailbox -Identity $upn -EmailAddresses @{Add=$new}
  Set-Mailbox -Identity $upn -PrimarySmtpAddress $new
}