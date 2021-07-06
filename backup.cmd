:: Giovix92 was here, 06/07/2021
@echo off
title Backup Script
setlocal enableDelayedExpansion enableExtensions
set adbsync=%~dp0tools\adbsync.exe
set adb=%~dp0tools\adb\adb.exe

:: Editable vars
set "device_list=DCIM Download Documents Pictures WhatsApp Movies Migrate"

:: Init
title Backup Script - Init
%adb% devices
set /p device="Enter here your device's serial number: "
if NOT exist "%device%\" ( goto makeafolder ) ELSE ( goto selectoption )

:makeafolder
echo The folder for this device doesn't exist! 
echo Please refrain from using restore/fullrestore options.
echo Making one...
mkdir %device%\
echo Press a key to continue.
pause>nul
goto selectoption

:: Selection and error-checks
:selectoption
cls
echo Current device: %device%
set /p id="Enter the desired option. Available ones: backup, restore, fullbackup, fullrestore. "
goto %id%
if %ERRORLEVEL% == 1 ( goto error )

:error
echo An error has occured. Exiting.
pause>nul
exit

:finish
echo.
echo Done! Press a key to exit.
pause>nul
exit

:: Preparations
:prep
title Backup Script - Preparations
echo Preparing the env...
for /F %%x in ('%adb% -s %device% shell ls -A /sdcard') do (
	%adb% -s %device% shell touch /sdcard/%%x/.noadbsync >nul
)
for %%y in (%device_list%) do (
	%adb% -s %device% shell rm -f /sdcard/%%y/.noadbsync >nul
	if "%%y" EQU "WhatsApp" (
		%adb% -s %device% shell rm -f /sdcard/Android/.noadbsync
		%adb% -s %device% shell touch /sdcard/Android/data/.noadbsync
		%adb% -s %device% shell touch /sdcard/Android/obb/.noadbsync
	)
)
echo Prep done, switching to %id% option...
timeout /T 5 >nul
cls
EXIT /B

:: Main functions
:backup
title Backup Script - Selective Backup
call :prep
echo Backing up!
%adbsync% /d%device% /hscu /s /v "%device%\" "/storage/emulated/0"
goto finish

:restore
title Backup Script - Selective Restore
call :prep
echo Restoring your data onto your phone!
%adbsync% /d%device% /ascu /s /v "%device%\" "/storage/emulated/0"
goto finish

:fullbackup
title Backup Script - Full Backup
for /F %%x in ('%adb% -s %device% shell ls /sdcard') do (
	if "%%x" NEQ "Android" (
    	echo Pulling %%x...
    	%adb% -s %device% pull /sdcard/%%x .
  	) ELSE (
    	echo Skipping Android folder BUT backing up Whatsapp folder
    	mkdir Android\media\com.whatsapp\WhatsApp
    	%adb% -s %device% pull /sdcard/Android/media/com.whatsapp/WhatsApp Android\media\com.whatsapp\WhatsApp
  	)
  	if %ERRORLEVEL% == 1 ( goto error )
)
goto finish

:fullrestore
title Backup Script - Full Restore
for /F %%x in ('dir /B/D %~dp0') do (
  	echo Pushing %%x...
  	%adb% -s %device% push %%x /sdcard/
  	if %ERRORLEVEL% == 1 ( goto error )
)
goto finish
endlocal