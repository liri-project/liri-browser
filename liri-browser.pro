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

SOURCES += src/main.cpp

RESOURCES += src/qml.qrc

TRANSLATIONS += translations/de_DE.ts \
                translations/ru_RU.ts \
                translations/fr_FR.ts

OTHER_FILES += translations/*.qm

lupdate_only{
    SOURCES = *.qml \
              *.js \
              src/qml/* \
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES += \
    src/qml/TabBarItemDelegate.qml
