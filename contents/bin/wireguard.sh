#!/bin/bash

export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export QT_SCALE_FACTOR=1.25

active_wg=($(nmcli -t -f NAME,TYPE connection show --active | grep ':wireguard$' | cut -d: -f1))

if [[ ${#active_wg[@]} -gt 0 ]]; then
  for profile in "${active_wg[@]}"; do
    nmcli connection down "$profile"
  done
  sleep 3 && kdialog --passivepopup "All active WireGuard profiles deactivated" 5
  exit 0
fi

wg_profiles=($(nmcli -t -f NAME,TYPE connection show | grep ':wireguard$' | cut -d: -f1))
if [[ ${#wg_profiles[@]} -eq 1 ]]; then
  VPN_ID="${wg_profiles[0]}"
elif [[ ${#wg_profiles[@]} -gt 1 ]]; then
  menu=()
  for profile in "${wg_profiles[@]}"; do
    menu+=("$profile" "$profile")
  done
  VPN_ID=$(kdialog --menu "Select WireGuard profile to activate:" "${menu[@]}")
  [[ -z "$VPN_ID" ]] && exit 0
fi

if [[ -n "$VPN_ID" ]]; then
  nmcli connection up "$VPN_ID"
  exit 0
fi


FILE=$(kdialog --getopenfilename "$HOME" "*.conf" --title "Choose WireGuard profile to import")

if [[ -n "$FILE" && -f "$FILE" ]]; then
    new_name="/tmp/$(basename "$FILE" | tr ' -' '__')"
    cp "$FILE" "$new_name"
    if result=$(nmcli connection import type wireguard file "$new_name" 2>&1); then
        sleep 3 && kdialog --passivepopup "WireGuard profile '$(basename "$FILE")' imported" 5
    else
        kdialog --error "Failed to import profile:\n$result\n\nAvoid using dashes and spaces in the profile name!"
    fi
else
  if kdialog --yesno "No WireGuard profiles found.
You can add one manually or place a config file on your system.
Click the toggle again to select a config." --yes-label "Open network settings" --no-label "Exit" --title "Profiles not found"; then
    kcmshell6 networkmanagement
  fi
fi
