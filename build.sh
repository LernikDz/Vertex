#!/bin/sh
# Build flashable module ZIP archives for Vertex
DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="${1:-$DIR/Vertex.zip}"

echo "Building $OUTPUT..."
rm -f "$OUTPUT"
cd "$DIR" && zip -r "$OUTPUT" . -x ".*" -x "*.zip" -x "*.log" -x "*.tmp" -x "daemon.pid" -x "build.sh"
echo "Build complete: $OUTPUT"

# Also maintain SamsungDailyOptimizer.zip alias for compatibility
if [ "$OUTPUT" = "$DIR/Vertex.zip" ]; then
    cp -f "$DIR/Vertex.zip" "$DIR/SamsungDailyOptimizer.zip"
    echo "Created compatibility alias: $DIR/SamsungDailyOptimizer.zip"
fi
