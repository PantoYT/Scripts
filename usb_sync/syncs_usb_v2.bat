@echo off
setlocal EnableDelayedExpansion
title USB Sync + Git Auto Push

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
robocopy "%SRC_APPS%" "%DST_APPS%" /MIR /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: Apps sync failed >> "%LOGFILE%"

robocopy "%SRC_AHK%" "%DST_AHK%" /MIR /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: AutoHotkey sync failed >> "%LOGFILE%"

robocopy "%SRC_SCRIPTS%" "%DST_SCRIPTS%" /MIR /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: Scripts sync failed >> "%LOGFILE%"

REM ==== USB TO LOCAL BACKUP (G: -> E:) - STANDARD MODE ====
echo [%time%] Syncing USB to LOCAL... >> "%LOGFILE%"
robocopy "%SRC_DB%" "%DST_DB%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: Database sync failed >> "%LOGFILE%"

robocopy "%SRC_CPP%" "%DST_CPP%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: C++ sync failed >> "%LOGFILE%"

robocopy "%SRC_PY%" "%DST_PY%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: Python sync failed >> "%LOGFILE%"

robocopy "%SRC_WEB%" "%DST_WEB%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: Web sync failed >> "%LOGFILE%"

robocopy "%SRC_BHP%" "%DST_BHP%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: BHP sync failed >> "%LOGFILE%"

robocopy "%SRC_POD_INF%" "%DST_POD_INF%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: Podstawy Informatyki sync failed >> "%LOGFILE%"

robocopy "%SRC_INF%" "%DST_INF%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: Informatyka sync failed >> "%LOGFILE%"

robocopy "%SRC_PRZYGOT%" "%DST_PRZYGOT%" /E /R:3 /W:5 >> "%LOGFILE%"
if errorlevel 8 echo [%time%] ERROR: Przygotowanie do zawodu programisty sync failed >> "%LOGFILE%"

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