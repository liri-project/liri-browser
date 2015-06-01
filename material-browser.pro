TEMPLATE = app

QT += qml quick widgets svg xml #webview (for android)
#QT += androidextras

QTPLUGIN += qsvg

SOURCES += main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)
