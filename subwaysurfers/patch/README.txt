Subway Surfers NextOS Asset Patch
==================================

Folder ini berfungsi untuk memodifikasi visual game saat instalasi baru secara otomatis:
1. Mengubah background loading screen (LoadingScreen_Barcelona) menjadi warna hitam solid.
2. Menonaktifkan promo overlay saat loading agar tampilan bersih dan nyaman di layar R36S.

Cara Kerja:
- Pengguna cukup menaruh file APK original/asli ke dalam folder gamedata/ (misalnya gamedata/subway.apk, gamedata/subway-surf.apk, subway-2.30.2.apk, atau game.apk).
- Saat game pertama kali dijalankan atau diekstrak, script `apply_patch.sh` akan otomatis
  memodifikasi file asset di dalam APK dan folder bin/Data tanpa perlu mengedit APK manual.
- File penanda `.patch_applied` akan dibuat setelah patch selesai agar tidak perlu diproses ulang.

Wi-Fi Crash Fix (libnet_fix.so / libnet_fix.c):
- Mengatasi crash SIGSEGV saat Wi-Fi terhubung karena ketidakcocokan layout struct addrinfo (ai_addr vs ai_canonname) antara Android Bionic dan GNU libc.
- libnet_fix.so mengintersep getaddrinfo() dan mengembalikan EAI_NONAME agar Unity/IL2CPP berjalan aman dalam mode offline.
