@echo off
REM ===================================================
REM Master Start Script - Start All Launcher Scripts
REM ===================================================
REM This is a quick-access script to start all scripts
REM Uses master_launcher.vbs /start under the hood

title Starting All Scripts...

set "SCRIPT_DIR=%~dp0"

REM Run the master launcher in start mode silently
cscript.exe //nologo "%SCRIPT_DIR%master_launcher.vbs" /start

REM Show completion message
echo.
echo All scripts started successfully!
echo Check launcher.log for details.
echo.
timeout /t 3 >nul
