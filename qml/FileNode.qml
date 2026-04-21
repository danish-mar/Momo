// qml/FileNode.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15

Column {
    id: rootNode

    property string folderPath:     ""
    property int    depth:          0
    property string accentColor:    "#cba6f7"
    property string textColor:      "#cdd6f4"
    property string mutedColor:     "#6c7086"
    property string hoverColor:     "#313244"
    property string selectionColor: "#45475a"

    signal requestCreation(string path, bool isFolder)

    // ── Must match the prefix in your qml.qrc exactly ─────────────
    // If your qrc has:  <file>vscode-icons/icons/file_type_cpp.svg</file>
    // and prefix="/qml" then the runtime path is:
    //   qrc:/qml/vscode-icons/icons/file_type_cpp.svg
    readonly property string iconBase: "qrc:/qml/vscode-icons/icons/"

    width: parent ? parent.width : 0

    // ── Map file extension → vscode-icons stem ────────────────────
    function iconForSuffix(suffix, isDir, isExpanded) {
        if (isDir) {
            return isExpanded
                ? rootNode.iconBase + "default_folder_opened.svg"
                : rootNode.iconBase + "default_folder.svg"
        }
        var map = {
            "cpp":   "file_type_cpp",
            "cxx":   "file_type_cpp",
            "cc":    "file_type_cpp",
            "c":     "file_type_c",
            "h":     "file_type_cheader",
            "hpp":   "file_type_cheader",
            "qml":   "file_type_qml",
            "py":    "file_type_python",
            "js":    "file_type_js",
            "ts":    "file_type_typescript",
            "jsx":   "file_type_reactjs",
            "tsx":   "file_type_reactts",
            "json":  "file_type_json",
            "md":    "file_type_markdown",
            "txt":   "file_type_text",
            "sh":    "file_type_shell",
            "bash":  "file_type_shell",
            "zsh":   "file_type_shell",
            "cmake": "file_type_cmake",
            "xml":   "file_type_xml",
            "html":  "file_type_html",
            "css":   "file_type_css",
            "svg":   "file_type_svg",
            "png":   "file_type_image",
            "jpg":   "file_type_image",
            "gif":   "file_type_image",
            "rs":    "file_type_rust",
            "go":    "file_type_go",
            "toml":  "file_type_toml",
            "yaml":  "file_type_yaml",
            "yml":   "file_type_yaml",
            "lock":  "file_type_lock",
            "log":   "file_type_log",
            "env":   "file_type_dotenv",
            "git":   "file_type_git"
        }
        var name = map[suffix.toLowerCase()]
        return name ? (rootNode.iconBase + name + ".svg") : ""
    }

    FolderListModel {
        id: dirModel
        folder:           rootNode.folderPath !== "" ? ("file://" + rootNode.folderPath) : ""
        showDirsFirst:    true
        showDotAndDotDot: false
        showHidden:       false
    }

    Repeater {
        model: dirModel

        delegate: Column {
            id: entry
            width: rootNode.width

            property string entryName:   fileName
            property string entryPath:   filePath
            property url    entryUrl:    fileUrl
            property bool   entryIsDir:  fileIsDir
            property string entrySuffix: fileSuffix
            property bool   expanded:    false

            // ── Row ───────────────────────────────────────────────
            Rectangle {
                id: row
                width:  entry.width
                height: 24
                color:  rowMouse.containsMouse ? rootNode.hoverColor : "transparent"
                Behavior on color { ColorAnimation { duration: 80 } }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 6 + (rootNode.depth * 16)
                    spacing: 0

                    // Chevron — dirs only
                    Item {
                        width:   16
                        height:  24
                        visible: entry.entryIsDir

                        Text {
                            anchors.centerIn: parent
                            text:  "\u203A"
                            color: rootNode.mutedColor
                            font.pixelSize: 13
                            font.bold: true

                            transform: Rotation {
                                origin.x: 4; origin.y: 6
                                angle: entry.expanded ? 90 : 0
                                Behavior on angle {
                                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                    }

                    // Spacer for files (no chevron)
                    Item {
                        width:   16
                        height:  24
                        visible: !entry.entryIsDir
                    }

                    // ── Icon ──────────────────────────────────────
                    Item {
                        width:  18
                        height: 24

                        // SVG icon — shown when loaded successfully
                        Image {
                            id: fileIcon
                            anchors.centerIn: parent
                            width:  14; height: 14
                            sourceSize: Qt.size(14, 14)
                            // Build the source; empty string → Image.Null (not Error)
                            // so we only go to "" when we have no mapping
                            source: rootNode.iconForSuffix(
                                        entry.entrySuffix,
                                        entry.entryIsDir,
                                        entry.expanded)
                            smooth: true
                            // Show SVG only when it actually loaded
                            visible: (status === Image.Ready)

                            onStatusChanged: {
                                // Uncomment to debug icon resolution:
                                // if (status === Image.Error)
                                //     console.log("Icon missing:", source)
                            }
                        }

                        // Unicode fallback — shown when SVG not available
                        Text {
                            anchors.centerIn: parent
                            visible: (fileIcon.status !== Image.Ready)
                            text: entry.entryIsDir
                                  ? (entry.expanded ? "📂" : "📁")
                                  : "📄"
                            font.pixelSize: 11
                            color: rootNode.mutedColor
                        }
                    }

                    Item { width: 5; height: 1 }

                    // Filename
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text:  entry.entryName
                        color: rowMouse.containsMouse
                               ? (entry.entryIsDir ? "#89b4fa" : rootNode.accentColor)
                               : rootNode.textColor
                        font.pixelSize: 13
                        font.family:    "Sans Serif"
                        elide:          Text.ElideRight
                        maximumLineCount: 1
                        Behavior on color { ColorAnimation { duration: 80 } }
                    }
                }

                MouseArea {
                    id:           rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            fileNodeMenu.x = mouse.x
                            fileNodeMenu.y = mouse.y
                            fileNodeMenu.open()
                        } else {
                            if (entry.entryIsDir) {
                                entry.expanded = !entry.expanded
                                if (entry.expanded) {
                                    childLoader.setSource("qrc:/qml/FileNode.qml", {
                                        "folderPath":     entry.entryPath,
                                        "depth":          rootNode.depth + 1,
                                        "accentColor":    rootNode.accentColor,
                                        "textColor":      rootNode.textColor,
                                        "mutedColor":     rootNode.mutedColor,
                                        "hoverColor":     rootNode.hoverColor,
                                        "selectionColor": rootNode.selectionColor
                                    })
                                    childLoader.item.requestCreation.connect(rootNode.requestCreation)
                                } else {
                                    childLoader.source = ""
                                }
                            } else {
                                var path = entry.entryUrl.toString().replace("file://", "")
                                backend.docManager.openFile(path)
                            }
                        }
                    }
                }

                Menu {
                    id: fileNodeMenu
                    background: Rectangle { color: "#1e1e2e"; border.color: "#313244"; border.width: 1; radius: 6 }
                    MenuItem {
                        text: "New File"
                        onTriggered: rootNode.requestCreation(entry.entryIsDir ? entry.entryPath : rootNode.folderPath, false)
                    }
                    MenuItem {
                        text: "New Folder"
                        onTriggered: rootNode.requestCreation(entry.entryIsDir ? entry.entryPath : rootNode.folderPath, true)
                    }
                }
            }

            // ── Animated slide-down children ──────────────────────
            Item {
                width:  entry.width
                height: entry.expanded ? childLoader.implicitHeight : 0
                clip:   true
                Behavior on height {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }

                Loader {
                    id:     childLoader
                    width:  entry.width
                    active: entry.expanded
                }
            }
        }
    }
}
