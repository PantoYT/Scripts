@echo off
REM ========================================
REM XAMPP - Install as Windows Services
REM Run this ONCE as Administrator
REM ========================================

echo ========================================
echo Installing XAMPP as Windows Services
echo ========================================
echo.
echo This will install Apache and MySQL as
echo Windows services that start automatically.
echo.
echo You need to run this as Administrator!
echo.
pause

cd /d E:\xampp

echo.
echo [1/4] Installing Apache service...
apache\bin\httpd.exe -k install -n Apache2.4
if errorlevel 1 (
    echo ERROR: Apache install failed
    echo Make sure you're running as Administrator
    pause
    exit /b 1
)
echo Apache service installed!

echo.
echo [2/4] Installing MySQL service...
mysql\bin\mysqld.exe --install MySQL
if errorlevel 1 (
    echo ERROR: MySQL install failed
    echo Make sure you're running as Administrator
    pause
    exit /b 1
)
echo MySQL service installed!

echo.
echo [3/4] Starting Apache service...
net start Apache2.4
echo Apache started!

echo.
echo [4/4] Starting MySQL service...
net start MySQL
echo MySQL started!

echo.
echo ========================================
echo SUCCESS! Services installed and running
echo ========================================
echo.
echo Services will now start automatically
echo when Windows boots.
echo.
echo To manage services:
echo - Press Win+R
echo - Type: services.msc
echo - Look for Apache2.4 and MySQL
echo.
pause
