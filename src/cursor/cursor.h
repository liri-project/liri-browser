#ifndef CURSOR_H
#define CURSOR_H

#include <QObject>
#include <QVariant>
#include <QPoint>
#include <QCursor>

class Cursor : public QObject
{
    Q_OBJECT
public:
    explicit Cursor(QObject *parent = 0);

signals:

public slots:
    QPoint pos(){return QCursor::pos();}
};

#endif // CURSOR_H
