#include "clipboardadapter.h"

#include <QApplication>

ClipBoardAdapter::ClipBoardAdapter(QObject *parent) : QObject(parent){
	clip = QApplication::clipboard();
}

void ClipBoardAdapter::copyText(QString text){
	clip->setText(text, QClipboard::Clipboard);
	clip->setText(text, QClipboard::Selection);
}
