#!/system/bin/sh
# KernelSU / APatch Action Button Trigger
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Executing Samsung Daily Optimizer..."
sh "$SCRIPT_DIR/run_now.sh"
echo "Done! Check optimizer.log for details."
