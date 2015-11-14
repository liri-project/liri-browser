#ifndef API_H
#define API_H

#include <QObject>
#include <QList>
#include <QJSValue>
#include <QMap>
#include <QVariantList>
#include <QQmlApplicationEngine>
#include <QJsonArray>
#include "../config.h"

class PluginAPI : public QObject{
        Q_OBJECT
        public:
                explicit PluginAPI(QString pluginName, QVariantList features, QQmlApplicationEngine *appEngine, Config *config, QObject *parent = 0);

                static QStringList events;
                static QMap<QString, QVariant> eventFeatures;

                bool trigger(QString event, QJSValueList args);

                /* API invokable functions */

                // Basic console output
                Q_INVOKABLE const QString print(QString text);

                // Register callbacks on events
                Q_INVOKABLE bool on(QString event, QJSValue callback);

                // Network functionality
                Q_INVOKABLE bool fetchURL(QUrl url, QJSValue callback);

                // Search Suggestions
                Q_INVOKABLE bool appendSearchSuggestion(QJSValue text, QJSValue icon, QJSValue insert=QJSValue("end"));

                // Browser history
                Q_INVOKABLE QVariant getHistory();

                // Browser bookmarks
                Q_INVOKABLE QVariant getBookmarks();
        private:
                const QString version = QString("0.1");
                QString pluginName;
                QVariantList features;

                QMap<QString, QList<QJSValue>> eventsMap;
                QQmlApplicationEngine *appEngine;
                Config *config;

                bool hasFeature(QVariant feature);
                bool hasPermission(QVariant feature);
};

#endif // API_H
