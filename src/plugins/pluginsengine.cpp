#include "pluginsengine.h"

#include <QDebug>
#include <QJSEngine>
#include <QDir>
#include <QStandardPaths>

#include "plugin.h"

PluginsEngine::PluginsEngine(QQmlApplicationEngine *appEngine, Config *config, QObject *parent)
        : QObject(parent), m_appEngine(appEngine), m_config(config)
{
    m_pluginsPath = QStandardPaths::locate(QStandardPaths::GenericDataLocation,
                                           QStringLiteral("liri-browser/plugins"),
                                           QStandardPaths::LocateDirectory);

    if (m_pluginsPath.isEmpty()) {
        qWarning() << "Plugin location not found!";
    }
}

void PluginsEngine::loadPlugin(QString name, QString path)
{
    qDebug() << "Loading plugin" << name << path;
    Plugin *plugin = new Plugin(name, path, m_appEngine, m_config);
    plugins[name] = plugin;
    plugin->load();
}

void PluginsEngine::loadPlugins()
{
    return;

    if (m_pluginsPath.isEmpty())
        return;

    qDebug() << "Loading plugins";

    QDir pluginsDirectory(m_pluginsPath);
    pluginsDirectory.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);

    foreach (QString name, pluginsDirectory.entryList()) {
        loadPlugin(name, m_pluginsPath + "/" + name);
    }
}

bool PluginsEngine::trigger(QString event, QStringList args)
{
    qDebug() << "Triggered event" << event;

    foreach (Plugin *plugin, plugins.values()) {
        plugin->trigger(event, args);
    }

    return true;
}

bool PluginsEngine::trigger(QString event, QString text)
{
    return trigger(event, QStringList() << QString(text));
}
