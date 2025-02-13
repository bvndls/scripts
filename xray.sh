#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title xray
# @raycast.mode fullOutput
# @raycast.icon 🥳
# @raycast.argument1 {"type": "dropdown", "placeholder": "setup", "data": [{"title": "Setup", "value": "Setup"}]}
# @raycast.argument2
# @raycast.argument3

XRAY_BIN=$(which xray)
if [[ -z "$XRAY_BIN" ]]; then
  echo "Xray is not installed"
  exit 127
fi
XRAY_CMD="xray run -c $1"

HOST=$(jq -r '.inbounds[] | select(.protocol=="socks") | .listen' "$1" 2>/dev/null)
PORT=$(jq -r '.inbounds[] | select(.protocol=="socks") | .port' "$1" 2>/dev/null)
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
  update_dropdown() {
    local pattern="$1"
    local placeholder="$2"
    local data="$3"
    local comment="$4"
    local arg="# @raycast.$comment {\"type\": \"dropdown\", \"placeholder\": \"$placeholder\", \"data\": [{\"title\": \"$pattern\", \"value\": \"$pattern\"},$data]}"

    if grep -q "^# @raycast.$comment" "$0"; then
      sed -i '' "/^# @raycast.$comment/c\\
$arg
    " "$0"
    else
      echo -e "\n$arg" >> "$0"
    fi
  }

    echo "Updating configs dropdown"
    configs=$(find ~ /opt -path ~/Library -prune -o -name "*.json" -exec grep -l '"inbounds"' {} + 2>/dev/null | while read -r config; do
      if jq empty "$config" 2>/dev/null; then
        address=$(jq -r '.outbounds[].settings.vnext[0].address // .inbounds[].settings.clients[].address' "$config" 2>/dev/null)
        [[ -z "$address" ]] && continue
        filename=$(basename "$config")
        printf '{"title": "%s (%s)", "value": "%s"}\n' "$address" "$filename" "$config"
      fi
    done | paste -sd, -)
    update_dropdown "Setup" "config" "$configs" "argument1"

    echo "Updating apps dropdown"
    apps=$(find /Applications -type d -name "*.app" ! -path "*/Contents/*" | while read -r app; do 
      app_name=$(basename "$app" .app)
      printf '{"title": "%s", "value": "%s"}\n' "$app_name" "$app_name"
    done | paste -sd, -)
    update_dropdown "System" "app" "$apps" "argument2"

    echo "Updating ifaces dropdown"
    ifaces=$(networksetup -listallnetworkservices | sed '1d' | while read -r iface; do
      printf '{"title": "%s", "value": "%s"}\n' "$iface" "$iface"
    done | paste -sd, -)
    update_dropdown "Interface" "interface" "$ifaces" "argument3"

    echo "Setting script to silent mode"
    sed -i '' 's/^# @raycast.mode fullOutput/# @raycast.mode silent/' "$0"

    echo -e "\nScript updated."
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
          stop "$2"
          start "$XRAY_CMD"
          start "$APP_CMD"
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