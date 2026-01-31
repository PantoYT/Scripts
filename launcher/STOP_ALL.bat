@echo off
title Stop All Scripts
color 0C

echo.
echo ====================================================
echo   STOPPING ALL SCRIPTS
echo ====================================================
echo.

set "SCRIPT_DIR=%~dp0"
cscript.exe //nologo "%SCRIPT_DIR%master_launcher.vbs" /stop

echo.
echo ====================================================
pause
