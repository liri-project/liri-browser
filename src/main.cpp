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


int main(int argc, char **argv)
{
    Application app(argc, argv);

    app.setOrganizationName("tim-sueberkrueb");
    app.setOrganizationDomain("github.com/tim-sueberkrueb");
    app.setApplicationName("material-browser");

    // Load Translations
    QTranslator qtTranslator;
    qtTranslator.load("qt_" + QLocale::system().name(),
            QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    app.installTranslator(&qtTranslator);

    QTranslator translator;
    translator.load("translations/" + QLocale::system().name());
    app.installTranslator(&translator);

    // Initialize QtWebEngine
    QtWebEngine::initialize();

    QQmlApplicationEngine appEngine;
    //appEngine.rootContext()->setContextProperty("utils", &utils);
    appEngine.load(QUrl("qrc:/Application.qml"));
    QMetaObject::invokeMethod(appEngine.rootObjects().first(), "load");

    return app.exec();
}
