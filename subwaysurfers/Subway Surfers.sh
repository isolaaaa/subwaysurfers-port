#!/usr/bin/env bash
# PORTMASTER: subwaysurfers, Subway Surfers.sh
# Subway Surfers v2.30.2 NextOS Port for Handhelds (dArkOS, ArkOS, muOS, AmberELEC, ROCKNIX, etc.)

# Firmware dynamic loader environment preservation
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
controlfolder=""

# 1. Exhaustive PortMaster discovery across all known CFWs
for pm in \
  "${PM_DIR:-}" \
  /opt/system/Tools/PortMaster \
  /opt/tools/PortMaster \
  "$XDG_DATA_HOME/PortMaster" \
  /storage/.config/PortMaster \
  /var/data/PortMaster \
  /PortMaster \
  /roms/tools/PortMaster \
  /roms2/tools/PortMaster \
  /storage/roms/ports/PortMaster \
  /storage/roms/Ports/PortMaster \
  /roms/ports/PortMaster \
  /roms/Ports/PortMaster \
  /roms2/ports/PortMaster \
  /roms2/Ports/PortMaster \
  /userdata/system/.local/share/PortMaster \
  /userdata/roms/ports/PortMaster \
  /userdata/roms/Ports/PortMaster \
  /mnt/mmc/MUOS/PortMaster \
  /mnt/mmc/ports/PortMaster \
  /mnt/mmc/Ports/PortMaster \
  /mnt/mmc/roms/ports/PortMaster \
  /mnt/mmc/ROMS/Ports/PortMaster \
  /mnt/SDCARD/Apps/PortMaster/PortMaster \
  /mnt/sdcard/Roms/.portmaster/PortMaster \
  /mnt/sdcard/ports/PortMaster \
  /mnt/sdcard/Ports/PortMaster \
  /mnt/sdcard/roms/ports/PortMaster \
  /mnt/sdcard/ROMS/Ports/PortMaster; do
  if [ -n "$pm" ] && [ -r "$pm/control.txt" ]; then
    controlfolder="$pm"
    break
  fi
done

# 2. Source PortMaster control & CFW definitions
if [ -n "$controlfolder" ] && [ -r "$controlfolder/control.txt" ]; then
  # shellcheck source=/dev/null
  . "$controlfolder/control.txt"
  case "${CFW_NAME:-}" in
    ''|*[!A-Za-z0-9._-]*) ;;
    *) [ ! -r "$controlfolder/mod_${CFW_NAME}.txt" ] || . "$controlfolder/mod_${CFW_NAME}.txt" ;;
  esac
  command -v get_controls >/dev/null 2>&1 && get_controls
fi

: "${CUR_TTY:=/dev/tty0}"
: "${ESUDO:=}"

# 3. Robust Game Directory (GAMEDIR) resolution across all mount layouts
PORTS_DIR="$(cd -- "$(dirname -- "$0")" 2>/dev/null && pwd -P)"
GAMEDIR=""
for candidate in \
  "$PORTS_DIR/subwaysurfers" \
  "$PORTS_DIR" \
  "/${directory#/}/ports/subwaysurfers" \
  "/${directory#/}/Ports/subwaysurfers" \
  /mnt/sdcard/ports/subwaysurfers \
  /mnt/sdcard/Ports/subwaysurfers \
  /mnt/sdcard/roms/ports/subwaysurfers \
  /mnt/sdcard/ROMS/Ports/subwaysurfers \
  /mnt/mmc/ports/subwaysurfers \
  /mnt/mmc/Ports/subwaysurfers \
  /mnt/mmc/roms/ports/subwaysurfers \
  /mnt/mmc/ROMS/Ports/subwaysurfers \
  /mnt/SDCARD/Ports/subwaysurfers \
  /mnt/SDCARD/ports/subwaysurfers \
  /storage/roms/ports/subwaysurfers \
  /storage/roms/Ports/subwaysurfers \
  /roms/ports/subwaysurfers \
  /roms2/ports/subwaysurfers \
  /userdata/roms/ports/subwaysurfers \
  /userdata/roms/Ports/subwaysurfers; do
  if [ -n "$candidate" ] && [ -f "$candidate/subwaysurfers-nextos" ]; then
    GAMEDIR="$(cd -- "$candidate" 2>/dev/null && pwd -P)"
    break
  fi
done

[ -n "$GAMEDIR" ] || {
  echo "subwaysurfers-nextos not found. Please install the complete port directory beside this launcher." >&2
  command -v pm_finish >/dev/null 2>&1 && pm_finish
  exit 2
}

