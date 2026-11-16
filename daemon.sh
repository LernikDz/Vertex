#!/system/bin/sh
# Vertex Scheduler Daemon
# Sleeps until 05:00 AM daily, executes optimizer.sh, then repeats.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$SCRIPT_DIR/daemon.pid"

# Check if already running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE" 2>/dev/null)
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        echo "Optimizer daemon is already running (PID $OLD_PID)."
        exit 0
    fi
fi

echo $$ > "$PID_FILE" 2>/dev/null

log_daemon() {
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] [DAEMON] $1"
}

log_daemon "Optimizer scheduler started (PID $$). Initial boot execution is DISABLED."

# Target time: 05:00 AM
TARGET_HOUR=5
TARGET_MIN=0
TARGET_SEC_DAY=$(( TARGET_HOUR * 3600 + TARGET_MIN * 60 ))

while true; do
    CUR_H=$(date '+%H' 2>/dev/null)
    CUR_M=$(date '+%M' 2>/dev/null)
    CUR_S=$(date '+%S' 2>/dev/null)

    CUR_H=$((10#$CUR_H))
    CUR_M=$((10#$CUR_M))
    CUR_S=$((10#$CUR_S))

    CUR_SEC_DAY=$(( CUR_H * 3600 + CUR_M * 60 + CUR_S ))

    if [ "$CUR_SEC_DAY" -lt "$TARGET_SEC_DAY" ]; then
        SLEEP_SEC=$(( TARGET_SEC_DAY - CUR_SEC_DAY ))
    else
        SLEEP_SEC=$(( 86400 - CUR_SEC_DAY + TARGET_SEC_DAY ))
    fi

    HOURS_WAIT=$(( SLEEP_SEC / 3600 ))
    MINS_WAIT=$(( (SLEEP_SEC % 3600) / 60 ))
    log_daemon "Next scheduled optimization at 05:00 AM (in ${HOURS_WAIT}h ${MINS_WAIT}m / ${SLEEP_SEC}s)..."

    sleep "$SLEEP_SEC"

    log_daemon "Scheduled time reached! Checking device state..."
    
    # Load configuration
    SMART_SCREEN_AWARE=1
    if [ -f "$SCRIPT_DIR/config.prop" ]; then
        . "$SCRIPT_DIR/config.prop"
    elif [ -f "/data/adb/modules/samsung_daily_optimizer/config.prop" ]; then
        . "/data/adb/modules/samsung_daily_optimizer/config.prop"
    fi

    if [ "$SMART_SCREEN_AWARE" = "1" ]; then
        MAX_WAIT=60 # Defer up to 60 minutes if user is actively using the phone
        WAIT_COUNT=0
        while [ "$WAIT_COUNT" -lt "$MAX_WAIT" ]; do
            if dumpsys power 2>/dev/null | grep -q "mWakefulness=Awake"; then
                log_daemon "Screen is currently active/awake. Deferring optimization for 60s to ensure zero UI stutter ($((WAIT_COUNT + 1))/$MAX_WAIT min)..."
                sleep 60
                WAIT_COUNT=$((WAIT_COUNT + 1))
            else
                break
            fi
        done
        if [ "$WAIT_COUNT" -ge "$MAX_WAIT" ]; then
            log_daemon "Max deferral reached. Running maintenance now..."
        else
            log_daemon "Screen is asleep/idle. Triggering optimizer now..."
        fi
    else
        log_daemon "Triggering optimizer..."
    fi

    if [ -f "$SCRIPT_DIR/optimizer.sh" ]; then
        sh "$SCRIPT_DIR/optimizer.sh"
    elif [ -f "/data/adb/modules/samsung_daily_optimizer/optimizer.sh" ]; then
        sh "/data/adb/modules/samsung_daily_optimizer/optimizer.sh"
    fi

    sleep 65
done
