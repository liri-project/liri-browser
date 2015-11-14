#include <QDebug>
#include <QVariantList>
#include <QJSValueList>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QSignalMapper>
#include "api.h"
#include "urlopener.h"

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


void PluginAPI::fetchURL(QUrl url, QJSValue callback){
    URLOpener *urlopener = new URLOpener();
    urlopener->fetch(url, callback);
}

void PluginAPI::appendSearchSuggestion(QJSValue text, QJSValue icon, QJSValue insert) {
    QObject *rootObject = this->appEngine->rootObjects().first();
    QObject *qmlObject = rootObject->findChild<QObject*>("searchSuggestionsModel");
    QMetaObject::invokeMethod(qmlObject,
        "appendSuggestion",
        Q_ARG(QVariant, text.toVariant()),
        Q_ARG(QVariant, icon.toVariant()),
        Q_ARG(QVariant, insert.toVariant())
    );
}
