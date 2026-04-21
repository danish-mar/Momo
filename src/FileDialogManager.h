// src/FileDialogManager.h
#ifndef FILEDIALOGMANAGER_H
#define FILEDIALOGMANAGER_H

#include <QObject>
#include <QString>
#include <QFileDialog>
#include <QUrl>

class FileDialogManager : public QObject {
    Q_OBJECT

public:
    explicit FileDialogManager(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE QString getOpenFileName() {
        QString fileName = QFileDialog::getOpenFileName(nullptr, 
            tr("Open File"), "", tr("Text Files (*.txt);;C++ Files (*.cpp *.h);;All Files (*)"));
        return fileName;
    }

    Q_INVOKABLE QString getSaveFileName() {
        QString fileName = QFileDialog::getSaveFileName(nullptr,
            tr("Save File"), "", tr("Text Files (*.txt);;C++ Files (*.cpp *.h);;All Files (*)"));
        return fileName;
    }
    
    Q_INVOKABLE QString getOpenDirectory() {
        QString dir = QFileDialog::getExistingDirectory(nullptr, tr("Open Folder"),
                                                    "", QFileDialog::ShowDirsOnly | QFileDialog::DontResolveSymlinks);
        return dir;
    }
};

#endif // FILEDIALOGMANAGER_H
