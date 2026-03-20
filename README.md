# Elevator STM32 — Keil µVision Project

## Hardware

| Component | Part |
|-----------|------|
| Microcontroller | STM32F103C8Tx (Blue Pill) |
| Programmer / Debugger | ST-Link V2 |

---

## Getting Started

### Requirements

- [Keil µVision 5](https://www.keil.com/download/product/)
- STM32F1xx device pack (installed via Keil Pack Installer)

---

Open `Elevator_stm32.uvprojx` in Keil µVision.

---

## Debug Configuration (ST-Link V2)

Follow these steps once to configure the debugger correctly:

1. Go to **Project → Options for Target**
2. Select the **Debug** tab
3. Choose **ST-Link Debugger** from the dropdown on the right side
4. Click **Settings** next to the dropdown
5. Under the **Debug** tab in settings, set **Connect** to `Under Reset`
6. Switch to the **Flash Download** tab and make sure the following are checked:
   - ✅ Program
   - ✅ Verify
   - ✅ Reset and Run
7. Switch to the **Pack** tab and **uncheck** `Enable`
8. Click **OK** to save

