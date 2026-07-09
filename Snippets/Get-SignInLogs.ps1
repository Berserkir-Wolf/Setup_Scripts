# Get sign-in logs from Microsoft Graph API and select relevant properties for display.
#The selected properties include:
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