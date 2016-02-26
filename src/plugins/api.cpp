#include "api.h"

#include <QDebug>
#include <QString>
#include <QVariantList>
#include <QJSValueList>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QSignalMapper>
#include <QtQml>
#include <QJsonArray>

#include "urlopener.h"

#define VERIFY_PERMISSION(permission)                                                              \
    if (!hasPermission(#permission)) {                                                             \
        qWarning() << "blocked" << #permission << "access for plugin" << m_pluginName;             \
        return false;                                                                              \
    }

QStringList PluginAPI::events = QStringList() << "load"
                                              << "omnibox.search"; // QJSValue text

QMap<QString, QString> PluginAPI::eventFeatures = QMap<QString, QString>();

PluginAPI::PluginAPI(QString pluginName, QVariantList features, QQmlApplicationEngine *appEngine,
                     Config *config, QObject *parent)
        : QObject(parent), m_pluginName(pluginName), m_features(features), m_appEngine(appEngine),
          m_config(config)
{
    // TODO: Can we do this once instead of per constructor call? (eventFeatures is static)
    eventFeatures["load"] = "common";
    eventFeatures["omnibox.search"] = "omniplet";

    foreach (QString event, events) {
        m_eventListeners[event] = QList<QJSValue>();
    }
}

bool PluginAPI::hasFeature(QString feature)
{
    return feature == "common" || m_features.contains(feature);
}

bool PluginAPI::hasPermission(QString feature)
{
    return feature == "common" ||
           (hasFeature(feature) && m_config->getPluginIsPermitted(m_pluginName, feature));
}

const QString PluginAPI::print(QString text)
{
    qDebug() << "plugin" << m_pluginName + ":" << text;
    return text;
}

bool PluginAPI::on(QString event, QJSValue callback)
{
    if (!events.contains(event)) {
        qWarning() << "plugin" << m_pluginName << "tried to register callback for event" << event
                   << "without permission";
        return false;
    }

    if (!hasPermission(eventFeatures[event])) {
        qWarning() << "plugin" << m_pluginName << "tried to register callback for event" << event
                   << "without permission";
        return false;
    }

    m_eventListeners[event] << callback;
    qDebug() << "plugin" << m_pluginName << "successfully registered callback for event" << event;
    return true;
}

bool PluginAPI::trigger(QString event, QStringList args)
{
    if (!events.contains(event)) {
        qWarning() << "Trying to trigger non-existing event" << event;
        return false;
    }

    QJSValueList list;
    foreach (QString arg, args) {
        list << QJSValue(arg);
    }

    QList<QJSValue> eventListeners = m_eventListeners[event];

    foreach (QJSValue listener, eventListeners) {
        listener.call(list);
    }

    return true;
}

bool PluginAPI::fetchURL(QUrl url, QJSValue callback)
{
    VERIFY_PERMISSION(network)

    URLOpener *urlopener = new URLOpener();
    urlopener->fetch(url, callback);
    return true;
}

bool PluginAPI::appendSearchSuggestion(QJSValue text, QJSValue icon, QJSValue insert)
{
    VERIFY_PERMISSION(omniplet)

    QObject *rootObject = m_appEngine->rootObjects().first();
    QObject *qmlObject = rootObject->findChild<QObject *>("searchSuggestionsModel");
    QMetaObject::invokeMethod(qmlObject, "appendSuggestion", Q_ARG(QVariant, text.toVariant()),
                              Q_ARG(QVariant, icon.toVariant()),
                              Q_ARG(QVariant, insert.toVariant()));
    return true;
}

QVariant PluginAPI::getHistory()
{
    VERIFY_PERMISSION(history)

    QVariant retValue;
    QMetaObject::invokeMethod(m_appEngine->rootObjects().first(), "getHistoryArray",
                              Q_RETURN_ARG(QVariant, retValue));
    return retValue.toList();
}

QVariant PluginAPI::getBookmarks()
{
    VERIFY_PERMISSION(bookmarks)

    QVariant retValue;
    QMetaObject::invokeMethod(m_appEngine->rootObjects().first(), "getBookmarksArray",
                              Q_RETURN_ARG(QVariant, retValue));
    return retValue.toList();
}
