#ifndef PLUGIN_H
#define PLUGIN_H

#include <QObject>
#include <QJSEngine>
#include "api.h"
#include <QQmlApplicationEngine>

class Plugin : public QObject{
        Q_OBJECT
        public:
                explicit Plugin(QString name, QString path, QQmlApplicationEngine *appEngine, QObject *parent = 0);

                void load();
                bool trigger(QString event, QJSValueList args=QJSValueList());

        private:
                void createEngine();
                bool loadManifest();
                bool loadEngine();
                void loadScript();

                QJSEngine engine;
                QString name;
                QString path;
                QString title;
                QString description;
                QString maintainer;
                QString apiVersion;
                QString version;
                QStringList policyGroups;
                QVariantList permissions;

                PluginAPI * api;

                QQmlApplicationEngine *appEngine;
};

#endif // PLUGIN_H
