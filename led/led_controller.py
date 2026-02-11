#!/usr/bin/env python3
"""
LED Controller for Sonoff devices via eWeLink
Usage: python led_controller.py [on|off|toggle|status]
"""

import asyncio
import logging
import os
import sys
from pathlib import Path
from typing import Optional

# Import the existing sonoff_manager
from sonoff_manager import SonoffManager


class LEDController:
    """Simple LED controller with logging"""
    
    def __init__(self, log_file: Optional[str] = None):
        self.log_file = log_file or r"E:\Scripts\led\led_controller.log"
        self.setup_logging()
        
        self.email = os.getenv("EWELINK_EMAIL")
        self.password = os.getenv("EWELINK_PASSWORD")
        self.country_code = os.getenv("EWELINK_COUNTRY", "+48")
        
        if not self.email or not self.password:
            raise ValueError("EWELINK_EMAIL and EWELINK_PASSWORD must be set")
    
    def setup_logging(self):
        """Setup logging to file and console"""
        log_dir = Path(self.log_file).parent
        log_dir.mkdir(parents=True, exist_ok=True)
        
        logging.basicConfig(
            level=logging.INFO,
            format="%(asctime)s [%(levelname)s] %(message)s",
            handlers=[
                logging.FileHandler(self.log_file),
                logging.StreamHandler()
            ]
        )
    
    async def get_first_online_device(self, manager: SonoffManager):
        """Get the first online device"""
        switches = await manager.discover_switches()
        online_switches = [d for d in switches if d.get("online")]
        
        if not online_switches:
            logging.error("No online devices found")
            return None
        
        return online_switches[0]
    
    async def turn_on(self):
        """Turn on the LED"""
        manager = SonoffManager()
        try:
            logging.info("Logging in to eWeLink...")
            await manager.login(
                username=self.email,
                password=self.password,
                country_code=self.country_code
            )
            
            device = await self.get_first_online_device(manager)
            if device:
                logging.info(f"Turning ON: {device['name']}")
                await manager.turn_on(device["deviceid"])
                print(f"✓ Włączono {device['name']}")
                logging.info(f"Successfully turned ON {device['name']}")
            else:
                print("✗ Brak dostępnych urządzeń")
        finally:
            await manager.close()
    
    async def turn_off(self):
        """Turn off the LED"""
        manager = SonoffManager()
        try:
            logging.info("Logging in to eWeLink...")
            await manager.login(
                username=self.email,
                password=self.password,
                country_code=self.country_code
            )
            
            device = await self.get_first_online_device(manager)
            if device:
                logging.info(f"Turning OFF: {device['name']}")
                await manager.turn_off(device["deviceid"])
                print(f"✓ Wyłączono {device['name']}")
                logging.info(f"Successfully turned OFF {device['name']}")
            else:
                print("✗ Brak dostępnych urządzeń")
        finally:
            await manager.close()
    
    async def toggle(self):
        """Toggle the LED state"""
        manager = SonoffManager()
        try:
            logging.info("Logging in to eWeLink...")
            await manager.login(
                username=self.email,
                password=self.password,
                country_code=self.country_code
            )
            
            device = await self.get_first_online_device(manager)
            if device:
                current_state = device.get("params", {}).get("switch", "off")
                new_state = "off" if current_state == "on" else "on"
                
                logging.info(f"Toggling {device['name']}: {current_state} -> {new_state}")
                
                if new_state == "on":
                    await manager.turn_on(device["deviceid"])
                    print(f"✓ Włączono {device['name']}")
                else:
                    await manager.turn_off(device["deviceid"])
                    print(f"✓ Wyłączono {device['name']}")
            else:
                print("✗ Brak dostępnych urządzeń")
        finally:
            await manager.close()
    
    async def status(self):
        """Show status of all devices"""
        manager = SonoffManager()
        try:
            logging.info("Logging in to eWeLink...")
            await manager.login(
                username=self.email,
                password=self.password,
                country_code=self.country_code
            )
            
            switches = await manager.discover_switches()
            
            if not switches:
                print("No devices found")
                return
            
            print(f"\nFound {len(switches)} device(s):\n")
            for i, device in enumerate(switches, 1):
                online = "✓ ONLINE" if device.get("online") else "✗ OFFLINE"
                state = device.get("params", {}).get("switch", "unknown")
                print(f"{i}. {device['name']}")
                print(f"   Status: {online}")
                print(f"   State: {state.upper()}")
                print(f"   ID: {device['deviceid']}\n")
        finally:
            await manager.close()


def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage: python led_controller.py [on|off|toggle|status]")
        print("\nCommands:")
        print("  on     - Turn on the LED")
        print("  off    - Turn off the LED")
        print("  toggle - Toggle LED state")
        print("  status - Show all devices and their status")
        sys.exit(1)
    
    command = sys.argv[1].lower()
    controller = LEDController()
    
    try:
        if command == "on":
            asyncio.run(controller.turn_on())
        elif command == "off":
            asyncio.run(controller.turn_off())
        elif command == "toggle":
            asyncio.run(controller.toggle())
        elif command == "status":
            asyncio.run(controller.status())
        else:
            print(f"Unknown command: {command}")
            print("Valid commands: on, off, toggle, status")
            sys.exit(1)
    except Exception as e:
        logging.error(f"Error: {e}")
        print(f"✗ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()