REM WIRELESS PROFILE IMPORTER
REM WRITTEN BY DYSON PARKES
REM BERSERKIR-NET
REM 15/09/2015
@ECHO OFF
CLS

@ECHO We are going to import all the profiles contained in this folder!
@ECHO If you have not yet exported the profiles you want to keep
@ECHO (from the source computer)
@ECHO using the ExportAll script, please do so before running this script.
SET /P ANSWER=Do you want to continue (Y/N)?

IF /i {%ANSWER%}=={y} (GOTO:YES)
IF /i {%ANSWER%}=={yes} (GOTO:YES)
GOTO:NO

:YES
FORFILES /M *.xml /C "cmd /c netsh wlan add profile @path"
@ECHO Done!
PAUSE
EXIT /b 0

:NO
@ECHO Bye!
PAUSE
EXIT /b 1