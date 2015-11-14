#ifndef CONFIG_H
#define CONFIG_H

#include <QObject>
#include <QVariantMap>

class Config : public QObject{
                Q_OBJECT
        public:
                bool load();
                bool save();

                QVariantMap getPluginPermissions(QString pluginName);
                bool getPluginIsPermitted(QString pluginName, QString feature);

                explicit Config(QObject *parent = 0);
        private:
                QVariantMap plugins;

};

#endif // CONFIG_H
