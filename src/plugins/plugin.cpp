#include <QJSEngine>
#include <QDebug>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include "plugin.h"
#include "api.h"

Plugin::Plugin(QString name, QString path, QQmlApplicationEngine *appEngine, QObject *parent) : QObject(parent){
    this->name = name;
    this->path = path;
    this->appEngine = appEngine;
}


void Plugin::load() {
    loadManifest();
    bool success = loadEngine();
    if (success)
        loadScript();
}


bool Plugin::loadEngine(){
    qDebug() << "Plugin API version:" << this->apiVersion;
    if (this->apiVersion == "0.1") {
        PluginAPI * apiObject = new PluginAPI(name, this->appEngine);
        QJSValue jsApi = engine.newQObject(apiObject);
        this->api = apiObject;
        engine.globalObject().setProperty("liri", jsApi);
    }
    else {
            qWarning() << "Plugin uses unknown API version. Cancel loading.";
            return false;
    }
    return true;
}


void Plugin::loadScript(){
    QFile scriptFile(path + "/main.js");
    if (!scriptFile.open(QIODevice::ReadOnly))
        qWarning("Couldn't open script file.");
    QTextStream stream(&scriptFile);
    QString contents = stream.readAll();
    scriptFile.close();
    engine.evaluate(contents, path);
}


bool Plugin::loadManifest() {
    QFile manifestFile(path + "/manifest.json");

    if (!manifestFile.open(QIODevice::ReadOnly)) {
        qWarning("Couldn't open manifest file.");
        return false;
    }

    QByteArray jsonData = manifestFile.readAll();
    QJsonDocument manifestDoc (QJsonDocument::fromJson(jsonData));

    auto json = manifestDoc.object();
    // TODO: Validate

    this->title = json["title"].toString();
    this->description = json["description"].toString();
    this->maintainer = json["maintainer"].toString();
    this->version = json["version"].toString();
    this->apiVersion = json["api"].toString();
    this->permissions = json["permissions"].toArray().toVariantList();

    return true;
}


bool Plugin::trigger(QString event, QJSValueList args){
    return this->api->trigger(event, args);
}
