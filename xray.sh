#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title xray
# @raycast.mode silent
# @raycast.icon 🥳
# @raycast.argument1 {"type": "dropdown", "placeholder": "setup", "data": [{"title": "Setup", "value": "Setup"}]}
# @raycast.argument2 

XRAY_BIN=$(which xray)
if [[ -z "$XRAY_BIN" ]]; then
    echo "Xray is not installed"
    exit 127
fi

build_dropdown() {
    local number="$1"
    local name="$2"
    local data="$3"

    if [[ "$name" == "config" ]]; then
        json=$(while IFS= read -r file; do
            [[ -f "$file" ]] || continue
            address=$(jq -r '.outbounds[0].settings.address // .inbounds[0].settings.clients[0].address // "Unknown"' "$file" 2>/dev/null)
            filename=$(basename "$file")
            echo "{\"title\": \"$address ($filename)\", \"value\": \"$file\"}"
        done <<< "$data" | jq -s -c '{"type": "dropdown", "placeholder": "config", "data": .}')
    else
        json=$(echo "$data" | jq -R . | jq -s -c '{"type": "dropdown","placeholder": "'"$name"'","data": map({"title": ., "value": .})}')
    fi

    sed -i '' "s|^# @raycast.argument$number.*|# @raycast.argument$number $json|" "$0"
}

update_dropdowns() {
    local xray_configs=$(find ~ /opt -maxdepth 6 -name "*.json" ! -path "*/Library/*" -exec grep -l '"inbounds"' {} + 2>/dev/null)
    local interface_list=$(networksetup -listallnetworkservices | tail -n +2)
    
    build_dropdown 1 "config" "$xray_configs"
    build_dropdown 2 "interface" "$interface_list"
}

toggle_proxy() {
    local config=$1
    local host=$(jq -r '.inbounds[0].listen' "$config")
    local port=$(jq -r '.inbounds[0].port' "$config")
    local interface=$2
    local proxy_status=$(networksetup -getsocksfirewallproxy "$interface" | awk '/^Enabled/ {print $2}')

    if [[ $proxy_status == *"No"* ]]; then
        (nohup xray run -c "$config" >/dev/null 2>&1 &)
        networksetup -setsocksfirewallproxy "$interface" "$host" "$port"
        networksetup -setsocksfirewallproxystate "$interface" on
        echo "▶️"
    else
        networksetup -setsocksfirewallproxystate "$interface" off
        pkill -f "xray run -c"
        echo "⏸️"
    fi
}

if [[ $1 == "Setup" ]]; then
    update_dropdowns
    echo "✅"
else
    toggle_proxy $1 $2
    update_dropdowns
fi