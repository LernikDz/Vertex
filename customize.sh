SKIPUNZIP=0

ui_print "- Installing Vertex..."
ui_print "- Scheduled time: 05:00 AM daily"
ui_print "- Note: Immediate boot-run disabled (Temproot safe)"

# Volume Key Selector function
chooseport() {
  local count=0
  while true; do
    local key
    key=$(timeout 1 getevent -lqc 1 2>/dev/null)
    case "$key" in
      *KEY_VOLUMEUP*|*0073*) return 0 ;;
      *KEY_VOLUMEDOWN*|*0072*) return 1 ;;
    esac
    count=$((count + 1))
    if [ "$count" -ge 12 ]; then
      return 2
    fi
  done
}

ui_print " "
ui_print "=========================================="
ui_print "       RAM PLUS CONFIGURATION"
ui_print "=========================================="
ui_print "  Select RAM Plus setting using Volume keys:"
ui_print "  [Vol+] = DISABLE RAM Plus (0 GB - Less lag)"
ui_print "  [Vol-] = ENABLE RAM Plus (2 GB)"
ui_print " "
ui_print "  Waiting for volume key press (12s timeout)..."

chooseport
CHOICE=$?

if [ "$CHOICE" -eq 0 ]; then
  ui_print "  -> Selected: DISABLE RAM Plus (0 GB)"
  RAM_PLUS_ENABLED=0
  RAM_PLUS_SIZE=0
elif [ "$CHOICE" -eq 1 ]; then
  ui_print "  -> Selected: ENABLE RAM Plus (2 GB)"
  RAM_PLUS_ENABLED=1
  RAM_PLUS_SIZE=2048
else
  ui_print "  -> No key detected or timeout reached."
  if [ -f "/data/adb/modules/samsung_daily_optimizer/config.prop" ]; then
    ui_print "  -> Preserving existing config.prop"
    cp -f "/data/adb/modules/samsung_daily_optimizer/config.prop" "$MODPATH/config.prop" 2>/dev/null
    RAM_PLUS_SIZE=""
  else
    ui_print "  -> Defaulting to: ENABLE RAM Plus (2 GB)"
    RAM_PLUS_ENABLED=1
    RAM_PLUS_SIZE=2048
  fi
fi

if [ -n "$RAM_PLUS_SIZE" ]; then
  cat << EOF > "$MODPATH/config.prop"
# Vertex Configuration (samsung_daily_optimizer)
RAM_PLUS_ENABLED=$RAM_PLUS_ENABLED
RAM_PLUS_SIZE=$RAM_PLUS_SIZE
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
EOF
fi

ui_print " "
ui_print "- Finalizing permissions..."

# Set executable permissions on all shell scripts
set_perm_recursive "$MODPATH" 0 0 0755 0755
set_perm "$MODPATH/module.prop" 0 0 0644
set_perm "$MODPATH/config.prop" 0 0 0644
set_perm "$MODPATH/webroot/index.html" 0 0 0644
set_perm "$MODPATH/optimizer.sh" 0 0 0755
set_perm "$MODPATH/daemon.sh" 0 0 0755
set_perm "$MODPATH/run_now.sh" 0 0 0755
set_perm "$MODPATH/start_daemon.sh" 0 0 0755
set_perm "$MODPATH/stop_daemon.sh" 0 0 0755
set_perm "$MODPATH/start_webui.sh" 0 0 0755
set_perm "$MODPATH/stop_webui.sh" 0 0 0755
set_perm "$MODPATH/web_handler.sh" 0 0 0755
set_perm "$MODPATH/configure.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755

ui_print "- Installation complete!"
