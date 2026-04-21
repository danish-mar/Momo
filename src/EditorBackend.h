// src/EditorBackend.h
#ifndef EDITORBACKEND_H
#define EDITORBACKEND_H

#include <QObject>
#include "DocumentManager.h"
#include "TerminalManager.h"

class EditorBackend : public QObject {
    Q_OBJECT
    // Composition: EditorBackend uses (contains) a DocumentManager
    Q_PROPERTY(DocumentManager* docManager READ docManager CONSTANT)
    Q_PROPERTY(TerminalManager* terminal READ terminal CONSTANT)

public:
    explicit EditorBackend(QObject *parent = nullptr);
    DocumentManager* docManager() { return &m_docManager; }
    TerminalManager* terminal() { return &m_terminal; }

private:
    DocumentManager m_docManager;
    TerminalManager m_terminal;
};

#endif // EDITORBACKEND_H
