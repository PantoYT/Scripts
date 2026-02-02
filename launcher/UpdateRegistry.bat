@echo off
REM Update Windows Registry to use master_launcher.vbs directly with /silent mode
REM This replaces the old START_ALL.bat registry entry

setlocal enabledelayedexpansion
title Update Registry for Launcher

REM Get the full path to master_launcher.vbs
set "SCRIPT_DIR=%~dp0"
set "LAUNCHER_PATH=%SCRIPT_DIR%master_launcher.vbs"

echo.
echo ====================================================
echo Registry Updater for Script Launcher
echo ====================================================
echo.

REM Check if running as admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo.
    echo Right-click Command Prompt and select "Run as Administrator"
    pause
    exit /b 1
)

echo Updating registry entries...
echo.

REM Update HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
echo [*] Updating HKLM registry...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" ^
    /v "Script Launcher" ^
    /t REG_SZ ^
    /d "wscript.exe \"%LAUNCHER_PATH%\" /silent" ^
    /f >nul 2>&1

if errorlevel 1 (
    echo [-] Failed to update HKLM (might not have permissions - try User registry instead)
) else (
    echo [+] Updated HKLM registry
)

REM Also update HKCU for current user
echo [*] Updating HKCU registry...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" ^
    /v "Script Launcher" ^
    /t REG_SZ ^
    /d "wscript.exe \"%LAUNCHER_PATH%\" /silent" ^
    /f >nul 2>&1

if errorlevel 1 (
    echo [-] Failed to update HKCU
) else (
    echo [+] Updated HKCU registry
)

echo.
echo ====================================================
echo Registry update complete!
echo.
echo Changes made:
echo - Script Launcher will now start at boot with /silent mode
echo - All AutoStart=true scripts in config.ini will auto-start
echo - No GUI will appear (silent mode)
echo.
echo To manually start with GUI, run: master_launcher.vbs
echo To stop all: run: master_launcher.vbs /stop
echo.
pause
