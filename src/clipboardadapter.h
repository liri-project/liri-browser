#ifndef CLIPBOARDADAPTER_H
#define CLIPBOARDADAPTER_H

#include <QObject>
#include <QClipboard>

class ClipBoardAdapter : public QObject{
		Q_OBJECT
	public:
		explicit ClipBoardAdapter(QObject *parent = 0);
		Q_INVOKABLE void copyText(QString text);

	private:
		QClipboard *clip;
};

#endif // CLIPBOARDADAPTER_H
