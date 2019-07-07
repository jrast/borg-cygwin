@echo off
setlocal

REM --- Need cpu version at first parameter
if "%~1"=="" GOTO CPUERROR

REM --- NSIS zip must be in folder!  Get NSIS from http://nsis.sourceforge.net/Download
REM https://sourceforge.net/projects/nsis/files/NSIS%203/3.04/nsis-3.04.zip/download

REM --- NSIS version
set NSISV=nsis-3.04

set OURPATH=%cd%
set CYGPATH=%OURPATH%\Borg-installer

IF EXIST "C:\Program Files (x86)\NSIS" (
    set MAKENSIS="C:\Program Files (x86)\NSIS\makensis.exe"
) ELSE (
    IF NOT EXIST "%OURPATH%\%NSISV%.zip" GOTO ERROR
    IF NOT EXIST "%OURPATH%\%NSISV%" Call :UnZipFile "%OURPATH%" "%OURPATH%\%NSISV%.zip"
)


REM --- Automatic Borg version check
REM --- Can't use pipe directly in command, workaround with temp file
cd %CYGPATH%
bin\bash --login -c 'borg -V' > borg-version
bin\bash --login -c 'cut -d " " -f 2 /borg-version'
FOR /F "tokens=*" %%a in ('bin\bash --login -c 'cut -d " " -f 2 /borg-version'') do SET BVERSION=%%a
bin\bash --login -c 'rm /borg-version'
cd %OURPATH%

%MAKENSIS% /DARCH=%1 /DVERSION=%BVERSION% /V4 nsis-installer.nsi

goto :EOF

:UnZipFile <ExtractTo> <newzipfile>
set vbs="%temp%\_.vbs"
if exist %vbs% del /f /q %vbs%
>%vbs%  echo Set fso = CreateObject("Scripting.FileSystemObject")
>>%vbs% echo If NOT fso.FolderExists(%1) Then
>>%vbs% echo fso.CreateFolder(%1)
>>%vbs% echo End If
>>%vbs% echo set objShell = CreateObject("Shell.Application")
>>%vbs% echo set FilesInZip=objShell.NameSpace(%2).items
>>%vbs% echo objShell.NameSpace(%1).CopyHere(FilesInZip)
>>%vbs% echo Set fso = Nothing
>>%vbs% echo Set objShell = Nothing
cscript //nologo %vbs%
if exist %vbs% del /f /q %vbs%
exit /b

:ERROR
echo Error missing %NSISV%.zip in folder
exit

:CPUERROR
echo Error missing firt argument "x86" or "x86_64"
exit