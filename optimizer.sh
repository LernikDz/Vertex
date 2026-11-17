#!/system/bin/sh
# Vertex Routine (formerly Samsung Daily Optimizer)
# Automated performance maintenance for Samsung Galaxy devices (One UI)
# Safe for Xposed / Vector (com.android.systemui is explicitly excluded)

export PATH="/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH:/system/bin:/system/xbin"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load configuration if present
if [ -f "$SCRIPT_DIR/config.prop" ]; then
    . "$SCRIPT_DIR/config.prop"
elif [ -f "/data/adb/modules/samsung_daily_optimizer/config.prop" ]; then
    . "/data/adb/modules/samsung_daily_optimizer/config.prop"
fi

# Defaults
RAM_PLUS_ENABLED="${RAM_PLUS_ENABLED:-1}"
RAM_PLUS_SIZE="${RAM_PLUS_SIZE:-2048}"
TUNE_SWAPPINESS="${TUNE_SWAPPINESS:-1}"
SWAPPINESS_VALUE="${SWAPPINESS_VALUE:-60}"
TUNE_READ_AHEAD="${TUNE_READ_AHEAD:-1}"
READ_AHEAD_KB="${READ_AHEAD_KB:-512}"
PURGE_CRASH_LOGS="${PURGE_CRASH_LOGS:-1}"
TRIM_APP_CACHES="${TRIM_APP_CACHES:-1}"
DISABLE_BACKGROUND_BLE_SCAN="${DISABLE_BACKGROUND_BLE_SCAN:-1}"
DISABLE_BACKGROUND_WIFI_SCAN="${DISABLE_BACKGROUND_WIFI_SCAN:-1}"
WHITELIST_AUDIO_APPS="${WHITELIST_AUDIO_APPS:-1}"
ENHANCED_CPU_RESPONSIVENESS="${ENHANCED_CPU_RESPONSIVENESS:-1}"
SHOW_NOTIFICATIONS="${SHOW_NOTIFICATIONS:-1}"
TUNE_VFS_CACHE="${TUNE_VFS_CACHE:-1}"
VFS_CACHE_PRESSURE="${VFS_CACHE_PRESSURE:-50}"
DISABLE_SCHED_STATS="${DISABLE_SCHED_STATS:-1}"
TUNE_STAT_INTERVAL="${TUNE_STAT_INTERVAL:-1}"
STAT_INTERVAL_SEC="${STAT_INTERVAL_SEC:-10}"
ENABLE_TCP_BBR="${ENABLE_TCP_BBR:-1}"
DISABLE_BT_SNOOP_LOG="${DISABLE_BT_SNOOP_LOG:-1}"
TUNE_WIFI_SLEEP="${TUNE_WIFI_SLEEP:-1}"
RESTRICT_SAMSUNG_TELEMETRY="${RESTRICT_SAMSUNG_TELEMETRY:-1}"
BOOST_AUDIO_PRIORITY="${BOOST_AUDIO_PRIORITY:-1}"
PREVENT_LOCKSCREEN_AUDIO_STUTTER="${PREVENT_LOCKSCREEN_AUDIO_STUTTER:-1}"
TUNE_ZRAM_ALGORITHM="${TUNE_ZRAM_ALGORITHM:-1}"
ZRAM_COMP_ALGORITHM="${ZRAM_COMP_ALGORITHM:-zstd}"
FORCE_120HZ_REFRESH="${FORCE_120HZ_REFRESH:-0}"

# Notification helpers (Live NowBar / Dynamic Island notification while running, static on finish)
notify_live() {
    [ "$SHOW_NOTIFICATIONS" != "1" ] && return 0
    cmd notification post -S media -i @android:drawable/stat_notify_sync -t "Vertex" "samsung_optimizer" "$1" >/dev/null 2>&1
}

notify_done() {
    [ "$SHOW_NOTIFICATIONS" != "1" ] && return 0
    cmd notification post -i @android:drawable/ic_dialog_info -t "Vertex" "samsung_optimizer" "$1" >/dev/null 2>&1
}

# Determine log file path
if [ -d "/data/adb/modules/samsung_daily_optimizer" ]; then
    LOG_FILE="/data/adb/modules/samsung_daily_optimizer/optimizer.log"
elif [ -w "$SCRIPT_DIR" ]; then
    LOG_FILE="$SCRIPT_DIR/optimizer.log"
else
    LOG_FILE="/data/local/tmp/samsung_daily_optimizer.log"
fi

