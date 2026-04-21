# Momo Editor

A premium C++ and QML based code editor demonstrating core OOP principles.

## Features
- **Abstraction & Polymorphism**: Uses a `BaseDocument` interface to handle different file types (currently implemented for plain text).
- **Inheritance**: `TextDocument` inherits from `BaseDocument`.
- **Encapsulation**: `DocumentManager` and `EditorBackend` encapsulate file handling and state management.
- **Composition**: `EditorBackend` composes `DocumentManager`.
- **Modern UI**: QML-based interface with a dark theme and JetBrains Mono typography.

## Prerequisites
- Qt 5.15+ (Modules: Core, Gui, Qml, Quick)
- CMake 3.16+
- A C++17 compatible compiler

## Building
1. Create a build directory:
   ```bash
   mkdir build && cd build
   ```
2. Run CMake:
   ```bash
   cmake ..
   ```
3. Build the project:
   ```bash
   make
   ```
4. Run the editor:
   ```bash
   ./MomoEditor
   ```
>>>>>>> 42d15c6 (initial commit)
