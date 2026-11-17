# ⚡ Vertex (Samsung Daily Optimizer)

> **Keep your Samsung Galaxy fast, smooth, and stutter-free — automatically.**

Vertex is an automated performance module for Samsung Galaxy phones running One UI. Think of it as a **nightly pit crew** for your phone: while you sleep, it cleans out system junk, stops background micro-stutters, and keeps your phone feeling brand new.

Compatible with **KernelSU**, **Magisk**, **APatch**, and **Temproot**.

---

## 🌟 What Vertex Does (In Plain English)

| What You Feel | How Vertex Does It |
|---|---|
| 🧈 **Silky Smooth 120Hz Scrolling** | Stops One UI from awkwardly dropping down to 60Hz mid-scroll in apps like Twitter, Instagram, or Chrome. |
| 🎧 **No More Audio Stutter** | Stops your Galaxy Buds or Bluetooth headphones from cutting out when you lock your screen or walk around. |
| 🚀 **Instant App Switching** | Fixes Samsung's slow virtual memory ("RAM Plus") so your apps open quickly and stay in memory without lag. |
| ❄️ **Cool Gaming & Desk Mode** | Play games or charge at your desk without heating up the phone or wearing out the battery (*Bypass Charging*). |
| 🧹 **Automatic Daily Tune-Up** | Cleans out crash dumps, dead app caches, and organizes memory at 5:00 AM (only when you aren't using the phone!). |
| 🔋 **Better Battery Life** | Puts Samsung's hidden background diagnostic and tracking services to sleep. |

---

## 📲 How to Install (30-Second Guide)

1. **Download**: Grab **`Vertex.zip`** from the [Latest Release](https://github.com/WollyDev24/Vertex/releases/latest).
2. **Flash**:
   - Open your root app (**KernelSU**, **Magisk**, or **APatch**).
   - Tap **Modules** ➜ **Install from storage** ➜ select `Vertex.zip`.
3. **Choose RAM Plus**:
   - During flashing, use your **Volume Up** button to pick **0 GB (Off)** — *Recommended for the fastest, smoothest experience!*
4. **Reboot** your phone. You're done! 🎉

*(Don't have root manager? Check the [Standalone Guide](#standalone-installation-no-flashing) below).*

---

## 🎨 The Dashboard (Styled like Samsung Good Lock / Home Up)

Vertex includes a built-in dashboard right inside KernelSU, APatch, or MMRL. Tap the **WebUI** button to open it:

- **Master Switch**: See when your next automatic 5:00 AM tune-up is scheduled, or run one right now.
- **RAM Plus Card**: Switch between 0 GB, 2 GB, 4 GB, or 8 GB with one tap.
- **ZRAM Engine Card**: Boost your memory capacity using high-speed compression (`ZSTD`).
- **Smooth Scroll Card**: Lock your screen to 120Hz for zero micro-stutter, or tap to restore standard dynamic LTPO.
- **Bypass Charging Card**: Power your phone directly from the charger without heating the battery while gaming.
- **Audio Guard Card**: Give real-time priority to Bluetooth and audio threads to prevent glitches.
- **1-Tap Maintenance**: Clean crash logs, trim storage (`fstrim`), and compact memory on demand.

*To open in Samsung Internet or Chrome: run `su -c /data/adb/modules/samsung_daily_optimizer/start_webui.sh` and visit `http://127.0.0.1:8888`.*

---

## ❓ Frequently Asked Questions (FAQ)

### Will this delete my photos, messages, or apps?
**No, never.** Vertex only cleans temporary system crash dumps, dead app caches, and inactive memory buffers. Your personal data, photos, and files are 100% untouched.

### Why should I turn off RAM Plus (0 GB)?
Samsung's "RAM Plus" uses your phone's storage flash drive as extra memory. Because flash storage is much slower than real RAM, swapping data in and out causes micro-freezes and audio stutter. Modern Galaxy phones (8 GB / 12 GB RAM) run **significantly faster** with RAM Plus turned off.

### Does Vertex drain my battery?
**No.** Vertex does not stay running heavy tasks in the background. It schedules a quick 3-second cleanup at 5:00 AM, and if you are using your phone, it politely waits until the screen turns off. Hibernating Samsung diagnostic background trackers often *improves* standby battery life.

### Which devices are supported?
All modern Samsung Galaxy devices running **One UI 5, 6, 6.1, or 7** (Galaxy S24, S23, S22, S21, Z Fold, Z Flip, A-series, and Galaxy Tabs).

---

## 🛠️ For Geeks & Advanced Users (Under the Hood)

<details>
<summary><b>Click to expand kernel and sysctl tuning details</b></summary>

- **ZRAM Switcher**: Supports `zstd`, `lz4`, and `lzo-rle`. On ARMv9 (Snapdragon 8 Gen 3 / Exynos 2400), `zstd` offers ~35% higher compression ratio.
- **Virtual Memory (VM)**: Lowers `vm.swappiness` to 60 (down from Samsung stock 160-180), tunes `dirty_ratio = 20`, and `dirty_background_ratio = 10`.
- **Dentry & Inode Caching**: `vm.vfs_cache_pressure = 50` keeps directory structures in RAM for faster cold app launches.
- **Timer Jitter**: Raises `vm.stat_interval = 10` and sets `kernel.sched_schedstats = 0` to reduce context switch accounting overhead.
- **Network & Audio**: Enables **TCP BBR** congestion control, disables BLE/Wi-Fi background polling collisions with 2.4 GHz Bluetooth, disables BT HCI snoop logs, sets `wifi_sleep_policy = 2`, and pins audio HAL/BT threads to Performance Cores (Cortex-A720/X4).
- **Safe Compilation**: Profile-guided ART compilation (`speed-profile`) strictly excludes `com.android.systemui` to prevent breaking Xposed/Vector hooks.
- **Config file**: Tunable via `/data/adb/modules/samsung_daily_optimizer/config.prop`.

</details>

---

## 💻 Standalone Installation (No Flashing)

If you use Temproot or prefer running Vertex directly from a terminal:

```bash
# 1. Copy folder to /data/local/tmp/SamsungDailyOptimizer
# 2. Start the 5:00 AM scheduler:
su -c /data/local/tmp/SamsungDailyOptimizer/start_daemon.sh

# Run optimization immediately:
su -c /data/local/tmp/SamsungDailyOptimizer/run_now.sh

# Interactive terminal menu:
su -c /data/local/tmp/SamsungDailyOptimizer/configure.sh
```

---

## 📜 License
Open-source under the [MIT License](LICENSE). Made for the Samsung Galaxy community.
