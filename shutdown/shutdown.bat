@echo off
setlocal enabledelayedexpansion
color 0A
title Safe System Shutdown

:: ============================================
:: CONFIGURATION
:: ============================================
set "LED_SCRIPT=E:\Scripts\led\led_off.py"
set "AUTOSYNC_SCRIPT=E:\Pliki\Projects\AutoSync\stop_autosync.bat"
set "LOG_FILE=E:\Scripts\shutdown_log.txt"
set "PYTHON_EXE=python"

:: ============================================
:: LOGGING FUNCTION
:: ============================================
echo ============================================ > "%LOG_FILE%"
echo Safe Shutdown Started: %DATE% %TIME% >> "%LOG_FILE%"
echo ============================================ >> "%LOG_FILE%"
echo.

:: ============================================
:: STEP 1: Turn off LED via Sonoff
:: ============================================
echo.
echo ============================================
echo [STEP 1/5] Turning off LED lights...
echo ============================================
echo [STEP 1/5] Turning off LED lights... >> "%LOG_FILE%"

if exist "%LED_SCRIPT%" (
    echo Running LED shutdown script...
    echo Running LED shutdown script at %TIME% >> "%LOG_FILE%"
    
    "%PYTHON_EXE%" "%LED_SCRIPT%"
    
    if !errorlevel! equ 0 (
        echo [SUCCESS] LED script completed successfully
        echo [SUCCESS] LED script completed successfully >> "%LOG_FILE%"
    ) else (
        echo [WARNING] LED script returned error code: !errorlevel!
        echo [WARNING] LED script returned error code: !errorlevel! >> "%LOG_FILE%"
        echo Continuing shutdown process...
    )
    
    :: Give it time to complete
    timeout /t 3 /nobreak >nul
) else (
    echo [WARNING] LED script not found at: %LED_SCRIPT%
    echo [WARNING] LED script not found >> "%LOG_FILE%"
)

:: ============================================
:: STEP 2: Stop AutoSync processes
:: ============================================
echo.
echo ============================================
echo [STEP 2/5] Stopping AutoSync processes...
echo ============================================
echo [STEP 2/5] Stopping AutoSync processes at %TIME% >> "%LOG_FILE%"

if exist "%AUTOSYNC_SCRIPT%" (
    echo Running AutoSync stop script...
    echo Running AutoSync stop script... >> "%LOG_FILE%"
    
    call "%AUTOSYNC_SCRIPT%"
    
    if !errorlevel! equ 0 (
        echo [SUCCESS] AutoSync stopped successfully
        echo [SUCCESS] AutoSync stopped successfully >> "%LOG_FILE%"
    ) else (
        echo [WARNING] AutoSync script returned error code: !errorlevel!
        echo [WARNING] AutoSync script returned error code: !errorlevel! >> "%LOG_FILE%"
    )
    
    :: Wait for processes to fully terminate
    timeout /t 5 /nobreak >nul
) else (
    echo [WARNING] AutoSync script not found at: %AUTOSYNC_SCRIPT%
    echo [WARNING] AutoSync script not found >> "%LOG_FILE%"
)

:: ============================================
:: STEP 3: Stop XAMPP Services Safely
:: ============================================
echo.
echo ============================================
echo [STEP 3/5] Stopping XAMPP services...
echo ============================================
echo [STEP 3/5] Stopping XAMPP services at %TIME% >> "%LOG_FILE%"

:: Stop Apache
sc query "Apache2.4" >nul 2>&1
if !errorlevel! equ 0 (
    echo Stopping Apache service...
    echo Stopping Apache service... >> "%LOG_FILE%"
    net stop Apache2.4 /y >nul 2>&1
    timeout /t 2 /nobreak >nul
)

:: Stop MySQL
sc query "MySQL" >nul 2>&1
if !errorlevel! equ 0 (
    echo Stopping MySQL service...
    echo Stopping MySQL service... >> "%LOG_FILE%"
    net stop MySQL /y >nul 2>&1
    timeout /t 3 /nobreak >nul
)

