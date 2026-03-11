import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    width: 1280
    height: 720
    visible: true
    title: "Flight Control Application"
    color: "#0a0e17"

    // ── GLOBAL STATE ──
    property string activePanel: ""
    property int rtkSatelliteCount: 14

    // Kamera tam ekranda mı? false = harita büyük, kamera küçük (varsayılan)
    property bool cameraFullscreen: false

    // RTK renk hesaplama
    function rtkStatusColor(count) {
        if (count < 10)  return "#ef4444";
        if (count <= 20) return "#f97316";
        return "#22c55e";
    }

    // ══════════════════════════════════════════════════════════
    //  KATMAN 0: TAM EKRAN İÇERİK (Harita veya Kamera)
    // ══════════════════════════════════════════════════════════

    // Harita — Tam ekran (varsayılan) veya PiP
    MapPage {
        id: mapPage
        z: cameraFullscreen ? 2 : 0
        topBarHeight: topBar.height
        isPiP: cameraFullscreen

        // State değiştiğinde pozisyon/boyut animasyonlu geçiş
        anchors.fill: cameraFullscreen ? undefined : parent

        // PiP modu (küçük pencere) - kamera tam ekrandayken
        x: cameraFullscreen ? 10 : 0
        y: cameraFullscreen ? (parent.height - 200) : 0
        width:  cameraFullscreen ? 300 : parent.width
        height: cameraFullscreen ? 190 : parent.height

        Behavior on x      { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on y      { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on width  { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }

        // PiP modunda tıklayınca swap yap
        MouseArea {
            anchors.fill: parent
            enabled: cameraFullscreen
            cursorShape: cameraFullscreen ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.cameraFullscreen = false
            z: cameraFullscreen ? 100 : -1
        }

        // PiP modunda köşe çerçevesi
        Rectangle {
            visible: cameraFullscreen
            anchors.fill: parent
            color: "transparent"
            radius: 10
            border.color: "#40ffffff"
            border.width: 1.5
            z: 99
        }
    }

    // Kamera — PiP (varsayılan) veya Tam ekran
    CameraView {
        id: cameraView
        z: cameraFullscreen ? 0 : 2
        isFullscreen: cameraFullscreen

        // Tam ekran modunda
        anchors.fill: !cameraFullscreen ? undefined : parent

        // PiP modu — sol alt köşe (harita tam ekrandayken)
        x: !cameraFullscreen ? 10 : 0
        y: !cameraFullscreen ? (parent.height - 200) : 0
        width:  !cameraFullscreen ? 300 : parent.width
        height: !cameraFullscreen ? 190 : parent.height

        Behavior on x      { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on y      { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on width  { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }

        // Sadece PiP modundayken (kamera küçükken) tıkla → kamerayı büyüt
        onClicked: {
            if (!root.cameraFullscreen)
                root.cameraFullscreen = true;
        }
    }

    // ══════════════════════════════════════════════════════════
    //  KATMAN 1: ÜST BAR (HEADER)
    // ══════════════════════════════════════════════════════════
    Rectangle {
        id: topBar
        z: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 54

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#e6131a2e" }
            GradientStop { position: 1.0; color: "#f00a0e17" }
        }

        // Alt çizgi
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

            // Logo
            Rectangle {
                width: 32; height: 32; radius: 7
                color: "#e94560"
                Text {
                    anchors.centerIn: parent
                    text: "F"
                    color: "white"
                    font.pixelSize: 17; font.bold: true
                }
            }

            Text {
                text: "Flight Control"
                color: "#e2e8f0"
                font.pixelSize: 17; font.bold: true
            }

            // Bağlantı durumu
            Rectangle {
                width: 9; height: 9; radius: 5
                color: "#22c55e"
            }
            Text {
                text: "Connected"
                color: "#64748b"
                font.pixelSize: 12
            }

            // Ayırıcı
            Rectangle { width: 1; height: 28; color: "#1e2a3a"; Layout.leftMargin: 6; Layout.rightMargin: 6 }

            // RTK Göstergesi
            Rectangle {
                width: rtkRow.width + 20
                height: 32; radius: 7
                color: Qt.rgba(
                    rtkStatusColor(root.rtkSatelliteCount).r,
                    rtkStatusColor(root.rtkSatelliteCount).g,
                    rtkStatusColor(root.rtkSatelliteCount).b,
                    0.15
                )
                border.color: rtkStatusColor(root.rtkSatelliteCount)
                border.width: 1

                Behavior on border.color {
                    ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
                }

                Row {
                    id: rtkRow
                    anchors.centerIn: parent
                    spacing: 6

                    Item {
                        width: 10; height: 10
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
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

            // Spacer
            Item { Layout.fillWidth: true }

            // Menü butonları
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

    // ══════════════════════════════════════════════════════════
    //  KATMAN 2: SAĞ PANEL
    // ══════════════════════════════════════════════════════════
    Rectangle {
        id: sidePanel
        z: 10
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 320
        color: "#f0101520"
        visible: root.activePanel !== ""

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
