#!/usr/bin/env python3
import os

# Updated to match project root structure
ICON_DIR = os.path.join("vscode-icons", "icons")
OUT_FILE = "qml.qrc"

def main():
    svgs = []
    if os.path.isdir(ICON_DIR):
        for f in sorted(os.listdir(ICON_DIR)):
            if f.endswith(".svg"):
                svgs.append(f)
    else:
        print(f"WARNING: icon dir not found: {ICON_DIR}")

    lines = []
    lines.append('<RCC>')

    # QML source files
    lines.append('    <qresource prefix="/">')
    qml_dir = "qml"
    if os.path.isdir(qml_dir):
        for f in sorted(os.listdir(qml_dir)):
            if f.endswith(".qml"):
                lines.append(f'        <file>qml/{f}</file>')
    lines.append('    </qresource>')

    # Icons — alias them so they are accessible via qrc:/qml/vscode-icons/icons/
    lines.append('    <qresource prefix="/qml">')
    for svg in svgs:
        # Physical path: vscode-icons/icons/name.svg
        phys = f"vscode-icons/icons/{svg}"
        # Logical path in QRC (alias): vscode-icons/icons/name.svg
        # Accessible as: qrc:/qml/vscode-icons/icons/name.svg
        alias = f"vscode-icons/icons/{svg}"
        lines.append(f'        <file alias="{alias}">{phys}</file>')
    lines.append('    </qresource>')

    lines.append('</RCC>')

    content = "\n".join(lines) + "\n"
    with open(OUT_FILE, "w") as f:
        f.write(content)

    print(f"Written {OUT_FILE}  ({len(svgs)} icons included)")

if __name__ == "__main__":
    main()