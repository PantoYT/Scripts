@echo off
setlocal EnableDelayedExpansion
title USB Sync + Git Auto Push

REM ==== CONFIG ====
set USB_DRIVE=G:

set SRC_APPS=C:\Aplikacje
set DST_APPS=G:\Pliki\Inne\Instalki

set SRC_AHK=C:\Autohotkey
set DST_AHK=G:\Pliki\Inne\AutoHotkey

set SRC_SCRIPTS=C:\Scripts
set DST_SCRIPTS=G:\Pliki\Inne\Scripts

set SRC_DB=G:\Pliki\Technik Programista\Bazy Danych
set DST_DB=E:\Pliki\Projects\databases

set SRC_CPP=G:\Pliki\Technik Programista\Programowanie\cpp
set DST_CPP=E:\Pliki\Projects\cpp

set SRC_PY=G:\Pliki\Technik Programista\Programowanie\python
set DST_PY=E:\Pliki\Projects\python

set SRC_WEB=G:\Pliki\Technik Programista\Strony internetowe
set DST_WEB=E:\Pliki\Projects\websites

set GIT_ROOT=E:\Pliki\Projects

set LOGDIR=C:\Scripts\logs
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

REM ==== LOCAL TO USB BACKUP (C: -> G:) ====
echo [%time%] Syncing LOCAL to USB... >> "%LOGFILE%"
robocopy "%SRC_APPS%" "%DST_APPS%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: Apps sync failed >> "%LOGFILE%"

robocopy "%SRC_AHK%" "%DST_AHK%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: AutoHotkey sync failed >> "%LOGFILE%"

robocopy "%SRC_SCRIPTS%" "%DST_SCRIPTS%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: Scripts sync failed >> "%LOGFILE%"

REM ==== USB TO LOCAL BACKUP (G: -> E:) ====
echo [%time%] Syncing USB to LOCAL... >> "%LOGFILE%"
robocopy "%SRC_DB%" "%DST_DB%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: Database sync failed >> "%LOGFILE%"

robocopy "%SRC_CPP%" "%DST_CPP%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: C++ sync failed >> "%LOGFILE%"

robocopy "%SRC_PY%" "%DST_PY%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: Python sync failed >> "%LOGFILE%"

robocopy "%SRC_WEB%" "%DST_WEB%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: Web sync failed >> "%LOGFILE%"

echo [%time%] Backup finished >> "%LOGFILE%"

REM ==== GITHUB AUTO UPDATE ====
echo [%time%] GitHub sync start >> "%LOGFILE%"

call :GIT_SYNC "%GIT_ROOT%"

REM ==== USB MONITOR ====
:USB_MONITOR
timeout /t 5 >nul

if not exist %USB_DRIVE%\ (
    echo [%time%] USB removed >> "%LOGFILE%"
    goto MAIN_LOOP
)

goto USB_MONITOR

:GIT_SYNC
set DIR=%~1

REM Check top-level directory for .git
if exist "%DIR%\.git" (
    pushd "%DIR%"
    git add . >> "%LOGFILE%"
    git commit -m "Auto backup %date% %time%" >> "%LOGFILE%"
    if errorlevel 1 (
        echo [%time%] WARNING: Git commit failed for %DIR% >> "%LOGFILE%"
    ) else (
        git push origin >> "%LOGFILE%"
        if errorlevel 1 (
            echo [%time%] WARNING: Git push failed for %DIR% >> "%LOGFILE%"
        ) else (
            echo [%time%] Git synced: %DIR% >> "%LOGFILE%"
        )
    )
    popd
)

REM Check first-level subfolders for .git (klasa1, klasa2, etc)
for /d %%d in ("%DIR%\*") do (
    if exist "%%d\.git" (
        pushd "%%d"
        git add . >> "%LOGFILE%"
        git commit -m "Auto backup %date% %time%" >> "%LOGFILE%"
        if errorlevel 1 (
            echo [%time%] WARNING: Git commit failed for %%d >> "%LOGFILE%"
        ) else (
            git push origin >> "%LOGFILE%"
            if errorlevel 1 (
                echo [%time%] WARNING: Git push failed for %%d >> "%LOGFILE%"
            ) else (
                echo [%time%] Git synced: %%d >> "%LOGFILE%"
            )
        )
        popd
    )
)

exit /b
