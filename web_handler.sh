#!/system/bin/sh
# Micro HTTP request handler for Vertex WebUI

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBROOT="$SCRIPT_DIR/webroot"

read -r REQUEST_LINE
METHOD=$(echo "$REQUEST_LINE" | awk '{print $1}')
URI=$(echo "$REQUEST_LINE" | awk '{print $2}')

# Read remaining headers
CONTENT_LENGTH=0
while read -r header; do
    header=$(echo "$header" | tr -d '\r')
    [ -z "$header" ] && break
    case "$header" in
        [Cc][Oo][Nn][Tt][Ee][Nn][Tt]-[Ll][Ee][Nn][Gg][Tt][Hh]:*)
            CONTENT_LENGTH=$(echo "$header" | awk '{print $2}')
            ;;
    esac
done

# Read body if present
BODY=""
if [ "$CONTENT_LENGTH" -gt 0 ]; then
    BODY=$(head -c "$CONTENT_LENGTH")
fi

if [ "$METHOD" = "GET" ]; then
    case "$URI" in
        "/"|"/index.html")
            if [ -f "$WEBROOT/index.html" ]; then
                FILE_SIZE=$(wc -c < "$WEBROOT/index.html")
                printf "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: %d\r\nConnection: close\r\n\r\n" "$FILE_SIZE"
                cat "$WEBROOT/index.html"
            else
                printf "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nNot Found"
            fi
            ;;
        *)
            printf "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nNot Found"
            ;;
    esac
elif [ "$METHOD" = "POST" ]; then
    case "$URI" in
        "/api/exec")
            # Extract cmd parameter from JSON body {"cmd":"..."}
            CMD=$(echo "$BODY" | sed -n 's/.*"cmd"[ ]*:[ ]*"\([^"]*\)".*/\1/p' | sed 's/\\"/\"/g')
            if [ -n "$CMD" ]; then
                OUTPUT=$(eval "$CMD" 2>&1)
            else
                OUTPUT="No command provided"
            fi
            # Escape output for JSON
            ESCAPED_OUT=$(echo "$OUTPUT" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')
            JSON_RESP="{\"errno\":0,\"stdout\":\"$ESCAPED_OUT\"}"
            RESP_LEN=$(printf "%s" "$JSON_RESP" | wc -c)
            printf "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s" "$RESP_LEN" "$JSON_RESP"
            ;;
        *)
            printf "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nNot Found"
            ;;
    esac
else
    printf "HTTP/1.1 405 Method Not Allowed\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nMethod Not Allowed"
fi
