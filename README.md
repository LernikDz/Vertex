# Samsung Daily Optimizer

An automated daily performance maintenance module and standalone utility for Samsung Galaxy devices running One UI (compatible with **Magisk**, **KernelSU**, **APatch**, and **Temproot**).

---

## Features

- **RAM Plus Control**: Easily disable (0 GB) or configure (2 GB / 4 GB / 8 GB) Samsung's virtual RAM to eliminate swap thrashing and `kswapd0` CPU spikes.
- **Kernel VM & Swappiness Tuning**: Lowers `vm.swappiness` to 60 (down from Samsung's 160–180) and tunes dirty page ratios (`dirty_background_ratio = 10`, `dirty_ratio = 20`) to prevent UI stalls during background writes.
- **UFS Read-Ahead Boost**: Sets block queue read-ahead to 512 KB on UFS storage for faster sequential reads and quicker app cold starts.
- **Audio & Bluetooth Stutter Prevention**:
  - Automatically disables background BLE and Wi-Fi scanning (`wifi_scan_always_enabled 0`, `ble_scan_always_enabled 0`) to eliminate 2.4 GHz radio collisions with Bluetooth audio (e.g. Galaxy Buds).
  - Automatically ensures audio apps and Galaxy Wearable/Buds managers are exempt from Doze sleep.
- **Crash Dump & Cache Cleanup**: Purges stale `/data/anr/*`, `/data/tombstones/*`, and `/data/system/dropbox/*` logs and trims dead app caches via `pm trim-caches`.
- **Memory Compaction & Storage Trim**: Compacts kernel memory (`compact_memory`), drops inactive page caches, and runs `fstrim` on `/data` and `/cache`.
- **Samsung Enhanced CPU Responsiveness**: Enables `sem_enhanced_cpu_responsiveness 1` for faster CPU clock ramp-up.
- **Dynamic Island & Xposed Safety**: Performs profile-guided ART compilation (`speed-profile`) on user apps and launchers while **strictly excluding `com.android.systemui`** to prevent breaking Xposed/Vector hooks and custom widgets.

---

## Installation & Flashing

### Magisk / KernelSU / APatch
1. Download or transfer `SamsungDailyOptimizer.zip` to your phone.
2. Open your root manager > **Modules** > **Install from storage**.
3. During installation, use the hardware **Volume keys** to choose your RAM Plus preference:
   - **Vol+**: Disable RAM Plus (`0 GB` - Recommended for lowest lag).
   - **Vol-**: Enable RAM Plus (`2 GB`).

### Standalone / Temproot
If your device uses temporary root (or you prefer running without flashing a module), copy the folder to `/data/local/tmp/SamsungDailyOptimizer`:

```bash
# Start the daily 5:00 AM timer daemon:
su -c /data/local/tmp/SamsungDailyOptimizer/start_daemon.sh

# Run an optimization immediately on demand:
su -c /data/local/tmp/SamsungDailyOptimizer/run_now.sh

# Configure settings anytime in terminal:
su -c /data/local/tmp/SamsungDailyOptimizer/configure.sh
```

---

## Configuration (`config.prop`)

You can adjust settings anytime by editing `config.prop` directly or using `configure.sh`:

```properties
RAM_PLUS_ENABLED=1
RAM_PLUS_SIZE=2048
TUNE_SWAPPINESS=1
SWAPPINESS_VALUE=60
TUNE_READ_AHEAD=1
READ_AHEAD_KB=512
PURGE_CRASH_LOGS=1
TRIM_APP_CACHES=1
DISABLE_BACKGROUND_BLE_SCAN=1
DISABLE_BACKGROUND_WIFI_SCAN=1
WHITELIST_AUDIO_APPS=1
ENHANCED_CPU_RESPONSIVENESS=1
```
