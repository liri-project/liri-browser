# Copy translation files

#copydata.commands = $(COPY_DIR) $$PWD/translations $$OUT_PWD
#first.depends = $(first) copydata
#export(first.depends)
#export(copydata.commands)
#QMAKE_EXTRA_TARGETS += first copydata

TEMPLATE = app

QT += qml quick widgets svg xml webengine multimedia core network webenginewidgets
QTPLUGIN += qsvg

SOURCES += src/main.cpp \
    src/config.cpp \
    src/cursor/cursor.cpp \
    src/clipboardadapter.cpp \
    src/plugins/pluginsengine.cpp \
    src/plugins/plugin.cpp \
    src/plugins/api.cpp \
    src/plugins/urlopener.cpp

HEADERS += \
    src/config.h \
    src/cursor/cursor.h \
    src/plugins/pluginsengine.h \
    src/plugins/plugin.h \
    src/plugins/api.h \
    src/plugins/urlopener.h

RESOURCES += \
    src/qml.qrc


CONFIG += c++11

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

DISTFILES +=

# Windows icon
RC_ICONS = icons/liri-browser.ico

# OS X icon
ICON = icons/liri-browser.icns

HEADERS += \
    src/clipboardadapter.h

linux-g++{
    target.path=/opt/liri-browser-build
    target.files+=liri-browser
    target.files+=liri-browser.desktop
}
