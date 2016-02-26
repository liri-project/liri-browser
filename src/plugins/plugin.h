#ifndef PLUGIN_H
#define PLUGIN_H

#include <QObject>
#include <QJSEngine>
#include "api.h"
#include <QQmlApplicationEngine>
#include "../config.h"

class Plugin : public QObject
{
    Q_OBJECT
public:
    explicit Plugin(QString name, QString path, QQmlApplicationEngine *appEngine, Config *config,
                    QObject *parent = 0);

public slots:
    void load();
    bool trigger(QString event, QStringList args = QStringList());

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
    QVariantList features;

    PluginAPI *api;

    QQmlApplicationEngine *appEngine;
    Config *config;
};

#endif // PLUGIN_H
