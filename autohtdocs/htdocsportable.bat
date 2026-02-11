@echo off
setlocal EnableDelayedExpansion

:: ===== INPUT =====
set /p USB=Podaj litere USB (np. E): 
set /p XAMPP=Podaj litere dysku XAMPP (np. C): 
set /p HTDOCS=Podaj folder w htdocs (np. 1p): 

set "SOURCE=%USB%:\Pliki\Technik Programista\Strony internetowe"
set "DEST=%XAMPP%:\xampp\htdocs\%HTDOCS%"

echo.
echo [DEBUG] SOURCE = "%SOURCE%"
echo [DEBUG] DEST   = "%DEST%"
echo.

if not exist "%SOURCE%" (
    echo [BLAD] SOURCE nie istnieje
    pause
    exit /b
)

if not exist "%DEST%" mkdir "%DEST%"

set "COPIED="

for /r "%SOURCE%" %%F in (*.php) do (

    set "CURDIR=%%~dpF"
    set "CURDIR=!CURDIR:~0,-1!"

    echo [PHP] %%F
    echo [FOLDER] !CURDIR!

    echo !COPIED! | findstr /C:"|!CURDIR!|" >nul
    if errorlevel 1 (

        set "REL=!CURDIR:%SOURCE%\=!"
        set "REL=!REL:\=_!"

        set "TARGET=%DEST%\!REL!"

        echo [COPY] "!CURDIR!" --> "!TARGET!"
        xcopy "!CURDIR!" "!TARGET!\" /E /I /Y >nul

        set "COPIED=!COPIED!|!CURDIR!|"
    ) else (
        echo [POMINIETO] juz skopiowane
    )
)

echo.
echo ===== GOTOWE =====
pause
