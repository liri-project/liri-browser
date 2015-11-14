#include <QDebug>
#include <QString>
#include <QVariantList>
#include <QJSValueList>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QSignalMapper>
#include "api.h"
#include "urlopener.h"

QStringList PluginAPI::events = QStringList() << QString("load")
                                              << QString("omnibox.search"); // QJSValue text

QMap<QString, QVariant> PluginAPI::eventFeatures = QMap<QString, QVariant>();


PluginAPI::PluginAPI(QString pluginName, QVariantList features, QQmlApplicationEngine *appEngine, Config *config, QObject *parent) : QObject(parent){
    eventFeatures["load"] = QVariant("common");
    eventFeatures["omnibox.search"] = QVariant("omniplet");

    this->pluginName = pluginName;
    this->appEngine = appEngine;
    this->config = config;
    this->features = features;

    for (int i=0; i<this->events.length(); i++) {
        eventsMap.insert(this->events[i], QList<QJSValue>());

    }
}

bool PluginAPI::hasFeature(QVariant feature) {
    return feature == "common" || this->features.contains(feature);
}

bool PluginAPI::hasPermission(QVariant feature){
    return feature == "common" || ( hasFeature(feature) && this->config->getPluginIsPermitted(this->pluginName, feature.toString()) );
}

const QString PluginAPI::print(QString text) {
    qDebug() << "plugin" << this->pluginName << ":" << text;
    return text;
}

bool PluginAPI::on(QString event, QJSValue callback) {
    if (events.contains(event)) {
        if (this->hasPermission(this->eventFeatures[event])) {
            eventsMap[event].append(callback);
            qDebug() << "plugin" << this->pluginName << "successfully registered callback for event" << event;
            return true;
        }
        else {
            qWarning() << "plugin" << this->pluginName << "tried to register callback for event" << event << "without permission";
            return false;
        }
    }
    else {
        qWarning() << "plugin" << this->pluginName << "tries to set callback for event" << event << "without permission";
        return false;
    }
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


bool PluginAPI::fetchURL(QUrl url, QJSValue callback){
    if (hasPermission("network")) {
        URLOpener *urlopener = new URLOpener();
        urlopener->fetch(url, callback);
        return true;
    }
    else {
        qWarning() << "blocked network access for plugin" << this->pluginName << "because of missing permission";
        return false;
    }
}

bool PluginAPI::appendSearchSuggestion(QJSValue text, QJSValue icon, QJSValue insert) {
    if (hasPermission("omniplet")) {
        QObject *rootObject = this->appEngine->rootObjects().first();
        QObject *qmlObject = rootObject->findChild<QObject*>("searchSuggestionsModel");
        QMetaObject::invokeMethod(qmlObject,
            "appendSuggestion",
            Q_ARG(QVariant, text.toVariant()),
            Q_ARG(QVariant, icon.toVariant()),
            Q_ARG(QVariant, insert.toVariant())
        );
        return true;
    }
    else {
        qWarning() << "blocked omniplet access for plugin" << this->pluginName;
        return false;
    }
}
