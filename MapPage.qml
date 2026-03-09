import QtQuick
import QtQuick.Controls
import QtLocation
import QtPositioning

Item {
    MapView {
        id: mapView
        anchors.fill: parent

        map.plugin: Plugin {
            name: "QGroundControl"
        }
        map.center: QtPositioning.coordinate(39.9334, 32.8597)
        map.zoomLevel: 12

        // Set map type to OpenStreetMap by default since others might need API keys
        Component.onCompleted: {
            // Find OSM map type
            for (var i = 0; i < mapView.map.supportedMapTypes.length; i++) {
                if (mapView.map.supportedMapTypes[i].name === "Street Map") {
                    mapView.map.activeMapType = mapView.map.supportedMapTypes[i];
                    break;
                }
            }
        }

        Shortcut {
            enabled: mapView.map.zoomLevel < mapView.map.maximumZoomLevel
            sequence: StandardKey.ZoomIn
            onActivated: mapView.map.zoomLevel = Math.round(mapView.map.zoomLevel + 1)
        }
        Shortcut {
            enabled: mapView.map.zoomLevel > mapView.map.minimumZoomLevel
            sequence: StandardKey.ZoomOut
            onActivated: mapView.map.zoomLevel = Math.round(mapView.map.zoomLevel - 1)
        }
    }

    // ── ZOOM KONTROLLERI ──
    Column {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        spacing: 4

        // Harita tipi butonu
        Rectangle {
            width: 36
            height: 36
            radius: 8
            color: mapTypeBtnMouse.containsMouse ? "#1e2a3a" : "#d9101520"
            border.color: "#1e2a3a"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "M"
                color: "#94a3b8"
                font.pixelSize: 14
                font.bold: true
            }

            MouseArea {
                id: mapTypeBtnMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: mapTypePanel.visible = !mapTypePanel.visible
            }
        }

        // Zoom in
        Rectangle {
            width: 36
            height: 36
            radius: 8
            color: zoomInMouse.containsMouse ? "#1e2a3a" : "#d9101520"
            border.color: "#1e2a3a"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "+"
                color: "#e2e8f0"
                font.pixelSize: 18
                font.bold: true
            }
            MouseArea {
                id: zoomInMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: mapView.map.zoomLevel += 1
            }
        }

        // Zoom out
        Rectangle {
            width: 36
            height: 36
            radius: 8
            color: zoomOutMouse.containsMouse ? "#1e2a3a" : "#d9101520"
            border.color: "#1e2a3a"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "-"
                color: "#e2e8f0"
                font.pixelSize: 18
                font.bold: true
            }
            MouseArea {
                id: zoomOutMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: mapView.map.zoomLevel -= 1
            }
        }
    }

    // ── HARİTA TİPİ PANELİ ──
    Rectangle {
        id: mapTypePanel
        visible: false
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 66
        anchors.bottomMargin: 20
        width: 180
        height: mapTypeColumn.height + 16
        radius: 10
        color: "#f0101520"
        border.color: "#1e2a3a"
        border.width: 1

        Column {
            id: mapTypeColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            spacing: 2

            Text {
                text: "Harita Gorunumu"
                color: "#64748b"
                font.pixelSize: 11
                font.bold: true
                bottomPadding: 4
            }

            Repeater {
                model: mapView.map.supportedMapTypes

                Rectangle {
                    required property var modelData
                    required property int index
                    width: parent ? parent.width : 0
                    height: 28
                    radius: 6
                    color: {
                        if (mapTypeItemMouse.containsMouse)
                            return "#1e2a3a";
                        if (mapView.map.activeMapType === modelData)
                            return "#e94560";
                        return "transparent";
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        text: parent.modelData.name
                        color: mapView.map.activeMapType === parent.modelData ? "white" : "#94a3b8"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: mapTypeItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            mapView.map.activeMapType = parent.modelData;
                            mapTypePanel.visible = false;
                        }
                    }
                }
            }
        }
    }

    // ── BİLGİ PANELİ ──
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 10
        anchors.topMargin: 58
        width: infoColumn.width + 20
        height: infoColumn.height + 14
        radius: 8
        color: "#d9101520"
        border.color: "#1e2a3a"
        border.width: 1

        Column {
            id: infoColumn
            anchors.centerIn: parent
            spacing: 3

            Text {
                text: "LAT  " + mapView.map.center.latitude.toFixed(4)
                color: "#64748b"
                font.pixelSize: 10
                font.family: "Consolas"
            }
            Text {
                text: "LNG  " + mapView.map.center.longitude.toFixed(4)
                color: "#64748b"
                font.pixelSize: 10
                font.family: "Consolas"
            }
            Text {
                text: "ZOOM " + mapView.map.zoomLevel.toFixed(1)
                color: "#64748b"
                font.pixelSize: 10
                font.family: "Consolas"
            }
        }
    }
}
