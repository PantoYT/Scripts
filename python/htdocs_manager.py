#!/usr/bin/env python3
"""
XAMPP htdocs Manager - FIXED VERSION
Copies PHP projects from source to htdocs with proper naming
"""

import argparse
import shutil
import sys
from pathlib import Path
from typing import List, Set

def pause():
    """Pause and wait for user input"""
    input("\nPress Enter to exit...")

class HtdocsManager:
    """Manage copying PHP projects to XAMPP htdocs"""
    
    def __init__(self, source: str, dest: str):
        self.source = Path(source)
        self.dest = Path(dest)
        
        if not self.source.exists():
            raise ValueError(f"Source directory not found: {self.source}")
        
        self.dest.mkdir(parents=True, exist_ok=True)
    
    def find_php_projects(self) -> List[Path]:
        """Find all directories containing PHP files"""
        php_files = list(self.source.rglob("*.php"))
        project_dirs = set()
        
        for php_file in php_files:
            project_dirs.add(php_file.parent)
        
        return sorted(project_dirs)
    
    def get_target_name(self, project_dir: Path) -> str:
        """Generate target directory name"""
        try:
            rel_path = project_dir.relative_to(self.source)
        except ValueError:
            return project_dir.name
        
        parts = rel_path.parts
        
        if len(parts) == 1:
            return parts[0]
        
        parent_name = parts[0]
        folder_name = parts[-1]
        
        return f"{parent_name}_{folder_name}"
    
    def copy_projects(self, dry_run: bool = False, overwrite: bool = False):
        """Copy all PHP projects to htdocs"""
        projects = self.find_php_projects()
        
        if not projects:
            print(f"X No PHP projects found in {self.source}")
            return
        
        print(f"Found {len(projects)} PHP project(s)")
        print("=" * 70)
        print()
        
        copied_count = 0
        skipped_count = 0
        copied_targets: Set[str] = set()
        
        for project_dir in projects:
            target_name = self.get_target_name(project_dir)
            target_path = self.dest / target_name
            
            if target_name in copied_targets:
                continue
            
            rel_source = project_dir.relative_to(self.source)
            print(f"[+] {rel_source}")
            print(f"    -> {target_name}")
            
            if target_path.exists() and not overwrite:
                print(f"    - Skipped (already exists)")
                skipped_count += 1
            else:
                if dry_run:
                    print(f"    [DRY RUN] Would copy")
                    copied_count += 1
                else:
                    try:
                        if target_path.exists():
                            shutil.rmtree(target_path)
                        
                        shutil.copytree(project_dir, target_path)
                        print(f"    OK Copied")
                        copied_count += 1
                        copied_targets.add(target_name)
                    except Exception as e:
                        print(f"    X Error: {e}")
            
            print()
        
        print("=" * 70)
        print(f"OK Copied:  {copied_count}")
        if skipped_count > 0:
            print(f"-  Skipped: {skipped_count}")
        print("=" * 70)

def interactive_mode():
    """Interactive mode"""
    print("=" * 70)
    print("htdocs Manager - Interactive Mode")
    print("=" * 70)
    print()
    
    print("Enter USB drive letter (e.g., G):")
    usb_drive = input("> ").strip().upper()
    if not usb_drive:
        usb_drive = "G"
    
    print("\nEnter XAMPP drive letter (e.g., E):")
    xampp_drive = input("> ").strip().upper()
    if not xampp_drive:
        xampp_drive = "E"
    
    print("\nEnter htdocs subfolder name (e.g., myfiles):")
    htdocs_folder = input("> ").strip()
    if not htdocs_folder:
        htdocs_folder = "myfiles"
    
    source = f"{usb_drive}:\\Pliki\\Technik Programista\\Strony internetowe"
    dest = f"{xampp_drive}:\\xampp\\htdocs\\{htdocs_folder}"
    
    print()
    print(f"Source:      {source}")
    print(f"Destination: {dest}")
    print()
    
    print("Overwrite existing projects? (y/N):")
    overwrite_input = input("> ").strip().lower()
    overwrite = overwrite_input in ('y', 'yes')
    
    print()
    
    try:
        manager = HtdocsManager(source, dest)
        manager.copy_projects(overwrite=overwrite)
    except Exception as e:
        print(f"\nX Error: {e}")
        pause()
        sys.exit(1)
    
    pause()

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Copy PHP projects to XAMPP htdocs"
    )
    parser.add_argument(
        "--source",
        help="Source directory containing PHP projects",
        default=r"E:\Pliki\Projects\websites"
    )
    parser.add_argument(
        "--dest",
        help="Destination htdocs directory",
        default=r"E:\xampp\htdocs\myfiles"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done"
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing projects"
    )
    parser.add_argument(
        "--interactive", "-i",
        action="store_true",
        help="Interactive mode"
    )
    
    args = parser.parse_args()
    
    try:
        if args.interactive:
            interactive_mode()
            return
        
        manager = HtdocsManager(
            source=args.source,
            dest=args.dest
        )
        manager.copy_projects(
            dry_run=args.dry_run,
            overwrite=args.overwrite
        )
        pause()
    except Exception as e:
        print(f"X Error: {e}")
        pause()
        sys.exit(1)

if __name__ == "__main__":
    main()