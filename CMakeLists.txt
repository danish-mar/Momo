cmake_minimum_required(VERSION 3.16)

project(MomoEditor VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5 COMPONENTS Core Gui Quick Qml Widgets REQUIRED)

add_executable(MomoEditor
    src/main.cpp
    src/EditorBackend.cpp
    src/EditorBackend.h
    src/DocumentManager.cpp
    src/DocumentManager.h
    src/FileDialogManager.cpp
    src/FileDialogManager.h
    src/FileSystemModelWrapper.h
    src/SyntaxHighlighter.cpp
    src/SyntaxHighlighter.h
    src/TerminalManager.cpp
    src/TerminalManager.h
    qml.qrc          # <-- AUTORCC compiles this automatically
)

target_link_libraries(MomoEditor
    Qt5::Core
    Qt5::Gui
    Qt5::Quick
    Qt5::Qml
    Qt5::Widgets
)

install(TARGETS MomoEditor
    RUNTIME DESTINATION bin
)