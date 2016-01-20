#ifndef PLUGINSENGINE_H
#define PLUGINSENGINE_H

#include <QObject>
#include <QJSEngine>
#include <QQmlApplicationEngine>
#include "plugin.h"
#include "../config.h"

class PluginsEngine : public QObject
{
    Q_OBJECT

public:
    explicit PluginsEngine(QQmlApplicationEngine *appEngine, Config *config, QObject *parent = 0);

    QMap<QString, Plugin *> plugins;

    void loadPlugins();
    void loadPlugin(QString name, QString path);

public slots:
    bool trigger(QString event, QStringList args = QStringList());
    bool trigger(QString event, QString text);

private:
    QJSValueList newArgsList(QJSValueList args);

    QQmlApplicationEngine *m_appEngine;
    Config *m_config;
    QString m_pluginsPath;
};

#endif // PLUGINSENGINE_H
