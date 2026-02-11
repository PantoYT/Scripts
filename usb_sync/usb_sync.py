#!/usr/bin/env python3
"""
USB Sync Manager
Monitors USB drive and automatically syncs files + Git repositories
Usage: python usb_sync.py [options]
"""

import argparse
import logging
import subprocess
import time
from datetime import datetime
from pathlib import Path
from typing import List, Tuple, Optional
import sys


class USBSyncManager:
    """Monitor USB and sync files + Git repos"""
    
    def __init__(self, usb_drive: str, config_file: Optional[str] = None):
        self.usb_drive = Path(usb_drive)
        self.log_file = Path(r"E:\Scripts\logs\usb_sync.log")
        self.setup_logging()
        
        # Default sync pairs: (source, dest, mirror_mode)
        # mirror_mode=True means exact copy (deletes files in dest not in source)
        # mirror_mode=False means only copy/update (keeps extra files in dest)
        self.sync_pairs = [
            # Local to USB (MIRROR - exact backup)
            (r"E:\Aplikacje", r"G:\Pliki\Inne\Instalki", True),
            (r"E:\Autohotkey", r"G:\Pliki\Inne\AutoHotkey", True),
            (r"E:\Scripts", r"G:\Pliki\Inne\Scripts", True),
            
            # USB to Local (COPY - keep extras)
            (r"G:\Pliki\Technik Programista\Bazy Danych", r"E:\Pliki\Projects\databases", False),
            (r"G:\Pliki\Technik Programista\Programowanie\cpp", r"E:\Pliki\Projects\cpp", False),
            (r"G:\Pliki\Technik Programista\Programowanie\python", r"E:\Pliki\Projects\python", False),
            (r"G:\Pliki\Technik Programista\Strony internetowe", r"E:\Pliki\Projects\websites", False),
            (r"G:\Pliki\Technik Programista\BHP", r"E:\Pliki\Projects\BHP", False),
            (r"G:\Pliki\Technik Programista\Podstawy Informatyki", r"E:\Pliki\Projects\PodstawyInformatyki", False),
            (r"G:\Pliki\Technik Programista\Informatyka", r"E:\Pliki\Projects\Informatyka", False),
            (r"G:\Pliki\Technik Programista\Przygotowanie Zawodu", r"E:\Pliki\Projects\PrzygotowanieZawodu", False),
        ]
        
        self.git_root = Path(r"E:\Pliki\Projects")
        self.check_interval = 3  # seconds
        self.resync_interval = 60  # seconds
    
    def setup_logging(self):
        """Setup logging"""
        self.log_file.parent.mkdir(parents=True, exist_ok=True)
        
        logging.basicConfig(
            level=logging.INFO,
            format="%(asctime)s [%(levelname)s] %(message)s",
            handlers=[
                logging.FileHandler(self.log_file),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def is_usb_present(self) -> bool:
        """Check if USB drive is present"""
        return self.usb_drive.exists()
    
    def sync_directory(self, source: str, dest: str, mirror: bool = False) -> bool:
        """
        Sync directory using robocopy
        Returns True if successful, False otherwise
        """
        source_path = Path(source)
        dest_path = Path(dest)
        
        if not source_path.exists():
            self.logger.warning(f"Source does not exist: {source}")
            return False
        
        # Build robocopy command
        cmd = ["robocopy", str(source_path), str(dest_path)]
        
        if mirror:
            cmd.append("/MIR")  # Mirror mode (exact copy)
        else:
            cmd.append("/E")  # Copy subdirectories including empty
        
        cmd.extend(["/R:3", "/W:5"])  # 3 retries, 5 second wait
        
        # Run robocopy
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=False
            )
            
            # Robocopy exit codes:
            # 0 = No files copied
            # 1 = Files copied successfully
            # 2 = Extra files or directories detected
            # 4 = Mismatched files or directories
            # 8+ = Failed
            
            if result.returncode < 8:
                return True
            else:
                self.logger.error(f"Robocopy failed with code {result.returncode}")
                return False
                
        except Exception as e:
            self.logger.error(f"Sync error: {e}")
            return False
    
    def sync_all(self) -> Tuple[int, int]:
        """
        Sync all configured directory pairs
        Returns (success_count, fail_count)
        """
        success = 0
        failed = 0
        
        self.logger.info("Starting sync...")
        
        for source, dest, mirror in self.sync_pairs:
            mode = "MIRROR" if mirror else "COPY"
            self.logger.info(f"Syncing [{mode}]: {source} -> {dest}")
            
            if self.sync_directory(source, dest, mirror):
                self.logger.info(f"  ✓ Success")
                success += 1
            else:
                self.logger.error(f"  ✗ Failed")
                failed += 1
        
        self.logger.info(f"Sync complete: {success} succeeded, {failed} failed")
        return success, failed
    
    def find_git_repos(self, root_dir: Path) -> List[Path]:
        """Find all Git repositories in root and first-level subdirectories"""
        repos = []
        
        # Check root directory
        if (root_dir / ".git").exists():
            repos.append(root_dir)
        
        # Check first-level subdirectories
        try:
            for subdir in root_dir.iterdir():
                if subdir.is_dir() and (subdir / ".git").exists():
                    repos.append(subdir)
        except Exception as e:
            self.logger.error(f"Error scanning for Git repos: {e}")
        
        return repos
    
    def git_sync_repo(self, repo_path: Path, max_retries: int = 3) -> bool:
        """
        Sync a single Git repository (add, commit, push)
        Returns True if successful
        """
        self.logger.info(f"Git sync: {repo_path.name}")
        
        try:
            # Check for changes
            result = subprocess.run(
                ["git", "status", "--porcelain"],
                cwd=repo_path,
                capture_output=True,
                text=True,
                check=True
            )
            
            if not result.stdout.strip():
                self.logger.info(f"  No changes to commit")
                return True
            
            # Add all changes
            subprocess.run(
                ["git", "add", "."],
                cwd=repo_path,
                capture_output=True,
                check=True
            )
            
            # Commit
            commit_msg = f"Auto backup {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
            subprocess.run(
                ["git", "commit", "-m", commit_msg],
                cwd=repo_path,
                capture_output=True,
                check=True
            )
            
            # Push with retries
            for attempt in range(1, max_retries + 1):
                try:
                    self.logger.info(f"  Push attempt {attempt}/{max_retries}")
                    subprocess.run(
                        ["git", "push", "origin", "--all"],
                        cwd=repo_path,
                        capture_output=True,
                        text=True,
                        check=True,
                        timeout=30
                    )
                    self.logger.info(f"  ✓ Git push successful")
                    return True
                except subprocess.TimeoutExpired:
                    self.logger.warning(f"  Push timeout (attempt {attempt})")
                    if attempt < max_retries:
                        time.sleep(3)
                except subprocess.CalledProcessError as e:
                    self.logger.warning(f"  Push failed (attempt {attempt}): {e.stderr}")
                    if attempt < max_retries:
                        time.sleep(3)
            
            self.logger.error(f"  ✗ Git push failed after {max_retries} attempts")
            return False
            
        except subprocess.CalledProcessError as e:
            self.logger.error(f"  ✗ Git error: {e}")
            return False
        except Exception as e:
            self.logger.error(f"  ✗ Unexpected error: {e}")
            return False
    
    def git_sync_all(self):
        """Sync all Git repositories"""
        self.logger.info("Starting Git sync...")
        
        repos = self.find_git_repos(self.git_root)
        
        if not repos:
            self.logger.info("No Git repositories found")
            return
        
        self.logger.info(f"Found {len(repos)} Git repository(ies)")
        
        for repo in repos:
            self.git_sync_repo(repo)
        
        self.logger.info("Git sync complete")
    
    def monitor(self):
        """Main monitoring loop"""
        self.logger.info("=" * 60)
        self.logger.info("USB Sync Manager Started")
        self.logger.info(f"Monitoring USB drive: {self.usb_drive}")
        self.logger.info("=" * 60)
        
        last_sync_time = 0
        
        try:
            while True:
                time.sleep(self.check_interval)
                
                if not self.is_usb_present():
                    if last_sync_time > 0:  # Was previously present
                        self.logger.info("USB drive removed")
                        last_sync_time = 0
                    continue
                
                current_time = time.time()
                
                # First detection or resync interval passed
                if last_sync_time == 0:
                    self.logger.info("USB drive detected")
                    self.sync_all()
                    self.git_sync_all()
                    last_sync_time = current_time
                elif current_time - last_sync_time >= self.resync_interval:
                    self.logger.info("Re-syncing (periodic check)")
                    self.sync_all()
                    last_sync_time = current_time
                    
        except KeyboardInterrupt:
            self.logger.info("\nStopping USB Sync Manager...")
            sys.exit(0)


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="USB Sync Manager - Auto sync files and Git repos"
    )
    parser.add_argument(
        "--usb-drive",
        default="G:",
        help="USB drive letter (default: G:)"
    )
    parser.add_argument(
        "--once",
        action="store_true",
        help="Run sync once and exit (don't monitor)"
    )
    parser.add_argument(
        "--no-git",
        action="store_true",
        help="Skip Git sync"
    )
    
    args = parser.parse_args()
    
    try:
        manager = USBSyncManager(usb_drive=args.usb_drive)
        
        if args.once:
            # Single sync run
            if not manager.is_usb_present():
                print(f"✗ USB drive not present: {args.usb_drive}")
                sys.exit(1)
            
            manager.sync_all()
            
            if not args.no_git:
                manager.git_sync_all()
            
            print("\n✓ Sync complete")
        else:
            # Continuous monitoring
            manager.monitor()
            
    except Exception as e:
        print(f"✗ Error: {e}")
        logging.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()