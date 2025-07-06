#!/bin/bash

VPN_ID=`nmcli -t c show | grep '^[^:]*:[^:]*:wireguard:[^:]*$' | head -n 1 | cut -d : -f 1`
if nmcli -t c show "$VPN_ID" | grep -q '^GENERAL.STATE:activated$' ; then
  nmcli c down "$VPN_ID"
  kdialog --passivepopup "Wireguard profile '$FILE' successfully deactivated" 5
else
  if [ ! -z "$VPN_ID" ] ; then
    nmcli c up "$VPN_ID"
    kdialog --passivepopup "Wireguard profile '$FILE' successfully activated" 5
  else
    mkdir -p /etc/wireguard
    for f in /etc/wireguard/*-*; do [ -e "$f" ] && mv -- "$f" "${f//-/}"; done
    FILE=`ls /etc/wireguard | ls -tp | grep -v '/$' | head -n 1`
    if [ ! -z "$FILE" ] ; then
      nmcli connection import type wireguard file /etc/wireguard/$FILE
      kdialog --passivepopup "Wireguard profile '$FILE' imported" 5
    else
      if [ -z "$1" ] && kdialog --yesno "No configured Wireguard profiles found. You can add the profile manually or put the config in the /etc/wireguard/. Click 'Yes' to open network settings and 'No' to exit" --title "Profiles not found"; then
        kcmshell6 networkmanagement && exec "$0" stop
      fi
    fi
  fi
fi


# nmcli connection add type wireguard ifname wg0 con-name wg-mobile
# 0. Если VPN активирован - отключаем + уведомление
#    Иначе:
#
# 1. Смотрим существующие профили nmcli в поисках wireguard
# 2. Если нашли - активируем + уведомление
# 3. Иначе:
#      Смотрим папку, если есть конфиг (если много - последний изменённый) -> nmcli connection import type wireguard file wg0.conf
#      Иначе:
#          Выводим вспывающее окно: "Настроенные профили wireguard не найдены.
#          Вы можете добавить профиль вручную или положить конфиг по пути /etc/wireguard/"
#           <OK> - завершить скрипт
#           <Открыть настройки сети> - kcmshell6 (5?) networkmanagement. Ловим событие завершения настроек, переходим к п.1
#
#
#

