import QtQuick
import QtQuick.Controls

// CameraView — Bağımsız kamera görüntüsü bileşeni.
// Hem tam ekran hem de küçük pencere (PiP) modunda kullanılabilir.
// Tıklandığında sinyal (signal) yayar, ana sayfa (Main.qml) bu sinyali dinleyerek
// kamera ↔ harita geçişini yönetir.
Item {
    id: cameraRoot

    // Dışarıdan tıklama olayını bildirmek için sinyal
    signal clicked()

    // Tam ekran mı, küçük pencere (PiP) mi olduğunu belirleyen özellik
    property bool isFullscreen: false

    Rectangle {
        id: cameraFrame
        anchors.fill: parent
        radius: isFullscreen ? 0 : 10
        color: "#f00a0e17"
        border.color: "#2a3a4e"
        border.width: isFullscreen ? 0 : 1.5
        clip: true

        // Kamera yok iken arkaplan gradyanı
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#0d1117" }
                GradientStop { position: 0.5; color: "#111820" }
                GradientStop { position: 1.0; color: "#0a0e14" }
            }
        }

        // Tarama çizgileri efekti (CRT/kamera hissi)
        Column {
            anchors.fill: parent
            opacity: 0.03
            Repeater {
                model: Math.ceil(cameraFrame.height / 4)
                Rectangle {
                    width: cameraFrame.width
                    height: 2
                    color: "white"
                }
            }
        }

        // Ortada "CAMERA FEED" placeholder
        Column {
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "📷"
                font.pixelSize: isFullscreen ? 48 : 28
                opacity: 0.4
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "CAMERA FEED"
                color: "#3a4a5e"
                font.pixelSize: isFullscreen ? 18 : 12
                font.bold: true
                font.family: "Consolas"
                font.letterSpacing: 2
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Waiting for connection..."
                color: "#2a3a4e"
                font.pixelSize: isFullscreen ? 12 : 9
                font.family: "Consolas"
            }
        }

        // Nişangah çizgileri (crosshair)
        Rectangle {
            anchors.centerIn: parent
            width: isFullscreen ? 80 : 40
            height: 1
            color: "#30ffffff"
        }
        Rectangle {
            anchors.centerIn: parent
            width: 1
            height: isFullscreen ? 80 : 40
            color: "#30ffffff"
        }

        // Köşe çerçeveleri (tactical frame)
        // Sol üst
        Rectangle { x: 8;  y: 8;  width: 16; height: 2; color: "#50ffffff" }
        Rectangle { x: 8;  y: 8;  width: 2;  height: 16; color: "#50ffffff" }
        // Sağ üst
        Rectangle { x: parent.width - 24; y: 8;  width: 16; height: 2;  color: "#50ffffff" }
        Rectangle { x: parent.width - 10; y: 8;  width: 2;  height: 16; color: "#50ffffff" }
        // Sol alt
        Rectangle { x: 8;  y: parent.height - 10; width: 16; height: 2;  color: "#50ffffff" }
        Rectangle { x: 8;  y: parent.height - 24; width: 2;  height: 16; color: "#50ffffff" }
        // Sağ alt
        Rectangle { x: parent.width - 24; y: parent.height - 10; width: 16; height: 2;  color: "#50ffffff" }
        Rectangle { x: parent.width - 10; y: parent.height - 24; width: 2;  height: 16; color: "#50ffffff" }

        // ── ÜST BAR: CAM 1 + REC ──
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: isFullscreen ? 32 : 24
            color: "#80000000"
            radius: 0

            // Üst köşeleri yuvarlatma (PiP modunda)
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 10
                radius: cameraFrame.radius
                color: parent.color
                visible: !isFullscreen
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                // Yanıp sönen kayıt noktası
                Rectangle {
                    width: 8; height: 8; radius: 4
                    color: "#ef4444"
                    anchors.verticalCenter: parent.verticalCenter

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.0; duration: 500 }
                        NumberAnimation { to: 0.2; duration: 500 }
                    }
                }

                Text {
                    text: "CAM 1"
                    color: "#c8d6e5"
                    font.pixelSize: isFullscreen ? 12 : 10
                    font.bold: true
                    font.family: "Consolas"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: "00:00:00"
                color: "#64748b"
                font.pixelSize: isFullscreen ? 11 : 9
                font.family: "Consolas"
            }
        }

        // ── ALT BAR: Codec bilgisi ──
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: isFullscreen ? 28 : 20
            color: "#60000000"

            // Alt köşeleri yuvarlatma (PiP modunda)
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 10
                radius: cameraFrame.radius
                color: parent.color
                visible: !isFullscreen
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Text {
                    text: "1920×1080"
                    color: "#4a5568"
                    font.pixelSize: isFullscreen ? 10 : 8
                    font.family: "Consolas"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "30 FPS"
                    color: "#4a5568"
                    font.pixelSize: isFullscreen ? 10 : 8
                    font.family: "Consolas"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "H.264"
                    color: "#4a5568"
                    font.pixelSize: isFullscreen ? 10 : 8
                    font.family: "Consolas"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Tıklama ile mod değiştirme
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: cameraRoot.clicked()
        }

        // PiP modunda sol üste küçük genişletme simgesi
        Rectangle {
            visible: !isFullscreen
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 8
            anchors.topMargin: 28
            width: 20; height: 20; radius: 4
            color: "#60000000"

            Text {
                anchors.centerIn: parent
                text: "⛶"
                color: "#80ffffff"
                font.pixelSize: 12
            }
        }
    }
}
