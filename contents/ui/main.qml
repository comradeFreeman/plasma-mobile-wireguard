// SPDX-FileCopyrightText: 2025 @ComradeFreeman
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

MobileShell.QuickSetting {
    PlasmaNM.NetworkStatus {
        id: networkStatus
    }

    text: i18n("Wireguard VPN")
    status: networkStatus.activeConnections.indexOf("\nVPN: ") != -1 ? networkStatus.activeConnections.replace(/^(.|\n)*VPN: /, "") : ""
    icon: "network-vpn"
    settingsCommand: "kcmshell networkmanagement"
    function toggle() {
        MobileShell.ShellUtil.executeCommand(Qt.resolvedUrl("../bin/wireguard.sh").replace(/^file:\/\//,""));
    }
    enabled: networkStatus.activeConnections.indexOf("\nVPN: ") != -1
}
