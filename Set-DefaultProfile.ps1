# --------------------------------------------------------
# Script: Set-DefaultProfile.ps1
# Author: Dyson Parkes, ClarityIT
# Date: 17/04/2025 09:00:00
# Keywords: Configuration Scripts
# Comments: 
# Description: This script sets the default user profile for Windows 10/11
# to a specified profile. It copies the contents of the specified profile to the default user profile location.
# --------------------------------------------------------

#region Select Profile
Write-Host Select the profile you want to copy to the default user profile
$userprofile = Read-Host "Enter the profile name (e.g. localuser)"
#endregion

#region Confirm Profile
Write-Host "You have selected the profile: $userprofile"
Write-Host "Do you want to continue? (Y/N)"
$confirm = Read-Host "Enter Y to continue or N to cancel"
if ($confirm -eq 'N') {
    Write-Host "Script cancelled."
    exit
} elseif ($confirm -ne 'Y') {
    Write-Host "Invalid input. Exiting script."
    exit
}
#endregion

:selectprofile
cls
echo / / / / / / / / / / / / / / / / / / / / / / / / / / / /
echo Win8 Profile Copy Script
echo / / / / / / / / / / / / / / / / / / / / / / / / / / / /
echo Press 1 to continue
echo Press 2 to cancel

echo.
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