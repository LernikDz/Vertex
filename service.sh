#!/system/bin/sh
# Magisk / KernelSU / APatch late service script
# Note: Initial boot execution is DISABLED per user preference.
# This simply launches the scheduler daemon in the background to wait for 05:00 AM.

MODDIR="${0%/*}"

# Launch scheduler daemon in background
nohup sh "$MODDIR/daemon.sh" >/dev/null 2>&1 &
