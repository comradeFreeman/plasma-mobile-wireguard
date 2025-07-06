#!/bin/bash

VPN_ID=`nmcli -t c show | grep '^[^:]*:[^:]*:wireguard:[^:]*$' | head -n 1 | cut -d : -f 1`
if nmcli -t c show "$VPN_ID" | grep -q '^GENERAL.STATE:activated$' ; then
  nmcli c down "$VPN_ID"
  # Notification
else
  if [ ! -z "$VPN_ID" ] ; then
    nmcli c up "$VPN_ID"
    # Notification
  else
    mkdir -p /etc/wireguard
    for f in /etc/wireguard/*-*; do [ -e "$f" ] && mv -- "$f" "${f//-/}"; done
    FILE=`ls /etc/wireguard | ls -tp | grep -v '/$' | head -n 1`
    if [ ! -z "$FILE" ] ; then
      nmcli connection import type wireguard file /etc/wireguard/$FILE
      kdialog --passivepopup "Импортирован профиль Wireguard $FILE" 5
    else
      if [ -z "$1" ] && kdialog --yesno "Настроенные профили wireguard не найдены. Вы можете добавить профиль вручную или положить конфиг по пути /etc/wireguard/. Нажмите 'ОК', чтобы открыть настройки сети и 'Отмена', чтобы выйти" --title "Конфиг не найден"; then
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

