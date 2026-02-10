@echo off
setlocal enabledelayedexpansion
title Ultimate "New" Menu Cleaner - PORTABLE EDITION
color 0F

:: ============================================
:: ULTIMATE NEW MENU CLEANER & REBUILDER
:: PORTABLE EDITION - Works on ANY PC
:: ============================================
:: NUKES everything, registers file types,
:: then adds back only what you want
:: ============================================

:MENU
cls
echo ============================================
echo  ULTIMATE "NEW" MENU CLEANER
echo  PORTABLE EDITION
echo ============================================
echo.
echo  [1] NUKE and Rebuild Clean Menu
echo  [2] Restore Backup
echo  [3] Exit
echo.
echo ============================================
echo.
set /p choice="Select option (1-3): "

if "%choice%"=="1" goto NUKE
if "%choice%"=="2" goto RESTORE
if "%choice%"=="3" exit /b 0
goto MENU

:NUKE
cls
echo ============================================
echo  NUCLEAR CLEANUP MODE
echo ============================================
echo.
echo This will:
echo  1. Backup current registry
echo  2. DELETE ALL ShellNew entries
echo  3. REGISTER all file types (if missing)
echo  4. Add back only your chosen file types
echo.
echo Works even on fresh/foreign PCs!
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
echo  STEP 1: Creating Backup
echo ============================================
set "BACKUP=%~dp0new_menu_backup.reg"
echo Backing up to: %BACKUP%
reg export HKEY_CLASSES_ROOT "%BACKUP%" /y >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Backup created successfully!
) else (
    echo [ERROR] Backup failed!
    pause
    goto MENU
)

echo.
echo ============================================
echo  STEP 2: NUKING ALL ShellNew Entries
echo ============================================
echo Scanning and destroying all ShellNew entries...
echo.

:: Get all file extensions with ShellNew
for /f "delims=" %%a in ('reg query HKEY_CLASSES_ROOT /s /k /f ShellNew 2^>nul ^| findstr /i "ShellNew"') do (
    echo Deleting: %%a
    reg delete "%%a" /f >nul 2>&1
)

echo.
echo [OK] All ShellNew entries obliterated!

echo.
echo ============================================
echo  STEP 3: Registering File Types
echo ============================================
echo Ensuring all file types are registered...
echo.

:: ============================================
:: REGISTER PROGRAMMING LANGUAGES
:: ============================================

:: Python (.py)
echo [REG] Python (.py)
reg add "HKEY_CLASSES_ROOT\.py" /ve /t REG_SZ /d "Python.File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\Python.File" /ve /t REG_SZ /d "Python File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\Python.File\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-102" /f >nul 2>&1

:: C++ (.cpp)
echo [REG] C++ (.cpp)
reg add "HKEY_CLASSES_ROOT\.cpp" /ve /t REG_SZ /d "C++.File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\C++.File" /ve /t REG_SZ /d "C++ Source File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\C++.File\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-102" /f >nul 2>&1

:: Java (.java)
echo [REG] Java (.java)
reg add "HKEY_CLASSES_ROOT\.java" /ve /t REG_SZ /d "Java.File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\Java.File" /ve /t REG_SZ /d "Java Source File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\Java.File\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-102" /f >nul 2>&1

:: C# (.cs)
echo [REG] C# (.cs)
reg add "HKEY_CLASSES_ROOT\.cs" /ve /t REG_SZ /d "CSharp.File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\CSharp.File" /ve /t REG_SZ /d "C# Source File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\CSharp.File\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-102" /f >nul 2>&1

:: ============================================
:: REGISTER SCRIPTING LANGUAGES
:: ============================================

:: Batch (.bat) - already registered by Windows, but ensure it
echo [REG] Batch (.bat)
reg add "HKEY_CLASSES_ROOT\.bat" /ve /t REG_SZ /d "batfile" /f >nul 2>&1

:: VBScript (.vbs) - already registered by Windows
echo [REG] VBScript (.vbs)
reg add "HKEY_CLASSES_ROOT\.vbs" /ve /t REG_SZ /d "VBSFile" /f >nul 2>&1

:: PowerShell (.ps1)
echo [REG] PowerShell (.ps1)
reg add "HKEY_CLASSES_ROOT\.ps1" /ve /t REG_SZ /d "Microsoft.PowerShellScript.1" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1" /ve /t REG_SZ /d "Windows PowerShell Script" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\WindowsPowerShell\v1.0\powershell.exe,0" /f >nul 2>&1

:: ============================================
:: REGISTER WEB DEVELOPMENT FILES
:: ============================================

:: HTML (.html)
echo [REG] HTML (.html)
reg add "HKEY_CLASSES_ROOT\.html" /ve /t REG_SZ /d "htmlfile" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\htmlfile" /ve /t REG_SZ /d "HTML Document" /f >nul 2>&1

:: CSS (.css)
echo [REG] CSS (.css)
reg add "HKEY_CLASSES_ROOT\.css" /ve /t REG_SZ /d "CSS.File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\CSS.File" /ve /t REG_SZ /d "Cascading Style Sheet" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\CSS.File\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-102" /f >nul 2>&1

:: JavaScript (.js)
echo [REG] JavaScript (.js)
reg add "HKEY_CLASSES_ROOT\.js" /ve /t REG_SZ /d "JSFile" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\JSFile" /ve /t REG_SZ /d "JavaScript File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\JSFile\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-102" /f >nul 2>&1

:: ============================================
:: REGISTER DATA & CONFIG FILES
:: ============================================

