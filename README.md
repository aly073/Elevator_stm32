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
- STM32F1xx device pack (installed via Keil Pack Installer)

---

Open `Elevator_stm32.uvprojx` in Keil µVision.

---

## Debug Configuration (ST-Link V2)

Follow these steps once to configure the debugger correctly:

1. Go to **Project → Options for Target**
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

### note
to view and write in the registers.inc file, in keil click open and open the file normally, do not add it to the source group as it will try to compile the file

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
├── vcpkg-configuration.json        # More vscode files
├── Elevator_stm32_Target_1.sct     # Last one
└── .gitignore
```

## (Optional) VS Code Setup (windows setup only)

This setup uses CMSIS and CMake tooling in VS Code to build, upload, and debug code. Setup can be a bit annoying, but it works well if you prefer VS Code over Keil. Alternatively you can just install the keil assistant extension and arm assembly extension to be able to write code, build, and flash in vscode, but debugging would require using keil.

One important detail: the VS Code CMSIS project files are separate from the Keil project files. To keep them in sync, this repository includes scripts in the `scripts/` folder.

**Make sure you run the sync scripts before modifying project-group files.**

### Requirements

- Arm Keil Studio Pack (MDK v6) extension pack
- Keil Assistant extension (optional)

### Steps
1. Download the vscode project files from the google drive https://drive.google.com/file/d/1x8iBDBBVm7FrahMtdIq_7hUy2PMPQEcU/view?usp=sharing
2. extract and copy the content of vscode_stm32_setup into the project folder
3. Open the project in VS Code.
4. Install the **Arm Keil Studio Pack (MDK v6)** extension pack.
5. Install **Keil Assistant** (optional, useful for checking whether the Keil project is synced with CMSIS).
6. Open the CMSIS view in the sidebar and click **Build Solution** (hammer icon).
7. If the build succeeds, start debugging (bug icon) to upload and run the code on the STM32 target.

### Syncing Keil and CMSIS Groups

The repository contains two project formats:
- Keil project groups (`.uvprojx`)
- CMSIS project groups (`.cproject.yml`)

These group lists do not stay synchronized automatically, so use the sync tasks whenever groups/files are changed.

1. Open the VS Code command palette (`Ctrl+Shift+P`).
2. Run **Tasks: Run Task**.
3. Choose one of the following:
   - **Sync Keil Groups to CMSIS**: Use this after pulling changes from GitHub.
   - **Sync CMSIS Groups to Keil**: Use this before pushing to GitHub.

Recommended habit:
- After `git pull` -> run **Sync Keil Groups to CMSIS**.
- Before `git push` -> run **Sync CMSIS Groups to Keil**.

### Note

You can verify syncing by checking the Keil µVision project view in the Explorer. If the source groups do not match the groups in your VS Code CMSIS project, run the sync task again.
