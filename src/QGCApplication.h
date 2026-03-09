// QGCApplication.h — Shim (köprü) dosyası
// QGC'nin ana uygulama sınıfı. QtLocationPlugin bu sınıfı 4 yerde kullanıyor:
//   1. getCurrentLanguage()  — Harita dilini almak için
//   2. showAppMessage()      — Kullanıcıya mesaj göstermek için
//   3. numberToString()      — Sayıları formatlamak için (ör: 1,234)
//   4. bigSizeToString()     — Dosya boyutlarını formatlamak için (ör: 2.4 GB)
//
// Biz bu fonksiyonları basit stub'lar olarak sağlıyoruz.

#pragma once

#include <QtCore/QDebug>
#include <QtCore/QLocale>
#include <QtCore/QStandardPaths>
#include <QtCore/QString>


class QGCApplication {
public:
  // Harita tile'larının dili için kullanılıyor
  QLocale getCurrentLanguage() const { return QLocale::system(); }

  // Sayıları yerel formatta göster (ör: 1.234 veya 1,234)
  QString numberToString(quint64 number) const {
    return QLocale::system().toString(number);
  }

  // Büyük dosya boyutlarını okunabilir formata çevir
  QString bigSizeToString(quint64 size) const {
    if (size < 1024ULL)
      return QString::number(size) + QStringLiteral(" B");
    if (size < 1048576ULL)
      return QString::number(size / 1024.0, 'f', 1) + QStringLiteral(" KB");
    if (size < 1073741824ULL)
      return QString::number(size / 1048576.0, 'f', 1) + QStringLiteral(" MB");
    return QString::number(size / 1073741824.0, 'f', 1) + QStringLiteral(" GB");
  }

  // Cache dolu gibi uyarılarda kullanılıyor
  void showAppMessage(const QString &message) {
    qWarning() << "[DroneTakip Map]" << message;
  }
};

// QGC'de qgcApp() global fonksiyonu ana uygulamaya erişim sağlar
// Biz basit bir singleton döndürüyoruz
inline QGCApplication *qgcApp() {
  static QGCApplication app;
  return &app;
}
