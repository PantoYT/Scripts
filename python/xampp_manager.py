#!/usr/bin/env python3
"""
XAMPP Manager - FIXED VERSION
Control Apache and MySQL services
Usage: python xampp_manager_fixed.py [start|stop|restart|status]
"""

import subprocess
import sys
import time
from pathlib import Path
import ctypes

def pause():
    """Pause and wait for user input"""
    input("\nPress Enter to exit...")

class XAMPPManager:
    """Manage XAMPP Apache and MySQL services"""
    
    def __init__(self, xampp_root: str = r"E:\xampp"):
        self.xampp_root = Path(xampp_root)
        self.apache_bin = self.xampp_root / "apache" / "bin" / "httpd.exe"
        self.mysql_bin = self.xampp_root / "mysql" / "bin" / "mysqld.exe"
        
    def is_admin(self) -> bool:
        """Check if running as administrator"""
        try:
            return ctypes.windll.shell32.IsUserAnAdmin()
        except:
            return False
    
    def is_process_running(self, process_name: str) -> bool:
        """Check if a process is running"""
        try:
            result = subprocess.run(
                ["tasklist", "/FI", f"IMAGENAME eq {process_name}"],
                capture_output=True,
                text=True,
                check=False
            )
            return process_name.lower() in result.stdout.lower()
        except Exception as e:
            print(f"Warning: Could not check process {process_name}: {e}")
            return False
    
    def is_service_installed(self, service_name: str) -> bool:
        """Check if a Windows service is installed"""
        try:
            result = subprocess.run(
                ["sc", "query", service_name],
                capture_output=True,
                text=True,
                check=False
            )
            return result.returncode == 0
        except:
            return False
    
    def start_services(self):
        """Start Apache and MySQL"""
        print("Starting XAMPP services...")
        print()
        
        apache_service = self.is_service_installed("Apache2.4")
        mysql_service = self.is_service_installed("MySQL")
        
        if apache_service and mysql_service:
            print("[1/2] Starting Apache service...")
            subprocess.run(["net", "start", "Apache2.4"], check=False)
            
            print("[2/2] Starting MySQL service...")
            subprocess.run(["net", "start", "MySQL"], check=False)
        else:
            print("[1/2] Starting Apache...")
            subprocess.Popen(
                [str(self.apache_bin)],
                cwd=str(self.apache_bin.parent),
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            time.sleep(2)
            
            print("[2/2] Starting MySQL...")
            subprocess.Popen(
                [str(self.mysql_bin), "--defaults-file=my.ini"],
                cwd=str(self.mysql_bin.parent),
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            time.sleep(3)
        
        print()
        self.show_status()
    
    def stop_services(self):
        """Stop Apache and MySQL"""
        print("Stopping XAMPP services...")
        print()
        
        if self.is_service_installed("Apache2.4"):
            print("[1/2] Stopping Apache service...")
            subprocess.run(["net", "stop", "Apache2.4", "/y"], check=False)
        else:
            print("[1/2] Stopping Apache process...")
            subprocess.run(["taskkill", "/F", "/IM", "httpd.exe"], check=False)
        
        if self.is_service_installed("MySQL"):
            print("[2/2] Stopping MySQL service...")
            subprocess.run(["net", "stop", "MySQL", "/y"], check=False)
        else:
            print("[2/2] Stopping MySQL process...")
            subprocess.run(["taskkill", "/F", "/IM", "mysqld.exe"], check=False)
        
        print()
        print("OK Services stopped")
    
    def restart_services(self):
        """Restart Apache and MySQL"""
        print("Restarting XAMPP services...")
        self.stop_services()
        time.sleep(2)
        self.start_services()
    
    def show_status(self):
        """Show status of Apache and MySQL"""
        print("XAMPP Service Status:")
        print("-" * 40)
        
        apache_running = self.is_process_running("httpd.exe")
        apache_status = "OK RUNNING" if apache_running else "X NOT RUNNING"
        print(f"Apache:  {apache_status}")
        
        mysql_running = self.is_process_running("mysqld.exe")
        mysql_status = "OK RUNNING" if mysql_running else "X NOT RUNNING"
        print(f"MySQL:   {mysql_status}")
        
        print("-" * 40)
        if apache_running and mysql_running:
            print("\nOK All services running")
            print("  Visit: http://localhost")
        elif not apache_running and not mysql_running:
            print("\nX All services stopped")
        else:
            print("\n! Some services not running")

def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("XAMPP Manager")
        print("=" * 50)
        print("Usage: python xampp_manager_fixed.py [command]")
        print("\nCommands:")
        print("  start   - Start Apache and MySQL")
        print("  stop    - Stop Apache and MySQL")
        print("  restart - Restart Apache and MySQL")
        print("  status  - Show service status")
        print("\nConfiguration:")
        print("  Edit XAMPP path in script if not using E:\\xampp")
        pause()
        sys.exit(1)
    
    command = sys.argv[1].lower()
    manager = XAMPPManager()
    
    try:
        if command == "start":
            manager.start_services()
        elif command == "stop":
            manager.stop_services()
        elif command == "restart":
            manager.restart_services()
        elif command == "status":
            manager.show_status()
        else:
            print(f"X Unknown command: {command}")
            print("Valid commands: start, stop, restart, status")
            pause()
            sys.exit(1)
        
        pause()
    except KeyboardInterrupt:
        print("\n\nOperation cancelled")
        pause()
        sys.exit(0)
    except Exception as e:
        print(f"\nX Error: {e}")
        pause()
        sys.exit(1)

if __name__ == "__main__":
    main()