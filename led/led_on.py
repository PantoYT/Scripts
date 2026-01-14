import asyncio
from sonoff_manager import SonoffManager
import os

EMAIL = os.getenv("EWELINK_EMAIL")
PASSWORD = os.getenv("EWELINK_PASSWORD")
COUNTRY_CODE = "+48"

async def turn_on_led():
    manager = SonoffManager()
    try:
        await manager.login(username=EMAIL, password=PASSWORD, country_code=COUNTRY_CODE)
        switches = await manager.discover_switches()
        online_switches = [d for d in switches if d.get("online")]
        if online_switches:
            device = online_switches[0]
            await manager.turn_on(device["deviceid"])
            print(f"Włączono {device['name']}")
        else:
            print("Brak online urządzeń do włączenia.")
    finally:
        await manager.close()

if __name__ == "__main__":
    asyncio.run(turn_on_led())
