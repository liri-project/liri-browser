#include <QDebug>
#include <QVariantList>
#include <QJSValueList>
#include "api.h"

QStringList PluginAPI::events = QStringList() << QString("load")
                                              << QString("omnibox.search"); // QJSValue text


PluginAPI::PluginAPI(QString pluginName, QQmlApplicationEngine *appEngine, QObject *parent) : QObject(parent){
    this->pluginName = pluginName;
    this->appEngine = appEngine;

    for (int i=0; i<this->events.length(); i++) {
        eventsMap.insert(this->events[i], QList<QJSValue>());

    }
}

const QString PluginAPI::print(QString text) {
    qDebug() << "plugin" << this->pluginName << ":" << text;
    return text;
}

bool PluginAPI::on(QString event, QJSValue callback) {
    if (events.contains(event)) {
        qDebug() << "plugin" << this->pluginName << "successfully registered callback for event" << event;
        eventsMap[event].append(callback);
    }
    else {
        qWarning() << "plugin" << this->pluginName << "tries to set callback for non-existing event" << event;
    }
    return true;
}

bool PluginAPI::trigger(QString event, QJSValueList args) {
    qDebug() << "Triggering engine event" << event;
    if (!events.contains(event)) {
        qWarning() << "Trying to trigger non-existing event" << event;
        return false;
    }
    QList<QJSValue> events = eventsMap[event];
    for (int i=0; i<events.length(); i++){
        events[i].call(args);
    }
    return true;
}


void PluginAPI::appendSearchSuggestion(QJSValue text) {}
