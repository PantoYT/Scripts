#!/usr/bin/env python3
"""
Windows Context Menu Manager - Fully Fixed
==========================================

Fixes all issues with:
  • New Folder creation (uses Directory value, NOT NullFile)
  • New Shortcut wizard (uses proper FileName value)
  • Essential file types (txt, py, md, etc.)
  • CLSID / context menu handler
  • Explorer cache clearing

Run as Administrator!
"""
import ctypes
import sys
import winreg
import subprocess
import time
import os
from typing import List, Tuple

ESSENTIAL_TYPES = {
    'text': { 'key': '.txt', 'description': 'Text Document', 'use_nullfile': True },
    'python': { 'key': '.py', 'description': 'Python File', 'use_nullfile': True },
    'markdown': { 'key': '.md', 'description': 'Markdown File', 'use_nullfile': True },
    'batch': { 'key': '.bat', 'description': 'Batch File', 'use_nullfile': True },
    'javascript': { 'key': '.js', 'description': 'JavaScript File', 'use_nullfile': True },
    'html': { 'key': '.html', 'description': 'HTML File', 'use_nullfile': True },
    'css': { 'key': '.css', 'description': 'CSS File', 'use_nullfile': True },
    'json': { 'key': '.json', 'description': 'JSON File', 'use_nullfile': True },
}

# CLSID for Windows "New" context menu
NEW_CLSID = "{D969A300-E7FF-11d0-A93B-00A0C90F2719}"


def check_admin() -> bool:
    try:
        return ctypes.windll.shell32.IsUserAnAdmin() != 0
    except Exception:
        return False


def run(cmd: List[str]) -> bool:
    """Run subprocess command silently"""
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0


def ensure_folder_shellnew():
    """
    Restore CORRECT Folder\ShellNew
    CRITICAL: Use "Directory" value, NOT "NullFile"!
    """
    try:
        with winreg.CreateKey(winreg.HKEY_CLASSES_ROOT, r"Folder\ShellNew") as key:
            # Directory value (empty string) = create folder
            # NullFile = create file (WRONG for folders!)
            winreg.SetValueEx(key, "Directory", 0, winreg.REG_SZ, "")
        print("  ✓ Folder\\ShellNew restored (Directory value)")
        return True
    except Exception as e:
        print(f"  ✗ Failed to restore Folder\\ShellNew: {e}")
        return False


def ensure_shortcut_shellnew():
    """
    Restore .lnk\ShellNew for shortcuts
    Uses FileName value for Windows 10/11 compatibility
    """
    try:
        with winreg.CreateKey(winreg.HKEY_CLASSES_ROOT, r".lnk\ShellNew") as key:
            # FileName with empty value = invoke Windows shortcut wizard
            winreg.SetValueEx(key, "FileName", 0, winreg.REG_SZ, "")
        print("  ✓ .lnk\\ShellNew restored (FileName value)")
        return True
    except Exception as e:
        print(f"  ✗ Failed to restore .lnk\\ShellNew: {e}")
        return False


def register_clsid():
    """Ensure New context menu CLSID exists"""
    try:
        clsid_path = f"CLSID\\{NEW_CLSID}"
        with winreg.CreateKey(winreg.HKEY_CLASSES_ROOT, clsid_path) as key:
            winreg.SetValueEx(key, "", 0, winreg.REG_SZ, "New")
        with winreg.CreateKey(winreg.HKEY_CLASSES_ROOT, f"{clsid_path}\\InProcServer32") as key:
            winreg.SetValueEx(key, "", 0, winreg.REG_SZ, "shell32.dll")
            winreg.SetValueEx(key, "ThreadingModel", 0, winreg.REG_SZ, "Apartment")
        print("  ✓ CLSID registered")
        return True
    except Exception as e:
        print(f"  ✗ Failed to register CLSID: {e}")
        return False


def restore_context_handlers():
    """Restore context menu handlers pointing to CLSID"""
    paths = [
        r'Directory\Background\shellex\ContextMenuHandlers\New',
        r'DesktopBackground\shellex\ContextMenuHandlers\New',
        r'Folder\ShellEx\ContextMenuHandlers\New',
        r'LibraryFolder\background\shellex\ContextMenuHandlers\New',
    ]
    success = True
    for path in paths:
        if run(['reg', 'add', f'HKEY_CLASSES_ROOT\\{path}', '/ve', '/t', 'REG_SZ', '/d', NEW_CLSID, '/f']):
            print(f"  ✓ Restored handler: {path.split(chr(92))[0]}")
        else:
            print(f"  ✗ Failed to restore handler: {path}")
            success = False
    return success


