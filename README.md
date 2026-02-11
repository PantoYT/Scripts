# Scripts

A collection of Python scripts to help optimize my workflow - rewritten from batch/VBS for better maintainability.

## ⚠️ Warning
Projects: **usb_sync**, **autodb**, **autohtdocs** have been updated and combined into the **AutoSync** application:
→ https://github.com/PantoYT/AutoSync

The original Python versions remain here as **v1** predecessors to the AutoSync application.

---

## 📦 Requirements

```bash
pip install aiohttp  # For LED controller (Sonoff integration)
```

**Additional dependencies:** Keep `sonoff_manager.py`, `base.py`, and `cloud.py` in the same directory as LED scripts.

---

## 📁 Script Overview

### 1. 💡 LED Controller (Sonoff eWeLink)

**Files:** `led_on.py`, `led_off.py`, `led_controller.py`

Control Sonoff smart switches via eWeLink cloud.

**Standalone scripts (for autostart/shutdown):**
```bash
# Turn LED on (use in Windows startup)
python led_on.py

# Turn LED off (use in shutdown script)
python led_off.py
```

**Universal controller (for manual control):**
```bash
# Turn LED on
python led_controller.py on

# Turn LED off
python led_controller.py off

# Toggle LED state
python led_controller.py toggle

# Show all devices and their status
python led_controller.py status
```

**Setup - Environment variables:**
```cmd
setx EWELINK_EMAIL "your_email@example.com"
setx EWELINK_PASSWORD "your_password"
setx EWELINK_COUNTRY "+48"
```

**Use cases:**
- `led_on.py` → Windows Task Scheduler (startup)
- `led_off.py` → Shutdown script
- `led_controller.py` → Manual control & testing

---

### 2. 🌐 XAMPP Manager

**File:** `xampp_manager.py`

**Replaces:** `start_xampp_simple.bat`, `xampp_install_services.bat`, `xampp_uninstall_services.bat`, `xampp_registry_starter.vbs`

All XAMPP control in ONE script.

**Usage:**
```bash
# Start Apache and MySQL
python xampp_manager.py start

# Stop services
python xampp_manager.py stop

# Restart services
python xampp_manager.py restart

# Check status
python xampp_manager.py status

# Install as Windows services (requires Admin)
python xampp_manager.py install

# Uninstall Windows services (requires Admin)
python xampp_manager.py uninstall
```

**Configuration:** Edit `xampp_root` parameter if not using `E:\xampp`

---

### 3. 🗄️ MySQL Importer

**File:** `mysql_importer.py`

**Replaces:** `autodb.bat`, `dbportable.bat`

