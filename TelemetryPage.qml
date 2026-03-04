import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Column {
    spacing: 12

    Text {
        text: "Telemetri"
        color: "#e2e8f0"
        font.pixelSize: 18
        font.bold: true
    }

    Rectangle {
        width: parent ? parent.width : 0
        height: 1
        color: "#1e2a3a"
    }

    Repeater {
        model: [
            {
                label: "Yukseklik",
                value: "120 m",
                unit: "ALT"
            },
            {
                label: "Hiz",
                value: "15.3 m/s",
                unit: "SPD"
            },
            {
                label: "Batarya",
                value: "78%",
                unit: "BAT"
            },
            {
                label: "GPS Uydu",
                value: "12",
                unit: "SAT"
            },
            {
                label: "Mesafe",
                value: "450 m",
                unit: "DST"
            },
            {
                label: "Ucus Suresi",
                value: "04:32",
                unit: "TMR"
            }
        ]

        Rectangle {
            required property var modelData
            width: parent ? parent.width : 0
            height: 52
            radius: 8
            color: "#0d1520"
            border.color: "#1e2a3a"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12

                // Kisa kod etiketi
                Rectangle {
                    width: 36
                    height: 20
                    radius: 4
                    color: "#1e2a3a"
                    Text {
                        anchors.centerIn: parent
                        text: parent.parent.parent.modelData.unit
                        color: "#64748b"
                        font.pixelSize: 9
                        font.bold: true
                        font.family: "Consolas"
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.leftMargin: 4
                    Text {
                        text: parent.parent.parent.modelData.label
                        color: "#64748b"
                        font.pixelSize: 10
                    }
                    Text {
                        text: parent.parent.parent.modelData.value
                        color: "#e2e8f0"
                        font.pixelSize: 15
                        font.bold: true
                    }
                }
            }
        }
    }
}
