#include <QJSValueList>
#include "urlopener.h"

void URLOpener::replyFinished(QNetworkReply *reply)
{
    this->callback.call(QJSValueList() << QJSValue(QString(reply->readAll())));
}

void URLOpener::fetch(QUrl url, QJSValue callback)
{
    this->callback = callback;
    manager = new QNetworkAccessManager(this);
    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyFinished(QNetworkReply*)));
    manager->get(QNetworkRequest(url));
}
