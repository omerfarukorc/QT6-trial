import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// SettingsPage — Ayarlar paneli.
// RTK uydu sayısı gibi parametreleri test için değiştirmeye olanak verir.
Column {
    spacing: 16

    // Başlık
    Text {
        text: "Ayarlar"
        color: "#e2e8f0"
        font.pixelSize: 18
        font.bold: true
    }

    Rectangle {
        width: parent ? parent.width : 0
        height: 1
        color: "#1e2a3a"
    }

    // ── RTK UYDU SAYISI AYARI ──
    Rectangle {
        width: parent ? parent.width : 0
        height: rtkSettCol.height + 20
        radius: 10
        color: "#0d1520"
        border.color: "#1e2a3a"
        border.width: 1

        Column {
            id: rtkSettCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 14
            spacing: 10

            RowLayout {
                width: parent.width
                spacing: 8

                Text {
                    text: "📡  RTK Uydu Sayısı"
                    color: "#94a3b8"
                    font.pixelSize: 13
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                // Mevcut değer göstergesi
                Rectangle {
                    width: rtkValText.width + 16
                    height: 24; radius: 6
                    color: {
                        var count = root.rtkSatelliteCount;
                        if (count < 10)  return "#30ef4444";
                        if (count <= 20) return "#30f97316";
                        return "#3022c55e";
                    }

                    Text {
                        id: rtkValText
                        anchors.centerIn: parent
                        text: root.rtkSatelliteCount.toString()
                        color: {
                            var count = root.rtkSatelliteCount;
                            if (count < 10)  return "#ef4444";
                            if (count <= 20) return "#f97316";
                            return "#22c55e";
                        }
                        font.pixelSize: 13
                        font.bold: true
                        font.family: "Consolas"
                    }
                }
            }

            // Slider
            Slider {
                id: rtkSlider
                width: parent.width
                from: 0
                to: 40
                stepSize: 1
                
                // Başlangıç değerini al
                Component.onCompleted: {
                    rtkSlider.value = root.rtkSatelliteCount;
                }

                // Sadece kullanıcı kaydırdığında değeri güncelle (binding loop'u önler)
                onMoved: {
                    root.rtkSatelliteCount = Math.round(rtkSlider.value);
                }

                background: Rectangle {
                    x: rtkSlider.leftPadding
                    y: rtkSlider.topPadding + rtkSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 24 // Slider'ın tıklanabilir yüksekliğini belirler
                    width: rtkSlider.availableWidth
                    height: 4
                    radius: 2
                    color: "#1e2a3a"

                    Rectangle {
                        width: rtkSlider.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: {
                            var count = root.rtkSatelliteCount;
                            if (count < 10)  return "#ef4444";
                            if (count <= 20) return "#f97316";
                            return "#22c55e";
                        }
                    }
                }

                handle: Rectangle {
                    x: rtkSlider.leftPadding + rtkSlider.visualPosition * (rtkSlider.availableWidth - width)
                    y: rtkSlider.topPadding + rtkSlider.availableHeight / 2 - height / 2
                    implicitWidth: 18
                    implicitHeight: 18
                    width: 18
                    height: 18
                    radius: 9
                    color: rtkSlider.pressed ? "#ffffff" : "#c8d6e5"
                    border.color: "#475569"
                    border.width: 1
                }
            }

            // Min/Max etiketleri
            RowLayout {
                width: parent.width
                Text { text: "0";  color: "#475569"; font.pixelSize: 10; font.family: "Consolas" }
                Item { Layout.fillWidth: true }
                Text { text: "10"; color: "#ef4444"; font.pixelSize: 10; font.family: "Consolas" }
                Item { Layout.fillWidth: true }
                Text { text: "20"; color: "#f97316"; font.pixelSize: 10; font.family: "Consolas" }
                Item { Layout.fillWidth: true }
                Text { text: "40"; color: "#22c55e"; font.pixelSize: 10; font.family: "Consolas" }
            }
        }
    }

    // ── BAĞLANTI AYARLARI ──
    Rectangle {
        width: parent ? parent.width : 0
        height: connCol.height + 20
        radius: 10
        color: "#0d1520"
        border.color: "#1e2a3a"
        border.width: 1

        Column {
            id: connCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 14
            spacing: 10

            Text {
                text: "🔗  Bağlantı"
                color: "#94a3b8"
                font.pixelSize: 13
                font.bold: true
            }

            // Seri Port
            RowLayout {
                width: parent.width
                Text {
                    text: "Seri Port"
                    color: "#64748b"
                    font.pixelSize: 12
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: portText.width + 16
                    height: 26; radius: 6
                    color: "#151c28"
                    border.color: "#1e2a3a"; border.width: 1
                    Text {
                        id: portText
                        anchors.centerIn: parent
                        text: "COM3"
                        color: "#94a3b8"
                        font.pixelSize: 11
                        font.family: "Consolas"
                    }
                }
            }

            // Baud Rate
            RowLayout {
                width: parent.width
                Text {
                    text: "Baud Rate"
                    color: "#64748b"
                    font.pixelSize: 12
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: baudText.width + 16
                    height: 26; radius: 6
                    color: "#151c28"
                    border.color: "#1e2a3a"; border.width: 1
                    Text {
                        id: baudText
                        anchors.centerIn: parent
                        text: "115200"
                        color: "#94a3b8"
                        font.pixelSize: 11
                        font.family: "Consolas"
                    }
                }
            }
        }
    }

    // ── GÖRÜNÜM AYARLARI ──
    Rectangle {
        width: parent ? parent.width : 0
        height: viewCol.height + 20
        radius: 10
        color: "#0d1520"
        border.color: "#1e2a3a"
        border.width: 1

        Column {
            id: viewCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 14
            spacing: 10

            Text {
                text: "🎨  Görünüm"
                color: "#94a3b8"
                font.pixelSize: 13
                font.bold: true
            }

            // Koordinat gösterimi
            RowLayout {
                width: parent.width
                Text {
                    text: "Koordinat Gösterimi"
                    color: "#64748b"
                    font.pixelSize: 12
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: coordText.width + 16
                    height: 26; radius: 6
                    color: "#151c28"
                    border.color: "#1e2a3a"; border.width: 1
                    Text {
                        id: coordText
                        anchors.centerIn: parent
                        text: "Decimal"
                        color: "#94a3b8"
                        font.pixelSize: 11
                    }
                }
            }

            // Dil
            RowLayout {
                width: parent.width
                Text {
                    text: "Dil"
                    color: "#64748b"
                    font.pixelSize: 12
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: langText.width + 16
                    height: 26; radius: 6
                    color: "#151c28"
                    border.color: "#1e2a3a"; border.width: 1
                    Text {
                        id: langText
                        anchors.centerIn: parent
                        text: "Türkçe"
                        color: "#94a3b8"
                        font.pixelSize: 11
                    }
                }
            }
        }
    }

    // Versiyon
    Item { height: 8; width: 1 }
    Text {
        text: "Flight Control v0.1.0"
        color: "#2a3444"
        font.pixelSize: 10
        font.family: "Consolas"
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
