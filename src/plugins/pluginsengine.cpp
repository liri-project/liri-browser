#include <QDebug>
#include <QJSEngine>
#include <QDir>
#include "pluginsengine.h"
#include "plugin.h"

PluginsEngine::PluginsEngine(QQmlApplicationEngine*appEngine, QObject *parent) : QObject(parent){
    this->appEngine = appEngine;
}

void PluginsEngine::loadPlugin(QString name, QString path) {
    qDebug() << "Loading plugin" << name << path;
    Plugin *plugin = new Plugin(name, path, this->appEngine);
    this->plugins[name] = plugin;
    plugin->load();
}

void PluginsEngine::loadPlugins(){
    qDebug() << "Loading plugins";
    QDir pluginsDirectory;
    pluginsDirectory.setCurrent("plugins/");
    pluginsDirectory.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
    for (unsigned int i=0; i<pluginsDirectory.count(); i++) {
        QString name = pluginsDirectory.entryList().at(i);
        loadPlugin(name, pluginsDirectory.currentPath().append("/"+name));
    }
}

bool PluginsEngine::trigger(QString event, QJSValueList args){
    qDebug() << "Triggered event" << event;
    for (int i=0; i<this->plugins.values().length(); i++){
       this->plugins.values()[i]->trigger(event, args);
    }
    return true;
}

bool PluginsEngine::trigger(QJSValue event, QJSValueList args){
    return PluginsEngine::trigger(event.toString(), args);
}

bool PluginsEngine::trigger(QJSValue event, QString text){
    return PluginsEngine::trigger(event.toString(), QJSValueList() << QJSValue(text));
}