cd "$GAMEDIR" || exit 2
exec 1>"$GAMEDIR/log.txt" 2>&1

echo "=========================================="
echo "Starting Subway Surfers (NextOS Port)"
echo "GAMEDIR: $GAMEDIR"
echo "CFW: ${CFW_NAME:-unknown} | Arch: $(uname -m)"
echo "Date: $(date)"
echo "=========================================="

# 4. Exit & Signal Traps (Ensures pm_finish and cleanup always execute)
game_pid=""
finished=0

cleanup() {
  [ "$finished" = 0 ] || return 0
  finished=1

  # Terminate game process gracefully if still alive
  if [ -n "$game_pid" ]; then
    kill -TERM "$game_pid" 2>/dev/null || true
    for ((i = 0; i < 30; i++)); do
      kill -0 "$game_pid" 2>/dev/null || break
      sleep 0.1
    done
    kill -KILL "$game_pid" 2>/dev/null || true
    wait "$game_pid" 2>/dev/null || true
  fi

  # Stop GPTK controller daemon
  if [ -n "${GPTOKEYB:-}" ]; then
    kill -9 "$(pidof gptokeyb)" 2>/dev/null || true
  fi

  # Restore CPU governors
  for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$gov" ] && echo ondemand > "$gov" 2>/dev/null || true
  done

  # Reset terminal and notify frontend
  [ -z "${CUR_TTY:-}" ] || { [ ! -c "$CUR_TTY" ] || printf '\033c' > "$CUR_TTY" 2>/dev/null; }
  if command -v pm_finish >/dev/null 2>&1; then
    pm_finish
  fi
  return 0
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

# 5. muOS, Wayland & runtime socket discovery
if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
  for runtime in /run/0-runtime-dir /var/run/0-runtime-dir "/run/user/$(id -u)"; do
    [ -d "$runtime" ] || continue
    export XDG_RUNTIME_DIR="$runtime"
    break
  done
fi

if [ -z "${WAYLAND_DISPLAY:-}" ] && [ -n "${XDG_RUNTIME_DIR:-}" ]; then
  for socket in "$XDG_RUNTIME_DIR"/wayland-[0-9]*; do
    [ -S "$socket" ] || continue
    export WAYLAND_DISPLAY="${socket##*/}"
    break
  done
fi

# muOS button label authority
IS_MUOS=0
case "${CFW_NAME:-} $(uname -n)" in *muos*|*muOS*|*MuOS*) IS_MUOS=1 ;; esac
[ ! -d /opt/muos ] || IS_MUOS=1
if [ "$IS_MUOS" = 1 ]; then
  export SDL_GAMECONTROLLER_USE_BUTTON_LABELS=0
fi

# 6. Library search paths (PortMaster AArch64 libs)
LIBS=""
for libdir in \
  "${controlfolder:+$controlfolder/libs.aarch64}" \
  "${controlfolder:+$controlfolder/libs}" \
  /usr/lib/aarch64-linux-gnu /lib/aarch64-linux-gnu /usr/local/lib; do
  [ -n "$libdir" ] && [ -d "$libdir" ] || continue
  LIBS="${LIBS:+$LIBS:}$libdir"
done
[ -z "$LIBS" ] || export LD_LIBRARY_PATH="${LIBS}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# 7. Asset extraction check (NXExtract)
if [ ! -f "$GAMEDIR/lib/libunity.so" ] && [ ! -f "$GAMEDIR/lib/arm64-v8a/libunity.so" ]; then
  echo "Assets not extracted yet. Launching NXExtract..."
  export NXEXTRACT_GAME_DIR="$GAMEDIR"
  if [ -f "$GAMEDIR/nxextract/run-extractor.sh" ]; then
    bash "$GAMEDIR/nxextract/nxextract-runtime-env.sh" bash "$GAMEDIR/nxextract/run-extractor.sh" --ui auto || true
  fi
  if [ ! -f "$GAMEDIR/lib/libunity.so" ] && [ ! -f "$GAMEDIR/lib/arm64-v8a/libunity.so" ]; then
    python3 "$GAMEDIR/nxextract/nxextract.py" install --recipe "$GAMEDIR/extractor.json" --game-dir "$GAMEDIR" --ui auto || true
  fi
fi

# Verify core libraries exist
if [ ! -f "$GAMEDIR/lib/libunity.so" ] && [ ! -f "$GAMEDIR/lib/arm64-v8a/libunity.so" ]; then
  echo "ERROR: Game data is missing. Please place Subway Surfers v2.30.2 (arm64-v8a) APK into $GAMEDIR/gamedata/ (e.g. gamedata/subway.apk or game.apk)."
  exit 1
