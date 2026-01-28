@echo off
setlocal

:: Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires Administrator privileges.
    echo Please right-click and select "Run as administrator".
    pause
    exit /b 1
)

set "SCRIPT_DIR=%~dp0"
set "DLL_PATH=%SCRIPT_DIR%HeicToPng\bin\x64\Release\HeicToPng.dll"

echo Uninstalling HeicToPng Shell Extension...
echo.

:: Use regasm to unregister the COM server
set "REGASM64=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\regasm.exe"

if exist "%REGASM64%" (
    echo Using 64-bit regasm...
    "%REGASM64%" /unregister "%DLL_PATH%"
    if %errorlevel% neq 0 (
        echo Unregistration may have failed or extension was not registered.
    )
) else (
    echo ERROR: Could not find regasm.exe
    pause
    exit /b 1
)

echo.
echo Uninstallation complete!
echo.
echo NOTE: You may need to restart Windows Explorer or log out and back in
echo for the changes to take effect.
echo.
echo To restart Explorer now, press any key...
pause >nul

taskkill /f /im explorer.exe
start explorer.exe

echo Explorer restarted.
pause
