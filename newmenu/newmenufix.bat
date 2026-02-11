@echo off
setlocal enabledelayedexpansion
title COMPLETE Folder Creation Fix
color 0F

:: ============================================
:: COMPREHENSIVE FOLDER CREATION FIX
:: Fixes: Right-click -> New -> Folder
::        Ctrl+Shift+N
:: ============================================

:MENU
cls
echo ============================================
echo  FOLDER CREATION FIX - COMPLETE
echo ============================================
echo.
echo  [1] Full Diagnostic Scan
echo  [2] Nuclear Fix (Recommended)
echo  [3] Manual Registry Export/Import
echo  [4] Exit
echo.
echo ============================================
set /p choice="Select option (1-4): "

if "%choice%"=="1" goto DIAGNOSTIC
if "%choice%"=="2" goto NUCLEAR_FIX
if "%choice%"=="3" goto MANUAL_FIX
if "%choice%"=="4" exit /b 0
goto MENU

:DIAGNOSTIC
cls
echo ============================================
echo  DIAGNOSTIC SCAN
echo ============================================
echo.

:: Check admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] NOT running as Administrator
    echo     Run this script as Admin!
    pause
    goto MENU
) else (
    echo [OK] Running as Administrator
)

echo.
echo Checking critical registry keys...
echo.

:: Check 1: Context Menu Handler for "New"
echo [1] Checking Background Context Menu Handler...
reg query "HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\New" /ve >nul 2>&1
if %errorlevel% equ 0 (
    echo     [OK] Handler exists
    for /f "tokens=3*" %%a in ('reg query "HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\New" /ve 2^>nul ^| findstr /i "REG_SZ"') do (
        echo     Value: %%a
        if "%%a"=="{D969A300-E7FF-11d0-A93B-00A0C90F2719}" (
            echo     [OK] Correct CLSID
        ) else (
            echo     [!!] WRONG CLSID - This is your problem!
        )
    )
) else (
    echo     [!!] MISSING - This is your problem!
)

echo.
echo [2] Checking Desktop Background Handler...
reg query "HKEY_CLASSES_ROOT\DesktopBackground\Shell" >nul 2>&1
if %errorlevel% equ 0 (
    echo     [OK] Desktop handler key exists
) else (
    echo     [!!] MISSING
)

echo.
echo [3] Checking Policies (blocks)...
set "BLOCKED=0"

reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoNewFolder >nul 2>&1
if %errorlevel% equ 0 (
    echo     [!!] BLOCKED by User Policy: NoNewFolder
    set "BLOCKED=1"
)

reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoNewFolder >nul 2>&1
if %errorlevel% equ 0 (
    echo     [!!] BLOCKED by Machine Policy: NoNewFolder
    set "BLOCKED=1"
)

reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoViewContextMenu >nul 2>&1
if %errorlevel% equ 0 (
    echo     [!!] BLOCKED: NoViewContextMenu
    set "BLOCKED=1"
)

if "%BLOCKED%"=="0" (
    echo     [OK] No policy blocks found
)

echo.
echo [4] Checking .Folder file association...
reg query "HKEY_CLASSES_ROOT\.Folder" >nul 2>&1
if %errorlevel% equ 0 (
    echo     [OK] .Folder extension registered
) else (
    echo     [WARN] .Folder extension missing (usually not needed)
)

echo.
echo [5] Checking CLSID registration...
reg query "HKEY_CLASSES_ROOT\CLSID\{D969A300-E7FF-11d0-A93B-00A0C90F2719}" >nul 2>&1
if %errorlevel% equ 0 (
    echo     [OK] New menu CLSID is registered
) else (
    echo     [!!] CRITICAL: CLSID not registered!
)

echo.
echo ============================================
echo  DIAGNOSTIC COMPLETE
echo ============================================
echo.
echo Recommendation: Run option [2] Nuclear Fix
echo.
pause
goto MENU

:NUCLEAR_FIX
cls
echo ============================================
echo  NUCLEAR FOLDER FIX
echo ============================================
echo.
echo This will:
echo  1. Remove ALL policy blocks
echo  2. Restore CLSID registration
echo  3. Rebuild ALL "New" menu handlers
echo  4. Clear Explorer cache
echo  5. Restart Explorer (twice)
echo.
set /p confirm="Continue? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU

:: Check admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Run as Administrator!
    pause
    goto MENU
)

echo.
echo ============================================
echo  STEP 1: Removing Policy Blocks
echo ============================================

:: Remove all known policy blocks
for %%K in (
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
) do (
    echo Cleaning %%K...
    reg delete %%K /v NoNewFolder /f >nul 2>&1
    reg delete %%K /v NoViewContextMenu /f >nul 2>&1
    reg delete %%K /v NoFileMenu /f >nul 2>&1
    reg delete %%K /v NoChangeStartMenu /f >nul 2>&1
)

:: Remove Explorer state blocks
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v NoNewFolder /f >nul 2>&1

echo [OK] Policies cleared

echo.
echo ============================================
echo  STEP 2: Registering CLSID
echo ============================================

:: Register the New menu CLSID if missing
echo Ensuring {D969A300-E7FF-11d0-A93B-00A0C90F2719} exists...

reg add "HKEY_CLASSES_ROOT\CLSID\{D969A300-E7FF-11d0-A93B-00A0C90F2719}" /ve /t REG_SZ /d "New" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\CLSID\{D969A300-E7FF-11d0-A93B-00A0C90F2719}\InProcServer32" /ve /t REG_SZ /d "shell32.dll" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\CLSID\{D969A300-E7FF-11d0-A93B-00A0C90F2719}\InProcServer32" /v ThreadingModel /t REG_SZ /d "Apartment" /f >nul 2>&1

