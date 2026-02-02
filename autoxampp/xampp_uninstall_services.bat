@echo off
REM ========================================
REM XAMPP - Uninstall Windows Services
REM Run as Administrator if you want to remove services
REM ========================================

echo ========================================
echo Uninstalling XAMPP Windows Services
echo ========================================
echo.
pause

cd /d E:\xampp

echo.
echo [1/4] Stopping Apache...
net stop Apache2.4

echo.
echo [2/4] Stopping MySQL...
net stop MySQL

echo.
echo [3/4] Uninstalling Apache service...
apache\bin\httpd.exe -k uninstall -n Apache2.4

echo.
echo [4/4] Uninstalling MySQL service...
mysql\bin\mysqld.exe --remove MySQL

echo.
echo ========================================
echo Services uninstalled
echo ========================================
pause
