#ifndef PLUGINSENGINE_H
#define PLUGINSENGINE_H

#include <QObject>
#include <QJSEngine>
#include <QQmlApplicationEngine>
#include "plugin.h"
#include "../config.h"

class PluginsEngine : public QObject{
                Q_OBJECT
        public:
                explicit PluginsEngine(QQmlApplicationEngine *appEngine, Config *config, QObject *parent = 0);

                QMap<QString, Plugin *> plugins;

                void loadPlugins();
                void loadPlugin(QString name, QString path);

                bool trigger(QString event, QJSValueList args=QJSValueList());
                Q_INVOKABLE bool trigger(QJSValue event, QJSValueList args=QJSValueList());
                Q_INVOKABLE bool trigger(QJSValue event, QString text);

        private:
                QJSValueList newArgsList(QJSValueList args);

                QQmlApplicationEngine *appEngine;
                Config *config;
};

#endif // PLUGINSENGINE_H
