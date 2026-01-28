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

:: Check if DLL exists
if not exist "%DLL_PATH%" (
    echo ERROR: HeicToPng.dll not found at:
    echo %DLL_PATH%
    echo.
    echo Please build the solution in Release x64 mode first.
    pause
    exit /b 1
)

echo Installing HeicToPng Shell Extension...
echo.

:: Use regasm to register the COM server
:: Try .NET Framework 4.x regasm first (64-bit)
set "REGASM64=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\regasm.exe"

if exist "%REGASM64%" (
    echo Using 64-bit regasm...
    "%REGASM64%" /codebase "%DLL_PATH%"
    if %errorlevel% neq 0 (
        echo Registration failed.
        pause
        exit /b 1
    )
) else (
    echo ERROR: Could not find regasm.exe
    echo Please ensure .NET Framework 4.x is installed.
    pause
    exit /b 1
)

echo.
echo Installation complete!
echo.
echo NOTE: You may need to restart Windows Explorer or log out and back in
echo for the context menu to appear.
echo.
echo To restart Explorer now, press any key...
pause >nul

taskkill /f /im explorer.exe
start explorer.exe

echo Explorer restarted. The "Convert to PNG" option should now appear
echo when you right-click on .heic or .heif files.
pause
