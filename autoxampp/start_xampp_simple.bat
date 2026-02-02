@echo off
REM Simple XAMPP Starter - Apache + MySQL
REM No fancy characters, just works

echo Starting XAMPP Services...
echo.

REM Start Apache
echo [1/2] Starting Apache...
start "" "E:\xampp\xampp_start.exe"

REM Wait a bit
timeout /t 5 /nobreak >nul

echo [2/2] Checking status...
echo.

REM Check Apache
tasklist /FI "IMAGENAME eq httpd.exe" 2>NUL | find /I "httpd.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Apache: RUNNING
) else (
    echo Apache: NOT RUNNING
)

REM Check MySQL
tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I "mysqld.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo MySQL: RUNNING
) else (
    echo MySQL: NOT RUNNING
)

echo.
echo Done. Check http://localhost
timeout /t 3