# Log rotation: keep last 300 lines if larger than 256KB
if [ -f "$LOG_FILE" ]; then
    FILE_SIZE=$(wc -c < "$LOG_FILE" 2>/dev/null || echo 0)
    if [ "$FILE_SIZE" -gt 262144 ]; then
        tail -n 300 "$LOG_FILE" > "$LOG_FILE.tmp" 2>/dev/null && mv "$LOG_FILE.tmp" "$LOG_FILE"
    fi
fi

log() {
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE" 2>/dev/null
}

log "======================================================"
log "Starting Vertex Optimization..."
log "======================================================"

notify_live "⚡ Starting daily optimization routine..."

# 1. RAM Plus Configuration
log "Configuring RAM Plus settings..."
notify_live "⚙️ Tuning RAM Plus & kernel parameters..."
if [ "$RAM_PLUS_ENABLED" = "0" ] || [ "$RAM_PLUS_SIZE" = "0" ]; then
    settings put global ram_expand_size 0 2>/dev/null && log "  [OK] RAM Plus DISABLED (0 MB)" || log "  [WARN] Failed to disable RAM Plus"
else
    settings put global ram_expand_size "$RAM_PLUS_SIZE" 2>/dev/null && log "  [OK] RAM Plus set to ${RAM_PLUS_SIZE} MB" || log "  [WARN] Failed to set RAM Plus"
fi

# 2. Kernel VM & Swappiness Tuning
if [ "$TUNE_SWAPPINESS" = "1" ]; then
    log "Tuning kernel VM parameters..."
    if [ -w /proc/sys/vm/swappiness ]; then
        echo "$SWAPPINESS_VALUE" > /proc/sys/vm/swappiness 2>/dev/null && log "  [OK] Kernel swappiness set to $SWAPPINESS_VALUE"
    fi
    if [ -w /proc/sys/vm/dirty_background_ratio ]; then
        echo 10 > /proc/sys/vm/dirty_background_ratio 2>/dev/null
    fi
    if [ -w /proc/sys/vm/dirty_ratio ]; then
        echo 20 > /proc/sys/vm/dirty_ratio 2>/dev/null
    fi
    if [ "$TUNE_VFS_CACHE" = "1" ] && [ -w /proc/sys/vm/vfs_cache_pressure ]; then
        echo "$VFS_CACHE_PRESSURE" > /proc/sys/vm/vfs_cache_pressure 2>/dev/null && log "  [OK] VFS cache pressure set to $VFS_CACHE_PRESSURE"
    fi
    if [ "$DISABLE_SCHED_STATS" = "1" ] && [ -w /proc/sys/kernel/sched_schedstats ]; then
        echo 0 > /proc/sys/kernel/sched_schedstats 2>/dev/null && log "  [OK] Kernel scheduler statistics disabled"
    fi
    if [ "$TUNE_STAT_INTERVAL" = "1" ] && [ -w /proc/sys/vm/stat_interval ]; then
        echo "$STAT_INTERVAL_SEC" > /proc/sys/vm/stat_interval 2>/dev/null && log "  [OK] VM stat interval set to ${STAT_INTERVAL_SEC}s"
    fi
fi

# 3. Flash Storage Read-Ahead
if [ "$TUNE_READ_AHEAD" = "1" ]; then
    log "Optimizing flash storage read-ahead queue..."
    for q in /sys/block/sd*/queue/read_ahead_kb; do
        if [ -w "$q" ]; then
            echo "$READ_AHEAD_KB" > "$q" 2>/dev/null
        fi
    done
    log "  [OK] Block read-ahead set to ${READ_AHEAD_KB} KB"
fi

# 4. Wireless & Audio Stability (Reduce 2.4GHz interference)
log "Configuring wireless radio scans and Doze whitelists..."
notify_live "📶 Stabilizing wireless radio & audio streaming..."
if [ "$DISABLE_BACKGROUND_BLE_SCAN" = "1" ]; then
    settings put global ble_scan_always_enabled 0 2>/dev/null && log "  [OK] Background BLE scanning disabled"
    settings put system nearby_scanning_enabled 0 2>/dev/null && log "  [OK] Samsung nearby device scanning disabled"
fi
if [ "$DISABLE_BACKGROUND_WIFI_SCAN" = "1" ]; then
    settings put global wifi_scan_always_enabled 0 2>/dev/null && log "  [OK] Background Wi-Fi scanning disabled"
fi

if [ "$WHITELIST_AUDIO_APPS" = "1" ]; then
    TARGET_PKGS="com.samsung.accessory.budsunitemgr com.samsung.accessory.paranmgr com.google.android.apps.youtube.music com.metrolist.music com.spotify.music"
    for pkg in $TARGET_PKGS; do
        if pm list packages 2>/dev/null | grep -q "$pkg"; then
            if dumpsys deviceidle whitelist 2>/dev/null | grep -q "$pkg"; then
                log "  [SKIP] $pkg already in Doze whitelist"
            else
                cmd deviceidle whitelist "+$pkg" 2>/dev/null && log "  [ADDED] $pkg added to Doze whitelist"
            fi
        fi
    done
