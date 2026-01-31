@echo off
setlocal EnableDelayedExpansion

:: ===== INPUT =====
set /p BASEDIR_DRIVE=Podaj litere dysku z plikami SQL (np. G): 
set /p MYSQL_DRIVE=Podaj litere dysku XAMPP (np. E): 

set "BASEDIR=%BASEDIR_DRIVE%:\Pliki\Technik Programista\Bazy Danych"
set "MYSQL=%MYSQL_DRIVE%:\xampp\mysql\bin\mysql.exe"
set USER=root
set PASS=

echo.
echo [DEBUG] BASEDIR = "%BASEDIR%"
echo [DEBUG] MYSQL   = "%MYSQL%"
echo.

:: Sprawdzenie czy ścieżki istnieją
if not exist "%BASEDIR%" (
    echo [BLAD] BASEDIR nie istnieje: "%BASEDIR%"
    pause
    exit /b
)

if not exist "%MYSQL%" (
    echo [BLAD] MySQL nie istnieje: "%MYSQL%"
    pause
    exit /b
)

:: Przetwarzanie plików SQL
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
    
    echo [SQL] Importowanie: !FINALDB! z pliku %%~nxF
    
    "%MYSQL%" -u %USER% %PASS% -e "DROP DATABASE IF EXISTS !FINALDB!; CREATE DATABASE !FINALDB! CHARACTER SET utf8mb4;"
    "%MYSQL%" -u %USER% %PASS% "!FINALDB!" < "%%F"
)

echo.
echo ===== GOTOWE =====
pause
endlocal