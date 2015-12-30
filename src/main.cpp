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
    Config * config = new Config();
    config->load();

    // Set domain
    app.setOrganizationName("liri-project");
    app.setOrganizationDomain("liri-project.me");
    app.setApplicationName("liri-browser");

    // Load Translations
    QTranslator qtTranslator;
    qtTranslator.load("qt_" + QLocale::system().name(),
            QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    app.installTranslator(&qtTranslator);

    QTranslator translator;
    translator.load(":/translations/" + QLocale::system().name());
    app.installTranslator(&translator);

    qputenv("QTWEBENGINE_REMOTE_DEBUGGING", "0.0.0.0:9992");

    // Initialize QtWebEngine (and some attempts to activate pepper plugins, but it doesn't work)
    //QWebEngineSettings::globalSettings()->setAttribute(QWebEngineSettings::PluginsEnabled, true);
    QtWebEngine::initialize();
    //QWebEngineSettings::globalSettings()->setAttribute(QWebEngineSettings::JavascriptEnabled, false);
    /*QWebEngineSettings *defaultSettings = QWebEngineSettings::globalSettings();
    defaultSettings->setAttribute(QWebEngineSettings::PluginsEnabled, true);
    QWebEngineSettings::globalSettings()->setAttribute(QWebEngineSettings::PluginsEnabled, true);*/

    QQmlApplicationEngine * appEngine = new QQmlApplicationEngine();
    //appEngine.rootContext()->setContextProperty("utils", &utils);
	qmlRegisterType<ClipBoardAdapter>("Clipboard", 1, 0, "Clipboard");
    appEngine->load(QUrl("qrc:/qml/DesktopApplication.qml"));
    QMetaObject::invokeMethod(appEngine->rootObjects().first(), "load");
    appEngine->rootContext()->setContextProperty("G_Cursor",new Cursor);

    // Load plugins
    PluginsEngine * pluginsEngine = new PluginsEngine(appEngine, config);
    appEngine->rootContext()->setContextProperty("PluginsEngine", pluginsEngine);
    pluginsEngine->loadPlugins();
    pluginsEngine->trigger(QString("load"));

    return app.exec();
}
