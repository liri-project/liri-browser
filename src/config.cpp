#include <QDebug>
#include <QFile>
#include <QByteArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariant>
#include "config.h"

Config::Config(QObject *parent) : QObject(parent){

}


bool Config::load(){
    QFile configFile("config/liri-config.json");

    if (!configFile.open(QIODevice::ReadOnly)) {
        qWarning("Couldn't open config file.");
        return false;
    }

    QByteArray jsonData = configFile.readAll();
    QJsonDocument configDoc (QJsonDocument::fromJson(jsonData));

    auto json = configDoc.object();
    QJsonObject pluginsObject = json["plugins"].toObject();
    this->plugins = pluginsObject.toVariantMap();

    return true;
}


bool Config::save(){
    return false;
}


QVariantMap Config::getPluginPermissions(QString pluginName) {
    return this->plugins[pluginName].toMap()["permissions"].toMap();
}


bool Config::getPluginIsPermitted(QString pluginName, QString feature){
    QVariantMap permissions = this->getPluginPermissions(pluginName);
    if (permissions.keys().contains(feature))
        return permissions[feature].toBool();
    else
        return false;
}
