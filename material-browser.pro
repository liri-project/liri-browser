# Copy translation files
copydata.commands = $(COPY_DIR) $$PWD/translations $$OUT_PWD
first.depends = $(first) copydata
export(first.depends)
export(copydata.commands)
QMAKE_EXTRA_TARGETS += first copydata

TEMPLATE = app

QT += qml quick widgets svg xml webengine #webview (for android)
#QT += androidextras

QTPLUGIN += qsvg

SOURCES += main.cpp

RESOURCES += qml.qrc

TRANSLATIONS += translations/de_DE.ts /
                translations/ru_RU.ts

OTHER_FILES += translations/*.qm

lupdate_only{
    SOURCES = *.qml \
              *.js
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES +=
