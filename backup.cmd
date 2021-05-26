@echo off
setlocal enableDelayedExpansion 
set adb=%~dp0tools\adb\adb.exe

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

:selectoption
cls
cd %device%\
echo Current device: %device%
set /p id="Enter the desired option. Available ones: backup, restore, fullbackup, fullrestore. "
goto %id%
if %ERRORLEVEL% == 1 ( goto error )

:error
echo An error has occured. Exiting.
pause>nul
exit

:finish
echo Done! Press a key to exit.
pause>nul
exit

:backup
echo Pulling DCIM...
%adb% -s %device% pull /sdcard/DCIM .
echo Pulling Downloads...
%adb% -s %device% pull /sdcard/Download .
echo Pulling Docs...
%adb% -s %device% pull /sdcard/Documents .
echo Pulling Pictures...
%adb% -s %device% pull /sdcard/Pictures .
echo Pulling Whatsapp...
%adb% -s %device% pull /sdcard/Whatsapp .
echo Finishing...
%adb% -s %device% pull /sdcard/Movies .
goto finish

:restore
echo Pushing DCIM...
%adb% -s %device% push DCIM /sdcard/
echo Pushing Downloads...
%adb% -s %device% push Download /sdcard/
echo Pushing Docs...
%adb% -s %device% push Documents /sdcard/
echo Pushing Pictures...
%adb% -s %device% push Pictures /sdcard/
echo Pushing Whatsapp...
%adb% -s %device% push Whatsapp /sdcard/
echo Finishing...
%adb% -s %device% push Movies /sdcard/
goto finish

:fullbackup
for /F %%x in ('%adb% -s %device% shell ls /sdcard') do (
  if "%%x" NEQ "Android" (
    echo Pulling %%x...
    %adb% -s %device% pull /sdcard/%%x .
  ) ELSE (
    echo Skipping Android folder
  )
  if %ERRORLEVEL% == 1 ( goto error )
)
goto finish

:fullrestore
for /F %%x in ('dir /B/D %~dp0') do (
  if "%%x" NEQ "adb" (
    echo Pushing %%x...
    %adb% -s %device% push %%x /sdcard/ 
  ) ELSE (
    echo Skipping adb folder
  )
  if %ERRORLEVEL% == 1 ( goto error )
)
goto finish