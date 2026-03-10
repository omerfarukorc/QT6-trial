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

            // In Qt 6 with MapView, MapQuickItems must be explicitly added to the map object
            mapView.map.addMapItem(baseMarker);
            mapView.map.addMapItem(userMarker);
            mapView.map.addMapItem(droneMarker);
        }

        // --- MOCK DATA FOR MARKERS ---
        // TODO: In the future, connect these properties to real C++ Telemetry/GPS models
        property var droneCoordinate: QtPositioning.coordinate(39.9350, 32.8620)
        property var baseCoordinate: QtPositioning.coordinate(39.9334, 32.8597)
        property var userCoordinate: QtPositioning.coordinate(39.9310, 32.8570)
        property real droneHeading: 45 // degrees

        // 1. Base Station Marker
        MapQuickItem {
            id: baseMarker
            coordinate: mapView.baseCoordinate
            anchorPoint: Qt.point(baseIcon.width / 2, baseIcon.height / 2)
            sourceItem: Image {
                id: baseIcon
                source: "assets/base_station.svg"
                sourceSize: Qt.size(36, 36)
            }
        }

        // 2. User Marker
        MapQuickItem {
            id: userMarker
            coordinate: mapView.userCoordinate
            anchorPoint: Qt.point(userIcon.width / 2, userIcon.height / 2)
            sourceItem: Image {
                id: userIcon
                source: "assets/user.svg"
                sourceSize: Qt.size(24, 24)
            }
        }

        // 3. Drone Marker
        MapQuickItem {
            id: droneMarker
            coordinate: mapView.droneCoordinate
            anchorPoint: Qt.point(48 / 2, 48 / 2)
            sourceItem: Item {
                width: 48
                height: 48

                Image {
                    id: droneIcon
                    anchors.centerIn: parent
                    source: "assets/drone.svg"
                    sourceSize: Qt.size(48, 48)
                    rotation: mapView.droneHeading

                    Behavior on rotation {
                        RotationAnimation {
                            direction: RotationAnimation.Shortest
                            duration: 250
                        }
                    }
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

    // --- ANIMATON FOR SMOOTH PANNING ---
    PropertyAnimation {
        id: mapCenterAnimation
        target: mapView.map
        property: "center"
        duration: 500
        easing.type: Easing.InOutQuad
    }

    function smoothFocusMap(targetCoordinate) {
        mapCenterAnimation.stop();
        mapCenterAnimation.to = targetCoordinate;
        mapCenterAnimation.start();
    }

    // ── ODAKLANMA / NAVİGASYON PANELİ (TOP-RIGHT) ──
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 20
        anchors.topMargin: 20
        width: 140
        height: navColumn.height + 16
        radius: 10
        color: "#d9101520" // Semitransparent dark like other panels
        border.color: "#1e2a3a"
        border.width: 1

        Column {
            id: navColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            spacing: 6

            Text {
                text: "Harita Odak"
                color: "#64748b"
                font.pixelSize: 11
                font.bold: true
                bottomPadding: 4
            }

            // Drone Button
            Rectangle {
                width: parent.width
                height: 32
                radius: 6
                color: droneBtnMouse.containsMouse ? "#1e2a3a" : "transparent"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    spacing: 8

                    Image {
                        source: "qrc:/assets/drone.svg"
                        sourceSize: Qt.size(16, 16)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Drone'a Git"
                        color: "#e2e8f0"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: droneBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: smoothFocusMap(mapView.droneCoordinate)
                }
            }

            // Base Station Button
            Rectangle {
                width: parent.width
                height: 32
                radius: 6
                color: baseBtnMouse.containsMouse ? "#1e2a3a" : "transparent"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    spacing: 8

                    Image {
                        source: "qrc:/assets/base_station.svg"
                        sourceSize: Qt.size(16, 16)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Ev'e Dön"
                        color: "#e2e8f0"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: baseBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: smoothFocusMap(mapView.baseCoordinate)
                }
            }

            // User Button
            Rectangle {
                width: parent.width
                height: 32
                radius: 6
                color: userBtnMouse.containsMouse ? "#1e2a3a" : "transparent"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    spacing: 8

                    Image {
                        source: "qrc:/assets/user.svg"
                        sourceSize: Qt.size(16, 16)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Bana Git"
                        color: "#e2e8f0"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: userBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: smoothFocusMap(mapView.userCoordinate)
                }
            }
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
