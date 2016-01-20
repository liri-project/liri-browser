//#include <QApplication>
//#include <QQmlApplicationEngine>
#ifndef QT_NO_WIDGETS
#include <QtWidgets/QApplication>
typedef QApplication Application;
#else
#include <QtGui/QGuiApplication>
typedef QGuiApplication Application;
#endif
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtWebEngine/qtwebengineglobal.h>
#include <QtWebEngine/QtWebEngine>
#include <QWebEngineSettings>
#include "cursor/cursor.h"
#include "clipboardadapter.h"
#include "plugins/pluginsengine.h"
#include "config.h"

int main(int argc, char **argv)
{
    Application app(argc, argv);

    // Load configuration
    Config config;
    config.load();

    // Set domain
    app.setOrganizationName("Liri Project");
    app.setOrganizationDomain("liri-project.me");
    app.setApplicationName("Liri Browser");

    // Load Translations
    QTranslator qtTranslator;
    qtTranslator.load("qt_" + QLocale::system().name(),
                      QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    app.installTranslator(&qtTranslator);

    QTranslator translator;
    translator.load(":/translations/" + QLocale::system().name());
    app.installTranslator(&translator);

    qputenv("QTWEBENGINE_REMOTE_DEBUGGING", "0.0.0.0:9992");

    QtWebEngine::initialize();

    QQmlApplicationEngine appEngine;

    qmlRegisterType<ClipBoardAdapter>("Clipboard", 1, 0, "Clipboard");
    appEngine.load(QUrl(QStringLiteral("qrc:/qml/DesktopApplication.qml")));
    QMetaObject::invokeMethod(appEngine.rootObjects().first(), "load");
    appEngine.rootContext()->setContextProperty("G_Cursor", new Cursor);

    // Load plugins
    PluginsEngine pluginsEngine(&appEngine, &config);
    appEngine.rootContext()->setContextProperty("PluginsEngine", &pluginsEngine);
    pluginsEngine.loadPlugins();
    pluginsEngine.trigger("load");

    return app.exec();
}