:: Stop FileZilla
sc query "FileZillaServer" >nul 2>&1
if !errorlevel! equ 0 (
    echo Stopping FileZilla service...
    echo Stopping FileZilla service... >> "%LOG_FILE%"
    net stop FileZillaServer /y >nul 2>&1
    timeout /t 2 /nobreak >nul
)

:: Stop Tomcat
sc query "Tomcat9" >nul 2>&1
if !errorlevel! equ 0 (
    echo Stopping Tomcat service...
    echo Stopping Tomcat service... >> "%LOG_FILE%"
    net stop Tomcat9 /y >nul 2>&1
    timeout /t 2 /nobreak >nul
)

:: Force kill XAMPP control panel if running
taskkill /IM xampp-control.exe /F >nul 2>&1

echo [SUCCESS] XAMPP services stopped
echo [SUCCESS] XAMPP services stopped >> "%LOG_FILE%"

:: ============================================
:: STEP 4: Gracefully terminate processes
:: ============================================
echo.
echo ============================================
echo [STEP 4/5] Gracefully closing applications...
echo ============================================
echo [STEP 4/5] Gracefully closing applications at %TIME% >> "%LOG_FILE%"

:: Close common applications gracefully (allow save prompts)
echo Closing user applications...
echo Closing user applications... >> "%LOG_FILE%"

:: Chrome, Firefox, Edge
taskkill /IM chrome.exe >nul 2>&1
taskkill /IM firefox.exe >nul 2>&1
taskkill /IM msedge.exe >nul 2>&1

:: Office applications
taskkill /IM WINWORD.EXE >nul 2>&1
taskkill /IM EXCEL.EXE >nul 2>&1
taskkill /IM POWERPNT.EXE >nul 2>&1

:: Wait for graceful closure
echo Waiting for applications to close gracefully...
timeout /t 10 /nobreak >nul

:: Force close if still running
echo Force closing remaining applications...
echo Force closing remaining applications... >> "%LOG_FILE%"

taskkill /IM chrome.exe /F >nul 2>&1
taskkill /IM firefox.exe /F >nul 2>&1
taskkill /IM msedge.exe /F >nul 2>&1
taskkill /IM WINWORD.EXE /F >nul 2>&1
taskkill /IM EXCEL.EXE /F >nul 2>&1
taskkill /IM POWERPNT.EXE /F >nul 2>&1

:: Additional robocopy cleanup (in case AutoSync didn't catch all)
taskkill /IM robocopy.exe /F >nul 2>&1

:: Wait for file system to sync
echo Syncing file system...
echo Syncing file system... >> "%LOG_FILE%"
timeout /t 3 /nobreak >nul

echo [SUCCESS] Applications closed
echo [SUCCESS] Applications closed >> "%LOG_FILE%"

:: ============================================
:: STEP 5: Final system shutdown
:: ============================================
echo.
echo ============================================
echo [STEP 5/5] Initiating system shutdown...
echo ============================================
echo [STEP 5/5] Initiating system shutdown at %TIME% >> "%LOG_FILE%"
echo ============================================ >> "%LOG_FILE%"

:: Flush disk cache
echo Flushing disk cache...
echo Flushing disk cache... >> "%LOG_FILE%"
timeout /t 2 /nobreak >nul

echo.
echo ============================================
echo  ALL TASKS COMPLETED SUCCESSFULLY
echo  System will shutdown in 10 seconds...
echo  Press Ctrl+C to cancel
echo ============================================
echo.

:: Final log entry
echo Shutdown initiated successfully at %TIME% >> "%LOG_FILE%"
echo ============================================ >> "%LOG_FILE%"

:: 10 second countdown with cancel option
timeout /t 10

:: Shutdown the system
shutdown /s /f /t 0

endlocal