def ensure_extension(ext: str, desc: str):
    """Register essential file types (ProgID, shell\open\command, default icon)"""
    try:
        progid = f"{ext[1:]}file"
        with winreg.CreateKey(winreg.HKEY_CLASSES_ROOT, ext) as k:
            winreg.SetValueEx(k, "", 0, winreg.REG_SZ, progid)
        with winreg.CreateKey(winreg.HKEY_CLASSES_ROOT, progid) as k:
            winreg.SetValueEx(k, "", 0, winreg.REG_SZ, desc)
        # Open command for Notepad
        cmd_path = f"{progid}\\shell\\open\\command"
        with winreg.CreateKey(winreg.HKEY_CLASSES_ROOT, cmd_path) as k:
            winreg.SetValueEx(k, "", 0, winreg.REG_SZ, 'notepad.exe "%1"')
        # Default icon
        icon_path = f"{progid}\\DefaultIcon"
        with winreg.CreateKey(winreg.HKEY_CLASSES_ROOT, icon_path) as k:
            winreg.SetValueEx(k, "", 0, winreg.REG_SZ, "%SystemRoot%\\system32\\imageres.dll,-102")
        # Create ShellNew
        shellnew_path = f"{ext}\\ShellNew"
        with winreg.CreateKey(winreg.HKEY_CLASSES_ROOT, shellnew_path) as k:
            winreg.SetValueEx(k, "NullFile", 0, winreg.REG_SZ, "")
        print(f"  ✓ Registered {desc} ({ext})")
    except Exception as e:
        print(f"  ⚠ Failed to register {ext}: {e}")


def clear_cache():
    """Clear Explorer icon cache and shell bags"""
    try:
        bags_paths = [
            r"Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU",
            r"Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags",
        ]
        for path in bags_paths:
            try:
                winreg.DeleteKey(winreg.HKEY_CURRENT_USER, path)
            except:
                pass
        icon_cache = os.path.join(os.environ.get('LOCALAPPDATA', ''), 'IconCache.db')
        if os.path.exists(icon_cache):
            subprocess.run(['attrib', '-h', icon_cache], capture_output=True)
            os.remove(icon_cache)
            print("  ✓ Icon cache cleared")
    except:
        pass


def restart_explorer():
    """Restart Explorer to apply changes"""
    try:
        subprocess.run(['taskkill', '/F', '/IM', 'explorer.exe'], capture_output=True)
        time.sleep(1)
        subprocess.Popen(['explorer.exe'])
        time.sleep(2)
        print("  ✓ Explorer restarted")
    except Exception as e:
        print(f"  ✗ Failed to restart Explorer: {e}")


def full_fix():
    """Apply full fix to restore folders, shortcuts, and file types"""
    print("="*60)
    print("APPLYING FULL FIX")
    print("="*60)
    if not check_admin():
        print("⚠ Administrator required! Run as admin.")
        return
    
    print("\n[1] Restoring Folder\\ShellNew (with Directory value)...")
    ensure_folder_shellnew()
    
    print("\n[2] Restoring .lnk\\ShellNew (with FileName value)...")
    ensure_shortcut_shellnew()
    
    print("\n[3] Registering CLSID...")
    register_clsid()
    
    print("\n[4] Restoring context menu handlers...")
    restore_context_handlers()
    
    print("\n[5] Adding essential file types...")
    for name, cfg in ESSENTIAL_TYPES.items():
        ensure_extension(cfg['key'], cfg['description'])
    
    print("\n[6] Clearing Explorer cache...")
    clear_cache()
    
    print("\n[7] Restarting Explorer...")
    restart_explorer()
    
    print("\n" + "="*60)
    print("✓ FULL FIX COMPLETE!")
    print("="*60)
    print("\nTest now:")
    print("  • Right-click → New → Folder")
    print("  • Right-click → New → Shortcut")
    print("  • Ctrl+Shift+N (folder hotkey)")
    print("\nAll should work with default Windows behavior!")
    print("="*60)


def main():
    if not check_admin():
        print("="*60)
        print("⚠ Administrator privileges required!")
        print("="*60)
        print("\nPlease right-click this script and select 'Run as Administrator'")
        input("\nPress Enter to exit...")
        sys.exit(1)
    
    full_fix()
    input("\nPress Enter to exit...")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nCancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n\nFATAL ERROR: {e}")
        import traceback
        traceback.print_exc()
        input("\nPress Enter to exit...")
        sys.exit(1)