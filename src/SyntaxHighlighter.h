// src/SyntaxHighlighter.h
#ifndef SYNTAXHIGHLIGHTER_H
#define SYNTAXHIGHLIGHTER_H

#include <QObject>
#include <QSyntaxHighlighter>
#include <QTextCharFormat>
#include <QRegularExpression>
#include <QQuickTextDocument>

class SyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT
    Q_PROPERTY(QQuickTextDocument* textDocument READ textDocument WRITE setTextDocument NOTIFY textDocumentChanged)
    Q_PROPERTY(QString fileExtension READ fileExtension WRITE setFileExtension NOTIFY fileExtensionChanged)

public:
    explicit SyntaxHighlighter(QObject *parent = nullptr);

    QQuickTextDocument* textDocument() const;
    void setTextDocument(QQuickTextDocument *textDocument);

    QString fileExtension() const;
    void setFileExtension(const QString &extension);

signals:
    void textDocumentChanged();
    void fileExtensionChanged();

protected:
    void highlightBlock(const QString &text) override;

private:
    struct HighlightingRule {
        QRegularExpression pattern;
        QTextCharFormat format;
    };
    QVector<HighlightingRule> highlightingRules;
    void updateRules();

    QQuickTextDocument *m_textDocument;
    QString m_fileExtension;
};

#endif // SYNTAXHIGHLIGHTER_H
