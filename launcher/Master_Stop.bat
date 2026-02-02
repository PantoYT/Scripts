@echo off
REM ===================================================
REM Master Stop Script - Stop All Launcher Scripts
REM ===================================================
REM This is a quick-access script to stop all scripts
REM Uses master_launcher.vbs /stop under the hood

title Stopping All Scripts...
color 0C

echo.
echo ====================================================
echo   STOPPING ALL LAUNCHER SCRIPTS
echo ====================================================
echo.

set "SCRIPT_DIR=%~dp0"

REM Run the master launcher in stop mode
cscript.exe //nologo "%SCRIPT_DIR%master_launcher.vbs" /stop

echo.
echo ====================================================
pause
