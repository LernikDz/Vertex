#!/system/bin/sh
# KernelSU / APatch Action Button Trigger
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Executing Vertex Optimization..."
sh "$SCRIPT_DIR/run_now.sh"
echo "Done! Check optimizer.log for details."
