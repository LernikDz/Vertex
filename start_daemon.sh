#!/system/bin/sh
# Start optimizer daemon in background (Temproot / Standalone launcher)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$SCRIPT_DIR/daemon.pid"

# Terminate any duplicate daemon processes first
for p in $(pgrep -f "daemon.sh" 2>/dev/null); do
    [ "$p" != "$$" ] && kill -9 "$p" 2>/dev/null
done
rm -f "$PID_FILE"

nohup sh "$SCRIPT_DIR/daemon.sh" >/dev/null 2>&1 &
NEW_PID=$!
echo $NEW_PID > "$PID_FILE"
echo "Vertex daemon started in background (PID $NEW_PID)."
echo "It provides real-time audio core pinning and runs daily maintenance at 05:00 AM."
