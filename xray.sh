#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title xray
# @raycast.mode fullOutput
# @raycast.icon 🥳
# @raycast.argument1 {"type": "dropdown", "placeholder": "setup", "data": [{"title":"Setup","value":"Setup"}]}
# @raycast.argument2
# @raycast.argument3

XRAY_BIN=$(which xray)
if [[ -z "$XRAY_BIN" ]]; then
  echo "Xray is not installed"
  exit 127
fi
XRAY_CMD="xray run -c $1"

HOST=$(jq -r '.inbounds[] | select(.protocol=="socks") | .listen' "$1")
PORT=$(jq -r '.inbounds[] | select(.protocol=="socks") | .port' "$1")
APP_CMD="open -a $2 --args --proxy-server=$HOST:$PORT"

PROXY_STATUS=$(networksetup -getsocksfirewallproxy "$3" | grep "Enabled:" | cut -d ':' -f 2 | head -n 1 | xargs)

proxy_on() {
  networksetup -setsocksfirewallproxy "$1" "$HOST" "$PORT"
  networksetup -setsocksfirewallproxystate "$1" on
}

proxy_off() {
  networksetup -setsocksfirewallproxystate "$1" off
}

is_running() {
    pgrep -f "$1" > /dev/null 2>&1
}

stop() {
    pkill -9 -f "$1"
    echo "⏸️"
}

start() {
    nohup $1 >/dev/null 2>&1 &
    echo "▶️"
}

case $1 in
  Setup)
    if [[ -f "setup" ]]; then
      chmod +x setup && ./setup
    else
      echo "Setup file not found"
      exit 1
    fi
    ;;
  *)
    case $2 in
      System)
        case $PROXY_STATUS in
          Yes)
            if is_running "$XRAY_CMD"; then
              proxy_off "$3"
              stop "$XRAY_CMD"
            else
              start "$XRAY_CMD"
            fi
            ;;
          No) 
            if ! is_running "$XRAY_CMD"; then
              start "$XRAY_CMD"
            fi
            proxy_on "$3"
            ;;
          *)
            echo "Unexpected proxy status: $PROXY_STATUS"
            ;;
        esac
        ;;
      *)
        if is_running "$XRAY_CMD" && is_running "$2"; then
          stop "$2"
          stop "$XRAY_CMD"
        elif is_running "$2"; then
          start "$XRAY_CMD"
        elif is_running "$XRAY_CMD"; then
          start "$APP_CMD"
        else
          start "$XRAY_CMD"
          start "$APP_CMD"
        fi
        ;;
    esac
    ;;
esac