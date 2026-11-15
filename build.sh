#!/bin/sh
# Build flashable module ZIP archive
DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="${1:-$DIR/SamsungDailyOptimizer.zip}"

echo "Building $OUTPUT..."
rm -f "$OUTPUT"
cd "$DIR" && zip -r "$OUTPUT" . -x ".*" -x "*.zip" -x "*.log" -x "*.tmp" -x "daemon.pid" -x "build.sh"
echo "Build complete: $OUTPUT"
