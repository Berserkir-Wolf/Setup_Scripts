rem 00000000000000000000000000000000000000000000000000000000000000000000000000
rem SCRIPT NAME: Update Default User Profile.cmd
rem VERSION: 3.0
rem DISCRIPTION: Copies the chosen profile to the default user profile then
rem removes printers from defautl user’s registry in Windows 7.
rem Must right click script and run as administrator!
rem AUTHOR: Ben Stefan, John McFadden, Karolyn Hannam, Christine Schilling
rem DATE: 4/4/2013
rem 00000000000000000000000000000000000000000000000000000000000000000000000000

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