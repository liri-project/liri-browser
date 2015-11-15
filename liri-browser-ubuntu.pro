# Ubuntu SDK
TEMPLATE = app

#load Ubuntu specific features
load(ubuntu-click)


TEMPLATE = app

QT += qml quick widgets svg xml multimedia core network
QTPLUGIN += qsvg

SOURCES += src/ubuntu/main.cpp \
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

DISTFILES += liri-browser.timsueberkrueb.desktop

# Windows icon
RC_ICONS = icons/liri-browser.ico

# OS X icon
ICON = icons/liri-browser.icns

HEADERS += \
    src/clipboardadapter.h


# manifest
UBUNTU_MANIFEST_FILE=ubuntu/manifest.json

# specify translation domain, this must be equal with the
# app name in the manifest file
#UBUNTU_TRANSLATION_DOMAIN="liri-browser.timsueberkrueb"
#
# specify the source files that should be included into
# the translation file, from those files a translation
# template is created in po/template.pot, to create a
# translation copy the template to e.g. de.po and edit the sources
#UBUNTU_TRANSLATION_SOURCES+= \
#    $$files(*.qml,true) \
#    $$files(*.js,true)  \
#    $$files(*.cpp,true) \
#    $$files(*.h,true) \
#    $$files(*.desktop,true)
#
# specifies all translations files and makes sure they are
# compiled and installed into the right place in the click package
#UBUNTU_PO_FILES+=$$files(po/*.po)

TARGET = liri-browser.timsueberkrueb

RESOURCES += src/qml.qrc

QML_FILES += $$files(*.qml,true) \
             $$files(*.js,true)

CONF_FILES +=  ubuntu/liri-browser.timsueberkrueb.apparmor \
               icons/liri-browser.timsueberkrueb.png

ICON_FILES = $$files(icons/*.png,true)

LIB_FILES = $$files(lib/*,true)

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               $${AP_TEST_FILES} \
               ubuntu/liri-browser.timsueberkrueb.desktop \
               icons/liri-browser-ubuntu.png

# icon
icon_files.path = /icons
icon_files.files += $${ICON_FILES}

# lib files
lib_files.path = /lib
lib_files.files += $${LIB_FILES}

# qml/js files
qml_files.path = /src/qml
qml_files.files += $${QML_FILES}

# config files
config_files.path = /ubuntu
config_files.files += $${CONF_FILES}

# .desktop file
desktop_file.path = /ubuntu
desktop_file.files = ubuntu/liri-browser.timsueberkrueb.desktop
desktop_file.CONFIG += no_check_exist

INSTALLS+=config_files qml_files desktop_file lib_files icon_files
