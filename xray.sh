#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title xray
# @raycast.mode silent
# @raycast.icon 🥳
# @raycast.argument1 {"type": "dropdown", "placeholder": "setup", "data": [{"title": "setup", "value": "setup"}]}
# @raycast.argument2
# @raycast.argument3

XRAY_BIN=$(which xray)
if [[ -z "$XRAY_BIN" ]]; then
exit 127
fi
XRAY_CMD="$XRAY_BIN run -c $1"


HOST="$(cat $1 | grep -C 3 '"protocol": "socks"' | grep '"listen"' | awk '{print $2}' | tr -d ',"' | head -n 1)"
PORT="$(cat $1 | grep -C 3 '"protocol": "socks"' | grep '"port"' | awk '{print $2}' | tr -d ',' | head -n 1)"
APP_CMD="open -a $2 --proxy-server=$HOST:$PORT"


is_running() {
    pgrep -f "$1" > /dev/null 2>&1
}

stop() {
    pkill -f "$1"
    echo "⏸️"
}

start() {
    $1 &
    echo "▶️"
}


case $1 in
    setup)
        chmod +x ./setup && ./setup
        ;;
    *)
    case $2 in
    system)
        PROXY_STATUS=$(networksetup -getsocksfirewallproxy $3 | grep "Enabled:" | awk '{print $2}' | head -n 1)
        if [ "$PROXY_STATUS" == "Yes" ]; then
        stop "$XRAY_CMD" && networksetup -setsocksfirewallproxystate $3 off
        else
        start "$XRAY_CMD" && networksetup -setsocksfirewallproxy $3 $HOST $PORT && networksetup -setsocksfirewallproxystate $3 on
        fi
        ;;
    *)
        if is_running "$XRAY_CMD" && is_running "$APP_CMD"; then
        stop "$XRAY_CMD"
        stop "$APP_CMD"
        else
        start "$XRAY_CMD"
        sleep 2
        start "$APP_CMD"
        fi
        ;;
    esac
    ;;
esac