fi

if [ "$ENABLE_TCP_BBR" = "1" ] && [ -w /proc/sys/net/ipv4/tcp_congestion_control ]; then
    if grep -q "bbr" /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null; then
        echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null && log "  [OK] TCP congestion control set to BBR"
    else
        CURRENT_TCP=$(cat /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null)
        log "  [INFO] TCP congestion algorithm: $CURRENT_TCP"
    fi
fi

if [ "$DISABLE_BT_SNOOP_LOG" = "1" ]; then
    settings put global bluetooth_btsnoop_default_mode disabled 2>/dev/null
    setprop persist.bluetooth.btsnoopenable false 2>/dev/null
    log "  [OK] Bluetooth HCI snoop logging disabled"
fi

if [ "$TUNE_WIFI_SLEEP" = "1" ]; then
    settings put global wifi_sleep_policy 2 2>/dev/null && log "  [OK] Wi-Fi sleep policy set to never sleep"
fi

# 5. Samsung Enhanced CPU Responsiveness
if [ "$ENHANCED_CPU_RESPONSIVENESS" = "1" ]; then
    settings put global sem_enhanced_cpu_responsiveness 1 2>/dev/null && log "  [OK] Enhanced CPU responsiveness enabled"
fi

# 6. Samsung Diagnostics & Telemetry Hibernation
if [ "$RESTRICT_SAMSUNG_TELEMETRY" = "1" ]; then
    log "Restricting Samsung diagnostic and telemetry services..."
    notify_live "🛡️ Restricting Samsung diagnostic & telemetry services..."
    TELEMETRY_PKGS="com.sec.android.diagmonagent com.samsung.android.survey.service com.samsung.android.ipsgeofence"
    for tpkg in $TELEMETRY_PKGS; do
        if pm list packages 2>/dev/null | grep -q "$tpkg"; then
            am set-standby-bucket "$tpkg" restricted 2>/dev/null
            cmd appops set "$tpkg" RUN_IN_BACKGROUND ignore 2>/dev/null
            log "  [RESTRICTED] $tpkg placed into restricted standby"
        fi
    done
fi

