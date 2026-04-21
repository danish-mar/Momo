// src/SyntaxHighlighter.cpp
#include "SyntaxHighlighter.h"

SyntaxHighlighter::SyntaxHighlighter(QObject *parent)
    : QSyntaxHighlighter(parent), m_textDocument(nullptr),
      m_fileExtension("cpp") {
  updateRules();
}

QString SyntaxHighlighter::fileExtension() const { return m_fileExtension; }

void SyntaxHighlighter::setFileExtension(const QString &extension) {
  if (m_fileExtension == extension)
    return;
  m_fileExtension = extension;
  updateRules();
  rehighlight();
  emit fileExtensionChanged();
}

void SyntaxHighlighter::updateRules() {
  highlightingRules.clear();
  HighlightingRule rule;
  QTextCharFormat keywordFormat;
  QTextCharFormat classFormat;
  QTextCharFormat singleLineCommentFormat;
  QTextCharFormat quotationFormat;
  QTextCharFormat functionFormat;

  keywordFormat.setForeground(QColor("#cba6f7")); // Catppuccin Mauve
  keywordFormat.setFontWeight(QFont::Bold);

  QStringList keywordPatterns;

  QString ext = m_fileExtension.toLower();
  if (ext == "cpp" || ext == "cxx" || ext == "cc" || ext == "c" || ext == "h" ||
      ext == "hpp") {
    keywordPatterns =
        QStringList({"\\bchar\\b",     "\\bclass\\b",     "\\bconst\\b",
                     "\\bdouble\\b",   "\\benum\\b",      "\\bexplicit\\b",
                     "\\bfriend\\b",   "\\binline\\b",    "\\bint\\b",
                     "\\blong\\b",     "\\bnamespace\\b", "\\boperator\\b",
                     "\\bprivate\\b",  "\\bprotected\\b", "\\bpublic\\b",
                     "\\bshort\\b",    "\\bsignals\\b",   "\\bsigned\\b",
                     "\\bslots\\b",    "\\bstatic\\b",    "\\bstruct\\b",
                     "\\btemplate\\b", "\\btypedef\\b",   "\\btypename\\b",
                     "\\bunion\\b",    "\\bunsigned\\b",  "\\bvirtual\\b",
                     "\\bvoid\\b",     "\\bvolatile\\b",  "\\bbool\\b",
                     "\\bif\\b",       "\\belse\\b",      "\\bfor\\b",
                     "\\bwhile\\b",    "\\breturn\\b",    "\\bnew\\b",
                     "\\bdelete\\b",   "\\bauto\\b",      "\\b#include\\b",
                     "\\b#ifndef\\b",  "\\b#define\\b",   "\\b#endif\\b"});
  } else if (ext == "py") {
    keywordPatterns = QStringList(
        {"\\band\\b",     "\\bas\\b",       "\\bassert\\b",   "\\bbreak\\b",
         "\\bclass\\b",   "\\bcontinue\\b", "\\bdef\\b",      "\\bdel\\b",
         "\\belif\\b",    "\\belse\\b",     "\\bexcept\\b",   "\\bFalse\\b",
         "\\bfinally\\b", "\\bfor\\b",      "\\bfrom\\b",     "\\bglobal\\b",
         "\\bif\\b",      "\\bimport\\b",   "\\bin\\b",       "\\bis\\b",
         "\\blambda\\b",  "\\bNone\\b",     "\\bnonlocal\\b", "\\bnot\\b",
         "\\bor\\b",      "\\bpass\\b",     "\\braise\\b",    "\\breturn\\b",
         "\\bTrue\\b",    "\\btry\\b",      "\\bwhile\\b",    "\\bwith\\b",
         "\\byield\\b"});
  } else if (ext == "js" || ext == "ts" || ext == "jsx" || ext == "tsx") {
    keywordPatterns =
        QStringList({"\\bbreak\\b",    "\\bcase\\b",       "\\bcatch\\b",
                     "\\bclass\\b",    "\\bconst\\b",      "\\bcontinue\\b",
                     "\\bdebugger\\b", "\\bdefault\\b",    "\\bdelete\\b",
                     "\\bdo\\b",       "\\belse\\b",       "\\bexport\\b",
                     "\\bextends\\b",  "\\bfinally\\b",    "\\bfor\\b",
                     "\\bfunction\\b", "\\bif\\b",         "\\bimport\\b",
                     "\\bin\\b",       "\\binstanceof\\b", "\\bnew\\b",
                     "\\breturn\\b",   "\\bsuper\\b",      "\\bswitch\\b",
                     "\\bthis\\b",     "\\bthrow\\b",      "\\btry\\b",
                     "\\btypeof\\b",   "\\bvar\\b",        "\\bvoid\\b",
                     "\\bwhile\\b",    "\\bwith\\b",       "\\byield\\b",
                     "\\blet\\b",      "\\bawait\\b",      "\\basync\\b"});
  } else if (ext == "qml") {
    keywordPatterns = QStringList(
        {"\\bimport\\b", "\\bproperty\\b", "\\breadonly\\b", "\\bsignal\\b",
         "\\bOn\\b", "\\bfunction\\b", "\\bvar\\b", "\\blet\\b", "\\bconst\\b",
         "\\btrue\\b", "\\bfalse\\b", "\\bnull\\b", "\\bundefined\\b"});
  } else {
    // Default generic keywords
    keywordPatterns =
        QStringList({"\\bif\\b", "\\belse\\b", "\\bfor\\b", "\\bwhile\\b",
                     "\\breturn\\b", "\\bclass\\b", "\\bfunction\\b"});
  }

  for (const QString &pattern : keywordPatterns) {
    rule.pattern = QRegularExpression(pattern);
    rule.format = keywordFormat;
    highlightingRules.append(rule);
  }

  classFormat.setFontWeight(QFont::Bold);
  classFormat.setForeground(QColor("#f38ba8")); // Catppuccin Red
  rule.pattern = QRegularExpression(QStringLiteral("\\b[A-Z][A-Za-z0-9_]+\\b"));
  rule.format = classFormat;
  highlightingRules.append(rule);

  singleLineCommentFormat.setForeground(QColor("#6c7086")); // Overlay0
  if (ext == "py") {
    rule.pattern = QRegularExpression(QStringLiteral("#[^\n]*"));
  } else if (ext == "cmake" || ext == "sh") {
    rule.pattern = QRegularExpression(QStringLiteral("#[^\n]*"));
  } else {
    rule.pattern = QRegularExpression(
        QStringLiteral("//[^\n]*")); // C, C++, JS, TS, QML, etc.
  }
  rule.format = singleLineCommentFormat;
  highlightingRules.append(rule);

  quotationFormat.setForeground(QColor("#a6e3a1")); // Green
  rule.pattern = QRegularExpression(QStringLiteral("\".*?\"|\'.*?\'|`.*?`"));
  rule.format = quotationFormat;
  highlightingRules.append(rule);

  functionFormat.setFontItalic(true);
  functionFormat.setForeground(QColor("#89b4fa")); // Blue
  rule.pattern = QRegularExpression(QStringLiteral("\\b[A-Za-z0-9_]+(?=\\()"));
  rule.format = functionFormat;
  highlightingRules.append(rule);
}

QQuickTextDocument *SyntaxHighlighter::textDocument() const {
  return m_textDocument;
}

void SyntaxHighlighter::setTextDocument(QQuickTextDocument *textDocument) {
  if (textDocument == m_textDocument)
    return;

  m_textDocument = textDocument;
  if (m_textDocument) {
    setDocument(m_textDocument->textDocument());
  } else {
    setDocument(nullptr);
  }
  emit textDocumentChanged();
}

void SyntaxHighlighter::highlightBlock(const QString &text) {
  for (const HighlightingRule &rule : qAsConst(highlightingRules)) {
    QRegularExpressionMatchIterator matchIterator =
        rule.pattern.globalMatch(text);
    while (matchIterator.hasNext()) {
      QRegularExpressionMatch match = matchIterator.next();
      setFormat(match.capturedStart(), match.capturedLength(), rule.format);
    }
  }
}
