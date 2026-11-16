#!/system/bin/sh
# Samsung Daily Optimizer Routine
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
log "Starting Samsung Daily Optimization..."
log "======================================================"

# 1. RAM Plus Configuration
log "Configuring RAM Plus settings..."
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

# 5. Samsung Enhanced CPU Responsiveness
if [ "$ENHANCED_CPU_RESPONSIVENESS" = "1" ]; then
    settings put global sem_enhanced_cpu_responsiveness 1 2>/dev/null && log "  [OK] Enhanced CPU responsiveness enabled"
fi

# 6. Crash Logs & Stale Cache Cleanup
if [ "$PURGE_CRASH_LOGS" = "1" ]; then
    log "Purging crash dumps, ANR traces, and dropbox logs..."
    rm -f /data/anr/* 2>/dev/null
    rm -f /data/tombstones/* 2>/dev/null
    rm -f /data/system/dropbox/* 2>/dev/null
    log "  [OK] Stale ANRs, tombstones, and crash reports cleared"
fi

if [ "$TRIM_APP_CACHES" = "1" ]; then
    log "Trimming system and app caches..."
    pm trim-caches 4096M >/dev/null 2>&1 && log "  [OK] Dead caches trimmed"
fi

# 7. Kernel Memory Compaction & Storage Trim
log "Executing kernel memory maintenance and storage trim..."
sync
if [ -w /proc/sys/vm/compact_memory ]; then
    echo 1 > /proc/sys/vm/compact_memory 2>/dev/null && log "  [OK] Kernel memory compacted"
fi
if [ -w /proc/sys/vm/drop_caches ]; then
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null && log "  [OK] Inactive page cache dropped"
fi

fstrim -v /data 2>/dev/null | while read -r line; do log "  [TRIM] /data: $line"; done
fstrim -v /cache 2>/dev/null | while read -r line; do log "  [TRIM] /cache: $line"; done

# 8. Safe Selective ART AOT / Profile Compilation
# NOTE: com.android.systemui is strictly excluded to prevent breaking Dynamic Island / Xposed
log "Running selective ART profile compilation (excluding SystemUI)..."
COMPILE_PKGS="com.sec.android.app.launcher com.android.bluetooth com.google.android.apps.youtube.music com.metrolist.music com.samsung.accessory.budsunitemgr"
for pkg in $COMPILE_PKGS; do
    if pm list packages 2>/dev/null | grep -q "$pkg"; then
        log "  Compiling $pkg (speed-profile)..."
        cmd package compile -m speed-profile "$pkg" >/dev/null 2>&1 && log "  [OK] $pkg compiled successfully" || log "  [WARN] Failed to compile $pkg"
    fi
done

log "======================================================"
log "Optimization completed successfully."
log "======================================================"
