====================================================
           SCRIPT LAUNCHER - README
====================================================

QUICK START:
1. Copy all files to: E:\Scripts\launcher\
2. Run: master_launcher.vbs
3. Press "A" to start all scripts
4. Run: ADD_TO_STARTUP.bat (adds to Windows autostart)

====================================================
FILES:
====================================================

master_launcher.vbs   - Main program (GUI)
launcher_core.vbs     - Library (required)
config.ini            - Configuration
START_ALL.bat         - Start all scripts (goes to registry)
STOP_ALL.bat          - Stop all scripts
ADD_TO_STARTUP.bat    - Add to Windows autostart
REMOVE_FROM_STARTUP.bat - Remove from autostart
launcher.log          - Activity log (auto-created)
README.txt            - This file

====================================================
USAGE:
====================================================

GUI MODE:
  Double-click: master_launcher.vbs
  
  Options:
    A - Start All
    S - Stop All  
    R - Restart All
    1-5 - Toggle individual script
    Q - Quit

COMMAND LINE:
  master_launcher.vbs /start   - Start all
  master_launcher.vbs /stop    - Stop all
  master_launcher.vbs /restart - Restart all

====================================================
WHAT STARTS AUTOMATICALLY:
====================================================

When you boot Windows (after running ADD_TO_STARTUP.bat):
  - AutoSync
  - Fred Bot
  - Qred Bot
  - LED Lights (ON)
  - Control Station

====================================================
ADDING NEW SCRIPTS:
====================================================

1. Edit config.ini
2. Add new section:

[My Script]
Type=python
Path=E:\path\to\script.py
ProcessName=python.exe
ProcessSearch=script.py
AutoStart=true
Description=What it does

3. Save and restart launcher

====================================================
TROUBLESHOOTING:
====================================================

Script won't start?
  - Check path in config.ini
  - Check launcher.log

Can't find launcher_core.vbs?
  - Must be in same folder as master_launcher.vbs

Scripts start twice?
  - Remove old registry entries
  - Keep only ScriptLauncherMaster

====================================================
WINDOWS AUTOSTART:
====================================================

To add:
  Run: ADD_TO_STARTUP.bat

To remove:
  Run: REMOVE_FROM_STARTUP.bat

Or manually:
  Win+R -> regedit
  Go to: HKCU\Software\Microsoft\Windows\CurrentVersion\Run
  Add/Remove: ScriptLauncherMaster

====================================================
Version 1.1 | 2025-01-31
====================================================
