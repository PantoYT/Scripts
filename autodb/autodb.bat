@echo off
setlocal EnableDelayedExpansion

set BASEDIR=G:\Pliki\Technik Programista\Bazy Danych
set MYSQL=C:\xampp\mysql\bin\mysql.exe
set USER=root
set PASS=

for /r "%BASEDIR%" %%F in (*.sql) do (
    set FILE=%%F

    rem nazwa bazy = nazwa pliku
    set DB=%%~nF

    rem ścieżka względna względem BASEDIR
    set REL=%%F
    set REL=!REL:%BASEDIR%\=!

    rem pierwsza część ścieżki = klasa
    for /f "tokens=1 delims=\" %%K in ("!REL!") do set CLASS=%%K

    set FINALDB=!CLASS!_!DB!

    "%MYSQL%" -u %USER% %PASS% -e "DROP DATABASE IF EXISTS `!FINALDB!`; CREATE DATABASE `!FINALDB!` CHARACTER SET utf8mb4;"
    "%MYSQL%" -u %USER% %PASS% "!FINALDB!" < "%%F"
)

endlocal
