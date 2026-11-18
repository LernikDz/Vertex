#!/system/bin/sh
# Stop optimizer daemon
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for f in "$SCRIPT_DIR/daemon.pid" /dev/vertex_daemon.pid /data/local/tmp/vertex_daemon.pid /data/adb/modules/samsung_daily_optimizer/daemon.pid; do
    if [ -f "$f" ]; then
        PID=$(cat "$f" 2>/dev/null | tr -d '\r\n')
        if [ -n "$PID" ]; then
            kill "$PID" 2>/dev/null || kill -9 "$PID" 2>/dev/null
        fi
        rm -f "$f" 2>/dev/null
    fi
done

for p in $(pgrep -f "sh .*/daemon\.sh" 2>/dev/null); do
    [ "$p" != "$$" ] && kill -9 "$p" 2>/dev/null
done

echo "Optimizer daemon stopped."
