# Subway Surfers (v2.30.2) - PortMaster / NextOS Installation Guide

## Target Hardware
- **Device:** R36S, Rockchip RK3326, Mali-G31 MP2 GPU, DarkOS / Darkosen / ArkOS / AmberELEC
- **Architecture:** AArch64 (`arm64-v8a`)
- **Compatibility:** GLIBC >= 2.17 (fully compatible with standard GLIBC <= 2.30 baseline)

---

## Required Files
To run this game, you need the official Android APK:
- **Game Version:** Subway Surfers v2.30.2 (`arm64-v8a`)
- **Expected APK:** `subway-2.30.2.apk` (or `com.kiloo.subwaysurf_2.30.2-26120...apk`)
- **File Size:** ~217 MB
- **Package ID:** `com.kiloo.subwaysurf`

---

## Installation Steps

### Step 1: Copy to SD Card
1. Insert your handheld SD card (or connect via SFTP / SAMBA).
2. Navigate to your ports directory:
   - Single SD Card: `roms/ports/`
   - Two SD Cards (TF2): `roms2/ports/` or `ports/`
3. Copy:
   - `Subway Surfers.sh` into `roms/ports/`
   - The entire `subwaysurfers` directory into `roms/ports/`

The resulting directory structure on your SD card should look like:
```text
roms/ports/
├── Subway Surfers.sh
└── subwaysurfers/
    ├── subwaysurfers-nextos
    ├── Subway Surfers.sh
    ├── extractor.json
    ├── subwaysurfers.gptk
    ├── gameinfo.xml
    ├── port.json
    ├── INSTALLATION.md
    ├── README.md
    └── nxextract/
        ├── nxextract.py
        ├── nxextract-ui
        ├── nxextract-runtime-env.sh
        └── run-extractor.sh
```

### Step 2: Add Game Data (APK)
Copy your Subway Surfers v2.30.2 APK into `roms/ports/subwaysurfers/gamedata/`

### Step 3: Launch
1. On your device, open the **Ports** menu and select **Subway Surfers**.
2. On first launch, **NXExtract** will automatically unpack and verify all required assets, shaders, audio, and native libraries (`libmain.so`, `libunity.so`, `libil2cpp.so`).
3. Once extraction is complete, Subway Surfers will launch directly into the game!

---

## Controls

| Action | Handheld Control |
|---|---|
| **Change Lane (Left / Right)** | D-Pad Left / Right or Left Analog Stick Left / Right |
| **Jump** | D-Pad Up or Left Analog Stick Up or Button A |
| **Roll / Slide** | D-Pad Down or Left Analog Stick Down or Button B |
| **Hoverboard** | Button X or Button Y (automatic double-tap) |
| **Menu Navigation / Cursor** | Right Analog Stick |
| **Menu Select / Tap** | Button A or Right Shoulder (R1) or R3 |
| **Pause** | Start or Select |
| **Exit Game** | Select + Start |
