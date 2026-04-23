#!/usr/bin/env python3
"""
LED ON - Standalone script for autostart
Turns on Sonoff LED devices at system startup
"""

import asyncio
import logging
import os
import sys
from pathlib import Path

# Import the existing sonoff_manager
try:
    from sonoff_manager import SonoffManager
except ImportError:
    print("ERROR: sonoff_manager.py not found in the same directory")
    sys.exit(1)


def setup_logging(log_file: str):
    """Setup logging to file"""
    log_path = Path(log_file)
    log_path.parent.mkdir(parents=True, exist_ok=True)
    
    logging.basicConfig(
        filename=log_file,
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s"
    )


async def turn_on_led():
    """Turn on the first online LED device"""
    email = os.getenv("EWELINK_EMAIL")
    password = os.getenv("EWELINK_PASSWORD")
    country_code = os.getenv("EWELINK_COUNTRY", "+48")
    
    if not email or not password:
        logging.error("EWELINK_EMAIL and EWELINK_PASSWORD environment variables must be set")
        print("ERROR: EWELINK_EMAIL and EWELINK_PASSWORD must be set")
        return False
    
    manager = SonoffManager()
    try:
        logging.info("Logging in to eWeLink...")
        await manager.login(
            username=email,
            password=password,
            country_code=country_code
        )
        
        logging.info("Discovering devices...")
        switches = await manager.discover_switches()
        online_switches = [d for d in switches if d.get("online")]
        
        if online_switches:
            device = online_switches[0]
            logging.info(f"Sending ON command to {device['name']}")
            await manager.turn_on(device["deviceid"])
            print(f"Włączono {device['name']}")
            logging.info(f"Successfully turned ON {device['name']}")
            return True
        else:
            logging.warning("No online devices found")
            print("Brak online urządzeń")
            return False
            
    except Exception as e:
        logging.error(f"Error: {e}", exc_info=True)
        print(f"Error: {e}")
        return False
    finally:
        await manager.close()


def main():
    """Main entry point"""
    log_file = r"E:\Scripts\led\led_on.log"
    setup_logging(log_file)
    
    logging.info("=" * 50)
    logging.info("LED ON script started")
    logging.info("=" * 50)
    
    try:
        success = asyncio.run(turn_on_led())
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        logging.info("Interrupted by user")
        print("\nCancelled")
        sys.exit(1)
    except Exception as e:
        logging.error(f"Fatal error: {e}", exc_info=True)
        print(f"Fatal error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()