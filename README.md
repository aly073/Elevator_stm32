# Elevator STM32 — Keil µVision Project

## Hardware

| Component | Part |
|-----------|------|
| Microcontroller | STM32F103C8T6 (Blue Pill) |
| Programmer / Debugger | ST-Link V2 |

---

## Getting Started

### Requirements

- [Keil µVision 5](https://www.keil.com/download/product/)
- ST-Link V2 driver
- STM32F1xx device pack (installed via Keil Pack Installer)

### Clone the Repository

```bash
git clone <repo-url>
cd <repo-folder>
```

Open `Elevator_stm32.uvprojx` in Keil µVision.

---

## Debug Configuration (ST-Link V2)

Follow these steps once to configure the debugger correctly:

1. Go to **Project → Options for Target** (or press `Alt+F7`)
2. Select the **Debug** tab
3. Choose **ST-Link Debugger** from the dropdown on the right side
4. Click **Settings** next to it
5. Under the **Debug** tab in settings, set **Connect** to `Under Reset`
6. Switch to the **Flash Download** tab and make sure the following are checked:
   - ✅ Program
   - ✅ Verify
   - ✅ Reset and Run
7. Switch to the **Pack** tab and **uncheck** `Enable`
8. Click **OK** to save

> **Why "Under Reset"?** The STM32F103C8T6 can sometimes fail to connect if the firmware is already running. Connecting under reset holds the MCU in reset while the debugger attaches, ensuring a reliable connection.

---

## Project Conifguration
1. right click registers.inc
2. select options for file
3. in file type select assembly language file
4. click ok

---

## Project Structure

```
├── main.s                          # Application entry point (Assembly)
├── lib.s                           # file for all basic reusable functions such as delay
├── registers.inc                   # All register addresses
├── config                          # Stores the config function where all pins are initialised
├── Elevator_stm32.uvprojx          # Keil project file
├── RTE/                            # Folder for stm32 initialisation
├── Elevator_stm32.cproject.yml     # File for vscode cmsis project
├── Elevator_stm32.csolution        # File for vscode cmsis project
└── .gitignore
```

---

## Build & Flash

1. Build the project: **Project → Build Target** (`F7`)
2. Flash and run: **Debug → Start/Stop Debug Session** (`Ctrl+F5`)
   - With **Reset and Run** enabled, the MCU will start executing automatically after flashing
