import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    width: 1280
    height: 720
    visible: true
    title: "DroneTakip — Yer Kontrol Istasyonu"
    color: "#0a0e17"

    property string activePanel: ""

    // ── KATMAN 0: TAM EKRAN HARİTA ──
    MapPage {
        anchors.fill: parent
        topBarHeight: topBar.height
    }

    // ── KATMAN 1: ÜST BAR ──
    Rectangle {
        id: topBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 48
        color: "#d9101520"

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
            spacing: 6

            // Logo / Başlık
            Rectangle {
                width: 28
                height: 28
                radius: 6
                color: "#e94560"

                Text {
                    anchors.centerIn: parent
                    text: "D"
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                }
            }

            Text {
                text: "DroneTakip"
                color: "#e2e8f0"
                font.pixelSize: 16
                font.bold: true
            }

            // Durum göstergesi
            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: "#22c55e"
            }
            Text {
                text: "Bagli"
                color: "#64748b"
                font.pixelSize: 11
            }

            Item {
                Layout.fillWidth: true
            }

            // Menü butonları
            Repeater {
                model: ["Telemetri", "Gorev", "Ayarlar"]

                Rectangle {
                    required property string modelData
                    required property int index

                    width: btnText.width + 24
                    height: 30
                    radius: 6
                    color: {
                        if (btnMouse.containsMouse)
                            return "#1e2a3a";
                        if (root.activePanel === modelData)
                            return "#e94560";
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

    // ── KATMAN 2: SAĞ PANEL ──
    Rectangle {
        id: sidePanel
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 320
        color: "#f0101520"
        visible: root.activePanel !== ""

        // Sol kenar çizgisi
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
                if (root.activePanel === "Telemetri")
                    return "TelemetryPage.qml";
                if (root.activePanel === "Gorev")
                    return "MissionPage.qml";
                if (root.activePanel === "Ayarlar")
                    return "SettingsPage.qml";
                return "";
            }
        }
    }
}
