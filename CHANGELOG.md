# Changelog

All notable changes to the **Vertex** (formerly Samsung Daily Optimizer) project will be documented in this file.

---

## [v1.2] - 2026-11-16

### 🏷️ Rebrand
* **Display Name**: Rebranded the module display name and UI to **Vertex** while preserving the internal module ID (`samsung_daily_optimizer`) for seamless updates and full backwards compatibility.

### 🎨 Material 3 WebUI Dashboard
* **Native ReZygisk / KernelSU Design**: Completely overhauled the Web UI to match the clean Material 3 dark aesthetic.
* **Top Working Status Banner**: Real-time operational indicator (`✓ Working`) with dynamic status checks.
* **Material 3 Bottom Navigation**: Smooth, single-page navigation with pill highlights across **Home**, **RAM Plus**, **Actions**, and **Logs**.
* **Categorized System Overview**: Displays live stats for Android/Kernel versions, RAM & ZRAM allocation, VFS cache parameters, network congestion, and audio radio guards.
* **Interactive Terminal Log Viewer**: Built-in activity log viewer with one-click refresh and automatic scroll-to-bottom.
* **Dual Execution Modes**: Seamlessly renders inside KernelSU / APatch / MMRL embedded WebViews, or in standalone mobile/desktop browsers via the integrated zero-dependency micro HTTP server on port `8888`.

### 🏝️ Live Dynamic Island & One UI NowBar Notifications
* **Ongoing Live Capsule**: Automatically posts persistent, animated progress notifications using `category=transport` and sync indicators during maintenance passes.
* **Real-Time Step Tracking**: Follow along as the optimizer tunes RAM Plus, stabilizes wireless radios, purges crash dumps, compacts memory, and runs ART compilations.
* **Clean Completion Transition**: Seamlessly converts the ongoing pill into a dismissable static notification without cluttering your notification shade.

### 🎧 Real-Time Audio Scheduling (Buds3 Pro Desync Fix)
* **Thread Priority Boost**: Automatically gives `com.android.bluetooth`, `audioserver`, and `android.hardware.audio.service` real-time scheduling priority (`nice -16`).
* **High-Performance CPUSet Migration**: Pins audio and Bluetooth encoder worker threads directly to the `top-app` performance CPU cores (`/dev/cpuset/top-app`).
* **Eliminates Buffer Underruns**: Prevents background widgets (KWGT), overlays, or system tasks from preempting 24-bit Samsung Seamless Codec (SSC) processing, stopping left/right earbud phase-drift and re-sync stutters.

### ⚡ Kernel & Memory Subsystem Tuning
* **VFS Cache Pressure Tuning (`vm.vfs_cache_pressure = 50`)**: Keeps directory structures and file inodes cached in RAM longer, accelerating app launch and switching speeds.
* **Disabled Scheduler Statistics (`kernel.sched_schedstats = 0`)**: Eliminates scheduler context-switch accounting overhead across all CPU cores.
* **Optimized VM Stat Interval (`vm.stat_interval = 10`)**: Reduces idle CPU timer wakeups from once per second to every 10 seconds to save battery during screen-off.

### 🌐 Network & Wireless Streaming Enhancements
* **TCP BBR Congestion Control**: Sets default TCP congestion control to Google's BBR algorithm for lower packet latency, reduced bufferbloat, and smoother lossless music streaming.
* **Disabled Bluetooth HCI Snoop Logging**: Silences `bluetooth_btsnoop_default_mode` to prevent background packet dumps to internal flash and eliminate audio thread I/O stalls.
* **Optimized Wi-Fi Sleep Policy (`wifi_sleep_policy = 2`)**: Prevents modem link degradation while streaming audio with the screen off.

### 🛡️ Samsung Diagnostics & Telemetry Hibernation
* **Restricted App Standby**: Automatically places telemetry and diagnostic services into the `RESTRICTED` app standby bucket (`cmd appops` & `am set-standby-bucket`):
  * `com.sec.android.diagmonagent` (Samsung Diagnostic Monitor)
  * `com.samsung.android.survey.service` (Customer Survey)
  * `com.samsung.android.ipsgeofence` (Background Geofence Beaconing)
* **Privacy & Battery**: Eliminates unwanted background modem wakeups without breaking Knox, Samsung Accounts, or system stability.

---

## [v1.1] - 2026-11-15

* Added interactive Volume key hardware selection during flashing for RAM Plus (0 GB vs 2 GB).
* Added standalone interactive CLI configuration utility (`configure.sh`).
* Added memory compaction (`compact_memory`) and flash storage trim (`fstrim`).
* Added background BLE and Wi-Fi always-scanning disablement.
* Added Doze sleep whitelisting for Buds managers and music streaming apps.
* Added selective ART profile compilation with explicit SystemUI exclusion to protect Dynamic Island / Xposed hooks.
* Added Samsung Enhanced CPU responsiveness toggle.
