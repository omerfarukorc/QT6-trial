import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Window {
    id: root
    width: 1280
    height: 720
    visible: true
    title: "Flight Control Application"
    color: "#0a0e17"

    // ── GLOBAL STATE ──
    property string activePanel: ""

    // RTK Uydu Sayısı (Mock — gelecekte C++ backend'den gelecek)
    property int rtkSatelliteCount: 14

    // Hedef kilitleme paneli açık/kapalı durumu
    property bool targetLockOpen: false

    // Seçili hedef ("Drone" / "Base" / "Coordinate")
    property string lockedTarget: ""

    // ── RTK durumuna göre renk hesaplama fonksiyonu ──
    function rtkStatusColor(count) {
        if (count < 10)  return "#ef4444";  // Kırmızı — zayıf sinyal
        if (count <= 20) return "#f97316";  // Turuncu — orta sinyal
        return "#22c55e";                    // Yeşil — güçlü sinyal
    }

    // ── KATMAN 0: TAM EKRAN HARİTA ──
    MapPage {
        anchors.fill: parent
        topBarHeight: topBar.height
    }

    // ── KATMAN 1: ÜST BAR (HEADER) ──
    Rectangle {
        id: topBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 48

        // Gradient arka plan — üstten alta doğru kararan ton
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#e6131a2e" }
            GradientStop { position: 1.0; color: "#f00a0e17" }
        }

        // Alt kenar çizgisi
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: "#1e2a3a"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 8

            // ─── SOL GRUP: Logo + Ad + Durum ───

            // Logo
            Rectangle {
                width: 28; height: 28; radius: 6
                color: "#e94560"
                Text {
                    anchors.centerIn: parent
                    text: "F"
                    color: "white"
                    font.pixelSize: 15; font.bold: true
                }
            }

            Text {
                text: "Flight Control"
                color: "#e2e8f0"
                font.pixelSize: 15; font.bold: true
            }

            // Bağlantı durumu noktası
            Rectangle {
                width: 8; height: 8; radius: 4
                color: "#22c55e"
            }
            Text {
                text: "Connected"
                color: "#64748b"
                font.pixelSize: 11
            }

            // ─── AYIRICI ───
            Rectangle { width: 1; height: 24; color: "#1e2a3a"; Layout.leftMargin: 4; Layout.rightMargin: 4 }

            // ─── RTK UYDU GÖSTERGESİ ───
            Rectangle {
                id: rtkBadge
                width: rtkRow.width + 18
                height: 28
                radius: 6

                // Arka plan rengi — rtkSatelliteCount'a göre smooth geçiş
                color: Qt.rgba(
                    rtkStatusColor(root.rtkSatelliteCount).r,
                    rtkStatusColor(root.rtkSatelliteCount).g,
                    rtkStatusColor(root.rtkSatelliteCount).b,
                    0.15
                )
                border.color: rtkStatusColor(root.rtkSatelliteCount)
                border.width: 1

                // Renk geçişlerinde smooth animasyon
                Behavior on border.color {
                    ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
                }

                Row {
                    id: rtkRow
                    anchors.centerIn: parent
                    spacing: 6

                    // Uydu (nabız animasyonlu sinyal noktası)
                    Item {
                        width: 10; height: 10
                        anchors.verticalCenter: parent.verticalCenter

                        // Dış halka — nabız (pulse) efekti
                        Rectangle {
                            id: rtkPulse
                            anchors.centerIn: parent
                            width: 10; height: 10; radius: 5
                            color: "transparent"
                            border.color: rtkStatusColor(root.rtkSatelliteCount)
                            border.width: 1.5
                            opacity: 0

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.8; duration: 600 }
                                NumberAnimation { to: 0;   duration: 800 }
                                PauseAnimation  { duration: 400 }
                            }
                            SequentialAnimation on scale {
                                loops: Animation.Infinite
                                NumberAnimation { to: 2.2; duration: 1400 }
                                NumberAnimation { to: 1.0; duration: 0 }
                                PauseAnimation  { duration: 400 }
                            }
                        }

                        // İç nokta — sabit sinyal
                        Rectangle {
                            anchors.centerIn: parent
                            width: 6; height: 6; radius: 3
                            color: rtkStatusColor(root.rtkSatelliteCount)

                            Behavior on color {
                                ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
                            }
                        }
                    }

                    Text {
                        text: "RTK"
                        color: "#94a3b8"
                        font.pixelSize: 10; font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.rtkSatelliteCount.toString()
                        color: rtkStatusColor(root.rtkSatelliteCount)
                        font.pixelSize: 13; font.bold: true; font.family: "Consolas"
                        anchors.verticalCenter: parent.verticalCenter

                        Behavior on color {
                            ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
                        }
                    }
                }
            }

            // ─── AYIRICI ───
            Rectangle { width: 1; height: 24; color: "#1e2a3a"; Layout.leftMargin: 4; Layout.rightMargin: 4 }

            // ─── TARGET LOCK BUTONU + AÇILIR PANEL ───
            Item {
                width: targetLockBtn.width
                height: 30

                Rectangle {
                    id: targetLockBtn
                    width: targetLockRow.width + 20
                    height: 30
                    radius: 6
                    color: {
                        if (targetLockMouse.containsMouse) return "#1e2a3a";
                        if (root.targetLockOpen) return "#1a2744";
                        return "transparent";
                    }
                    border.color: root.targetLockOpen ? "#3b82f6" : "#1e2a3a"
                    border.width: 1

                    Behavior on border.color {
                        ColorAnimation { duration: 250 }
                    }

                    Row {
                        id: targetLockRow
                        anchors.centerIn: parent
                        spacing: 6

                        // Kilit ikonu (Unicode)
                        Text {
                            text: root.lockedTarget !== "" ? "🔒" : "🎯"
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.lockedTarget !== "" ? root.lockedTarget : "Target"
                            color: root.lockedTarget !== "" ? "#3b82f6" : "#94a3b8"
                            font.pixelSize: 11; font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Ok (chevron) — dönme animasyonlu
                        Text {
                            id: chevron
                            text: "▸"
                            color: "#64748b"
                            font.pixelSize: 10
                            rotation: root.targetLockOpen ? 90 : 0
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on rotation {
                                RotationAnimation {
                                    direction: RotationAnimation.Shortest
                                    duration: 250
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: targetLockMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.targetLockOpen = !root.targetLockOpen
                    }
                }
            }

            // ─── SPACER ───
            Item { Layout.fillWidth: true }

            // ─── MENÜ BUTONLARI ───
            Repeater {
                model: ["Telemetri", "Gorev", "Ayarlar"]

                Rectangle {
                    required property string modelData
                    required property int index
                    width: btnText.width + 24
                    height: 30; radius: 6

                    color: {
                        if (btnMouse.containsMouse) return "#1e2a3a";
                        if (root.activePanel === modelData) return "#e94560";
                        return "transparent";
                    }
                    border.width: root.activePanel === modelData ? 0 : 1
                    border.color: root.activePanel === modelData ? "transparent" : "#1e2a3a"

                    Text {
                        id: btnText
                        anchors.centerIn: parent
                        text: parent.modelData
                        color: root.activePanel === parent.modelData ? "white" : "#94a3b8"
                        font.pixelSize: 12
                        font.bold: root.activePanel === parent.modelData
                    }

                    MouseArea {
                        id: btnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.activePanel === parent.modelData)
                                root.activePanel = "";
                            else
                                root.activePanel = parent.modelData;
                        }
                    }
                }
            }
        }
    }

    // ── TARGET LOCK AÇILIR PANELİ ──
    Rectangle {
        id: targetLockPanel
        anchors.left: parent.left
        anchors.leftMargin: 340
        anchors.top: topBar.bottom
        anchors.topMargin: 4
        width: 220
        radius: 10
        color: "#f0101520"
        border.color: "#1e2a3a"
        border.width: 1
        clip: true

        // Yükseklik animasyonu ile açılıp kapanma
        height: root.targetLockOpen ? targetLockContent.height + 16 : 0
        opacity: root.targetLockOpen ? 1.0 : 0.0
        visible: height > 0

        Behavior on height {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        Column {
            id: targetLockContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            spacing: 4

            // Başlık
            Text {
                text: "TARGET LOCK"
                color: "#64748b"
                font.pixelSize: 10; font.bold: true; font.family: "Consolas"
                bottomPadding: 4
            }

            // Seçenekler
            Repeater {
                model: [
                    { name: "Drone",        icon: "✈" },
                    { name: "Base Station",  icon: "📡" },
                    { name: "Coordinate",    icon: "📍" }
                ]

                Rectangle {
                    required property var modelData
                    required property int index
                    width: parent ? parent.width : 0
                    height: 36; radius: 6

                    color: {
                        if (targetItemMouse.containsMouse) return "#1e2a3a";
                        if (root.lockedTarget === modelData.name) return "#1a3a5c";
                        return "transparent";
                    }
                    border.color: root.lockedTarget === modelData.name ? "#3b82f6" : "transparent"
                    border.width: root.lockedTarget === modelData.name ? 1 : 0

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left; anchors.leftMargin: 10
                        spacing: 8

                        Text {
                            text: parent.parent.modelData.icon
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: parent.parent.modelData.name
                            color: root.lockedTarget === parent.parent.modelData.name ? "#60a5fa" : "#c8d6e5"
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Sağda tik işareti (seçiliyse)
                    Text {
                        anchors.right: parent.right; anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: "✓"
                        color: "#3b82f6"
                        font.pixelSize: 14; font.bold: true
                        visible: root.lockedTarget === parent.modelData.name
                    }

                    MouseArea {
                        id: targetItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.lockedTarget === parent.modelData.name)
                                root.lockedTarget = "";   // Zaten seçiliyse kilidi kaldır
                            else
                                root.lockedTarget = parent.modelData.name;
                        }
                    }
                }
            }
        }
    }

    // ── KATMAN 2: SAĞ PANEL ──
    Rectangle {
        id: sidePanel
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 320
        color: "#f0101520"
        visible: root.activePanel !== ""

        // Sol kenar
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: "#1e2a3a"
        }

        Loader {
            id: panelLoader
            anchors.fill: parent
            anchors.margins: 16
            anchors.leftMargin: 20

            source: {
                if (root.activePanel === "Telemetri") return "TelemetryPage.qml";
                if (root.activePanel === "Gorev")     return "MissionPage.qml";
                if (root.activePanel === "Ayarlar")   return "SettingsPage.qml";
                return "";
            }
        }
    }
}
