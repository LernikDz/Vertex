#!/system/bin/sh
# Start WebUI server on port 8888
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PORT="${1:-8888}"
PID_FILE="$SCRIPT_DIR/webui.pid"

if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE" 2>/dev/null)
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        echo "WebUI is already running at http://127.0.0.1:$PORT (PID $OLD_PID)"
        exit 0
    fi
fi

# Find toybox nc or netcat
NC_BIN="toybox nc"
if ! command -v toybox >/dev/null 2>&1; then
    NC_BIN="nc"
fi

nohup $NC_BIN -L -p "$PORT" sh "$SCRIPT_DIR/web_handler.sh" >/dev/null 2>&1 &
SERVER_PID=$!
echo $SERVER_PID > "$PID_FILE"

echo "============================================="
echo " Samsung Daily Optimizer WebUI Started"
echo "============================================="
echo " Open in Chrome or any browser on your device:"
echo " -> http://127.0.0.1:$PORT"
echo "============================================="