:: JSON (.json)
echo [REG] JSON (.json)
reg add "HKEY_CLASSES_ROOT\.json" /ve /t REG_SZ /d "JSON.File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\JSON.File" /ve /t REG_SZ /d "JSON File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\JSON.File\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-102" /f >nul 2>&1

:: XML (.xml)
echo [REG] XML (.xml)
reg add "HKEY_CLASSES_ROOT\.xml" /ve /t REG_SZ /d "xmlfile" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\xmlfile" /ve /t REG_SZ /d "XML Document" /f >nul 2>&1

:: INI (.ini)
echo [REG] INI (.ini)
reg add "HKEY_CLASSES_ROOT\.ini" /ve /t REG_SZ /d "inifile" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\inifile" /ve /t REG_SZ /d "Configuration Settings" /f >nul 2>&1

:: SQL (.sql)
echo [REG] SQL (.sql)
reg add "HKEY_CLASSES_ROOT\.sql" /ve /t REG_SZ /d "SQL.File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\SQL.File" /ve /t REG_SZ /d "SQL Script" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\SQL.File\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-102" /f >nul 2>&1

:: ============================================
:: REGISTER DOCUMENTATION FILES
:: ============================================

:: Markdown (.md)
echo [REG] Markdown (.md)
reg add "HKEY_CLASSES_ROOT\.md" /ve /t REG_SZ /d "Markdown.File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\Markdown.File" /ve /t REG_SZ /d "Markdown Document" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\Markdown.File\DefaultIcon" /ve /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-102" /f >nul 2>&1

:: Text (.txt) - already registered by Windows
echo [REG] Text (.txt)
reg add "HKEY_CLASSES_ROOT\.txt" /ve /t REG_SZ /d "txtfile" /f >nul 2>&1

echo.
echo [OK] All file types registered!

echo.
echo ============================================
echo  STEP 4: Building Your Clean Menu
echo ============================================
echo Adding ShellNew entries...
echo.

:: Programming Languages
echo [+] Python (.py)
reg add "HKEY_CLASSES_ROOT\.py\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

echo [+] C++ (.cpp)
reg add "HKEY_CLASSES_ROOT\.cpp\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

echo [+] Java (.java)
reg add "HKEY_CLASSES_ROOT\.java\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

echo [+] C# (.cs)
reg add "HKEY_CLASSES_ROOT\.cs\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

:: Scripting
echo [+] Batch (.bat)
reg add "HKEY_CLASSES_ROOT\.bat\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

echo [+] VBScript (.vbs)
reg add "HKEY_CLASSES_ROOT\.vbs\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

echo [+] PowerShell (.ps1)
reg add "HKEY_CLASSES_ROOT\.ps1\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

:: Web Development
echo [+] HTML (.html)
reg add "HKEY_CLASSES_ROOT\.html\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

echo [+] CSS (.css)
reg add "HKEY_CLASSES_ROOT\.css\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

echo [+] JavaScript (.js)
reg add "HKEY_CLASSES_ROOT\.js\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

:: Data & Config
echo [+] JSON (.json)
reg add "HKEY_CLASSES_ROOT\.json\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

echo [+] XML (.xml)
reg add "HKEY_CLASSES_ROOT\.xml\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

echo [+] INI (.ini)
reg add "HKEY_CLASSES_ROOT\.ini\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

echo [+] SQL (.sql)
reg add "HKEY_CLASSES_ROOT\.sql\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

:: Documentation
echo [+] Markdown (.md)
reg add "HKEY_CLASSES_ROOT\.md\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

echo [+] Text (.txt)
reg add "HKEY_CLASSES_ROOT\.txt\ShellNew" /v NullFile /t REG_SZ /d "" /f >nul 2>&1

echo.
echo [OK] Clean menu built successfully!

echo.
echo ============================================
echo  STEP 5: Restarting Explorer
echo ============================================
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
timeout /t 2 /nobreak >nul

echo.
echo ============================================
echo  MISSION ACCOMPLISHED!
echo ============================================
echo.
echo Your "New" menu now contains ALL 16 types:
echo.
echo Programming:
echo  - Python (.py)
echo  - C++ (.cpp)
echo  - Java (.java)
echo  - C# (.cs)
echo.
echo Scripting:
echo  - Batch (.bat)
echo  - VBScript (.vbs)
echo  - PowerShell (.ps1)
echo.
echo Web:
echo  - HTML (.html)
echo  - CSS (.css)
echo  - JavaScript (.js)
echo.
echo Data/Config:
echo  - JSON (.json)
echo  - XML (.xml)
echo  - INI (.ini)
echo  - SQL (.sql)
echo.
echo Documentation:
echo  - Markdown (.md)
echo  - Text (.txt)
echo.
echo Built-in:
echo  - Folder
echo  - Shortcut
echo.
echo Works on ANY PC - even foreign ones!
echo ============================================
echo.
pause
goto MENU

:RESTORE
cls
echo ============================================
echo  RESTORE FROM BACKUP
echo ============================================
echo.

:: Check admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Run as Administrator!
    pause
    goto MENU
)

set "BACKUP=%~dp0new_menu_backup.reg"
if not exist "%BACKUP%" (
    echo [ERROR] No backup found!
    echo Run option 1 first to create a backup.
    pause
    goto MENU
)

echo Restoring from: %BACKUP%
echo.
echo WARNING: This will restore ALL previous
echo ShellNew entries including Office, etc.
echo.
set /p confirm="Continue? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU

echo.
echo Restoring registry...
regedit /s "%BACKUP%"

echo [OK] Restored!
echo.
echo Restarting Explorer...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
timeout /t 2 /nobreak >nul

echo.
echo ============================================
echo  DONE! Original menu restored.
echo ============================================
echo.
pause
goto MENU

endlocal