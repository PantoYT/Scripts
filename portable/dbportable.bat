@echo off
setlocal EnableDelayedExpansion

:: ===== INPUT =====
set /p USB=Podaj litere USB (np. G): 

set "BASEDIR=%USB%:\Pliki\Technik Programista\Bazy Danych"
set "MYSQL=C:\xampp\mysql\bin\mysql.exe"
set "USER=root"
set "PASS="

echo BASEDIR = "%BASEDIR%"
echo.

if not exist "%BASEDIR%" (
    echo [BLAD] Katalog nie istnieje
    pause
    exit /b
)

if not exist "%MYSQL%" (
    echo [BLAD] Nie znaleziono mysql.exe
    pause
    exit /b
)

:: ===== LOOP =====
for /r "%BASEDIR%" %%F in (*.sql) do (

    set "FILE=%%F"
    set "DB=%%~nF"

    set "REL=%%F"
    set "REL=!REL:%BASEDIR%\=!"

    for /f "tokens=1 delims=\" %%K in ("!REL!") do set "CLASS=%%K"

    set "FINALDB=!CLASS!_!DB!"

    echo -----------------------------------
    echo Import: !FINALDB!
    echo Plik: %%F

    "%MYSQL%" -u %USER% %PASS% -e "DROP DATABASE IF EXISTS `!FINALDB!`; CREATE DATABASE `!FINALDB!` CHARACTER SET utf8mb4;"

    "%MYSQL%" -u %USER% %PASS% "!FINALDB!" < "%%F"
)

echo.
echo ===== GOTOWE =====
endlocal
pause
