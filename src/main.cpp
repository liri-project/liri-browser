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
#include "cursor/cursor.h"
#include "clipboardadapter.h"
#include "plugins/pluginsengine.h"

int main(int argc, char **argv)
{
    Application app(argc, argv);

    // Set domain
    app.setOrganizationName("liri-browser");
    app.setOrganizationDomain("liri-browser.github.io");
    app.setApplicationName("liri-browser");

    // Load Translations
    QTranslator qtTranslator;
    qtTranslator.load("qt_" + QLocale::system().name(),
            QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    app.installTranslator(&qtTranslator);

    QTranslator translator;
    translator.load(":/translations/" + QLocale::system().name());
    app.installTranslator(&translator);

    // Initialize QtWebEngine
    QtWebEngine::initialize();

    QQmlApplicationEngine * appEngine = new QQmlApplicationEngine();
    //appEngine.rootContext()->setContextProperty("utils", &utils);
	qmlRegisterType<ClipBoardAdapter>("Clipboard", 1, 0, "Clipboard");
    appEngine->load(QUrl("qrc:/qml/DesktopApplication.qml"));
    QMetaObject::invokeMethod(appEngine->rootObjects().first(), "load");
    appEngine->rootContext()->setContextProperty("G_Cursor",new Cursor);

    // Load plugins
    PluginsEngine * pluginsEngine = new PluginsEngine(appEngine);
    appEngine->rootContext()->setContextProperty("PluginsEngine", pluginsEngine);
    pluginsEngine->loadPlugins();
    pluginsEngine->trigger(QString("load"));

    return app.exec();
}
