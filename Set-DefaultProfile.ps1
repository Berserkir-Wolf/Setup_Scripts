# --------------------------------------------------------
# Script: Set-DefaultProfile.ps1
# Author: Dyson Parkes, ClarityIT
# Date: 17/04/2025 09:00:00
# Keywords: Configuration Scripts
# Comments: 
# Description: This script sets the default user profile for Windows 10/11
# to a specified profile. It copies the contents of the specified profile to the default user profile location.
# --------------------------------------------------------




#region Set-UserProfileName
# This function prompts the user to enter a profile name and returns it.
Set-UserProfileName{
$profilename = Read-Host "Enter the profile name you wish to copy to the default user profile (e.g. localuser)"
return $profilename
}
#endregion
#region Test-UserProfileName
# This function checks if the specified profile name exists in the C:\Users directory.
Test-UserProfileName($profilename){
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
#region Main Script
$profilename = Set-UserProfileName
If (Test-UserProfileName($profilename)) {
    #Do the things
} else {
    Write-Host "Profile does not exist: $profilename"
    Write-Host "Please check the profile name and try again."
    Set-UserProfileName
}




#region Select Profile
Get-Userprofile($profilename)
#endregion
#region Confirm Profile exists
Write-Host "You have selected the profile: $userprofile"
$profileexists = (Test-Path "C:\Users\$userprofile" -ErrorAction SilentlyContinue)
if ($profileexists) {
    $confirm = Read-Host "Profile exists. Do you want to continue? (Y/N)"
#    if ($confirm -eq 'N') {
#        Write-Host "Script cancelled."
#        exit
#    } elseif ($confirm -ne 'Y') {
#        Write-Host "Invalid input. Exiting script."
#        exit
    }
    else {
        Write-Host "Continuing with profile: $userprofile"
    }
elseif !($?) {
    Write-Host "Profile does not exist. Please check the profile name and try again."
}

else {
    Write-Host "An error has occurred. Please try again."
}
#endregion

#region Get-UserProfile
Function Get-Userprofile{
    param(
        [string]$profileName
    )
    $profilePath = "C:\Users\$profileName"
    if (Test-Path $profilePath) {
        return $profilePath
    } else {
        Write-Host "Profile not found: $profilePath"
        return $null
    }
}
#endregion

set PROFILE=
choice /c 12
if errorlevel 3 set PROFILE=localuser
if errorlevel 2 goto enderror

if not exist “C:\Users%PROFILE%” echo ERROR - The Selected Profile Does Not Exist! && goto enderror

:confirmprofile
cls
echo / / / / / / / / / / / / / / / / / / / / / / / / / / / /
echo Win8 Profile Copy Script
echo / / / / / / / / / / / / / / / / / / / / / / / / / / / /
echo Copy C:\Users%PROFILE%\ to C:\Users\Default\ ?
echo.
choice /c YN
if errorlevel 2 goto enderror
if errorlevel 1 goto backupdefaultprofile

:backupdefaultprofile
attrib -h “C:\Users\Default”
if exist “C:\Users\Default_Backup” rmdir /s /q “C:\Users\Default_Backup”
ping 127.0.0.1 -n 6 -w 1000 > nul
if exist “C:\Users\Default_Backup” rmdir /s /q “C:\Users\Default_Backup”
ping 127.0.0.1 -n 6 -w 1000 > nul
if exist “C:\Users\Default_Backup” echo ERROR - Removal of old Backup Folder Failed! && goto enderror
rename “C:\Users\Default” “Default_Backup”
if not exist “C:\Users\Default_Backup” echo ERROR - Backup Failed! && goto enderror
echo.
echo Existing Default Profile Successfully Backed Up
echo.
ping 127.0.0.1 -n 6 -w 1000 > nul

:copyinstallerprofile
md “C:\Users\Default”
xcopy "C:\Users%PROFILE%*." “C:\Users\Default” /e /c /h /k /y
if exist “C:\Users\Default\AppData\Local\Packages” rmdir /s /q “C:\Users\Default\AppData\Local\Packages”
if exist “C:\Users\Default\AppData\Local\microsoft\Windows\Temporary Internet Files” rmdir /s /q “C:\Users\Default\AppData\Local\microsoft\Windows\Temporary Internet Files”
if exist “C:\Users\Default\AppData\Local\Temp” Del /s /q “C:\Users\Default\AppData\Local\temp”*.
if exist “C:\Users\Default\AppData\Local\microsoft\Windows\UsrClass.dat” del /s /q /aa “C:\Users\Default\AppData\Local\microsoft\Windows\UsrClass.dat”
:end
echo.
echo Script Completed Successfully . . .
echo.
pause
goto endnow

:enderror
echo.
echo Script Terminated with Errors . . .
echo.
pause
goto endnow

:endnow
exit