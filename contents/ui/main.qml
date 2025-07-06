// SPDX-FileCopyrightText: 2025 @ComradeFreeman
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.mobileshell as MobileShell

QS.QuickSetting {
    PlasmaNM.NetworkStatus {
        id: networkStatus
    }

    text: i18n("Wireguard VPN")
    status: networkStatus.activeConnections.indexOf("\nWireGuard: ") != -1 ? networkStatus.activeConnections.replace(/^(.|\n)*WireGuard: /, "") : ""
    icon: "network-vpn"
    settingsCommand: "kcmshell6 networkmanagement"
    function toggle() {
        MobileShell.ShellUtil.executeCommand(Qt.resolvedUrl("../bin/wireguard.sh").toString().replace(/^file:\/\//,""));
    }
    enabled: networkStatus.activeConnections.indexOf("\nWireGuard: ") != -1
}
