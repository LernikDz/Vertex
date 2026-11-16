#!/system/bin/sh
# Immediate manual trigger for Vertex
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -f "$SCRIPT_DIR/optimizer.sh" ]; then
    sh "$SCRIPT_DIR/optimizer.sh"
elif [ -f "/data/adb/modules/samsung_daily_optimizer/optimizer.sh" ]; then
    sh "/data/adb/modules/samsung_daily_optimizer/optimizer.sh"
else
    echo "Error: optimizer.sh not found."
    exit 1
fi
