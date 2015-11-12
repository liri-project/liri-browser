#ifndef PLUGINSENGINE_H
#define PLUGINSENGINE_H

#include <QObject>
#include <QJSEngine>
#include <QQmlApplicationEngine>
#include "plugin.h"

class PluginsEngine : public QObject{
                Q_OBJECT
        public:
                explicit PluginsEngine(QQmlApplicationEngine*appEngine, QObject *parent = 0);

                QMap<QString, Plugin *> plugins;

                void loadPlugins();
                void loadPlugin(QString name, QString path);

                bool trigger(QString event, QJSValueList args=QJSValueList());
                Q_INVOKABLE bool trigger(QJSValue event, QJSValueList args=QJSValueList());
                //Q_INVOKABLE void copyText(QString text);

        private:
                QQmlApplicationEngine *appEngine;
                //QClipboard *clip;
};

#endif // PLUGINSENGINE_H
