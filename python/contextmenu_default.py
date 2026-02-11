#!/usr/bin/env python3
import ctypes
import sys
import winreg
import subprocess
import time

# Default Windows ShellNew types
DEFAULT_TYPES = {
    '.txt':      'Text Document',
    '.bmp':      'Bitmap Image',
    '.rtf':      'Rich Text Document',
    '.zip':      'Compressed Folder',
    '.contact':  'Contact',
    '.folder':   'Folder'
}

def check_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def remove_custom_shellnew():
    print("Scanning for ShellNew entries...")
    to_delete = []
    with winreg.OpenKey(winreg.HKEY_CLASSES_ROOT, "") as root:
        i = 0
        while True:
            try:
                key_name = winreg.EnumKey(root, i)
                i += 1
                if key_name.startswith('.'):
                    try:
                        with winreg.OpenKey(winreg.HKEY_CLASSES_ROOT, f"{key_name}\\ShellNew") as sn:
                            if key_name not in DEFAULT_TYPES:
                                to_delete.append(key_name)
                    except FileNotFoundError:
                        pass
            except OSError:
                break

    for ext in to_delete:
        try:
            subprocess.run(['reg', 'delete', f'HKEY_CLASSES_ROOT\\{ext}\\ShellNew', '/f'],
                           capture_output=True, check=False)
            print(f"Removed custom ShellNew: {ext}")
        except Exception as e:
            print(f"Failed to remove {ext}: {e}")

def restore_defaults():
    print("\nRestoring default ShellNew entries...")
    for ext, desc in DEFAULT_TYPES.items():
        try:
            with winreg.CreateKey(winreg.HKEY_CLASSES_ROOT, f"{ext}\\ShellNew") as key:
                if ext == '.folder':
                    winreg.SetValueEx(key, "Directory", 0, winreg.REG_SZ, "")
                else:
                    winreg.SetValueEx(key, "NullFile", 0, winreg.REG_SZ, "")
            print(f"Restored: {desc} ({ext})")
        except Exception as e:
            print(f"Failed: {ext}: {e}")

def restore_handlers():
    print("\nRestoring default context menu handlers...")
    clsid = "{D969A300-E7FF-11d0-A93B-00A0C90F2719}"
    paths = [
        r'HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\New',
        r'HKEY_CLASSES_ROOT\DesktopBackground\shellex\ContextMenuHandlers\New',
        r'HKEY_CLASSES_ROOT\Folder\ShellEx\ContextMenuHandlers\New'
    ]
    for p in paths:
        subprocess.run(['reg', 'add', p, '/ve', '/t', 'REG_SZ', '/d', clsid, '/f'],
                       capture_output=True)
    print("Handlers restored.")

def fix_lnk_assoc():
    print("\nFixing .lnk shortcut associations...")
    subprocess.run(['assoc', '.lnk=lnkfile'], shell=True)
    subprocess.run(['ftype', 'lnkfile="%SystemRoot%\\System32\\rundll32.exe" "%SystemRoot%\\System32\\shell32.dll",OpenAs_RunDLL %1'], shell=True)
    print(".lnk associations fixed.")

def restart_explorer():
    print("\nRestarting Explorer...")
    subprocess.run(['taskkill', '/F', '/IM', 'explorer.exe'], capture_output=True)
    time.sleep(1)
    subprocess.Popen(['explorer.exe'])
    time.sleep(1)
    print("Explorer restarted.")

if __name__ == "__main__":
    if not check_admin():
        print("Run this script as Administrator!")
        sys.exit(1)

    remove_custom_shellnew()
    restore_defaults()
    restore_handlers()
    fix_lnk_assoc()
    restart_explorer()
    print("\n✅ Windows New menu and icons fully restored to default!")
