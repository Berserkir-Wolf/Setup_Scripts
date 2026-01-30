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
    # Go through all users and add primary domain, skipping Discovery Search Mailbox
    ForEach ($user in $users) {
        if($($user.Name).StartsWith("DiscoverySearchMailbox")){
            Write-Host "Skipping $($user.Name)"
        } else {
        Write-Host "User: $($user.UserPrincipalName) - Primary SMTP: $($user.PrimarySmtpAddress)"
        Write-Host "Adding $($user.Alias)@$NewDomain to $($user.UserPrincipalName)"
        Set-Mailbox -Identity $user.UserPrincipalName -EmailAddresses @{Add="$($user.Alias)@$NewDomain"}
        Set-Mailbox -Identity $user.UserPrincipalName -PrimarySmtpAddress "$($user.Alias)@$NewDomain"
        Write-Host "Updated Primary SMTP to: $($user.Alias)@$NewDomain"
        }
    }
}
#endregion