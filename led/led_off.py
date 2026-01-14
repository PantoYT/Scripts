import asyncio
from sonoff_manager import SonoffManager
import logging
import os

logging.basicConfig(filename=r"C:\Scripts\led\led_off.log",
                    level=logging.INFO,
                    format="%(asctime)s %(message)s")

logging.info("Skrypt odpalił się!")

EMAIL = os.getenv("EWELINK_EMAIL")
PASSWORD = os.getenv("EWELINK_PASSWORD")
COUNTRY_CODE = "+48"

async def turn_off_led():
    manager = SonoffManager()
    try:
        logging.info("Logowanie")
        await manager.login(username=EMAIL, password=PASSWORD, country_code=COUNTRY_CODE)
        logging.info("Zalogowano do Sonoff")
        switches = await manager.discover_switches()
        online_switches = [d for d in switches if d.get("online")]
        if online_switches:
            device = online_switches[0]
            logging.info(f"Wysyłam polecenie {device['name']}")
            await manager.turn_off(device["deviceid"])
            print(f"Wyłączono {device['name']}")
            logging.info(f"Wyłączono {device['name']}")
        else:
            print("Brak online urządzeń do wyłączenia.")
    finally:
        await manager.close()

if __name__ == "__main__":
    asyncio.run(turn_off_led())