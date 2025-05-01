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

<#
.SYNOPSIS
    This script sets the default user profile for Windows 10/11 to a specified profile.
    It copies the contents of the specified profile to the default user profile location.
.NOTES
    This script is designed to be run with administrative privileges.
    It is recommended to run it in a PowerShell session with elevated permissions.
.PARAMETER profilename
    The name of the profile to copy to the default user profile.
    If not provided, the script will prompt for a profile name.

#>
parameter(
    [Parameter(Mandatory=$false, HelpMessage="What profile do you want to copy to the default user profile?")][string]$profilename
)

#region Main Script
if($profilename)
{
    Write-Host "Profile name provided: $profilename"
} else {
    $profilename = Set-UserProfileName
}
If (Test-UserProfileName($profilename)) {
    Backup-DefaultProfile
    Write-Host $result
    Copy-DefaultProfile($profilename)
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
    If(Test-Path "C:\Users\Default_Backup" -ErrorAction SilentlyContinue){
        Write-Host "Previous backup already exists, updating backup."
        Remove-Item -Path "C:\Users\Default_Backup" -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "C:\Users\Default" -Destination "C:\Users\Default_Backup" -Recurse -Force
        Write-Host "Backup completed."
        $result = "Backup updated."
    } else {
        Write-Host "Backing up default profile..."
        Copy-Item -Path "C:\Users\Default" -Destination "C:\Users\Default_Backup" -Recurse -Force
        Write-Host "Backup completed."
        $result = "Backup created."
    }
    return $result
}
#endregion
#region Copy-DefaultProfile
function Copy-DefaultProfile {
    param (
        [string]$profilename
    )
    Write-Host "Copying profile $profilename to default profile..."
    #xcopy /e (include empty)
    #xcopy /c (continue on error) DONE
    #xcopy /h (include hidden and system)
    #xcopy /k (include attributes)
    #xcopy /y (suppress prompting) DONE
    Copy-Item -Path "C:\Users\$profilename" -Destination "C:\Users\Default" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Profile copied successfully."
}
#endregion Functions