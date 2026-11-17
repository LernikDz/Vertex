#!/system/bin/sh
# Vertex late service script
MODDIR="${0%/*}"

# Load configuration if present
if [ -f "$MODDIR/config.prop" ]; then
    . "$MODDIR/config.prop"
fi

# Apply boot-time Vulkan UI rendering & zero-latency frame latching
if [ "${VULKAN_UI_ENABLED:-1}" = "1" ]; then
    setprop debug.hwui.renderer skiavk
fi
if [ "${SF_ZERO_LATENCY_LATCHING:-1}" = "1" ]; then
    setprop debug.sf.latch_unsignaled 1
    setprop debug.sf.enable_gl_backpressure 0
fi

# Apply display refresh rate & touch sensitivity
if [ "${FORCE_120HZ_REFRESH:-0}" = "1" ]; then
    settings put system min_refresh_rate 120.0 2>/dev/null
    settings put system peak_refresh_rate 120.0 2>/dev/null
fi
if [ "${TOUCH_BOOST_ENABLED:-1}" = "1" ]; then
    settings put system touch_sensitivity 1 2>/dev/null
fi
if [ "${BYPASS_CHARGING_ENABLED:-0}" = "1" ]; then
    echo 1 > /sys/class/power_supply/battery/batt_slate_mode 2>/dev/null || echo 0 > /sys/class/power_supply/battery/charging_enabled 2>/dev/null
fi

# Apply UFS 4.0 scheduler queue optimizations
if [ "${TUNE_UFS_SCHEDULER:-1}" = "1" ]; then
    for q in /sys/block/sd*/queue /sys/block/nvme*/queue; do
        [ -d "$q" ] || continue
        grep -q "none" "$q/scheduler" 2>/dev/null && echo "none" > "$q/scheduler" 2>/dev/null
        [ -w "$q/nomerges" ] && echo 2 > "$q/nomerges" 2>/dev/null
        [ -w "$q/add_random" ] && echo 0 > "$q/add_random" 2>/dev/null
        [ -w "$q/iostats" ] && echo 0 > "$q/iostats" 2>/dev/null
    done
fi

# Launch scheduler daemon in background
nohup sh "$MODDIR/daemon.sh" >/dev/null 2>&1 &
