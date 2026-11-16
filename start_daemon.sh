#!/system/bin/sh
# Start optimizer daemon in background (Temproot / Standalone launcher)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -f "$SCRIPT_DIR/daemon.pid" ]; then
    PID=$(cat "$SCRIPT_DIR/daemon.pid" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        echo "Optimizer daemon is already running with PID $PID."
        exit 0
    fi
fi

nohup sh "$SCRIPT_DIR/daemon.sh" >/dev/null 2>&1 &
NEW_PID=$!
echo $NEW_PID > "$SCRIPT_DIR/daemon.pid"
echo "Vertex daemon started in background (PID $NEW_PID)."
echo "It will run daily at 05:00 AM."
