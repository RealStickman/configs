#!/usr/bin/env bash

set -euo pipefail

# You can call this script like this:
# $./dunst-volume.sh up
# $./dunst-volume.sh down
# $./dunst-volume.sh mute

get_volume() {
    amixer -D pulse get Master | grep '%' | head -n 1 | cut -d '[' -f 2 | cut -d '%' -f 1
}

is_mute() {
    amixer -D pulse get Master | grep '%' | grep -oE '[^ ]+$' | grep off >/dev/null
}

send_notification() {
    volume=$(get_volume)
    # Make the bar with the special character ─ (it's not dash -)
    # https://en.wikipedia.org/wiki/Box-drawing_character
    bar=$(seq -s "─" $(($volume / 5)) | sed 's/[0-9]//g')
    # Send the notification
    dunstify -i audio-volume-high -r 2593 -a volume-script "$volume    $bar    "
}

case $1 in
    up)
        # Set the volume on (if it was muted)
        amixer -D pulse set Master on >/dev/null
        # Up the volume (+ 5%)
        amixer -D pulse sset Master 5%+ >/dev/null
        send_notification
        ;;
    down)
        amixer -D pulse set Master on >/dev/null
        amixer -D pulse sset Master 5%- >/dev/null
        send_notification
        ;;
    mute)
        # Toggle mute
        amixer -D pulse set Master 1+ toggle >/dev/null
        if is_mute; then
            dunstify -i audio-volume-muted -r 2593 -u normal "Mute"
        else
            send_notification
        fi
        ;;
esac
