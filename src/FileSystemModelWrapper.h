// src/FileSystemModelWrapper.h
#ifndef FILESYSTEMMODELWRAPPER_H
#define FILESYSTEMMODELWRAPPER_H

#include <QFileSystemModel>

class FileSystemModelWrapper : public QFileSystemModel {
    Q_OBJECT
public:
    explicit FileSystemModelWrapper(QObject *parent = nullptr) : QFileSystemModel(parent) {
        setFilter(QDir::NoDotAndDotDot | QDir::AllDirs | QDir::Files);
    }

    Q_INVOKABLE QString getFilePath(const QModelIndex &index) const {
        return filePath(index);
    }
    
    Q_INVOKABLE bool isFolder(const QModelIndex &index) const {
        return isDir(index);
    }
};

#endif // FILESYSTEMMODELWRAPPER_H
