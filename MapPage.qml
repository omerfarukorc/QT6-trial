import QtQuick
import QtQuick.Controls
import QtLocation    // Plugin, MapView, MapQuickItem gibi harita objelerini sağlar.
import QtPositioning // Koordinat (latitude, longitude) değişkenlerini (coordinate objesi) oluşturmamızı sağlar.

// Item, ekranda boyutu ve konumu olan ama görünmez bir boş kutudur (div gibi düşünebilirsiniz).
Item {
    // MAIN'DEN GELEN ÖZELLİK (PROPERTY PASSING):
    // Main.qml'de, MapPage oluşturulurken "topBarHeight: topBar.height" diyerek bu değere atama yapıldı.
    // Biz de buradaki UI elemanlarımızı yukarıdan 'topBarHeight' kadar aşağıda başlatacağız ki,
    // üstteki navigation bar harita ikonlarının üzerine kapanmasın.
    property real topBarHeight: 48
    property bool isPiP: false

    // MapView (Qt 6.7+): Yeni nesil harita gösterim aracı. İçinde bir 'map' objesi barındırır ve touch (dokunma) özelliklerini otomatik yönetir.
    MapView {
        id: mapView
        anchors.fill: parent // Atası olan Item'ı tamamen kaplasın

        // ── QGC HARİTASININ ENTEGRASYONU ──
        // C++ tarafında qgc.core gibi bir kütüphane QGeoServiceProviderFactory miras alıp "QGroundControl" adıyla kaydedilmiştir.
        // QML tarafında map.plugin'e "QGroundControl" adını vererek, harita motorumuzun 
        // QGC'nin harita sisteminden (ör: çevrimdışı tile servisi vb.) verilerini çekmesini sağlıyoruz.
        map.plugin: Plugin {
            name: "QGroundControl" 
        }
        
        // Haritanın başlangıç noktası (Enlem: 39.9334, Boylam: 32.8597 => Ankara Kızılay)
        map.center: QtPositioning.coordinate(39.9334, 32.8597)
        map.zoomLevel: 16 // Başlangıç yakınlaştırma seviyesi artırıldı (12 -> 16)

        // Component.onCompleted: Bu MapView ekranda ilk oluşturulduğunda çalışacak JavaScript fonksiyonudur.
        Component.onCompleted: {
            // Adında "Satellite" (Uydu) geçen harita servisini/tipini bul ve onu aktif hale getir.
            for (var i = 0; i < mapView.map.supportedMapTypes.length; i++) {
                if (mapView.map.supportedMapTypes[i].name.indexOf("Satellite") !== -1 || mapView.map.supportedMapTypes[i].name.indexOf("Uydu") !== -1) {
                    mapView.map.activeMapType = mapView.map.supportedMapTypes[i];
                    break;
                }
            }

            // Qt 6'da MapView kullanıldığında, haritanın üzerindeki nesneler (MapQuickItem) 
            // C++ veya JS ile 'mapView.map.addMapItem' diyerek manuel olarak harita katmanına eklenmelidir.
            mapView.map.addMapItem(baseMarker);
            mapView.map.addMapItem(userMarker);
            mapView.map.addMapItem(droneMarker);
        }

        // --- TAKLİT (MOCK) VERİLER ---
        // 'property var' kullanarak koordinatları saklayan kendi değişkenlerimizi tanımladık.
        // Gerçek bir senaryoda bu değişkenler C++'tan gelen Telemetri/GPS bağlamalarına (binding) bağlı olur.
        property var droneCoordinate: QtPositioning.coordinate(39.9350, 32.8620)
        property var baseCoordinate: QtPositioning.coordinate(39.9334, 32.8597)
        property var userCoordinate: QtPositioning.coordinate(39.9310, 32.8570)
        property real droneHeading: 45 // Dronun Pusula yönü (derece cinsinden)

        // 1. Baz İstasyonu İkonu (Marker)
        // MapQuickItem, harita üzerindeki spesifik BİR KOORDİNATA herhangi bir görsel öğeyi tutturmak için kullanılır.
        // Normal X/Y pozisyonu kullanmaz. Koordinatını kullanır.
        MapQuickItem {
            id: baseMarker
            coordinate: mapView.baseCoordinate // İkonu baz istasyonu koordinatına koy
            
            // anchorPoint, resmin hangi noktasından harita koordinatına çivileneceğini belirtir.
            // Width/2, height/2 yaparak tam ortasını belirtmiş oluyoruz.
            anchorPoint: Qt.point(baseIcon.width / 2, baseIcon.height / 2)
            
            // Haritada görünecek olan görsel (SVG görselini veriyoruz)
            sourceItem: Image {
                id: baseIcon
                source: "assets/base_station.svg"
                sourceSize: Qt.size(36, 36)
            }
        }

        // 2. Kullanıcı İkonu
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

        // 3. Drone İkonu
        MapQuickItem {
            id: droneMarker
            coordinate: mapView.droneCoordinate
            anchorPoint: Qt.point(48 / 2, 48 / 2) // Tam ortadan tuttur
            sourceItem: Item {
                width: 48
                height: 48

                Image {
                    id: droneIcon
                    anchors.centerIn: parent
                    source: "assets/drone.svg"
                    sourceSize: Qt.size(48, 48)
                    rotation: mapView.droneHeading // Cihazın burnunu rotasyona göre çevirir
                    
                    // Behavior (Davranış): Bir değişkenin aniden değil, animasyonla değişmesini sağlar.
                    // Dönüş açısı (rotation) değiştiğinde anında dönmez de, RotationAnimation ile yavaşça döner.
                    Behavior on rotation {
                        RotationAnimation {
                            direction: RotationAnimation.Shortest // En kısa yoldan dön (saat yönü veya tersi)
                            duration: 250 // Çeyrek saniyede animasyonu bitir
                        }
                    }
                }
            }
        }

        // Shortcut, klavyeden basılan bir kısayolu tetiklemeye yarar. 
        // "+" (ZoomIn) ve "-" (ZoomOut) tuşlarıyla da haritaya yakınlaşıp uzaklaşmayı ayarlıyoruz.
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

    // ── YUMUŞAK ODAKLANMA (PANCHANGE) ANİMASYONU ──
    // Bir marker'a tıklandığında anında değil de, kameranın kayarak (pan) o koordinata gitmesini sağlar.
    PropertyAnimation {
        id: mapCenterAnimation
        target: mapView.map       // Neyin özelliğini değiştirecek? (haritanın)
        property: "center"        // Hangi özelliğini? ("center" yani merkez noktasını)
        duration: 500             // Animasyon süresi (0.5 saniye)
        easing.type: Easing.InOutQuad // Hızlanma ve yavaşlama grafiği (baştan hızlanır, sona doğru yavaşlar)
    }

    // Seçili ikona kamerayı kaydırmak için çağrılacak JS Fonksiyonu.
    function smoothFocusMap(targetCoordinate) {
        mapCenterAnimation.stop(); // Animasyon varsa durdur
        mapCenterAnimation.to = targetCoordinate; // Yeni hedef koordinatı belirle
        mapCenterAnimation.start(); // Animasyonu başlat
    }

    // ── ODAKLANMA / NAVİGASYON PANELİ (SAĞ VE ÜST ORTA) ──
    // Burası ekrandaki Drone, Kullanıcı ve Baz İstasyonu gibi butonları barındırır.
    Rectangle {
        visible: !isPiP
        anchors.right: parent.right   // Ekranda sağa yasla
        anchors.top: parent.top       // Ekranda üste yasla
        anchors.rightMargin: 10       // Sağdan 10px uzaklık
        
        // Üstten TopBar'ın boyutu(48) + 10 px daha aşağı indir, butonlar üst çubuğun altına saklanmasın!
        anchors.topMargin: topBarHeight + 10 
        
        width: navRow.width + 16
        height: navRow.height + 16
        radius: 12
        color: "#a0000000" // Saydam Siyah arka plan
        border.color: "#33ffffff"
        border.width: 1

        Row {
            id: navRow
            anchors.centerIn: parent
            spacing: 8

            // 1) Drone Butonu
            Rectangle {
                width: 40; height: 40; radius: 8
                // İçindeki MouseArea üzerinde imleç varsa şeffaf beyaz, yoksa tamamen şeffaf
                color: droneBtnMouse.containsMouse ? "#40ffffff" : "transparent"

                Image {
                    source: "assets/drone.svg"
                    sourceSize: Qt.size(24, 24)
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: droneBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true  // Üzerine gelince algıla ki color durumu değişsin
                    cursorShape: Qt.PointingHandCursor
                    // Tıklanınca kamerayı dronun olduğu koordinata kaydır.
                    onClicked: smoothFocusMap(mapView.droneCoordinate)
                }
            }

            // 2) Baz İstasyonu Butonu
            Rectangle {
                width: 40; height: 40; radius: 8
                color: baseBtnMouse.containsMouse ? "#40ffffff" : "transparent"

                Image {
                    source: "assets/base_station.svg"
                    sourceSize: Qt.size(24, 24)
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: baseBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: smoothFocusMap(mapView.baseCoordinate)
                }
            }

            // 3) Kullanıcı Butonu
            Rectangle {
                width: 40; height: 40; radius: 8
                color: userBtnMouse.containsMouse ? "#40ffffff" : "transparent"

                Image {
                    source: "assets/user.svg"
                    sourceSize: Qt.size(24, 24)
                    anchors.centerIn: parent
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

    // ── ZOOM KONTROLLERİ VE HARİTA TİPİ SEÇİCİ (SAĞ ALT KÖŞE) ──
    Column {
        visible: !isPiP
        anchors.right: parent.right
        anchors.bottom: parent.bottom // Sağ alta yerleştiriyoruz
        anchors.margins: 20
        spacing: 4

        // Harita tipi butonu "M"
        Rectangle {
            width: 36; height: 36; radius: 8
            color: mapTypeBtnMouse.containsMouse ? "#1e2a3a" : "#d9101520"
            border.color: "#1e2a3a"; border.width: 1

            Text {
                anchors.centerIn: parent
                text: "M"
                color: "#94a3b8"
                font.pixelSize: 14; font.bold: true
            }

            MouseArea {
                id: mapTypeBtnMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                // "M" ye tıklandığında sol tarafta açılan harita türü (uydu vs) panelini göster veya gizle
                onClicked: mapTypePanel.visible = !mapTypePanel.visible
            }
        }

        // Yakınlaştır (+) Butonu
        Rectangle {
            width: 36; height: 36; radius: 8
            color: zoomInMouse.containsMouse ? "#1e2a3a" : "#d9101520"
            border.color: "#1e2a3a"; border.width: 1

            Text {
                anchors.centerIn: parent; text: "+"
                color: "#e2e8f0"; font.pixelSize: 18; font.bold: true
            }
            MouseArea {
                id: zoomInMouse; anchors.fill: parent
                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: mapView.map.zoomLevel += 1 // zoomLevel'ı artırarak haritayı yakınlaştır
            }
        }

        // Uzaklaştır (-) Butonu
        Rectangle {
            width: 36; height: 36; radius: 8
            color: zoomOutMouse.containsMouse ? "#1e2a3a" : "#d9101520"
            border.color: "#1e2a3a"; border.width: 1

            Text {
                anchors.centerIn: parent; text: "-"
                color: "#e2e8f0"; font.pixelSize: 18; font.bold: true
            }
            MouseArea {
                id: zoomOutMouse; anchors.fill: parent
                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: mapView.map.zoomLevel -= 1
            }
        }
    }

    // ── HARİTA TİPİ AÇILIR PANELİ (Uydu, Sokak vs. Seçmek İçin) ──
    Rectangle {
        id: mapTypePanel
        visible: false
        anchors.right: parent.right
        anchors.bottom: parent.bottom // Zoom tuşlarının hemen soluna yerleştiriyoruz.
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
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 8; spacing: 2

            Text {
                text: "Harita Gorunumu"
                color: "#64748b"; font.pixelSize: 11; font.bold: true; bottomPadding: 4
            }

            // Repeater (döngü). C++ eklentisinden (QGC eklentisi vd) gelen 'supportedMapTypes' dizisindeki 
            // her bir harita çeşidi (Satellite, Hybrid, Street Map vs.) için butonu otomatik çoğaltır.
            Repeater {
                model: mapView.map.supportedMapTypes

                Rectangle {
                    required property var modelData
                    required property int index
                    width: parent ? parent.width : 0
                    height: 28; radius: 6
                    color: {
                        if (mapTypeItemMouse.containsMouse) return "#1e2a3a";
                        if (mapView.map.activeMapType === modelData) return "#e94560";
                        return "transparent";
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left; anchors.leftMargin: 8
                        // Harita tipinin gerçek adını yazdır
                        text: parent.modelData.name
                        color: mapView.map.activeMapType === parent.modelData ? "white" : "#94a3b8"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: mapTypeItemMouse
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        // Listeden bir öğeye tıklayınca aktif haritayı değiştir.
                        onClicked: {
                            mapView.map.activeMapType = parent.modelData;
                            mapTypePanel.visible = false; // paneli kapat
                        }
                    }
                }
            }
        }
    }

    // ── BİLGİ PANELİ (SOL ÜST KÖŞE, KOORDİNAT GÖSTERİCİ) ──
    Rectangle {
        visible: !isPiP
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 10
        anchors.topMargin: topBarHeight + 10
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
                color: "#64748b"; font.pixelSize: 10; font.family: "Consolas"
            }
            Text {
                text: "LNG  " + mapView.map.center.longitude.toFixed(4)
                color: "#64748b"; font.pixelSize: 10; font.family: "Consolas"
            }
            Text {
                text: "ZOOM " + mapView.map.zoomLevel.toFixed(1)
                color: "#64748b"; font.pixelSize: 10; font.family: "Consolas"
            }
        }
    }
}

