#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""
Subway Surfers NextOS Asset Patcher
Applies visual fixes to clean Subway Surfers v2.30.2 APK and extracted assets:
1. Replaces LoadingScreen_Barcelona with solid black ETC2_RGBA8 texture (split8).
2. Disables Loading_Promo_001 GameObject and Image component (split9).
This ensures a clean solid black startup loading screen.
"""

import os
import sys
import zipfile

def patch_split8_bytes(data: bytes) -> bytes:
    b = bytearray(data)
    # Texture2D LoadingScreen_Barcelona image data: offset 0xc1d4, length 524,288 (0x80000)
    # ETC2_RGBA8 format: 16 bytes per 4x4 block (8 bytes EAC alpha [0xff,0..], 8 bytes ETC2 RGB [0..])
    blk = b'\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    black_tex = blk * 32768
    tex_start = 0xc1d4
    tex_end = tex_start + len(black_tex)
    if len(b) >= tex_end:
        b[tex_start:tex_end] = black_tex
    return bytes(b)

def patch_split9_bytes(data: bytes) -> bytes:
    b = bytearray(data)
    # GO 565 "Loading_Promo_001": m_IsActive at offset 0xce876
    if len(b) > 0xce876:
        b[0xce876] = 0
    # MonoBehaviour 1719 (UI.Image): m_Enabled at offset 0xfbebc
    if len(b) > 0xfbebc:
        b[0xfbebc] = 0
    # MonoBehaviour 1719 (UI.Image): m_Color at offset 0xfbedc (16 bytes RGBA floats)
    if len(b) >= 0xfbeec:
        b[0xfbedc:0xfbeec] = b'\x00' * 16
    return bytes(b)

def patch_apk(apk_path: str):
    print(f"[patch] Checking APK: {apk_path}")
    if not os.path.isfile(apk_path):
        return False
    
    tmp_path = apk_path + ".patch_tmp"
    patched_any = False
    
    with zipfile.ZipFile(apk_path, "r") as zin:
        infolist = zin.infolist()
        # Quick check if split8 already has the patch
        try:
            s8 = zin.read("assets/bin/Data/sharedassets0.assets.split8")
            if s8[0xc1d4:0xc1e4] == b'\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00':
                print("[patch] APK already contains patched assets.")
                return True
        except KeyError:
            print("[patch] Warning: split8 not found in APK.")
            return False

        print(f"[patch] Patching assets inside {os.path.basename(apk_path)}...")
        with zipfile.ZipFile(tmp_path, "w", compression=zipfile.ZIP_DEFLATED) as zout:
            for item in infolist:
                if item.filename == "assets/bin/Data/sharedassets0.assets.split8":
                    orig = zin.read(item.filename)
                    modified = patch_split8_bytes(orig)
                    zout.writestr(item, modified, compress_type=item.compress_type)
                    patched_any = True
                elif item.filename == "assets/bin/Data/sharedassets0.assets.split9":
                    orig = zin.read(item.filename)
                    modified = patch_split9_bytes(orig)
                    zout.writestr(item, modified, compress_type=item.compress_type)
                    patched_any = True
                else:
                    zout.writestr(item, zin.read(item.filename), compress_type=item.compress_type)

    if patched_any:
        # Verify zip integrity
        with zipfile.ZipFile(tmp_path, "r") as zf:
            err = zf.testzip()
            if err is not None:
                raise RuntimeError(f"Patched APK validation error in {err}")
        os.replace(tmp_path, apk_path)
        print(f"[patch] Successfully patched {os.path.basename(apk_path)}")
    else:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)
            
    return True

def patch_loose_files(data_dir: str):
    s8_path = os.path.join(data_dir, "sharedassets0.assets.split8")
    s9_path = os.path.join(data_dir, "sharedassets0.assets.split9")
    
    if os.path.isfile(s8_path):
        print(f"[patch] Patching loose file {s8_path}...")
        with open(s8_path, "rb") as f:
            data = f.read()
        patched = patch_split8_bytes(data)
        with open(s8_path, "wb") as f:
            f.write(patched)
            
    if os.path.isfile(s9_path):
        print(f"[patch] Patching loose file {s9_path}...")
        with open(s9_path, "rb") as f:
            data = f.read()
        patched = patch_split9_bytes(data)
        with open(s9_path, "wb") as f:
            f.write(patched)

def main():
    force = "--force" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    
    if args:
        game_dir = os.path.abspath(args[0])
    else:
        game_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
        if not os.path.isdir(os.path.join(game_dir, "assets")) and os.path.isdir(os.getcwd()):
            game_dir = os.getcwd()

    marker = os.path.join(game_dir, ".patch_applied")
    if os.path.isfile(marker) and not force:
        print("[patch] All asset patches already marked as applied. Use --force to re-apply.")
        return 0

    print(f"[patch] Target game directory: {game_dir}")
    
    # 1. Patch loose extracted files
    data_dir = os.path.join(game_dir, "assets", "bin", "Data")
    if os.path.isdir(data_dir):
        patch_loose_files(data_dir)
        
    # 2. Patch APK files found in gamedata/ and game directory
    apk_paths = []
    gamedata_dir = os.path.join(game_dir, "gamedata")
    if os.path.isdir(gamedata_dir):
        for fn in sorted(os.listdir(gamedata_dir)):
            if fn.lower().endswith(".apk"):
                apk_paths.append(os.path.join(gamedata_dir, fn))

    for fn in sorted(os.listdir(game_dir)):
        if fn.lower().endswith(".apk"):
            apk_paths.append(os.path.join(game_dir, fn))

    for p in apk_paths:
        if os.path.isfile(p):
            patch_apk(p)

    # 3. Write marker
    try:
        with open(marker, "w") as f:
            f.write("subwaysurfers-nextos asset patch v1 (solid black loading screen)\n")
        print("[patch] Patch marker .patch_applied created successfully.")
    except Exception as e:
        print(f"[patch] Warning: could not write marker file: {e}")

    return 0

if __name__ == "__main__":
    sys.exit(main())
