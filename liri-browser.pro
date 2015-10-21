# Copy translation files

#copydata.commands = $(COPY_DIR) $$PWD/translations $$OUT_PWD
#first.depends = $(first) copydata
#export(first.depends)
#export(copydata.commands)
#QMAKE_EXTRA_TARGETS += first copydata

TEMPLATE = app

QT += qml quick widgets svg xml webengine multimedia core #webview (for android)
#QT += androidextras

include(dependencies/liri-player/dependencies/QmlVlc/QmlVlc.pri)

INCLUDEPATH += dependencies \
    dependencies/liri-player/dependencies

QTPLUGIN += qsvg

SOURCES += src/main.cpp \
    src/cursor/cursor.cpp \
    src/clipboardadapter.cpp

HEADERS += \
    src/cursor/cursor.h

RESOURCES += \
    src/qml.qrc \
    dependencies/liri-player/src/plugin.qrc


CONFIG += c++11

macx {
    LIBS += -L/Applications/VLC.app/Contents/MacOS/lib
}

android {
    LIBS += -L$$PWD/android/libs/armeabi-v7a -lvlcjni

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
}


TRANSLATIONS += src/translations/liri-browser.ts \
                src/translations/de_DE.ts \
                src/translations/ru_RU.ts \
                src/translations/fr_FR.ts \
                src/translations/es_CR.ts \
                src/translations/es_ES.ts \
                src/translations/pt_BR.ts \
                src/translations/pt_PT.ts

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

# Windows icon
RC_ICONS = icons/liri-browser.ico

# OS X icon
ICON = icons/liri-browser.icns

HEADERS += \
    src/clipboardadapter.h
