#!/system/bin/sh
# Start optimizer daemon in background (Temproot / Standalone launcher)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$SCRIPT_DIR/daemon.pid"

# Terminate duplicate daemon processes
for p in $(pgrep -f "sh .*/daemon\.sh" 2>/dev/null); do
    [ "$p" != "$$" ] && kill -9 "$p" 2>/dev/null
done
rm -f "$PID_FILE" /dev/vertex_daemon.pid /data/local/tmp/vertex_daemon.pid 2>/dev/null

# Launch using setsid and nohup to detach completely from parent shell session
setsid nohup sh "$SCRIPT_DIR/daemon.sh" >/dev/null 2>&1 &
NEW_PID=$!
echo $NEW_PID > "$PID_FILE" 2>/dev/null
echo $NEW_PID > /dev/vertex_daemon.pid 2>/dev/null
echo $NEW_PID > /data/local/tmp/vertex_daemon.pid 2>/dev/null

echo "Vertex daemon started in background (PID $NEW_PID)."
echo "It provides real-time audio core pinning and runs daily maintenance at 05:00 AM."
