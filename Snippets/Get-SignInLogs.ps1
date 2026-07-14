# Get all sign-in logs from Microsoft Graph API and select relevant properties for display.
# The selected properties include:
# - User display name
# - User principal name
# - Creation date and time of the sign-in event
# - Client application used
# - Device ID
# - Device name
# - Operating system
# - Browser
# - Whether the device is managed
Get-MgAuditLogSignIn | Select-Object userDisplayName, userPrincipalName, createdDateTime, clientAppUsed, @{n='DeviceID'; e={$_.deviceDetail.DeviceId}}, @{n='DeviceName'; e={$_.deviceDetail.DisplayName}}, @{n='OS'; e={$_.deviceDetail.operatingSystem}}, @{n='Browser'; e={$_.deviceDetail.browser}}, @{n='IsManaged'; e={$_.deviceDetail.isManaged}}

# Get all users and their last login date from Microsoft Graph API and select relevant properties for display.
Import-Module Microsoft.Graph.Users
Connect-MgGraph -Scopes "AuditLog.Read.All", "User.Read.All"
$Properties = @('DisplayName', 'UserPrincipalName', 'SignInActivity')
$AllUsers = Get-MgUser -All -Property $Properties
$AllUsers | ForEach-Object {
   $LastLoginDate = $_.SignInActivity.LastSignInDateTime
   $_ | Add-Member -MemberType NoteProperty -Name LastLoginDate -Value $LastLoginDate -Force
}
$AllUsers | Format-Table DisplayName, LastLoginDate