@echo off
setlocal enabledelayedexpansion

set SOURCE=E:\Pliki\Projects\websites
set DEST=C:\xampp\htdocs\myfiles

for /r "%SOURCE%" %%F in (*.php) do (
    set "FULLDIR=%%~dpF"
    set "FULLDIR=!FULLDIR:~0,-1!"

    REM folder strony
    for %%A in ("!FULLDIR!") do (
        set "FOLDERNAME=%%~nxA"
        set "PARENT=%%~dpA"
    )

    REM usuń końcowy backslash z parenta
    set "PARENT=!PARENT:~0,-1!"

    REM nazwa klasy (folder nadrzędny)
    for %%B in ("!PARENT!") do set "CLASSNAME=%%~nxB"

    REM sprawdź czy folder jest bezpośrednio w SOURCE
    if /I "!PARENT!"=="%SOURCE%" (
        set "TARGET=%DEST%\!FOLDERNAME!"
    ) else (
        set "TARGET=%DEST%\!CLASSNAME!_!FOLDERNAME!"
    )

    if not exist "!TARGET!" (
        echo Przenoszę: !FULLDIR! -> !TARGET!
        move "!FULLDIR!" "!TARGET!" >nul
    )
)

echo Gotowe.
pause
