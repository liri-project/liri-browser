#include "config.h"

#include <QDebug>
#include <QFile>
#include <QByteArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariant>
#include <QStandardPaths>

Config::Config(QObject *parent) : QObject(parent)
{
    // Nothing needed here
}

bool Config::load()
{
    QStringList configPaths = QStandardPaths::locateAll(QStandardPaths::ConfigLocation,
                                                        QStringLiteral("liri-config.json"));

    if (configPaths.isEmpty()) {
        qWarning() << "Configuration not found!";
        return false;
    }

    foreach (QString path, configPaths) {
        QFile configFile(path);

        if (!configFile.open(QIODevice::ReadOnly)) {
            qWarning() << "Couldn't open config file:" << path;
        }

        QByteArray jsonData = configFile.readAll();
        QJsonDocument configDoc(QJsonDocument::fromJson(jsonData));

        auto json = configDoc.object();
        QJsonObject pluginsObject = json["plugins"].toObject();
        this->plugins = pluginsObject.toVariantMap();

        return true;
    }

    return false;
}

bool Config::save()
{
    return false;
}

QVariantMap Config::getPluginPermissions(QString pluginName)
{
    return this->plugins[pluginName].toMap()["permissions"].toMap();
}

bool Config::getPluginIsPermitted(QString pluginName, QString feature)
{
    QVariantMap permissions = this->getPluginPermissions(pluginName);
    if (permissions.keys().contains(feature))
        return permissions[feature].toBool();
    else
        return false;
}
