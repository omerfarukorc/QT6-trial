// QGCLoggingCategory.h — Shim (köprü) dosyası
// QGC'de bu dosya src/Utilities/QGCLoggingCategory.h konumunda.
// Biz sadece QGC_LOGGING_CATEGORY makrosunu Qt'nin kendi makrosuna
// yönlendiriyoruz.
//
// Kullanım: QGC_LOGGING_CATEGORY(GoogleMapProviderLog, "qgc.map.google")
// Bu, Qt'nin Q_LOGGING_CATEGORY ile birebir aynı şey.

#pragma once

#include <QtCore/QLoggingCategory>

#define QGC_LOGGING_CATEGORY Q_LOGGING_CATEGORY
