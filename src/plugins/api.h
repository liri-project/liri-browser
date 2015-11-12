#ifndef API_H
#define API_H

#include <QObject>
#include <QList>
#include <QJSValue>
#include <QMap>
#include <QQmlApplicationEngine>

class PluginAPI : public QObject{
        Q_OBJECT
        public:
                explicit PluginAPI(QString pluginName, QQmlApplicationEngine *appEngine, QObject *parent = 0);

                static QStringList events;

                bool trigger(QString event, QJSValueList args);

                /* API invokable functions */

                // Basic console output
                Q_INVOKABLE const QString print(QString text);

                // Register callbacks on events
                Q_INVOKABLE bool on(QString event, QJSValue callback);

                // Search Suggestions
                Q_INVOKABLE void appendSearchSuggestion(QJSValue text);
        private:
                const QString version = QString("0.1");
                QString pluginName;

                QMap<QString, QList<QJSValue>> eventsMap;
                QQmlApplicationEngine * appEngine;
};

#endif // API_H