echo [OK] CLSID registered

echo.
echo ============================================
echo  STEP 3: Rebuilding Context Menu Handlers
echo ============================================

:: Directory background (right-click in folder)
echo [3a] Directory Background handler...
reg add "HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\New" /ve /t REG_SZ /d "{D969A300-E7FF-11d0-A93B-00A0C90F2719}" /f >nul 2>&1
echo      [OK]

:: Desktop background
echo [3b] Desktop Background handler...
reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell" /ve /t REG_SZ /d "" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\DesktopBackground\shellex\ContextMenuHandlers\New" /ve /t REG_SZ /d "{D969A300-E7FF-11d0-A93B-00A0C90F2719}" /f >nul 2>&1
echo      [OK]

:: Folder class
echo [3c] Folder class handler...
reg add "HKEY_CLASSES_ROOT\Folder\ShellEx\ContextMenuHandlers\New" /ve /t REG_SZ /d "{D969A300-E7FF-11d0-A93B-00A0C90F2719}" /f >nul 2>&1
echo      [OK]

:: LibraryFolder (Libraries)
echo [3d] Library folder handler...
reg add "HKEY_CLASSES_ROOT\LibraryFolder\background\shellex\ContextMenuHandlers\New" /ve /t REG_SZ /d "{D969A300-E7FF-11d0-A93B-00A0C90F2719}" /f >nul 2>&1
echo      [OK]

echo.
echo ============================================
echo  STEP 4: Ensuring Folder ShellNew
echo ============================================

:: Make sure there's a Folder entry in ShellNew
reg add "HKEY_CLASSES_ROOT\.Folder" /ve /t REG_SZ /d "Folder" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\.Folder\ShellNew" /v Command /t REG_SZ /d "" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\.Folder\ShellNew" /v Directory /t REG_SZ /d "" /f >nul 2>&1

echo [OK] Folder ShellNew configured

echo.
echo ============================================
echo  STEP 5: Clearing Explorer Cache
echo ============================================

:: Clear icon cache
echo Clearing icon cache...
reg delete "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1

:: Delete IconCache
if exist "%localappdata%\IconCache.db" (
    attrib -h "%localappdata%\IconCache.db" >nul 2>&1
    del /f /q "%localappdata%\IconCache.db" >nul 2>&1
)

echo [OK] Cache cleared

echo.
echo ============================================
echo  STEP 6: Restarting Explorer (First Pass)
echo ============================================
echo Killing Explorer...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 3 /nobreak >nul
echo Starting Explorer...
start explorer.exe
timeout /t 3 /nobreak >nul

echo.
echo ============================================
echo  STEP 7: Restarting Explorer (Second Pass)
echo ============================================
echo Killing Explorer again for good measure...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
echo Starting Explorer...
start explorer.exe
timeout /t 2 /nobreak >nul

echo.
echo ============================================
echo  NUCLEAR FIX COMPLETE!
echo ============================================
echo.
echo TEST NOW:
echo  1. Right-click on desktop -> New -> Folder
echo  2. Right-click in any folder -> New -> Folder  
echo  3. Press Ctrl+Shift+N in File Explorer
echo.
echo If STILL broken, try option [3] Manual Fix
echo or reboot your PC.
echo.
pause
goto MENU

:MANUAL_FIX
cls
echo ============================================
echo  MANUAL REGISTRY FIX
echo ============================================
echo.
echo This creates a .REG file you can import
echo manually if the automatic fix didn't work.
echo.

set "REGFILE=%~dp0folder_fix_manual.reg"
echo Creating: %REGFILE%
echo.

(
echo Windows Registry Editor Version 5.00
echo.
echo ; Remove policy blocks
echo [-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
echo "NoNewFolder"=-
echo "NoViewContextMenu"=-
echo.
echo [-HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
echo "NoNewFolder"=-
echo "NoViewContextMenu"=-
echo.
echo ; Register CLSID
echo [HKEY_CLASSES_ROOT\CLSID\{D969A300-E7FF-11d0-A93B-00A0C90F2719}]
echo @="New"
echo.
echo [HKEY_CLASSES_ROOT\CLSID\{D969A300-E7FF-11d0-A93B-00A0C90F2719}\InProcServer32]
echo @="shell32.dll"
echo "ThreadingModel"="Apartment"
echo.
echo ; Context menu handlers
echo [HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\New]
echo @="{D969A300-E7FF-11d0-A93B-00A0C90F2719}"
echo.
echo [HKEY_CLASSES_ROOT\DesktopBackground\shellex\ContextMenuHandlers\New]
echo @="{D969A300-E7FF-11d0-A93B-00A0C90F2719}"
echo.
echo [HKEY_CLASSES_ROOT\Folder\ShellEx\ContextMenuHandlers\New]
echo @="{D969A300-E7FF-11d0-A93B-00A0C90F2719}"
echo.
echo [HKEY_CLASSES_ROOT\LibraryFolder\background\shellex\ContextMenuHandlers\New]
echo @="{D969A300-E7FF-11d0-A93B-00A0C90F2719}"
) > "%REGFILE%"

echo [OK] File created!
echo.
echo MANUAL STEPS:
echo  1. Right-click: %REGFILE%
echo  2. Choose "Merge"
echo  3. Click Yes to confirm
echo  4. Restart Explorer or reboot
echo.
pause
goto MENU

endlocal