# Vertex (Samsung Daily Optimizer)

An automated daily performance maintenance module and standalone utility for Samsung Galaxy devices running One UI (compatible with **Magisk**, **KernelSU**, **APatch**, and **Temproot**).

---

## Features

- **ZRAM Compression Engine Switcher (`ZSTD` / `LZ4` / `LZO-RLE`)**: Switches kernel ZRAM compression to **ZSTD** for ~35% higher compression ratio on modern ARMv9 cores (S24), storing significantly more compressed memory in RAM and preventing memory thrashing.
- **120Hz Smooth Scroll Lock**: Forces display minimum refresh rate to 120Hz (`min_refresh_rate 120.0`) to eliminate scrolling micro-stutters and aggressive 60Hz downclocking, with 1-tap restore to dynamic LTPO (1Hz-120Hz).
- **Bypass Charging (Desk & Gaming Mode)**: Powers the device directly from the wall charger without routing charging current into the lithium battery (`batt_slate_mode`), preventing battery wear, overheating, and thermal throttling while gaming or docked.
- **Smart Screen-Off Aware Scheduler**: Automatically defers daily 5:00 AM maintenance passes if the screen is active/awake, guaranteeing zero frame drops or interruptions during active use.
- **RAM Plus Control**: Easily disable (0 GB) or configure (2 GB / 4 GB / 8 GB) Samsung's virtual RAM to eliminate swap thrashing and `kswapd0` CPU spikes.
- **Kernel VM & Memory Subsystem Tuning**:
  - Lowers `vm.swappiness` to 60 (down from Samsung's 160–180) and tunes dirty ratios (`dirty_background_ratio = 10`, `dirty_ratio = 20`) to eliminate UI frame stalls.
  - Tunes `vm.vfs_cache_pressure` to 50 to keep directory dentries and inodes cached in RAM, accelerating cold app launches and multitasking.
  - Disables kernel scheduler context-switch accounting (`kernel.sched_schedstats = 0`) to eliminate unnecessary CPU overhead on thread switches.
  - Raises VM stat interval to 10s (`vm.stat_interval = 10`) to reduce CPU timer interrupts when idle or screen-off.
- **UFS Read-Ahead Boost**: Sets block queue read-ahead to 512 KB on UFS storage for faster sequential reads.
- **Network, Audio & Bluetooth Stutter Prevention**:
  - Automatically enables **TCP BBR** congestion control for lower packet latency and smoother high-res streaming.
  - Automatically disables background BLE and Wi-Fi scanning (`wifi_scan_always_enabled 0`, `ble_scan_always_enabled 0`) to eliminate 2.4 GHz radio collisions with Bluetooth audio (Galaxy Buds).
  - Disables Bluetooth HCI Snoop and diagnostic logging (`bluetooth_btsnoop_default_mode disabled`) to save flash I/O and prevent audio thread lag.
  - Optimizes Wi-Fi sleep policy (`wifi_sleep_policy 2`) to prevent modem dropouts during screen-off audio playback.
  - Automatically ensures audio apps and Galaxy Wearable/Buds managers are exempt from Doze sleep.
- **Samsung Telemetry & Diagnostic Hibernation**: Restricts `com.sec.android.diagmonagent`, `com.samsung.android.survey.service`, and `com.samsung.android.ipsgeofence` to the `RESTRICTED` app standby bucket to prevent background battery drain without breaking Knox.
- **Crash Dump & Cache Cleanup**: Purges stale `/data/anr/*`, `/data/tombstones/*`, and `/data/system/dropbox/*` logs and trims dead app caches via `pm trim-caches`.
- **Memory Compaction & Storage Trim**: Compacts kernel memory (`compact_memory`), drops inactive page caches, and runs `fstrim` on `/data` and `/cache`.
- **Samsung Enhanced CPU Responsiveness**: Enables `sem_enhanced_cpu_responsiveness 1` for faster CPU clock ramp-up.
- **Dynamic Island & NowBar Live Notifications**: Displays a real-time ongoing capsule during execution and converts into a clean static notification upon completion.
- **Xposed & Dynamic Island Safety**: Performs profile-guided ART compilation (`speed-profile`) on user apps and launchers while **strictly excluding `com.android.systemui`** to prevent breaking Xposed/Vector hooks and custom widgets.

---

## Installation & Flashing

### Magisk / KernelSU / APatch
1. Download or transfer `SamsungDailyOptimizer.zip` to your phone.
2. Open your root manager > **Modules** > **Install from storage**.
3. During installation, use the hardware **Volume keys** to choose your RAM Plus preference:
   - **Vol+**: Disable RAM Plus (`0 GB` - Recommended for lowest lag).
   - **Vol-**: Enable RAM Plus (`2 GB`).

### Standalone
If you prefer running without flashing a module, copy the folder to `/data/local/tmp/SamsungDailyOptimizer`:

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
SHOW_NOTIFICATIONS=1
TUNE_VFS_CACHE=1
VFS_CACHE_PRESSURE=50
DISABLE_SCHED_STATS=1
TUNE_STAT_INTERVAL=1
STAT_INTERVAL_SEC=10
ENABLE_TCP_BBR=1
DISABLE_BT_SNOOP_LOG=1
TUNE_WIFI_SLEEP=1
RESTRICT_SAMSUNG_TELEMETRY=1
```

---

## WebUI Dashboard

The module includes a lightweight, zero-dependency One UI-styled Web Dashboard for real-time monitoring and control.

### How to Access:
- **KernelSU / APatch / MMRL**: Tap the **WebUI** button on the module card.
- **On-Phone Browser (Standalone / Temproot)**:
  ```bash
  su -c /data/local/tmp/SamsungDailyOptimizer/start_webui.sh
  ```
  Then open **`http://127.0.0.1:8888`** in Samsung Internet or Chrome.
- **From Your PC (via ADB)**:
  ```bash
  adb forward tcp:8888 tcp:8888
  ```
  Then open **`http://localhost:8888`** in your desktop browser.
- **Stop Web Server**:
  ```bash
  su -c /data/local/tmp/SamsungDailyOptimizer/stop_webui.sh
  ```

### Dashboard Capabilities:
- **Live Memory & Swap Metrics**: Real-time progress bars for Physical RAM and Swap/ZRAM usage.
- **Radio & System Status**: Live indicators for Nearby Scanning, Background BLE, Wi-Fi Scanning, Enhanced CPU, and Daemon status.
- **Interactive RAM Plus Selector**: Select and apply 0 GB (Off), 2 GB, 4 GB, or 8 GB with one tap.
- **Quick Actions**:
  - ⚡ **Optimize Now**: Run the complete daily optimization suite.
  - 🧹 **Compact Memory & Trim**: Compact kernel memory, drop caches, and run `fstrim`.
  - 🗑️ **Purge Logs**: Clear tombstones, ANRs, and dropbox crash logs.
  - 🚀 **Toggle Enhanced CPU**: Toggle `sem_enhanced_cpu_responsiveness`.
  - ⏱️ **Start / Stop Daemon**: Control the 5:00 AM timer daemon.
- **Live Log Viewer**: Inspect recent execution logs with one-click refresh.
