// src/EditorBackend.cpp
#include "EditorBackend.h"

EditorBackend::EditorBackend(QObject *parent)
    : QObject(parent), m_docManager(this) {}
