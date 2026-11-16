#!/system/bin/sh
# Stop WebUI server
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$SCRIPT_DIR/webui.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null
        rm -f "$PID_FILE"
        echo "WebUI server (PID $PID) stopped."
        exit 0
    fi
    rm -f "$PID_FILE"
fi

pkill -f "web_handler.sh" 2>/dev/null && echo "Stopped running WebUI instances." || echo "WebUI server is not running."
