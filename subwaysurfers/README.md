# Subway Surfers (v2.30.2) - NextOS Native Port

A native, standalone AArch64 Linux port of **Subway Surfers v2.30.2** for handheld gaming devices (specifically optimized for Rockchip RK3326 devices such as the R36S running DarkOS / Darkosen firmware, as well as AmberELEC and ArkOS).

## Key Features
- **Pure Native Execution:** No Android emulators, JVMs, or virtualization layers. Directly runs the original AArch64 Unity IL2CPP runtime (`libunity.so` + `libil2cpp.so`) on Linux.
- **Maximum Binary Compatibility:** Compiled for `aarch64-linux-gnu` with `GLIBC 2.17` baseline (passes NextOS ELF audit), compatible with virtually all modern retro handheld firmwares.
- **Fluid Handheld Controls:**
  - Responsive D-Pad and Left-stick cardinal swipe mapping for lane switching, jumping, and sliding.
  - One-button Hoverboard activation via automated double-tap generation.
  - Virtual pointer navigation for menus and shop using the Right analog stick.
  - RK3326 `BTN_TRIGGER_HAPPY1/2` hardware button mapping for Select/Start.
  - Clean exit via standard `Select + Start` combo.
- **Hardware-Accelerated GLES2/3 Graphics:** Backed by SDL2 and Mali-G31 GPU with software/hardware ETC2 texture decoding fallback.
- **Low-Latency Audio:** FMOD AudioTrack PCM buffer bridged directly to SDL2 audio subsystem.
- **Automated Data Extraction:** Powered by NextOS `NXExtract`, securely verifying and unpacking assets from the official Android APK.

## Directory Structure
- `src/`: Complete adapter source code:
  - `main.c`: Native Unity lifecycle driving `initJni`, `nativeRecreateGfxState`, surface events, and `nativeRender`.
  - `nx_elf.c`, `nx_elf.h`: AArch64 ELF loader and dynamic symbol relocator.
  - `bionic.c`: Android Bionic libc/libm/liblog shims (math constants, file descriptors, canary protection).
  - `pthread_bridge.c`: Bionic-to-glibc pthread bridge.
  - `android.c`: ANativeWindow, ALooper, ASensor, and NDK stubs.
  - `egl.c`, `egl_sdl.c`: EGL and GLES facade over SDL2.
  - `etc2_decode.c`: ETC2 texture decompression engine.
  - `jni.c`: JNI environment and Android object emulation (`UnityPlayer`, `InputDevice`, `MotionEvent`, `KeyEvent`, etc.).
  - `audio.c`: FMOD AudioTrack to SDL2 audio output queue.
  - `input.c`: Gamepad and synthetic gesture controller.
- `extractor.json`: NXExtract canonical asset extraction recipe.
- `nxextract/`: NXExtract installer runtime for on-device setup.
- `Subway Surfers.sh`: Canonical PortMaster launcher script.
- `build.sh`: Reproducible cross-compilation script via Zig.

## Building from Source
Requirements:
- Zig 0.11+ / 0.17+ with AArch64 target support.

Run:
```bash
./build.sh
```
This produces `subwaysurfers-nextos` and verifies it with `audit_elf.py`.
