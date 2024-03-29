#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Please supply one file"
    $(exit 1); echo "$?"
elif [ $# -ge 2 ]; then
    echo "Please only give one argument"
    $(exit 1); echo "$?"
fi

cd "$HOME"

file="$1"
parent="$(dirname "$file")"
extract="${parent}/vpnconfigs"
patched="${file%.*}-patched.zip"

cd "$parent"

mkdir -p "${parent}/vpnconfigs"

unzip "$file" -d "$extract"

readarray -d '' conffiles < <(find "$extract" -name "*\.conf" -print0)

for file in "${conffiles[@]}"; do
    if grep "PostUp" "$file" &>/dev/null; then
        echo "Skipping $file"
    else
        echo "Patching $file"
        # hetzner net
        awk 'NR==5{print "PostUp = ip route add 172.18.50.0/24 dev vladilena-road"}NR==5{print "PreDown = ip route del 172.18.50.0/24"}1' "$file" > "${file}.tmp"
        mv "${file}.tmp" "$file"
        # lan1dmz net
        awk 'NR==5{print "PostUp = ip route add 172.16.11.0/24 dev vladilena-road"}NR==5{print "PreDown = ip route del 172.16.11.0/24"}1' "$file" > "${file}.tmp"
        mv "${file}.tmp" "$file"
        # lan1dmz net
        awk 'NR==5{print "PostUp = ip route add 172.16.11.0/24 via 172.16.7.1 metric 10"}NR==5{print "PreDown = ip route del 172.16.11.0/24"}1' "$file" > "${file}.tmp"
        mv "${file}.tmp" "$file"
        # NOTE only one PreDown line is required as we are using a specific table for this
        # TODO tables do not work as intended
        #awk 'NR==5{print "PostUp = ip route add 192.168.1.0/24 via 192.168.86.1 metric 10 table 7"}NR==5{print "PreDown = ip route flush table 7"}1' "$file" > "${file}.tmp"
        # NOTE adds a dns to all configs
        #awk 'NR==4{print "DNS = 172.16.16.5"}1' "$file" > "${file}.tmp"
        #mv "${file}.tmp" "$file"
        # NOTE adds a dns to all configs
        #awk 'NR==5{print "DNS = 172.16.52.5"}1' "$file" > "${file}.tmp"
        #mv "${file}.tmp" "$file"
        # NOTE adds a dns to all configs
        #awk 'NR==6{print "DNS = 172.16.16.1"}1' "$file" > "${file}.tmp"
        #mv "${file}.tmp" "$file"
        # wifi
        #awk 'NR==6{print "PostUp = ip route add 192.168.1.0/24 via 172.16.52.1 metric 20 table 7"}1' "$file" > "${file}.tmp"
        #mv "${file}.tmp" "$file"
    fi
done

zip -r -9 "$patched" "vpnconfigs"

rm -rf "$extract"
