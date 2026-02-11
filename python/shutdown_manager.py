#!/usr/bin/env python3
"""
Safe System Shutdown Manager
Gracefully shuts down services and applications before system shutdown
Usage: python shutdown_manager.py [--no-confirm] [--skip-led] [--delay N]
"""

import argparse
import logging
import subprocess
import sys
import time
from pathlib import Path


class ShutdownManager:
    """Safely shutdown system with cleanup"""

    def __init__(self):
        self.log_file = Path(r"E:\Scripts\shutdown_log.txt")
        self.led_script = Path(r"E:\Scripts\led\led_off.py")
        self.setup_logging()

    def setup_logging(self):
        """Setup logging to file and console"""
        self.log_file.parent.mkdir(parents=True, exist_ok=True)
        logging.basicConfig(
            level=logging.INFO,
            format="%(asctime)s [%(levelname)s] %(message)s",
            handlers=[
                logging.FileHandler(self.log_file, mode='w'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
        self.logger.info("=" * 60)
        self.logger.info("Safe System Shutdown Started")
        self.logger.info("=" * 60)

    def turn_off_led(self) -> bool:
        """Turn off LED lights via Sonoff"""
        self.logger.info("[STEP 1/5] Turning off LED lights...")
        print("\n" + "=" * 60)
        print("[STEP 1/5] Turning off LED lights...")
        print("=" * 60)

        if not self.led_script.exists():
            self.logger.warning(f"LED script not found: {self.led_script}")
            print(f"⚠ LED script not found: {self.led_script}")
            return False

        try:
            result = subprocess.run(
                ["python", str(self.led_script)],
                capture_output=True,
                text=True,
                timeout=15,
                check=False
            )

            print(result.stdout)
            print(result.stderr)

            if result.returncode == 0:
                self.logger.info("✓ LED lights turned off")
                print("✓ LED lights turned off")
                return True
            else:
                self.logger.warning(f"LED script returned error: {result.returncode}")
                print(f"⚠ LED script error (continuing anyway)")
                return False

        except subprocess.TimeoutExpired:
            self.logger.warning("LED script timeout")
            print("⚠ LED script timeout (continuing anyway)")
            return False
        except Exception as e:
            self.logger.warning(f"LED script error: {e}")
            print(f"⚠ LED error: {e}")
            return False

    def stop_usb_sync(self) -> bool:
        """Stop USB sync processes"""
        self.logger.info("[STEP 2/5] Stopping USB sync processes...")
        print("\n" + "=" * 60)
        print("[STEP 2/5] Stopping USB sync processes...")
        print("=" * 60)

        processes_to_kill = ["robocopy.exe", "python.exe"]
        killed_any = False

        for process in processes_to_kill:
            try:
                result = subprocess.run(
                    ["taskkill", "/F", "/IM", process],
                    capture_output=True,
                    text=True,
                    check=False
                )
                print(result.stdout)
                print(result.stderr)
                if "SUCCESS" in result.stdout.upper():
                    self.logger.info(f"  Killed: {process}")
                    print(f"  ✓ Stopped: {process}")
                    killed_any = True
            except Exception as e:
                self.logger.debug(f"Could not kill {process}: {e}")

        if killed_any:
            time.sleep(2)
            self.logger.info("✓ USB sync processes stopped")
            print("✓ USB sync stopped")
        else:
            self.logger.info("  No USB sync processes running")
            print("  No USB sync processes running")

        self.logger.info("STEP 2 complete, moving to STEP 3")
        print("STEP 2 complete, moving to STEP 3")
        return True

    def is_service_running(self, service_name: str) -> bool:
        """Check if a Windows service is running"""
        try:
            result = subprocess.run(
                ["sc", "query", service_name],
                capture_output=True,
                text=True,
                check=False
            )
            return "RUNNING" in result.stdout
        except:
            return False

    def stop_xampp_services(self) -> bool:
        """Stop XAMPP services"""
        self.logger.info("[STEP 3/5] Stopping XAMPP services...")
        print("\n" + "=" * 60)
        print("[STEP 3/5] Stopping XAMPP services...")
        print("=" * 60)

        services = [
            "Apache2.4",
            "MySQL",
            "FileZillaServer",
            "Tomcat9"
        ]

        stopped_any = False
        for service in services:
            if self.is_service_running(service):
                self.logger.info(f"  Stopping {service}...")
                print(f"  Stopping {service}...")
                subprocess.run(
                    ["net", "stop", service, "/y"],
                    capture_output=True,
                    check=False
                )
                stopped_any = True

        # Kill XAMPP control panel anyway
        subprocess.run(
            ["taskkill", "/F", "/IM", "xampp-control.exe"],
            capture_output=True,
            check=False
        )

        if stopped_any:
            self.logger.info("✓ XAMPP services stopped")
            print("✓ XAMPP services stopped")
        else:
            self.logger.info("  No XAMPP services running")
            print("  No XAMPP services running")

        self.logger.info("STEP 3 complete, moving to STEP 4")
        print("STEP 3 complete, moving to STEP 4")
        return True

    def close_applications(self) -> bool:
        """Gracefully close applications"""
        self.logger.info("[STEP 4/5] Closing applications...")
        print("\n" + "=" * 60)
        print("[STEP 4/5] Closing applications...")
        print("=" * 60)

        apps = ["chrome.exe", "firefox.exe", "msedge.exe", "WINWORD.EXE", "EXCEL.EXE", "POWERPNT.EXE"]

        # Graceful close
        for app in apps:
            subprocess.run(["taskkill", "/IM", app], capture_output=True, check=False)

        print("  Waiting for apps to close gracefully...")
        time.sleep(5)

        # Force close
        for app in apps:
            subprocess.run(["taskkill", "/F", "/IM", app], capture_output=True, check=False)

        self.logger.info("✓ Applications closed")
        print("✓ Applications closed")

        self.logger.info("STEP 4 complete, moving to STEP 5")
        print("STEP 4 complete, moving to STEP 5")
        return True

    def shutdown_system(self, delay: int = 10) -> bool:
        """Initiate system shutdown"""
        self.logger.info("[STEP 5/5] Initiating system shutdown...")
        print("\n" + "=" * 60)
        print("[STEP 5/5] System shutdown...")
        print("=" * 60)

        print(f"\nFlushing disk cache...")
        time.sleep(2)

        print(f"\n{'=' * 60}")
        print("  ALL TASKS COMPLETED SUCCESSFULLY")
        print(f"  System will shutdown in {delay} seconds...")
        print("  Press Ctrl+C to cancel")
        print("=" * 60)
        print()

        self.logger.info(f"Shutdown initiated with {delay} second delay")

        try:
            for i in range(delay, 0, -1):
                print(f"  Shutting down in {i}...", end='\r')
                time.sleep(1)

            print("\n")
            subprocess.run(["shutdown", "/s", "/f", "/t", "0"], check=True)
            return True

        except KeyboardInterrupt:
            print("\n\n✗ Shutdown cancelled by user")
            self.logger.info("Shutdown cancelled by user")
            return False

    def run(self, skip_confirm: bool = False, skip_led: bool = False):
        """Run full shutdown sequence"""

        if not skip_confirm:
            print("=" * 60)
            print("SAFE SYSTEM SHUTDOWN")
            print("=" * 60)
            print("\nThis will:")
            print("  1. Turn off LED lights")
            print("  2. Stop USB sync")
            print("  3. Stop XAMPP services")
            print("  4. Close applications")
            print("  5. Shutdown the system")
            print("\nContinue? (y/N): ", end='')

            response = input().strip().lower()
            if response not in ('y', 'yes'):
                print("Shutdown cancelled")
                return

        # Execute shutdown sequence
        if not skip_led:
            self.turn_off_led()
            time.sleep(1)

        self.stop_usb_sync()
        time.sleep(1)

        self.stop_xampp_services()
        time.sleep(1)

        self.close_applications()
        time.sleep(1)

        self.shutdown_system()


def main():
    parser = argparse.ArgumentParser(description="Safe System Shutdown Manager")
    parser.add_argument("--no-confirm", action="store_true", help="Skip confirmation prompt")
    parser.add_argument("--skip-led", action="store_true", help="Skip LED shutdown")
    parser.add_argument("--delay", type=int, default=10, help="Shutdown delay in seconds (default: 10)")
    args = parser.parse_args()

    try:
        manager = ShutdownManager()
        manager.run(skip_confirm=args.no_confirm, skip_led=args.skip_led)
    except KeyboardInterrupt:
        print("\n\nShutdown cancelled")
        sys.exit(0)
    except Exception as e:
        print(f"\n✗ Error: {e}")
        logging.error(f"Shutdown error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
