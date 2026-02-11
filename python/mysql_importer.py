#!/usr/bin/env python3
"""
MySQL Database Importer - FIXED VERSION
Imports all .sql files from a directory structure into MySQL
Usage: python mysql_importer_fixed.py [options]
"""

import argparse
import subprocess
import sys
from pathlib import Path
from typing import List

def pause():
    """Pause and wait for user input"""
    input("\nPress Enter to exit...")

class MySQLImporter:
    """Import SQL files into MySQL databases"""
    
    def __init__(self, basedir: str, mysql_exe: str, user: str = "root", password: str = ""):
        self.basedir = Path(basedir)
        self.mysql_exe = Path(mysql_exe)
        self.user = user
        self.password = password
        
        # Validate paths
        if not self.basedir.exists():
            raise ValueError(f"Base directory not found: {self.basedir}")
        if not self.mysql_exe.exists():
            raise ValueError(f"MySQL executable not found: {self.mysql_exe}")
    
    def get_sql_files(self) -> List[Path]:
        """Recursively find all .sql files"""
        return list(self.basedir.rglob("*.sql"))
    
    def get_database_name(self, sql_file: Path) -> str:
        """Generate database name from file structure"""
        rel_path = sql_file.relative_to(self.basedir)
        parts = rel_path.parts
        
        if len(parts) > 1:
            class_name = parts[0]
        else:
            class_name = "default"
        
        db_name = f"{class_name}_{sql_file.stem}"
        return db_name
    
    def execute_mysql(self, query: str, database: str = None) -> bool:
        """Execute a MySQL query"""
        cmd = [str(self.mysql_exe), "-u", self.user]
        
        if self.password:
            cmd.extend([f"-p{self.password}"])
        
        if database:
            cmd.append(database)
        
        cmd.extend(["-e", query])
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True
            )
            return True
        except subprocess.CalledProcessError as e:
            print(f"  X MySQL Error: {e.stderr}")
            return False
    
    def import_sql_file(self, sql_file: Path, database: str) -> bool:
        """Import a SQL file into a database"""
        cmd = [str(self.mysql_exe), "-u", self.user]
        
        if self.password:
            cmd.extend([f"-p{self.password}"])
        
        cmd.append(database)
        
        try:
            with open(sql_file, 'r', encoding='utf-8') as f:
                result = subprocess.run(
                    cmd,
                    stdin=f,
                    capture_output=True,
                    text=True,
                    check=True
                )
            return True
        except subprocess.CalledProcessError as e:
            print(f"  X Import Error: {e.stderr}")
            return False
        except UnicodeDecodeError:
            try:
                with open(sql_file, 'r', encoding='latin-1') as f:
                    result = subprocess.run(
                        cmd,
                        stdin=f,
                        capture_output=True,
                        text=True,
                        check=True
                    )
                return True
            except Exception as e:
                print(f"  X Encoding Error: {e}")
                return False
    
    def import_all(self, dry_run: bool = False):
        """Import all SQL files"""
        sql_files = self.get_sql_files()
        
        if not sql_files:
            print(f"X No SQL files found in {self.basedir}")
            return
        
        print(f"Found {len(sql_files)} SQL file(s)")
        print("=" * 60)
        print()
        
        success_count = 0
        fail_count = 0
        
        for sql_file in sql_files:
            db_name = self.get_database_name(sql_file)
            rel_path = sql_file.relative_to(self.basedir)
            
            print(f"[+] {rel_path}")
            print(f"    Database: {db_name}")
            
            if dry_run:
                print(f"    [DRY RUN] Would import")
                success_count += 1
            else:
                drop_create_query = (
                    f"DROP DATABASE IF EXISTS `{db_name}`; "
                    f"CREATE DATABASE `{db_name}` CHARACTER SET utf8mb4;"
                )
                
                if not self.execute_mysql(drop_create_query):
                    print(f"    X Failed to create database")
                    fail_count += 1
                    continue
                
                if self.import_sql_file(sql_file, db_name):
                    print(f"    OK Imported successfully")
                    success_count += 1
                else:
                    print(f"    X Import failed")
                    fail_count += 1
            
            print()
        
        print("=" * 60)
        print(f"OK Success: {success_count}")
        if fail_count > 0:
            print(f"X Failed:  {fail_count}")
        print("=" * 60)

def interactive_mode():
    """Interactive mode to get user input"""
    print("=" * 60)
    print("MySQL Database Importer - Interactive Mode")
    print("=" * 60)
    print()
    
    print("Enter drive letter for SQL files (e.g., G):")
    basedir_drive = input("> ").strip().upper()
    if not basedir_drive:
        basedir_drive = "G"
    
    print("\nEnter drive letter for XAMPP (e.g., E):")
    xampp_drive = input("> ").strip().upper()
    if not xampp_drive:
        xampp_drive = "E"
    
    basedir = f"{basedir_drive}:\\Pliki\\Technik Programista\\BazyDanych"
    mysql_exe = f"{xampp_drive}:\\xampp\\mysql\\bin\\mysql.exe"
    
    print()
    print(f"Base Directory: {basedir}")
    print(f"MySQL:          {mysql_exe}")
    print()
    
    try:
        importer = MySQLImporter(basedir, mysql_exe)
        importer.import_all()
    except Exception as e:
        print(f"\nX Error: {e}")
        pause()
        sys.exit(1)
    
    pause()

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Import SQL files into MySQL databases"
    )
    parser.add_argument(
        "--basedir",
        help="Base directory containing SQL files",
        default=r"G:\Pliki\Technik Programista\BazyDanych"
    )
    parser.add_argument(
        "--mysql",
        help="Path to mysql.exe",
        default=r"E:\xampp\mysql\bin\mysql.exe"
    )
    parser.add_argument(
        "--user",
        help="MySQL username",
        default="root"
    )
    parser.add_argument(
        "--password",
        help="MySQL password",
        default=""
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without actually importing"
    )
    parser.add_argument(
        "--interactive", "-i",
        action="store_true",
        help="Interactive mode for drive letters"
    )
    
    args = parser.parse_args()
    
    try:
        if args.interactive:
            interactive_mode()
            return
        
        importer = MySQLImporter(
            basedir=args.basedir,
            mysql_exe=args.mysql,
            user=args.user,
            password=args.password
        )
        importer.import_all(dry_run=args.dry_run)
        pause()
    except Exception as e:
        print(f"X Error: {e}")
        pause()
        sys.exit(1)

if __name__ == "__main__":
    main()