@echo off

REM Self-hide the console window
if not defined HIDDEN (
    set HIDDEN=1
    start "" /B /MIN wscript.exe //nologo "%~dpn0.vbs"
    exit /b
)

REM Create temporary VBS to hide this script
echo Set objShell = CreateObject("WScript.Shell") > "%TEMP%\hidecmd.vbs"
echo objShell.Run "cmd /c """"%~f0"""" HIDDEN", 0, False >> "%TEMP%\hidecmd.vbs"
if not "%1"=="HIDDEN" (
    wscript.exe "%TEMP%\hidecmd.vbs"
    del "%TEMP%\hidecmd.vbs"
    exit /b
)

setlocal EnableDelayedExpansion
title USB Sync + Git Auto Push

REM ==== PREVENT SYSTEM SLEEP ====
REM Use PowerShell to prevent idle sleep during syncing
powershell -Command "Add-Type @\" using System; using System.Runtime.InteropServices; [DllImport('kernel32.dll', SetLastError = true)] public static extern uint SetThreadExecutionState(uint esFlags); public const uint ES_CONTINUOUS = 0x80000000; public const uint ES_SYSTEM_REQUIRED = 0x00000001; [SetThreadExecutionState]::Invoke([uint]($ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED)); \"@" >nul 2>&1

REM ==== CONFIG ====
set USB_DRIVE=G:

set SRC_APPS=E:\Aplikacje
set DST_APPS=G:\Pliki\Inne\Instalki

set SRC_AHK=E:\Autohotkey
set DST_AHK=G:\Pliki\Inne\AutoHotkey

set SRC_SCRIPTS=E:\Scripts
set DST_SCRIPTS=G:\Pliki\Inne\Scripts

set SRC_DB=G:\Pliki\Technik Programista\Bazy Danych
set DST_DB=E:\Pliki\Projects\databases

set SRC_CPP=G:\Pliki\Technik Programista\Programowanie\cpp
set DST_CPP=E:\Pliki\Projects\cpp

set SRC_PY=G:\Pliki\Technik Programista\Programowanie\python
set DST_PY=E:\Pliki\Projects\python

set SRC_WEB=G:\Pliki\Technik Programista\Strony internetowe
set DST_WEB=E:\Pliki\Projects\websites

set SRC_BHP=G:\Pliki\Technik Programista\BHP
set DST_BHP=E:\Pliki\Projects\BHP

set SRC_POD_INF=G:\Pliki\Technik Programista\Podstawy Informatyki
set DST_POD_INF=E:\Pliki\Projects\Podstawy informatyki

set SRC_INF=G:\Pliki\Technik Programista\Informatyka
set DST_INF=E:\Pliki\Projects\Informatyka

set SRC_PRZYGOT=G:\Pliki\Technik Programista\Przygotowanie do zawodu programisty
set DST_PRZYGOT=E:\Pliki\Projects\Przygotowanie do zawodu programisty

set GIT_ROOT=E:\Pliki\Projects

set LOGDIR=E:\Scripts\logs
set LOGFILE=%LOGDIR%\usb_sync.log

if not exist "%LOGDIR%" mkdir "%LOGDIR%"

echo ======================================= >> "%LOGFILE%"
echo START %date% %time% >> "%LOGFILE%"

:MAIN_LOOP
timeout /t 3 >nul

if not exist %USB_DRIVE%\ (
    echo [%time%] USB not present >> "%LOGFILE%"
    goto MAIN_LOOP
)

echo [%time%] USB detected >> "%LOGFILE%"

REM ==== LOCAL TO USB BACKUP (E: -> G:) - MIRROR MODE ====
echo [%time%] Syncing LOCAL to USB (MIRROR MODE - exact copy)... >> "%LOGFILE%"
robocopy "%SRC_APPS%" "%DST_APPS%" /MIR /R:3 /W:5 >> "%LOGFILE%" 2>&1
if errorlevel 8 (
    echo [%time%] ERROR: Apps sync failed >> "%LOGFILE%"
    goto MAIN_LOOP
)

robocopy "%SRC_AHK%" "%DST_AHK%" /MIR /R:3 /W:5 >> "%LOGFILE%" 2>&1
if errorlevel 8 (
    echo [%time%] ERROR: AutoHotkey sync failed >> "%LOGFILE%"
    goto MAIN_LOOP
)

robocopy "%SRC_SCRIPTS%" "%DST_SCRIPTS%" /MIR /R:3 /W:5 >> "%LOGFILE%" 2>&1
if errorlevel 8 (
    echo [%time%] ERROR: Scripts sync failed >> "%LOGFILE%"
    goto MAIN_LOOP
)

REM ==== USB TO LOCAL BACKUP (G: -> E:) - STANDARD MODE ====
echo [%time%] Syncing USB to LOCAL... >> "%LOGFILE%"
robocopy "%SRC_DB%" "%DST_DB%" /E /R:3 /W:5 >> "%LOGFILE%" 2>&1
if errorlevel 8 (
    echo [%time%] ERROR: Database sync failed >> "%LOGFILE%"
    goto MAIN_LOOP
)

robocopy "%SRC_CPP%" "%DST_CPP%" /E /R:3 /W:5 >> "%LOGFILE%" 2>&1
if errorlevel 8 (
    echo [%time%] ERROR: C++ sync failed >> "%LOGFILE%"
    goto MAIN_LOOP
)

