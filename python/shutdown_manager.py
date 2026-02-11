#!/usr/bin/env python3
import argparse
import logging
import subprocess
import sys
import time
from pathlib import Path

class ShutdownManager:
    def __init__(self):
        self.log_file = Path(r"E:\Scripts\shutdown_log.txt")
        self.led_script = Path(r"E:\Scripts\led\led_off.py")
        self.setup_logging()

    def setup_logging(self):
        self.log_file.parent.mkdir(parents=True, exist_ok=True)
        logging.basicConfig(
            level=logging.INFO,
            format="%(asctime)s [%(levelname)s] %(message)s",
            handlers=[logging.FileHandler(self.log_file, mode='w'), logging.StreamHandler()]
        )
        self.logger = logging.getLogger(__name__)
        self.logger.info("="*60)
        self.logger.info("Safe System Shutdown Started")
        self.logger.info("="*60)

    def turn_off_led(self) -> bool:
        self.logger.info("[STEP 1/5] Turning off LED lights...")
        print("\n" + "="*60)
        print("[STEP 1/5] Turning off LED lights...")
        print("="*60)

        if not self.led_script.exists():
            self.logger.warning(f"LED script not found: {self.led_script}")
            print(f"[WARN] LED script not found: {self.led_script}")
            return False

        try:
            result = subprocess.run(
                ["python", str(self.led_script)],
                capture_output=True,
                text=True,
                timeout=15,
                check=False
            )
            # Print LED output safely
            print(result.stdout)
            print(result.stderr)
            if result.returncode == 0:
                self.logger.info("[OK] LED lights turned off")
                print("[OK] LED lights turned off")
                return True
            else:
                self.logger.warning("[WARN] LED script returned error")
                print("[WARN] LED script returned error (continuing)")
                return False
        except Exception as e:
            self.logger.warning(f"[ERROR] LED script exception: {e}")
            print(f"[ERROR] LED script exception: {e}")
            return False

    def stop_usb_sync(self) -> bool:
        self.logger.info("[STEP 2/5] Stopping USB sync processes...")
        print("\n" + "="*60)
        print("[STEP 2/5] Stopping USB sync processes...")
        print("="*60)

        processes_to_kill = ["robocopy.exe", "python.exe"]
        killed_any = False
        for proc in processes_to_kill:
            try:
                result = subprocess.run(
                    ["taskkill", "/F", "/IM", proc],
                    capture_output=True,
                    text=True
                )
                print(result.stdout)
                print(result.stderr)
                if "SUCCESS" in result.stdout.upper():
                    killed_any = True
            except Exception as e:
                self.logger.warning(f"[ERROR] Could not kill {proc}: {e}")
        if killed_any:
            self.logger.info("[OK] USB sync stopped")
            print("[OK] USB sync stopped")
        else:
            self.logger.info("[INFO] No USB sync processes running")
            print("[INFO] No USB sync processes running")

        print("STEP 2 complete, moving to STEP 3")
        return True

    def is_service_running(self, service_name: str) -> bool:
        try:
            result = subprocess.run(["sc", "query", service_name], capture_output=True, text=True)
            return "RUNNING" in result.stdout
        except:
            return False

    def stop_xampp_services(self) -> bool:
        self.logger.info("[STEP 3/5] Stopping XAMPP services...")
        print("\n" + "="*60)
        print("[STEP 3/5] Stopping XAMPP services...")
        print("="*60)

        services = ["Apache2.4","MySQL","FileZillaServer","Tomcat9"]
        stopped_any = False
        for s in services:
            if self.is_service_running(s):
                print(f"Stopping {s}...")
                subprocess.run(["net", "stop", s, "/y"], capture_output=True)
                stopped_any = True
        subprocess.run(["taskkill", "/F", "/IM", "xampp-control.exe"], capture_output=True)
        if stopped_any:
            print("[OK] XAMPP services stopped")
        else:
            print("[INFO] No XAMPP services running")

        print("STEP 3 complete, moving to STEP 4")
        return True

    def close_applications(self) -> bool:
        self.logger.info("[STEP 4/5] Closing applications...")
        apps = ["chrome.exe","firefox.exe","msedge.exe","WINWORD.EXE","EXCEL.EXE","POWERPNT.EXE"]
        print("[STEP 4/5] Closing applications...")
        for app in apps:
            subprocess.run(["taskkill", "/IM", app], capture_output=True)
        time.sleep(5)
        for app in apps:
            subprocess.run(["taskkill", "/F", "/IM", app], capture_output=True)
        print("[OK] Applications closed")
        print("STEP 4 complete, moving to STEP 5")
        return True

    def shutdown_system(self, delay: int = 10) -> bool:
        self.logger.info("[STEP 5/5] Initiating system shutdown...")
        print("[STEP 5/5] System shutdown...")
        print(f"System will shutdown in {delay} seconds (Ctrl+C to cancel)")
        try:
            for i in range(delay,0,-1):
                print(f"Shutting down in {i}...", end='\r')
                time.sleep(1)
            subprocess.run(["shutdown","/s","/f","/t","0"], check=True)
            return True
        except KeyboardInterrupt:
            print("\nShutdown cancelled by user")
            return False

    def run(self, skip_confirm=False, skip_led=False):
        if not skip_confirm:
            response = input("Continue with shutdown? (y/N): ").strip().lower()
            if response not in ("y","yes"):
                print("Shutdown cancelled")
                return
        if not skip_led: self.turn_off_led()
        self.stop_usb_sync()
        self.stop_xampp_services()
        self.close_applications()
        self.shutdown_system()


if __name__=="__main__":
    parser = argparse.ArgumentParser(description="Safe System Shutdown Manager")
    parser.add_argument("--no-confirm", action="store_true", help="Skip confirmation")
    parser.add_argument("--skip-led", action="store_true", help="Skip LED step")
    parser.add_argument("--delay", type=int, default=10, help="Shutdown delay")
    args = parser.parse_args()

    manager = ShutdownManager()
    manager.run(skip_confirm=args.no_confirm, skip_led=args.skip_led)
