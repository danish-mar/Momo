// src/DocumentManager.h
#ifndef DOCUMENTMANAGER_H
#define DOCUMENTMANAGER_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <memory>
#include <vector>
#include <QDir>

// Abstract Base Class demonstrating Abstraction & Polymorphism
class BaseDocument {
public:
    virtual ~BaseDocument() = default;
    virtual QString getContent() const = 0;
    virtual void setContent(const QString& content) = 0;
    virtual QString getFilePath() const = 0;
    virtual void save() = 0;
    virtual bool isModified() const = 0;
    virtual void setModified(bool modified) = 0;
};

// Concrete Class demonstrating Inheritance
class TextDocument : public BaseDocument {
private:
    QString m_content;
    QString m_filePath;
    bool m_isModified = false;

public:
    TextDocument(const QString& filePath);
    QString getContent() const override;
    void setContent(const QString& content) override;
    QString getFilePath() const override;
    void save() override;
    bool isModified() const override;
    void setModified(bool modified) override;
};

class DocumentManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList openTabs READ openTabs NOTIFY openTabsChanged)
    Q_PROPERTY(int currentTabIndex READ currentTabIndex WRITE setCurrentTabIndex NOTIFY currentTabIndexChanged)
    Q_PROPERTY(QString currentContent READ currentContent WRITE setCurrentContent NOTIFY currentContentChanged)

public:
    explicit DocumentManager(QObject *parent = nullptr);
    
    Q_INVOKABLE void openFile(const QString& filePath);
    Q_INVOKABLE void saveFile();
    Q_INVOKABLE void closeTab(int index);
    Q_INVOKABLE void createFile(const QString& dirPath, const QString& fileName);
    Q_INVOKABLE void createFolder(const QString& dirPath, const QString& folderName);

    QString currentContent() const;
    void setCurrentContent(const QString& content);

    QVariantList openTabs() const;
    int currentTabIndex() const;
    void setCurrentTabIndex(int index);

signals:
    void currentContentChanged();
    void fileOpened(const QString& fileName);
    void openTabsChanged();
    void currentTabIndexChanged();

private:
    std::vector<std::shared_ptr<BaseDocument>> m_openDocs;
    int m_currentIndex = -1;
};

#endif // DOCUMENTMANAGER_H
