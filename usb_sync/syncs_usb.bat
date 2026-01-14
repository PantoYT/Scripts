@echo off
setlocal EnableDelayedExpansion
title USB Sync - persistent service

REM === KONFIGURACJA ===
set USB_DRIVE=G:
set SRC_APPS=C:\Aplikacje
set DST_APPS=G:\Pliki\Inne\Instalki
set SRC_AHK=C:\Autohotkey
set DST_AHK=G:\Pliki\Inne\AutoHotkey
set LOGDIR=C:\Scripts\logs
set LOGFILE=%LOGDIR%\usb_sync.log

REM === LOG DIR ===
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

echo ======================================= >> "%LOGFILE%"
echo START %date% %time% >> "%LOGFILE%"

REM === GŁÓWNA PĘTLA ===
:MAIN_LOOP
timeout /t 3 >nul

if not exist %USB_DRIVE%\ (
    echo [%time%] USB %USB_DRIVE% nieobecny >> "%LOGFILE%"
    goto MAIN_LOOP
)

echo [%time%] USB %USB_DRIVE% wykryty >> "%LOGFILE%"

REM === SYNC APLIKACJE (MIRROR) ===
robocopy "%SRC_APPS%" "%DST_APPS%" /MIR /R:3 /W:5 >> "%LOGFILE%"
echo [%time%] Robocopy Aplikacje exit code %errorlevel% >> "%LOGFILE%"

REM === SYNC AUTOHOTKEY (COPY) ===
robocopy "%SRC_AHK%" "%DST_AHK%" /E /R:3 /W:5 >> "%LOGFILE%"
echo [%time%] Robocopy AHK exit code %errorlevel% >> "%LOGFILE%"

echo [%time%] Synchronizacja zakonczona >> "%LOGFILE%"

REM === MONITORUJ, CZY USB NADAL JEST ===
:USB_MONITOR
timeout /t 5 >nul

if not exist %USB_DRIVE%\ (
    echo [%time%] USB odlaczony >> "%LOGFILE%"
    goto MAIN_LOOP
)

goto USB_MONITOR
