@echo off

REM --- Need version at first parameter
if "%~1"=="" GOTO ERROR

set CYGSETUP=%1
set TARGETPATH=.
set POWERSHELL=%windir%\System32\WindowsPowerShell\v1.0\powershell.exe

REM --- Fetch Cygwin setup from internet using powershell

"%POWERSHELL%" -Command "(New-Object Net.WebClient).DownloadFile('https://cygwin.com/%CYGSETUP%', '%CYGSETUP%')"

REM --- Install build version of CygWin in a subfolder
echo Install build version of Cygwin...
set OURPATH=%cd%
set CYGBUILD=%OURPATH%\CygWin
set CYGMIRROR=http://mirrors.kernel.org/sourceware/cygwin/
set BUILDPKGS=python3,python3-devel,binutils,gcc-g++,libssl,libssl-devel,git,make,openssh,liblz4-devel,liblz4_1,libzstd1,libzstd-devel,libcrypt-devel

%CYGSETUP% -q -B -o -n -g -R %CYGBUILD% -L -D -l %OURPATH% -s %CYGMIRROR% -P %BUILDPKGS%

REM --- Build borgbackup

cd %CYGBUILD%
bin\bash --login -c 'easy_install-3.6 pip'
bin\bash --login -c 'pip install -U pip'
bin\bash --login -c 'pip install -U borgbackup borgmatic'
cd %OURPATH%

REM --- Install release version of CygWin in a subfolder
echo Install release version of Cygwin...
set CYGPATH=%OURPATH%\Borg-installer
del /s /q %CYGPATH% >nul
set INSTALLPKGS=python3,openssh,python3-setuptools,liblz4_1,libzstd1,gcc-core,libssl,libcrypt2
set REMOVEPKGS=csih,gawk,lynx,man-db,groff,vim-minimal,tzcode,ncurses,info,util-linux

%CYGSETUP% -q -B -o -n -L -R %CYGPATH% -l %OURPATH% -P %INSTALLPKGS% -x %REMOVEPKGS%

REM --- Adjust final CygWin environment

echo @"%TARGETPATH%\bin\bash" --login -c "cd $(cygpath '%cd%'); /bin/borg %%*" >%CYGPATH%\borg.bat
copy nsswitch.conf %CYGPATH%\etc\
copy fstab %CYGPATH%\etc\

REM --- Copy built packages into release path

cd %CYGBUILD%

copy bin\borg %CYGPATH%\bin
copy bin\borgmatic %CYGPATH%\bin
for /d %%d in (lib\python3.6\site-packages) do xcopy /s /y %%d %CYGPATH%\%%d\

REM --- Remove all locales except EN (borg does not use them)
del /s /q %CYGPATH%\usr\share\locale\ >nul
for /d %%d in (usr\share\locale\en*) do xcopy /s /y %%d %CYGPATH%\%%d\

REM --- Remove all documentation
echo Remove all documentation...
del /s /q %CYGPATH%\usr\share\doc\ >nul
del /s /q %CYGPATH%\usr\share\info\ >nul
del /s /q %CYGPATH%\usr\share\man\ >nul

REM --- Remove gcc libs (gcc is installed only for ldconfig support)
echo Remove gcc libs...
del /s /q %CYGPATH%\lib\gcc >nul
del /s /q %CYGPATH%\lib\w32api >nul
del /s /q %CYGPATH%\usr\include\w32api >nul

REM --- Remove extra files
echo Remove extra files...
del /s /q %CYGPATH%\*.h >nul
del /s /q %CYGPATH%\var\log >nul
del /s /q %CYGPATH%\var\cache >nul
del /s /q %CYGPATH%\lib\groff >nul
del /s /q %CYGPATH%\usr\share\groff >nul

cd %OURPATH%

echo "Cygwin Setup Done!"

goto :EOF

:ERROR
echo Don't launch this script use build32.bat or build64.bat instead
pause
exit