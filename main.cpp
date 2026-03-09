#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtPlugin>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtPlugin>

#include "src/QtLocationPlugin/QGCMapEngine.h"

// QGC QtLocationPlugin'i statik olarak QtLocation modülüne kaydeder
Q_IMPORT_PLUGIN(QGeoServiceProviderFactoryQGC)

int main(int argc, char *argv[]) {
  QGuiApplication app(argc, argv);

  QQmlApplicationEngine engine;
  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
      []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
  engine.loadFromModule("dronetakip", "Main");

  return app.exec();
}
