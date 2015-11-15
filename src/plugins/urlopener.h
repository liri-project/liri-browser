#ifndef URLOPENER_H
#define URLOPENER_H

#include <QObject>

#include <QtCore>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJSValue>

class URLOpener : public QObject
{
    Q_OBJECT
    QNetworkAccessManager *manager;

    private slots:
          void replyFinished(QNetworkReply *);
    public:
          void fetch(QUrl url, QJSValue callback);
    private:
          QJSValue callback;
};


#endif // URLOPENER_H
