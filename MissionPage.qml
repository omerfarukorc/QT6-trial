import QtQuick
import QtQuick.Controls

Column {
    spacing: 12

    Text {
        text: "Gorev Planlama"
        color: "#e2e8f0"
        font.pixelSize: 18
        font.bold: true
    }

    Rectangle {
        width: parent ? parent.width : 0
        height: 1
        color: "#1e2a3a"
    }

    Text {
        text: "Harita uzerinde waypoint eklemek icin\nharitaya tiklayabileceksin."
        color: "#64748b"
        font.pixelSize: 12
        lineHeight: 1.4
    }

    Rectangle {
        width: parent ? parent.width : 0
        height: 80
        radius: 8
        color: "#0d1520"
        border.color: "#1e2a3a"
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: "Yakinda eklenecek"
            color: "#475569"
            font.pixelSize: 12
        }
    }
}
