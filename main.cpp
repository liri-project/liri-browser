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

    QtWebEngine::initialize();

    QQmlApplicationEngine appEngine;
    //appEngine.rootContext()->setContextProperty("utils", &utils);
    appEngine.load(QUrl("qrc:/Application.qml"));
    QMetaObject::invokeMethod(appEngine.rootObjects().first(), "load");

    return app.exec();
}
