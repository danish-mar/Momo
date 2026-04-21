// src/main.cpp
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include "EditorBackend.h"
#include "FileDialogManager.h"
#include "FileSystemModelWrapper.h"
#include "SyntaxHighlighter.h"

int main(int argc, char *argv[]) {
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QApplication app(argc, argv);

    EditorBackend backend;
    FileDialogManager dialogManager;

    QQmlApplicationEngine engine;
    
    // Register types for QML
    qmlRegisterType<DocumentManager>("Momo.Core", 1, 0, "DocumentManager");
    qmlRegisterType<SyntaxHighlighter>("Momo.Core", 1, 0, "SyntaxHighlighter");
    
    // Set backend and dialogs
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.rootContext()->setContextProperty("fileDialog", &dialogManager);

    FileSystemModelWrapper *fsModel = new FileSystemModelWrapper(&app);
    fsModel->setRootPath(QDir::homePath());
    engine.rootContext()->setContextProperty("fsModel", fsModel);

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