fi

# 8. Auto-apply asset patch (e.g. solid black loading screen) if not yet applied
if [ ! -f "$GAMEDIR/.patch_applied" ] && [ -d "$GAMEDIR/patch" ]; then
  echo "Applying asset patches from patch/ folder..."
  if [ -f "$GAMEDIR/patch/apply_patch.sh" ]; then
    bash "$GAMEDIR/patch/apply_patch.sh" "$GAMEDIR" || true
  elif [ -f "$GAMEDIR/patch/apply_patch.py" ]; then
    python3 "$GAMEDIR/patch/apply_patch.py" "$GAMEDIR" || true
  fi
fi

# 9. Performance & memory tuning for handhelds (Mali-G31 / RK3326 / H700)
export LANG="C"
export LC_ALL="C"
export MALLOC_ARENA_MAX=2
export MALLOC_TRIM_THRESHOLD_=131072
export MALLOC_MMAP_THRESHOLD_=131072
export SUBSURF_LOGCAT=0
export SUBSURF_VERBOSE=0
export SUBSURF_JNILOG=0
export SUBSURF_VSYNC=0
export SUBSURF_CURSOR_SPEED="${SUBSURF_CURSOR_SPEED:-580}"
export SUBSURF_CURSOR_TIMEOUT="${SUBSURF_CURSOR_TIMEOUT:-3.0}"

# Maximize CPU and GPU governors (fail-soft if not root)
for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [ -f "$gov" ] && echo performance > "$gov" 2>/dev/null || true
done
for gov in /sys/class/devfreq/*rk3326* /sys/class/devfreq/*mali* /sys/class/devfreq/*dmc* /sys/class/devfreq/dmc; do
  [ -d "$gov" ] && [ -f "$gov/governor" ] && echo performance > "$gov/governor" 2>/dev/null || true
done

# Drop page caches if permitted
sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true

# Prioritize the game process
renice -n -10 $$ 2>/dev/null || true

# 10. Audio & Input configuration
[ -n "${sdl_controllerconfig:-}" ] && export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export XDG_DATA_HOME="$GAMEDIR/userdata"
mkdir -p "$GAMEDIR/userdata/profile"

# Default age & GDPR consent
if [ ! -f "$GAMEDIR/userdata/data_consent.json" ]; then
  echo '{"Age":25,"ConsentGiven":1}' > "$GAMEDIR/userdata/data_consent.json"
fi

# Default completed tutorial profile
if [ ! -f "$GAMEDIR/userdata/profile/tutorial.json" ]; then
  echo '{"version":1,"data":"{\"lastSaved\": \"2026-10-27T13:26:00.506117Z\", \"patchVersion\": 0, \"runTutorialCompleted\": true, \"tutorialCompletionTime\": \"2026-10-27T13:26:00.506117Z\", \"hoverboardAllowed\": true, \"finalHoverboardNudgeShown\": true}"}' > "$GAMEDIR/userdata/profile/tutorial.json"
fi

# 11. Launch GPTK controller daemon
if [ -z "${GPTOKEYB:-}" ]; then
  for gptk_candidate in "$controlfolder/gptokeyb" "$controlfolder/gptokeyb.arm64" /usr/bin/gptokeyb; do
    if [ -x "$gptk_candidate" ]; then
      GPTOKEYB="$gptk_candidate"
      break
    fi
  done
fi

if [ -n "${GPTOKEYB:-}" ] && [ -f "$GAMEDIR/subwaysurfers.gptk" ]; then
  ${ESUDO:-} chmod 666 /dev/uinput "$CUR_TTY" 2>/dev/null || true
  $GPTOKEYB "subwaysurfers-nextos" -c "$GAMEDIR/subwaysurfers.gptk" &
fi

# 12. Run the native AArch64 executable
echo "Launching subwaysurfers-nextos..."
chmod +x "$GAMEDIR/subwaysurfers-nextos" 2>/dev/null || true
[ -f "$GAMEDIR/libnet_fix.so" ] && export LD_PRELOAD="$GAMEDIR/libnet_fix.so${LD_PRELOAD:+:$LD_PRELOAD}"
"$GAMEDIR/subwaysurfers-nextos" "$GAMEDIR" & game_pid=$!
wait "$game_pid"
STATUS=$?
game_pid=""

echo "Game exited with status $STATUS"
exit $STATUS