robocopy "%SRC_PY%" "%DST_PY%" /E /R:3 /W:5 >> "%LOGFILE%" 2>&1
if errorlevel 8 (
    echo [%time%] ERROR: Python sync failed >> "%LOGFILE%"
    goto MAIN_LOOP
)

robocopy "%SRC_WEB%" "%DST_WEB%" /E /R:3 /W:5 >> "%LOGFILE%" 2>&1
if errorlevel 8 (
    echo [%time%] ERROR: Web sync failed >> "%LOGFILE%"
    goto MAIN_LOOP
)

robocopy "%SRC_BHP%" "%DST_BHP%" /E /R:3 /W:5 >> "%LOGFILE%" 2>&1
if errorlevel 8 (
    echo [%time%] ERROR: BHP sync failed >> "%LOGFILE%"
    goto MAIN_LOOP
)

robocopy "%SRC_POD_INF%" "%DST_POD_INF%" /E /R:3 /W:5 >> "%LOGFILE%" 2>&1
if errorlevel 8 (
    echo [%time%] ERROR: Podstawy Informatyki sync failed >> "%LOGFILE%"
    goto MAIN_LOOP
)

robocopy "%SRC_INF%" "%DST_INF%" /E /R:3 /W:5 >> "%LOGFILE%" 2>&1
if errorlevel 8 (
    echo [%time%] ERROR: Informatyka sync failed >> "%LOGFILE%"
    goto MAIN_LOOP
)

robocopy "%SRC_PRZYGOT%" "%DST_PRZYGOT%" /E /R:3 /W:5 >> "%LOGFILE%" 2>&1
if errorlevel 8 (
    echo [%time%] ERROR: Przygotowanie do zawodu programisty sync failed >> "%LOGFILE%"
    goto MAIN_LOOP
)

echo [%time%] All syncs completed >> "%LOGFILE%"

REM ==== GITHUB AUTO UPDATE ====
echo [%time%] Starting Git auto-sync... >> "%LOGFILE%"
call :GIT_SYNC "%GIT_ROOT%"
echo [%time%] Git auto-sync completed >> "%LOGFILE%"

REM ==== USB MONITOR - Wait for USB removal ====
echo [%time%] GitHub sync start >> "%LOGFILE%"

call :GIT_SYNC "%GIT_ROOT%"

REM ==== USB MONITOR - Wait for USB removal ====
:USB_MONITOR
timeout /t 60 >nul

if not exist %USB_DRIVE%\ (
    echo [%time%] USB removed, returning to main loop >> "%LOGFILE%"
    goto MAIN_LOOP
)

echo [%time%] USB still present, re-syncing... >> "%LOGFILE%"
goto MAIN_LOOP

:GIT_SYNC
set DIR=%~1
set RETRY_COUNT=3
set GIT_SUCCESS=0

REM Check top-level directory for .git
if exist "%DIR%\.git" (
    call :GIT_SYNC_REPO "%DIR%" 1
)

REM Check first-level subfolders for .git (klasa1, klasa2, etc)
for /d %%d in ("%DIR%\*") do (
    if exist "%%d\.git" (
        call :GIT_SYNC_REPO "%%d" 1
    )
)

exit /b

:GIT_SYNC_REPO
set REPO=%~1
set RETRY=%~2

if %RETRY% gtr %RETRY_COUNT% (
    echo [%time%] Git sync for %REPO% - gave up after %RETRY_COUNT% retries >> "%LOGFILE%"
    exit /b
)

echo [%time%] Attempting Git sync for %REPO% (attempt %RETRY%/%RETRY_COUNT%) >> "%LOGFILE%"

pushd "%REPO%"

REM Check for changes to avoid error on commit with nothing to do
git status --porcelain >nul 2>&1
if errorlevel 1 (
    echo [%time%] WARNING: Cannot check git status in %REPO% >> "%LOGFILE%"
    popd
    set /a RETRY+=1
    goto :GIT_SYNC_REPO
)

REM Add all changes
git add . >nul 2>&1
if errorlevel 1 (
    echo [%time%] WARNING: Git add failed for %REPO% >> "%LOGFILE%"
    popd
    set /a RETRY+=1
    goto :GIT_SYNC_REPO
)

REM Try to commit
git commit -m "Auto backup %date% %time%" >nul 2>&1
if errorlevel 1 (
    echo [%time%] INFO: No changes to commit in %REPO% >> "%LOGFILE%"
    popd
    exit /b
)

REM Try to push with retries
set /a PUSH_RETRY=1
:GIT_PUSH_RETRY
if %PUSH_RETRY% gtr 3 (
    echo [%time%] WARNING: Git push failed for %REPO% after 3 retries >> "%LOGFILE%"
    popd
    exit /b
)

echo [%time%] Git push attempt %PUSH_RETRY%/3 for %REPO% >> "%LOGFILE%"
git push origin --all >nul 2>&1
if errorlevel 1 (
    echo [%time%] Git push attempt %PUSH_RETRY% failed, retrying... >> "%LOGFILE%"
    timeout /t 3 >nul
    set /a PUSH_RETRY+=1
    goto :GIT_PUSH_RETRY
)

echo [%time%] SUCCESS: Git synced for %REPO% >> "%LOGFILE%"
popd
exit /b