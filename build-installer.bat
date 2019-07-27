@echo off
setlocal

REM --- NSIS subfolder must be present!  Get NSIS from http://nsis.sourceforge.net/Download
REM https://sourceforge.net/projects/nsis/files/NSIS%203/3.04/nsis-3.04.zip/download

REM --- NSIS version
set NSISV=nsis-3.04

SET ARCH=x86_64
set OURPATH=%cd%
set CYGPATH=%OURPATH%\Borg-installer

IF EXIST "C:\Program Files (x86)\NSIS" (
    set MAKENSIS="C:\Program Files (x86)\NSIS\makensis.exe"
) ELSE (
    IF NOT EXIST "%OURPATH%\%NSISV%" GOTO ERROR
    set MAKENSIS="%OURPATH%\%NSISV%\makensis.exe"
)


REM --- Automatic Borg version check
REM --- Can't use pipe directly in command, workaround with temp file
cd %CYGPATH%
bin\bash --login -c 'borg -V' > borg-version
bin\bash --login -c 'cut -d " " -f 2 /borg-version'
FOR /F "tokens=*" %%a in ('bin\bash --login -c 'cut -d " " -f 2 /borg-version'') do SET BVERSION=%%a
bin\bash --login -c 'rm /borg-version'
cd %OURPATH%

%MAKENSIS% /DARCH=%ARCH% /DVERSION=%BVERSION% /V4 nsis-installer.nsi

goto :EOF


:ERROR
echo Error missing %NSISV% in folder
exit

