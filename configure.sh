#!/system/bin/sh
# Interactive Configuration Script for Vertex
# Allows changing RAM Plus, swappiness, and tuning anytime without re-flashing

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.prop"

echo "=========================================="
echo "   Vertex Configuration"
echo "=========================================="
echo "Current RAM Plus setting in system:"
CURRENT_SYS=$(settings get global ram_expand_size 2>/dev/null || echo "Unknown")
echo "  System ram_expand_size: $CURRENT_SYS MB"

if [ -f "$CONFIG_FILE" ]; then
    echo "Current configuration file ($CONFIG_FILE):"
    grep -E '^(RAM_PLUS_ENABLED|RAM_PLUS_SIZE|SWAPPINESS_VALUE|READ_AHEAD_KB)=' "$CONFIG_FILE" 2>/dev/null
fi

echo ""
echo "Select RAM Plus option:"
echo "  1) Disable RAM Plus (0 GB - Recommended for minimum lag)"
echo "  2) Enable RAM Plus (2 GB)"
echo "  3) Enable RAM Plus (4 GB)"
echo "  4) Enable RAM Plus (8 GB)"
echo "  5) Cancel / Exit"
echo ""
printf "Enter choice [1-5]: "
read -r choice

case "$choice" in
    1)
        ENABLED=0
        SIZE=0
        echo "Selected: Disable RAM Plus (0 GB)"
        ;;
    2)
        ENABLED=1
        SIZE=2048
        echo "Selected: Enable RAM Plus (2 GB)"
        ;;
    3)
        ENABLED=1
        SIZE=4096
        echo "Selected: Enable RAM Plus (4 GB)"
        ;;
    4)
        ENABLED=1
        SIZE=8192
        echo "Selected: Enable RAM Plus (8 GB)"
        ;;
    *)
        echo "Aborted. No changes made."
        exit 0
        ;;
esac

# Update config.prop preserving other keys
if [ -f "$CONFIG_FILE" ]; then
    sed -i "s/^RAM_PLUS_ENABLED=.*/RAM_PLUS_ENABLED=$ENABLED/" "$CONFIG_FILE"
    sed -i "s/^RAM_PLUS_SIZE=.*/RAM_PLUS_SIZE=$SIZE/" "$CONFIG_FILE"
else
    cat << EOF > "$CONFIG_FILE"
# Vertex Configuration (samsung_daily_optimizer)
RAM_PLUS_ENABLED=$ENABLED
RAM_PLUS_SIZE=$SIZE
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
EOF
fi

# Apply setting immediately to system settings
settings put global ram_expand_size "$SIZE" 2>/dev/null
echo ""
echo "[OK] config.prop updated and system setting applied ($SIZE MB)."
if [ "$SIZE" -eq 0 ]; then
    echo "Note: Disabling RAM Plus will fully take effect after the next device reboot."
else
    echo "Note: RAM Plus size changes take full effect after the next device reboot."
fi
