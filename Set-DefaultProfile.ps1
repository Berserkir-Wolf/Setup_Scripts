# --------------------------------------------------------
# Script: Set-DefaultProfile.ps1
# Author: Dyson Parkes, ClarityIT
# Date: 17/04/2025 09:00:00
# Keywords: Configuration Scripts
# Comments: 
# Description: This script sets the default user profile for Windows 10/11
# to a specified profile. It copies the contents of the specified profile to the default user profile location.
# This script is designed to be run with administrative privileges.
# It is recommended to run it in a PowerShell session with elevated permissions.
# --------------------------------------------------------


#region Main Script
$profilename = Set-UserProfileName
If (Test-UserProfileName($profilename)) {
    Backup-DefaultProfile
    #Do the things
} else {
    Write-Host "Profile does not exist: $profilename"
    Write-Host "Please check the profile name and try again."
    Set-UserProfileName
}
#endregion

#region Functions
#region Set-UserProfileName
# This function prompts the user to enter a profile name and returns it.
function Set-UserProfileName{
$profilename = Read-Host "Enter the profile name you wish to copy to the default user profile (e.g. localuser)"
return $profilename
}
#endregion
#region Test-UserProfileName
# This function checks if the specified profile name exists in the C:\Users directory.
function Test-UserProfileName($profilename){
$profilePath = "C:\Users\$profilename"
if (Test-Path $profilePath) {
    Write-Host "Profile exists: $profilePath"
    return $true
} else {
    Write-Host "Profile does not exist: $profilePath"
    return $false
}
}
#endregion
#region Backup-DefaultProfile
function Backup-DefaultProfile {
    param (
        OptionalParameters
    )
    
}
#endregion
#endregion Functions