**Status:** ⚠️ **v1** - Superseded by [AutoSync](https://github.com/PantoYT/AutoSync)

Imports all `.sql` files from a directory structure into MySQL with automatic database naming.

**Usage:**
```bash
# Portable mode (prompts for USB/XAMPP drives)
python mysql_importer.py -i
# or
python mysql_importer.py --portable

# Automatic mode with default paths
python mysql_importer.py

# Custom paths
python mysql_importer.py --basedir "G:\Pliki\..." --mysql "E:\xampp\mysql\bin\mysql.exe"

# Dry run (show what would be done)
python mysql_importer.py --dry-run

# With password
python mysql_importer.py --password "your_password"
```

**Database naming:** Creates databases as `{class}_{filename}` where class is the first folder in the path.

---

### 4. 📂 htdocs Manager

**File:** `htdocs_manager.py`

**Replaces:** `autohtdocs.bat`, `htdocsportable.bat`

**Status:** ⚠️ **v1** - Superseded by [AutoSync](https://github.com/PantoYT/AutoSync)

Copies PHP projects to XAMPP htdocs with intelligent naming.

**Usage:**
```bash
# Portable mode (prompts for USB/XAMPP drives)
python htdocs_manager.py -i
# or
python htdocs_manager.py --portable

# Automatic mode
python htdocs_manager.py

# Custom paths
python htdocs_manager.py --source "E:\Pliki\Projects\websites" --dest "E:\xampp\htdocs\myfiles"

# Overwrite existing projects
python htdocs_manager.py --overwrite

# Dry run
python htdocs_manager.py --dry-run
```

**Naming logic:**
- Projects directly in source: uses folder name
- Nested projects: uses `{parent}_{folder}` format

---

### 5. 🖱️ Context Menu Manager

**File:** `context_menu_manager.py`

**Replaces:** `newmenufix.bat`

**REQUIRES:** Administrator privileges

Nukes the Windows "New" context menu and rebuilds it with only mission-critical file types.

**Problem solved:** Too many useless items in right-click → New menu (Word, Excel, PowerPoint templates, etc.)

**Usage:**
```bash
# Interactive menu
python context_menu_manager.py

# Diagnostic scan only
python context_menu_manager.py --diagnostic

# Nuclear fix (auto mode, no confirmation - dangerous!)
python context_menu_manager.py --auto

# Nuclear fix + restore some Windows defaults
python context_menu_manager.py --restore-defaults
```

**What it does:**
1. **Diagnostic**: Scans and shows all items in "New" menu
2. **Nuclear Fix**: 
   - Removes ALL items from "New" menu
   - Restores core context menu handlers
   - Adds back ONLY essentials:
     - Folder
     - Text Document (.txt)
     - Python File (.py)
     - Batch File (.bat)
     - Markdown File (.md)
   - Restarts Windows Explorer

**Essential types can be customized** by editing `ESSENTIAL_TYPES` in the script.

---

### 6. 💾 USB Sync Manager

**File:** `usb_sync.py`

**Replaces:** `syncs_usb.bat`, `syncs_usb_v2.bat`, `usb_monitor.vbs`

**Status:** ⚠️ **v1** - Superseded by [AutoSync](https://github.com/PantoYT/AutoSync)

Monitors USB drive, syncs files, and auto-commits to Git. An "old but gold" system that remains as a predecessor to the modern AutoSync application.

**Features:**
- ✅ Continuous USB monitoring
- ✅ Automatic file synchronization (robocopy)
- ✅ Git auto-commit and push
- ✅ Mirror mode for backups (exact copy)
- ✅ Comprehensive logging
- ✅ Error recovery

**Usage:**
```bash
# Start monitoring (runs continuously)
python usb_sync.py

# Run once and exit
python usb_sync.py --once

# Skip Git sync
python usb_sync.py --no-git

# Custom USB drive
python usb_sync.py --usb-drive "F:"
```

**Configuration:** Edit the `sync_pairs` list in the script to customize what gets synced.

**Sync modes:**
- `mirror=True`: Exact copy (deletes files in destination not in source) - use for backups
- `mirror=False`: Copy/update only (keeps extra files) - use for development files

---

### 6. 🔌 Shutdown Manager

**File:** `shutdown_manager.py`

**Replaces:** `shutdown.bat`

Safe system shutdown with cleanup.

**Usage:**
```bash
# Interactive shutdown (asks for confirmation)
python shutdown_manager.py

# Auto shutdown (no confirmation)
python shutdown_manager.py --no-confirm

# Skip LED shutdown
python shutdown_manager.py --skip-led

# Custom delay (default 10 seconds)
python shutdown_manager.py --delay 5
```

**Shutdown sequence:**
1. Turn off LED lights (calls `led_off.py`)
2. Stop USB sync processes
3. Stop XAMPP services
4. Close applications gracefully
5. Shutdown system

---

## 🔧 Setup Instructions

### One-time Setup

**1. Copy scripts to a central location:**
```bash
mkdir E:\Scripts\python
copy *.py E:\Scripts\python\
```

**2. LED Scripts - Separate folder for dependencies:**
```bash
mkdir E:\Scripts\led
copy led_on.py led_off.py led_controller.py E:\Scripts\led\
copy sonoff_manager.py base.py cloud.py E:\Scripts\led\
```

**3. Add to Windows Task Scheduler:**

**For LED autostart:**
- Open Task Scheduler
- Create Basic Task → "LED Startup"
- Trigger: At startup
- Action: Start a program
- Program: `pythonw.exe` (no window)
- Arguments: `E:\Scripts\led\led_on.py`

**For USB sync (if using v1):**
- Create Basic Task → "USB Sync Monitor"
- Trigger: At startup
- Program: `pythonw.exe`
- Arguments: `E:\Scripts\python\usb_sync.py`

**4. Create desktop shortcuts:**
```
XAMPP Start:
  Target: python E:\Scripts\python\xampp_manager.py start

Safe Shutdown:
  Target: python E:\Scripts\python\shutdown_manager.py --no-confirm
```

---

## 🎯 Quick Reference

| Task | Script | Command |
|------|--------|---------|
| LED on (startup) | `led_on.py` | `python led_on.py` |
| LED off (shutdown) | `led_off.py` | `python led_off.py` |
| LED manual control | `led_controller.py` | `python led_controller.py [on\|off\|toggle\|status]` |
| Start XAMPP | `xampp_manager.py` | `python xampp_manager.py start` |
| Install XAMPP service | `xampp_manager.py` | `python xampp_manager.py install` |
| Import SQL (portable) | `mysql_importer.py` | `python mysql_importer.py -i` |
| Copy to htdocs (portable) | `htdocs_manager.py` | `python htdocs_manager.py -i` |
| Fix "New" context menu | `context_menu_manager.py` | `python context_menu_manager.py` |
| USB sync (v1) | `usb_sync.py` | `python usb_sync.py` |
| Safe shutdown | `shutdown_manager.py` | `python shutdown_manager.py` |

---

## 📝 Migration Notes

### From Batch/VBS to Python

**Old → New:**
- `led_on.py` (old) → `led_on.py` (new, standalone)
- `led_off.py` (old) → `led_off.py` (new, standalone) + `led_controller.py` (universal)
- 5 LED scripts → 3 files (cleaner architecture)
- `newmenufix.bat` → `context_menu_manager.py` (more robust, Python registry manipulation)
- 18 total scripts → 10 Python files
- Better error handling, logging, and user feedback

### Portable Mode

Both database and htdocs managers support **portable mode** with `-i` or `--portable` flag:
- Prompts for USB drive letter
- Prompts for XAMPP drive letter  
- Validates paths before proceeding
- Perfect for use on different computers/setups

**Example:**
```bash
python mysql_importer.py -i
# Prompts: USB drive (G:), XAMPP drive (E:)
# Then imports automatically
```

### Version 1 Scripts (Legacy)

The following scripts are **v1** and have been superseded by [AutoSync](https://github.com/PantoYT/AutoSync):
- `usb_sync.py`
- `mysql_importer.py`
- `htdocs_manager.py`

They remain here as:
- Historical reference
- Learning resource
- Fallback option
- "Old but gold" reliable systems

---

## ✨ Improvements Over Batch/VBS

1. **Better error handling** - Python exceptions vs BAT error codes
2. **Colored/formatted output** - Easier to read
3. **Logging** - All operations logged to files
4. **Cross-platform potential** - Can be adapted for Linux/Mac
5. **Type hints** - Better code documentation
6. **Modular code** - Reusable classes and functions
7. **Dry-run modes** - Test before executing
8. **Interactive modes** - User-friendly prompts
9. **Command-line arguments** - Flexible configuration
10. **No VBScript or hidden CMD windows** - Clean Python processes

---

## 🐛 Troubleshooting

**LED Controller not working:**
- Check environment variables are set (`EWELINK_EMAIL`, `EWELINK_PASSWORD`)
- Verify `sonoff_manager.py`, `base.py`, `cloud.py` are in same directory
- Check internet connection
- Verify eWeLink credentials

**XAMPP Manager:**
- Run as Administrator for service installation
- Check XAMPP path is correct (`E:\xampp` by default)
- Verify Apache/MySQL binaries exist

**USB Sync (v1):**
- Check USB drive letter is correct
- Verify source/destination paths exist
- Check Git is installed and in PATH
- Review logs in `E:\Scripts\logs\usb_sync.log`
- **Consider migrating to [AutoSync](https://github.com/PantoYT/AutoSync)**

**Permissions:**
- Some operations require Administrator privileges
- Right-click → "Run as Administrator" when needed

---

## 💡 Tips

- All scripts support `--help` flag for detailed usage
- Logs are stored in `E:\Scripts\logs\`
- Scripts are configured for drives E: and G: by default
- Edit paths in scripts if your setup is different
- Use `pythonw.exe` instead of `python.exe` in Task Scheduler to run without console window

---

## 📚 Project Structure

```
E:\Scripts\
├── led\
│   ├── led_on.py           # Startup script
│   ├── led_off.py          # Shutdown script
│   ├── led_controller.py   # Manual control
│   ├── sonoff_manager.py   # eWeLink manager
│   ├── base.py             # Base classes
│   └── cloud.py            # Cloud API
├── python\
│   ├── xampp_manager.py
│   ├── mysql_importer.py    # v1
│   ├── htdocs_manager.py    # v1
│   ├── usb_sync.py          # v1 - old but gold
│   └── shutdown_manager.py
└── logs\
    ├── led_on.log
    ├── led_off.log
    ├── usb_sync.log
    └── shutdown_log.txt
```

---

## 🎉 Summary

**Evolution:**
- 18 BAT/VBS scripts → 10 Python files
- No more batch file hell!
- Modern, maintainable codebase
- v1 scripts preserved for history
- Portable modes for flexibility

**Active projects:**
- LED control (on/off + universal controller)
- XAMPP management
- Context menu fixer (NEW!)
- Safe shutdown

**Legacy projects (v1):**
- USB sync → See [AutoSync](https://github.com/PantoYT/AutoSync)
- MySQL importer → See AutoSync (portable mode still useful!)
- htdocs manager → See AutoSync (portable mode still useful!)

---

Feel free to explore and use the code. Each script is self-contained and well-documented.