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
#include <QtQml>
#include <QtQml/QQmlContext>
#include <QTranslator>
#include <QLibraryInfo>
#include "../cursor/cursor.h"
#include "../clipboardadapter.h"
#include "../plugins/pluginsengine.h"
#include "../config.h"

int main(int argc, char **argv)
{
    Application app(argc, argv);

    // Load configuration
    Config * config = new Config();
    config->load();

    // Set domain
    app.setOrganizationName("liri-browser.timsueberkrueb");
    app.setOrganizationDomain("liri-browser.timsueberkrueb");
    app.setApplicationName("liri-browser.timsueberkrueb");

    // Load Translations
    QTranslator qtTranslator;
    qtTranslator.load("qt_" + QLocale::system().name(),
            QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    app.installTranslator(&qtTranslator);

    QTranslator translator;
    translator.load(":/translations/" + QLocale::system().name());
    app.installTranslator(&translator);

    QQmlApplicationEngine * appEngine = new QQmlApplicationEngine();
    //appEngine.rootContext()->setContextProperty("utils", &utils);
	qmlRegisterType<ClipBoardAdapter>("Clipboard", 1, 0, "Clipboard");
    appEngine->load(QUrl("src/qml/Main.qml"));
    //QMetaObject::invokeMethod(appEngine->rootObjects().first(), "load");
    //appEngine->rootContext()->setContextProperty("G_Cursor",new Cursor);

    // Load plugins
    //PluginsEngine * pluginsEngine = new PluginsEngine(appEngine, config);
    //appEngine->rootContext()->setContextProperty("PluginsEngine", pluginsEngine);
    //pluginsEngine->loadPlugins();
    //pluginsEngine->trigger(QString("load"));

    return app.exec();
}
