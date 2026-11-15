#!/system/bin/sh
# Stop optimizer daemon
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -f "$SCRIPT_DIR/daemon.pid" ]; then
    PID=$(cat "$SCRIPT_DIR/daemon.pid" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null
        rm -f "$SCRIPT_DIR/daemon.pid"
        echo "Optimizer daemon (PID $PID) stopped."
        exit 0
    fi
    rm -f "$SCRIPT_DIR/daemon.pid"
fi

pkill -f "daemon.sh" 2>/dev/null && echo "Stopped running daemon instances." || echo "Optimizer daemon is not running."
