REM WIRELESS PROFILE EXPORTER
REM WRITTEN BY DYSON PARKES
REM BERSERKIR-NET
REM 15/09/2015
@ECHO OFF
CLS

@ECHO We are going to export all the profiles contained on this computer!
@ECHO This will save the wireless profiles to this folder in .xml format.
@ECHO To import them to another computer, you can use the ImportAll script.
SET /P ANSWER=Do you want to continue (Y/N)?

IF /i {%ANSWER%}=={y} (GOTO:YES)
IF /i {%ANSWER%}=={yes} (GOTO:YES)
GOTO:NO

:YES
NETSH WLAN EXPORT PROFILE KEY=CLEAR
@ECHO Done!
PAUSE
EXIT /b 0

:NO
@ECHO Bye!
PAUSE
EXIT /b 1