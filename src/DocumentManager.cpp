// src/DocumentManager.cpp
#include "DocumentManager.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

TextDocument::TextDocument(const QString& filePath) : m_filePath(filePath) {
    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        m_content = in.readAll();
        file.close();
    }
}

QString TextDocument::getContent() const { return m_content; }
void TextDocument::setContent(const QString& content) { m_content = content; }
QString TextDocument::getFilePath() const { return m_filePath; }
bool TextDocument::isModified() const { return m_isModified; }
void TextDocument::setModified(bool modified) { m_isModified = modified; }
void TextDocument::save() {
    QFile file(m_filePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out << m_content;
        file.close();
        m_isModified = false;
    }
}

DocumentManager::DocumentManager(QObject *parent) : QObject(parent) {}

void DocumentManager::openFile(const QString& filePath) {
    QString actualPath = filePath;
    if (actualPath.startsWith("file://")) {
        actualPath = actualPath.mid(7);
    }
    
    qDebug() << "[openFile] actualPath:" << actualPath;
    
    // Check if already open
    for (int i = 0; i < (int)m_openDocs.size(); ++i) {
        if (m_openDocs[i]->getFilePath() == actualPath) {
            qDebug() << "[openFile] already open at index" << i;
            setCurrentTabIndex(i);
            return;
        }
    }
    
    // Open new tab
    auto doc = std::make_shared<TextDocument>(actualPath);
    qDebug() << "[openFile] content length:" << doc->getContent().length();
    qDebug() << "[openFile] first 100 chars:" << doc->getContent().left(100);
    m_openDocs.push_back(doc);
    emit openTabsChanged();
    setCurrentTabIndex(m_openDocs.size() - 1);
    emit fileOpened(actualPath.split('/').last());
}

void DocumentManager::saveFile() {
    if (m_currentIndex >= 0 && m_currentIndex < (int)m_openDocs.size()) {
        auto& doc = m_openDocs[m_currentIndex];
        QString content = doc->getContent();
        QStringList lines = content.split('\n');
        for (int i = 0; i < lines.size(); ++i) {
            while (lines[i].endsWith(' ') || lines[i].endsWith('\t')) {
                lines[i].chop(1);
            }
        }
        QString newContent = lines.join('\n');
        doc->setContent(newContent);
        doc->save();
        emit openTabsChanged();
        if (content != newContent) {
            emit currentContentChanged();
        }
    }
}

QString DocumentManager::currentContent() const {
    qDebug() << "[currentContent] index:" << m_currentIndex << "docs:" << m_openDocs.size();
    if (m_currentIndex >= 0 && m_currentIndex < (int)m_openDocs.size()) {
        QString c = m_openDocs[m_currentIndex]->getContent();
        qDebug() << "[currentContent] length:" << c.length();
        return c;
    }
    qDebug() << "[currentContent] returning empty";
    return "";
}

void DocumentManager::setCurrentContent(const QString& content) {
    qDebug() << "[setCurrentContent] index:" << m_currentIndex << "content length:" << content.length();
    if (m_currentIndex >= 0 && m_currentIndex < (int)m_openDocs.size()) {
        if (m_openDocs[m_currentIndex]->getContent() != content) {
            m_openDocs[m_currentIndex]->setContent(content);
            m_openDocs[m_currentIndex]->setModified(true);
            emit currentContentChanged();
            emit openTabsChanged();
        }
    }
}

QVariantList DocumentManager::openTabs() const {
    QVariantList list;
    for (const auto& doc : m_openDocs) {
        QVariantMap map;
        map["fileName"] = doc->getFilePath().split('/').last();
        map["filePath"] = doc->getFilePath();
        map["isModified"] = doc->isModified();
        list.append(map);
    }
    return list;
}

void DocumentManager::createFile(const QString& dirPath, const QString& fileName) {
    QDir dir(dirPath);
    if (!dir.exists()) dir.mkpath(".");
    QFile file(dir.filePath(fileName));
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        file.close();
    }
}

void DocumentManager::createFolder(const QString& dirPath, const QString& folderName) {
    QDir dir(dirPath);
    if (!dir.exists()) dir.mkpath(".");
    dir.mkdir(folderName);
}

int DocumentManager::currentTabIndex() const {
    return m_currentIndex;
}

void DocumentManager::setCurrentTabIndex(int index) {
    if (index >= -1 && index < (int)m_openDocs.size() && m_currentIndex != index) {
        m_currentIndex = index;
        emit currentTabIndexChanged();
        emit currentContentChanged();
    }
}

void DocumentManager::closeTab(int index) {
    if (index >= 0 && index < (int)m_openDocs.size()) {
        m_openDocs.erase(m_openDocs.begin() + index);
        emit openTabsChanged();
        
        if (m_openDocs.empty()) {
            m_currentIndex = -1;
            emit currentTabIndexChanged();
            emit currentContentChanged();
        } else if (m_currentIndex == index) {
            // We closed the active tab, another tab falls into its place or index-1 happens
            m_currentIndex = std::max(0, index - 1);
            emit currentTabIndexChanged();
            emit currentContentChanged();
        } else if (m_currentIndex > index) {
            // We closed a tab to the left of the active tab. The active tab shifted left.
            m_currentIndex--;
            emit currentTabIndexChanged();
            emit currentContentChanged(); 
        }
    }
}
