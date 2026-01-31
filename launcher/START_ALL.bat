@echo off
REM ===================================================
REM Start All Scripts (Silent)
REM ===================================================

set "SCRIPT_DIR=%~dp0"
start /min cscript.exe //nologo "%SCRIPT_DIR%master_launcher.vbs" /start
exit