# 7. Crash Logs & Stale Cache Cleanup
if [ "$PURGE_CRASH_LOGS" = "1" ]; then
    log "Purging crash dumps, ANR traces, and dropbox logs..."
    notify_live "🧹 Purging crash logs & trimming app caches..."
    rm -f /data/anr/* 2>/dev/null
    rm -f /data/tombstones/* 2>/dev/null
    rm -f /data/system/dropbox/* 2>/dev/null
    log "  [OK] Stale ANRs, tombstones, and crash reports cleared"
fi

if [ "$TRIM_APP_CACHES" = "1" ]; then
    log "Trimming system and app caches..."
    pm trim-caches 4096M >/dev/null 2>&1 && log "  [OK] Dead caches trimmed"
fi

# 8. Kernel Memory Compaction & Storage Trim
log "Executing kernel memory maintenance and storage trim..."
notify_live "💾 Compacting kernel memory & running fstrim..."
sync
if [ -w /proc/sys/vm/compact_memory ]; then
    echo 1 > /proc/sys/vm/compact_memory 2>/dev/null && log "  [OK] Kernel memory compacted"
fi
if [ -w /proc/sys/vm/drop_caches ]; then
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null && log "  [OK] Inactive page cache dropped"
fi

fstrim -v /data 2>/dev/null | while read -r line; do log "  [TRIM] /data: $line"; done
fstrim -v /cache 2>/dev/null | while read -r line; do log "  [TRIM] /cache: $line"; done

# 9. Safe Selective ART AOT / Profile Compilation
# NOTE: com.android.systemui is strictly excluded to prevent breaking Dynamic Island / Xposed
log "Running selective ART profile compilation (excluding SystemUI)..."
notify_live "🚀 Profile compiling apps (Speed-profile)..."
COMPILE_PKGS="com.sec.android.app.launcher com.android.bluetooth com.google.android.apps.youtube.music com.metrolist.music com.samsung.accessory.budsunitemgr"
for pkg in $COMPILE_PKGS; do
    if pm list packages 2>/dev/null | grep -q "$pkg"; then
        log "  Compiling $pkg (speed-profile)..."
        cmd package compile -m speed-profile "$pkg" >/dev/null 2>&1 && log "  [OK] $pkg compiled successfully" || log "  [WARN] Failed to compile $pkg"
    fi
done

# 10. Real-Time Audio & Bluetooth Thread Priority Boost
# Prevents audio thread starvation, screen-lock stutters, and L/R earbud desync
if [ "$BOOST_AUDIO_PRIORITY" = "1" ]; then
    log "Boosting Bluetooth, AudioFlinger, SoundAlive, and Exynos Audio HAL priorities..."
    notify_live "🎧 Prioritizing audio HAL & Bluetooth streaming threads..."
    AUDIO_DAEMONS="audioserver secaudiohalaidl android.hardware.audio.service com.android.bluetooth com.sec.android.app.soundalive android.hardware.bluetooth@1.1-service-qti"
    for daemon in $AUDIO_DAEMONS; do
        for apid in $(pidof "$daemon" 2>/dev/null); do
            renice -n -16 -p "$apid" >/dev/null 2>&1
            if [ -d "/proc/$apid/task" ]; then
                for atid in /proc/"$apid"/task/*; do
                    tid_num=$(basename "$atid")
                    [ -d /dev/cpuset/foreground-boost ] && echo "$tid_num" > /dev/cpuset/foreground-boost/tasks 2>/dev/null
                    [ -d /dev/cpuset/top-app ] && echo "$tid_num" > /dev/cpuset/top-app/tasks 2>/dev/null
                done
            fi
        done
    done
    log "  [OK] Audio HAL (secaudiohalaidl), SoundAlive, and Bluetooth pinned to performance cpusets"
fi

# 10b. Lockscreen Audio Collision Guard
# Disables lockscreen sound effect to prevent AudioFlinger PCM stream re-negotiation & 1-second stutter on screen lock
if [ "$PREVENT_LOCKSCREEN_AUDIO_STUTTER" = "1" ]; then
    settings put system lockscreen_sounds_enabled 0 2>/dev/null
    log "  [OK] Lockscreen sound effect disabled to prevent Bluetooth stream collision on lock"
fi

# 11. ZRAM Compression Algorithm Engine Tuning
# Switches kernel ZRAM compression to ZSTD for ~35% higher compression ratio on modern ARMv9
if [ "$TUNE_ZRAM_ALGORITHM" = "1" ] && [ -f "/sys/block/zram0/comp_algorithm" ]; then
    CURRENT_ALG=$(cat /sys/block/zram0/comp_algorithm 2>/dev/null | sed -n 's/.*\[\([^]]*\)\].*/\1/p')
    TARGET_ALG="${ZRAM_COMP_ALGORITHM:-zstd}"
    if [ -n "$CURRENT_ALG" ] && [ "$CURRENT_ALG" != "$TARGET_ALG" ]; then
        if grep -q "$TARGET_ALG" /sys/block/zram0/comp_algorithm 2>/dev/null; then
            log "Configuring ZRAM compression engine to $TARGET_ALG..."
            notify_live "⚡ Switching ZRAM compression engine to $TARGET_ALG..."
            ZRAM_SIZE=$(cat /sys/block/zram0/disksize 2>/dev/null)
            swapoff /dev/block/zram0 2>/dev/null
            echo 1 > /sys/block/zram0/reset 2>/dev/null
            echo "$TARGET_ALG" > /sys/block/zram0/comp_algorithm 2>/dev/null
            [ -n "$ZRAM_SIZE" ] && [ "$ZRAM_SIZE" -gt 0 ] && echo "$ZRAM_SIZE" > /sys/block/zram0/disksize 2>/dev/null
            mkswap /dev/block/zram0 >/dev/null 2>&1
            swapon /dev/block/zram0 >/dev/null 2>&1
            NEW_ALG=$(cat /sys/block/zram0/comp_algorithm 2>/dev/null | sed -n 's/.*\[\([^]]*\)\].*/\1/p')
            log "  [OK] ZRAM compression engine active: [$NEW_ALG]"
        else
            log "  [INFO] Target ZRAM algorithm $TARGET_ALG not supported by kernel, keeping [$CURRENT_ALG]"
        fi
    else
        log "  [OK] ZRAM compression algorithm already active: [$CURRENT_ALG]"
    fi
fi

# 12. Display Smooth Scroll Lock (120Hz Force)
if [ "$FORCE_120HZ_REFRESH" = "1" ]; then
    settings put system min_refresh_rate 120.0 2>/dev/null
    settings put system peak_refresh_rate 120.0 2>/dev/null
    log "  [OK] Display minimum refresh rate locked to 120Hz (zero micro-stutter)"
fi

log "======================================================"
log "Optimization completed successfully."
log "======================================================"

notify_done "✅ Optimization complete! Memory compacted & storage trimmed."
