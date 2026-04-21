// qml/main.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Momo.Core 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 1280
    height: 800
    title: qsTr("Momo")

    // ── Theme ─────────────────────────────────────────────────────
    property color bgColor:        "#1e1e2e"
    property color sidebarColor:   "#181825"
    property color headerColor:    "#11111b"
    property color tabBarColor:    "#181825"
    property color accentColor:    "#cba6f7"
    property color textColor:      "#cdd6f4"
    property color mutedColor:     "#6c7086"
    property color selectionColor: "#45475a"
    property color borderColor:    "#313244"
    property string editorFont:    "Monospace"
    property bool sidebarVisible:  true
    property real lineH:           20

    background: Rectangle { color: window.bgColor }
    property bool terminalVisible: false

    // ── Root layout ───────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ══════════════════════════════════════════════════════════
        // MENU BAR  (File / Edit / View / Help)
        // ══════════════════════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: window.headerColor

            Row {
                anchors.fill: parent
                anchors.leftMargin: 6
                spacing: 0

                // ── Generic menu-bar button ────────────────────────
                // Each top-level item is a Button that opens a Popup
                // positioned below it — same pattern VSCode uses.

                // FILE ──────────────────────────────────────────────
                Rectangle {
                    id: fileMenuBtn
                    width: fileMenuLabel.implicitWidth + 20
                    height: parent.height
                    color: fileMenuPopup.opened ? window.selectionColor
                         : fileMenuHover.containsMouse ? "#2a2a3d" : "transparent"
                    radius: 4

                    Text {
                        id: fileMenuLabel
                        anchors.centerIn: parent
                        text: "File"
                        color: window.textColor
                        font.pixelSize: 13
                    }
                    MouseArea {
                        id: fileMenuHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: fileMenuPopup.opened ? fileMenuPopup.close() : fileMenuPopup.open()
                    }

                    Popup {
                        id: fileMenuPopup
                        y: parent.height
                        x: 0
                        width: 230
                        padding: 4
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                        background: Rectangle {
                            color: "#1e1e2e"; border.color: window.borderColor
                            border.width: 1; radius: 6
                        }
                        contentItem: Column {
                            spacing: 0
                            MenuItemRow { label: "Open File…";       shortcut: "Ctrl+O";    onActivated: { fileMenuPopup.close(); let f = fileDialog.getOpenFileName(); if(f) backend.docManager.openFile(f) } }
                            MenuItemRow { label: "Open Folder…";     shortcut: "Ctrl+K O";  onActivated: { fileMenuPopup.close(); let d = fileDialog.getOpenDirectory(); if(d){ rootFileNode.folderPath = d; window.sidebarVisible = true } } }
                            MenuSeparatorRow {}
                            MenuItemRow { label: "Save";             shortcut: "Ctrl+S";    onActivated: { fileMenuPopup.close(); backend.docManager.saveFile() } }
                            MenuSeparatorRow {}
                            MenuItemRow { label: "Close Tab";        shortcut: "Ctrl+W";    onActivated: { fileMenuPopup.close(); let i = backend.docManager.currentTabIndex; if(i >= 0) backend.docManager.closeTab(i) } }
                            MenuSeparatorRow {}
                            MenuItemRow { label: "Quit";             shortcut: "Ctrl+Q";    onActivated: { fileMenuPopup.close(); Qt.quit() } }
                        }
                    }
                }

                // EDIT ──────────────────────────────────────────────
                Rectangle {
                    id: editMenuBtn
                    width: editMenuLabel.implicitWidth + 20
                    height: parent.height
                    color: editMenuPopup.opened ? window.selectionColor
                         : editMenuHover.containsMouse ? "#2a2a3d" : "transparent"
                    radius: 4

                    Text {
                        id: editMenuLabel
                        anchors.centerIn: parent
                        text: "Edit"
                        color: window.textColor
                        font.pixelSize: 13
                    }
                    MouseArea {
                        id: editMenuHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: editMenuPopup.opened ? editMenuPopup.close() : editMenuPopup.open()
                    }

                    Popup {
                        id: editMenuPopup
                        y: parent.height; x: 0; width: 230; padding: 4
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                        background: Rectangle { color: "#1e1e2e"; border.color: window.borderColor; border.width: 1; radius: 6 }
                        contentItem: Column {
                            spacing: 0
                            MenuItemRow { label: "Undo";        shortcut: "Ctrl+Z";   onActivated: { editMenuPopup.close(); editorArea.undo() } }
                            MenuItemRow { label: "Redo";        shortcut: "Ctrl+Y";   onActivated: { editMenuPopup.close(); editorArea.redo() } }
                            MenuSeparatorRow {}
                            MenuItemRow { label: "Cut";         shortcut: "Ctrl+X";   onActivated: { editMenuPopup.close(); editorArea.cut() } }
                            MenuItemRow { label: "Copy";        shortcut: "Ctrl+C";   onActivated: { editMenuPopup.close(); editorArea.copy() } }
                            MenuItemRow { label: "Paste";       shortcut: "Ctrl+V";   onActivated: { editMenuPopup.close(); editorArea.paste() } }
                            MenuSeparatorRow {}
                            MenuItemRow { label: "Select All";  shortcut: "Ctrl+A";   onActivated: { editMenuPopup.close(); editorArea.selectAll() } }
                        }
                    }
                }

                // VIEW ──────────────────────────────────────────────
                Rectangle {
                    id: viewMenuBtn
                    width: viewMenuLabel.implicitWidth + 20
                    height: parent.height
                    color: viewMenuPopup.opened ? window.selectionColor
                         : viewMenuHover.containsMouse ? "#2a2a3d" : "transparent"
                    radius: 4

                    Text {
                        id: viewMenuLabel
                        anchors.centerIn: parent
                        text: "View"
                        color: window.textColor
                        font.pixelSize: 13
                    }
                    MouseArea {
                        id: viewMenuHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: viewMenuPopup.opened ? viewMenuPopup.close() : viewMenuPopup.open()
                    }

                    Popup {
                        id: viewMenuPopup
                        y: parent.height; x: 0; width: 230; padding: 4
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                        background: Rectangle { color: "#1e1e2e"; border.color: window.borderColor; border.width: 1; radius: 6 }
                        contentItem: Column {
                            spacing: 0
                            MenuItemRow { label: "Toggle Sidebar"; shortcut: "Ctrl+B"; onActivated: { viewMenuPopup.close(); window.sidebarVisible = !window.sidebarVisible } }
                        }
                    }
                }

                // HELP ──────────────────────────────────────────────
                Rectangle {
                    id: helpMenuBtn
                    width: helpMenuLabel.implicitWidth + 20
                    height: parent.height
                    color: helpMenuPopup.opened ? window.selectionColor
                         : helpMenuHover.containsMouse ? "#2a2a3d" : "transparent"
                    radius: 4

                    Text {
                        id: helpMenuLabel
                        anchors.centerIn: parent
                        text: "Help"
                        color: window.textColor
                        font.pixelSize: 13
                    }
                    MouseArea {
                        id: helpMenuHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: helpMenuPopup.opened ? helpMenuPopup.close() : helpMenuPopup.open()
                    }

                    Popup {
                        id: helpMenuPopup
                        y: parent.height; x: 0; width: 230; padding: 4
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                        background: Rectangle { color: "#1e1e2e"; border.color: window.borderColor; border.width: 1; radius: 6 }
                        contentItem: Column {
                            spacing: 0
                            MenuItemRow { label: "About Momo"; shortcut: ""; onActivated: { helpMenuPopup.close(); aboutDialog.open() } }
                        }
                    }
                }
            }

            // Right side — LSP indicator + terminal toggle
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                // Terminal toggle
                Rectangle {
                    width: termToggleLabel.implicitWidth + 16
                    height: 22
                    radius: 4
                    color: window.terminalVisible
                        ? window.accentColor + "33"
                        : (termToggleMouse.containsMouse ? "#2a2a3d" : "transparent")
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        id: termToggleLabel
                        anchors.centerIn: parent
                        text: ">_"
                        color: window.terminalVisible ? window.accentColor : window.mutedColor
                        font.pixelSize: 12
                        font.family: window.editorFont
                    }
                    MouseArea {
                        id: termToggleMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: window.terminalVisible = !window.terminalVisible
                    }
                }

                Rectangle { width: 7; height: 7; radius: 4; color: "#a6e3a1"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "C++ LSP"; color: window.mutedColor; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        // ══════════════════════════════════════════════════════════
        // TAB BAR
        // ══════════════════════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            height: backend.docManager.openTabs.length > 0 ? 35 : 0
            color: window.tabBarColor
            visible: backend.docManager.openTabs.length > 0

            Rectangle {
                width: parent.width; height: 1
                anchors.bottom: parent.bottom
                color: window.borderColor
            }

            ListView {
                id: tabBar
                anchors.fill: parent
                orientation: ListView.Horizontal
                model: backend.docManager.openTabs
                clip: true
                spacing: 0

                delegate: Rectangle {
                    id: tabItem
                    width: Math.min(tabLabel.implicitWidth + 50, 200)
                    height: tabBar.height
                    color: index === backend.docManager.currentTabIndex
                           ? window.bgColor : "transparent"

                    // Active indicator line on top
                    Rectangle {
                        width: parent.width; height: 2
                        anchors.top: parent.top
                        color: index === backend.docManager.currentTabIndex
                               ? window.accentColor : "transparent"
                    }

                    // Right border between tabs
                    Rectangle {
                        width: 1; height: parent.height
                        anchors.right: parent.right
                        color: window.borderColor
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: backend.docManager.currentTabIndex = index
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 4
                        spacing: 6

                        Text {
                            id: tabLabel
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.fileName + (modelData.isModified ? " *" : "")
                            color: index === backend.docManager.currentTabIndex
                                   ? window.textColor : window.mutedColor
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            width: Math.min(implicitWidth, 130)
                        }

                        // Close button
                        Rectangle {
                            width: 18; height: 18
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 3
                            color: closeHover.containsMouse ? window.selectionColor : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: closeHover.containsMouse ? window.textColor : window.mutedColor
                                font.pixelSize: 11
                            }

                            MouseArea {
                                id: closeHover
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onClicked: backend.docManager.closeTab(index)
                            }
                        }
                    }
                }
            }
        }

        // ── Main split (Editor + Sidebar) VS Terminal ─────────────
        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Vertical

            // Top Part: Sidebar + Editor
            Item {
                SplitView.fillWidth: true
                SplitView.fillHeight: true
                SplitView.minimumHeight: 150

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

            // ── Sidebar ───────────────────────────────────────────
            Rectangle {
                width: window.sidebarVisible ? 260 : 0
                Layout.fillHeight: true
                color: window.sidebarColor
                visible: window.sidebarVisible
                clip: true
                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true; height: 35; color: "transparent"
                        
                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 15; anchors.rightMargin: 10
                            spacing: 8
                            Text {
                                text: "EXPLORER"; color: window.mutedColor
                                font.pixelSize: 11; font.bold: true; font.letterSpacing: 1
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 60
                            }
                            
                            // "New File" Button
                            Rectangle {
                                width: 22; height: 22; color: nfHover.containsMouse ? window.selectionColor : "transparent"; radius: 4
                                anchors.verticalCenter: parent.verticalCenter
                                Text { anchors.centerIn: parent; text: "📄"; font.pixelSize: 12; color: window.textColor }
                                MouseArea { id: nfHover; anchors.fill: parent; hoverEnabled: true; onClicked: { createDialog.isCreatingFolder = false; createDialog.open() } }
                            }
                            
                            // "New Folder" Button
                            Rectangle {
                                width: 22; height: 22; color: ndHover.containsMouse ? window.selectionColor : "transparent"; radius: 4
                                anchors.verticalCenter: parent.verticalCenter
                                Text { anchors.centerIn: parent; text: "📁"; font.pixelSize: 12; color: window.textColor }
                                MouseArea { id: ndHover; anchors.fill: parent; hoverEnabled: true; onClicked: { createDialog.isCreatingFolder = true; createDialog.open() } }
                            }
                        }
                    }

                    Flickable {
                        Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                        contentHeight: Math.max(parent.height, rootFileNode.height)

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            onClicked: (mouse) => {
                                if (mouse.button === Qt.RightButton) {
                                    explorerBgMenu.x = mouse.x
                                    explorerBgMenu.y = mouse.y
                                    explorerBgMenu.open()
                                }
                            }
                        }

                        FileNode { 
                            id: rootFileNode
                            width: parent.width - 12
                            folderPath: "" 
                            onRequestCreation: (path, isFolder) => {
                                createDialog.isCreatingFolder = isFolder
                                createDialog.targetPath = path
                                createDialog.open()
                            }
                        }
                        
                        ScrollBar.vertical: ScrollBar {
                            width: 12
                            policy: ScrollBar.AsNeeded
                            anchors.right: parent.right
                        }
                    }

                    Menu {
                        id: explorerBgMenu
                        background: Rectangle { color: "#1e1e2e"; border.color: window.borderColor; border.width: 1; radius: 6 }
                        MenuItem { 
                            text: "New File"
                            onTriggered: { createDialog.isCreatingFolder = false; createDialog.targetPath = rootFileNode.folderPath; createDialog.open() }
                        }
                        MenuItem { 
                            text: "New Folder"
                            onTriggered: { createDialog.isCreatingFolder = true; createDialog.targetPath = rootFileNode.folderPath; createDialog.open() }
                        }
                    }
                }

                Rectangle { width: 1; height: parent.height; anchors.right: parent.right; color: window.borderColor }
            }

            // ── Editor ───────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Font metrics — single source of truth
                FontMetrics {
                    id: fm
                    font.family:    window.editorFont
                    font.pixelSize: 14
                    Component.onCompleted: window.lineH = fm.height
                }

                // Empty-state hint
                Text {
                    anchors.centerIn: parent
                    visible: backend.docManager.openTabs.length === 0
                    text: "Open a file from the sidebar\nor  File → Open File…"
                    color: window.mutedColor
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    visible: backend.docManager.openTabs.length > 0

                    // ── Gutter ────────────────────────────────────
                    Rectangle {
                        id: gutter
                        width: 56
                        Layout.fillHeight: true
                        color: window.bgColor

                        Rectangle { width: 1; height: parent.height; anchors.right: parent.right; color: window.borderColor }

                        Item {
                            anchors.fill: parent
                            clip: true

                            Column {
                                id: lineNumbers
                                y: editorArea.topPadding - editorFlick.contentY
                                width: gutter.width - 10
                                spacing: 0

                                Repeater {
                                    model: editorArea.lineCount
                                    delegate: Text {
                                        width: lineNumbers.width
                                        height: window.lineH
                                        text: (index + 1).toString()
                                        color: index === currentLineIndex()
                                               ? window.textColor : window.mutedColor
                                        font.family:    window.editorFont
                                        font.pixelSize: 14
                                        horizontalAlignment: Text.AlignRight
                                        verticalAlignment:   Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }

                    // ── Flickable ─────────────────────────────────
                    Flickable {
                        id: editorFlick
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        contentWidth:  editorArea.implicitWidth  + editorArea.leftPadding + editorArea.rightPadding
                        contentHeight: editorArea.implicitHeight + editorArea.topPadding  + editorArea.bottomPadding

                        flickableDirection: Flickable.HorizontalAndVerticalFlick
                        boundsBehavior:     Flickable.StopAtBounds
                        ScrollBar.vertical:   ScrollBar { policy: ScrollBar.AsNeeded }
                        ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }

                        // ── Dynamic indent guide canvas ───────────
                        Canvas {
                            id: indentCanvas
                            x: editorArea.leftPadding; y: 0
                            width:  Math.max(editorFlick.contentWidth,  editorFlick.width)
                            height: Math.max(editorFlick.contentHeight, editorFlick.height)

                            property string watchText: editorArea.text
                            onWatchTextChanged: requestPaint()

                            onPaint: {
                                var ctx   = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                var tabW  = fm.advanceWidth(" ") * 4
                                var lines = editorArea.text.split('\n')
                                ctx.strokeStyle = "#2a2a3e"
                                ctx.lineWidth   = 1
                                for (var li = 0; li < lines.length; li++) {
                                    var line = lines[li], spaces = 0
                                    for (var ci = 0; ci < line.length; ci++) {
                                        if      (line[ci] === '\t') spaces += 4
                                        else if (line[ci] === ' ')  spaces += 1
                                        else break
                                    }
                                    var levels = Math.floor(spaces / 4)
                                    var lineY  = editorArea.topPadding + li * window.lineH
                                    for (var lv = 1; lv <= levels; lv++) {
                                        var gx = lv * tabW + 0.5
                                        ctx.beginPath()
                                        ctx.moveTo(gx, lineY)
                                        ctx.lineTo(gx, lineY + window.lineH)
                                        ctx.stroke()
                                    }
                                }
                            }
                        }

                        // ── TextArea ──────────────────────────────
                        TextArea {
                            id: editorArea
                            width: Math.max(editorFlick.width, implicitWidth)

                            // !! Tab-switch fix: do NOT use a declarative
                            // two-way binding here — it breaks on switch.
                            // Instead, load content explicitly via Connections.
                            color:             window.textColor
                            font.family:       window.editorFont
                            font.pixelSize:    14
                            selectionColor:    window.selectionColor
                            selectedTextColor: window.accentColor
                            selectByMouse:     true
                            tabStopDistance:   fm.advanceWidth(" ") * 4
                            wrapMode:          TextEdit.NoWrap
                            topPadding:    15; bottomPadding: 15
                            leftPadding:   10; rightPadding:  15; padding: 0

                            background: Item {}

                            // Push edits back to the model
                            onTextChanged: {
                                if (backend.docManager.currentTabIndex >= 0)
                                    backend.docManager.currentContent = text
                            }

                            SyntaxHighlighter {
                                id: syntaxHL
                                textDocument: editorArea.textDocument
                            }

                            // ── Right-click context menu ───────────
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.RightButton
                                // Let left-clicks through to TextArea
                                propagateComposedEvents: true
                                onClicked: (mouse) => {
                                    if (mouse.button === Qt.RightButton) {
                                        contextMenu.x = mouse.x
                                        contextMenu.y = mouse.y
                                        contextMenu.open()
                                    }
                                }
                            }

                            Menu {
                                id: contextMenu
                                background: Rectangle {
                                    color: "#1e1e2e"; border.color: window.borderColor
                                    border.width: 1; radius: 6
                                }

                                ContextMenuItem { text: "Cut";        shortcut: "Ctrl+X"; onTriggered: editorArea.cut() }
                                ContextMenuItem { text: "Copy";       shortcut: "Ctrl+C"; onTriggered: editorArea.copy() }
                                ContextMenuItem { text: "Paste";      shortcut: "Ctrl+V"; onTriggered: editorArea.paste() }
                                MenuSeparator { contentItem: Rectangle { implicitHeight: 1; color: window.borderColor } }
                                ContextMenuItem { text: "Select All"; shortcut: "Ctrl+A"; onTriggered: editorArea.selectAll() }
                                MenuSeparator { contentItem: Rectangle { implicitHeight: 1; color: window.borderColor } }
                                ContextMenuItem { text: "Save";       shortcut: "Ctrl+S"; onTriggered: backend.docManager.saveFile() }
                            }

                            // ── Smart key handling ─────────────────
                            Keys.onPressed: (event) => {
                                // Skip our custom logic if Control/Alt/Shift is held (unless it's our specific shortcut)
                                if ((event.modifiers & Qt.ControlModifier) || (event.modifiers & Qt.AltModifier) || (event.modifiers & Qt.ShiftModifier)) {
                                    if (!(event.key === Qt.Key_Space && (event.modifiers & Qt.ControlModifier))) {
                                        return; // Let standard TextArea handlers handle selection/navigation/shortcuts
                                    }
                                }

                                let cursor = cursorPosition
                                
                                if (autoCompletePopup.opened) {
                                    if (event.key === Qt.Key_Down) {
                                        suggestionList.incrementCurrentIndex(); event.accepted = true; return
                                    } else if (event.key === Qt.Key_Up) {
                                        suggestionList.decrementCurrentIndex(); event.accepted = true; return
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Tab || event.key === Qt.Key_Enter) {
                                        let modelData = suggestionList.model[suggestionList.currentIndex]
                                        let slice  = editorArea.text.substring(0, cursor)
                                        let start  = Math.max(slice.lastIndexOf(' '), Math.max(slice.lastIndexOf('\n'), slice.lastIndexOf('\t'))) + 1
                                        let newText = editorArea.text.substring(0, start) + modelData + editorArea.text.substring(cursor)
                                        editorArea.text = newText
                                        editorArea.cursorPosition = start + modelData.length
                                        autoCompletePopup.close(); event.accepted = true; return
                                    } else if (event.key === Qt.Key_Escape) {
                                        autoCompletePopup.close(); event.accepted = true; return
                                    }
                                }

                                if (event.key === Qt.Key_Space && (event.modifiers & Qt.ControlModifier)) {
                                    event.accepted = true; autoCompletePopup.open(); return
                                }
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    let lineStart = text.lastIndexOf('\n', cursor - 1) + 1
                                    let currentLine = text.substring(lineStart, cursor)
                                    let indent = (currentLine.match(/^\s*/) || [""])[0]
                                    let prevChar = cursor > 0 ? text.charAt(cursor - 1) : ''
                                    if (prevChar === '{') {
                                        insert(cursor, "\n" + indent + "    \n" + indent)
                                        cursorPosition = cursor + indent.length + 5
                                        event.accepted = true; return
                                    }
                                    insert(cursor, "\n" + indent)
                                    event.accepted = true
                                } else if (event.text === '"' || event.text === "'" || event.text === "`") {
                                    insert(cursor, event.text + event.text); cursorPosition = cursor + 1; event.accepted = true
                                } else if (event.text === '{') { insert(cursor, "{}"); cursorPosition = cursor + 1; event.accepted = true
                                } else if (event.text === '[') { insert(cursor, "[]"); cursorPosition = cursor + 1; event.accepted = true
                                } else if (event.text === '(') { insert(cursor, "()"); cursorPosition = cursor + 1; event.accepted = true
                                } else if (event.key === Qt.Key_Backspace) {
                                    if (cursor > 0 && cursor < text.length) {
                                        let cb = text.charAt(cursor - 1), ca = text.charAt(cursor)
                                        if ((cb==='{' && ca==='}') || (cb==='[' && ca===']') ||
                                            (cb==='(' && ca===')') || (cb==='"' && ca==='"') ||
                                            (cb==="'" && ca==="'")) {
                                            remove(cursor - 1, cursor + 1); event.accepted = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Auto-scroll cursor into view ──────────────────
                Connections {
                    target: editorArea
                    function onCursorRectangleChanged() {
                        var cr = editorArea.cursorRectangle
                        if (cr.y < editorFlick.contentY)
                            editorFlick.contentY = cr.y
                        else if (cr.y + cr.height > editorFlick.contentY + editorFlick.height)
                            editorFlick.contentY = cr.y + cr.height - editorFlick.height
                        if (cr.x < editorFlick.contentX)
                            editorFlick.contentX = cr.x
                        else if (cr.x + cr.width > editorFlick.contentX + editorFlick.width)
                            editorFlick.contentX = cr.x + cr.width - editorFlick.width
                    }
                }
            }
            }
        }

            // Bottom Part: Terminal Pane
            Rectangle {
                id: terminalPane
                SplitView.fillWidth: true
                SplitView.preferredHeight: 240
                visible: window.terminalVisible
                color: "#11111b"
                clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // ── Tab bar ───────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    color: "#181825"

                    // Top border
                    Rectangle { width: parent.width; height: 1; color: window.borderColor; anchors.top: parent.top }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 0

                        // TERMINAL label
                        Text {
                            text: "TERMINAL"
                            color: window.accentColor
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                            Layout.alignment: Qt.AlignVCenter
                            rightPadding: 12
                        }

                        // Tab list
                        ListView {
                            id: termTabBar
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            orientation: ListView.Horizontal
                            model: backend.terminal.tabs
                            clip: true
                            spacing: 2

                            delegate: Rectangle {
                                width: termTabLabel.implicitWidth + 36
                                height: termTabBar.height
                                color: index === backend.terminal.currentTabIndex
                                    ? "#1e1e2e" : "transparent"
                                radius: 4

                                // Active top line
                                Rectangle {
                                    width: parent.width; height: 2
                                    anchors.top: parent.top
                                    color: index === backend.terminal.currentTabIndex
                                        ? window.accentColor : "transparent"
                                    radius: 1
                                }

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Text {
                                        id: termTabLabel
                                        text: modelData.title
                                        color: index === backend.terminal.currentTabIndex
                                            ? window.textColor : window.mutedColor
                                        font.pixelSize: 12
                                        font.family: window.editorFont
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    // Close tab
                                    Text {
                                        text: "✕"
                                        color: termTabCloseMouse.containsMouse
                                            ? window.textColor : window.mutedColor
                                        font.pixelSize: 10
                                        anchors.verticalCenter: parent.verticalCenter

                                        MouseArea {
                                            id: termTabCloseMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: backend.terminal.closeTab(index)
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    // Don't block close btn
                                    onClicked: backend.terminal.currentTabIndex = index
                                }
                            }
                        }

                        // + New tab button
                        Rectangle {
                            width: 26; height: 26
                            radius: 4
                            color: newTermMouse.containsMouse ? window.selectionColor : "transparent"
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                color: window.mutedColor
                                font.pixelSize: 16
                            }
                            MouseArea {
                                id: newTermMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: backend.terminal.newTab()
                            }
                        }

                        // Hide terminal
                        Rectangle {
                            width: 26; height: 26
                            radius: 4
                            color: hideTermMouse.containsMouse ? window.selectionColor : "transparent"
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: window.mutedColor
                                font.pixelSize: 11
                            }
                            MouseArea {
                                id: hideTermMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: window.terminalVisible = false
                            }
                        }
                    }
                }

                // ── Output area ───────────────────────────────────
                Flickable {
                    id: termOutputFlick
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentHeight: termOutputText.implicitHeight + 20
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    // Auto-scroll to bottom when output changes
                    onContentHeightChanged: {
                        if (contentHeight > height)
                            contentY = contentHeight - height
                    }

                    TextEdit {
                        id: termOutputText
                        x: 10
                        width: termOutputFlick.width - 20
                        readOnly: true
                        text: backend.terminal.currentOutput
                        font.family: window.editorFont
                        font.pixelSize: 13
                        color: "#cdd6f4"
                        wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                        selectByMouse: true

                        // Re-scroll when tab switches
                        Connections {
                            target: backend.terminal
                            function onCurrentOutputChanged() {
                                termOutputText.text = backend.terminal.currentOutput
                                if (termOutputFlick.contentHeight > termOutputFlick.height)
                                    termOutputFlick.contentY =
                                        termOutputFlick.contentHeight - termOutputFlick.height
                            }
                            function onCurrentTabIndexChanged() {
                                termOutputText.text = backend.terminal.currentOutput
                                termOutputFlick.contentY = 0
                                Qt.callLater(function() {
                                    if (termOutputFlick.contentHeight > termOutputFlick.height)
                                        termOutputFlick.contentY =
                                            termOutputFlick.contentHeight - termOutputFlick.height
                                })
                            }
                        }
                    }
                }

        // ── Input row ─────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 34
            color: "#0d0d17"

            // Top border
            Rectangle { width: parent.width; height: 1; color: window.borderColor; anchors.top: parent.top }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 6

                Text {
                    text: "$"
                    color: "#a6e3a1"
                    font.family: window.editorFont
                    font.pixelSize: 13
                    Layout.alignment: Qt.AlignVCenter
                }

                TextField {
                    id: terminalInput
                    Layout.fillWidth: true
                    color: window.textColor
                    font.family: window.editorFont
                    font.pixelSize: 13
                    placeholderText: "enter command…"
                    placeholderTextColor: window.mutedColor
                    background: Item {}

                    // Command history
                    property var history: []
                    property int historyIdx: -1

                    onAccepted: {
                        if (text.trim() !== "") {
                            history.push(text)
                            historyIdx = -1
                            backend.terminal.sendCommand(text)
                            text = ""
                            terminalInput.forceActiveFocus()
                        }
                    }

                    Keys.onUpPressed: {
                        if (history.length > 0) {
                            if (historyIdx === -1) historyIdx = history.length - 1
                            else if (historyIdx > 0) historyIdx--
                            text = history[historyIdx]
                        }
                    }
                    Keys.onDownPressed: {
                        if (historyIdx !== -1) {
                            historyIdx++
                            if (historyIdx >= history.length) { historyIdx = -1; text = "" }
                            else text = history[historyIdx]
                        }
                    }
                }
            }
        }
    }

        }
    }

        // ── Status bar ────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 22
            color: "#181825"

            Row {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 16

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        var idx = backend.docManager.currentTabIndex
                        var tabs = backend.docManager.openTabs
                        return (tabs.length > 0 && idx >= 0 && idx < tabs.length)
                               ? tabs[idx].fileName : "No file open"
                    }
                    color: window.mutedColor; font.pixelSize: 11
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Ln " + (currentLineIndex() + 1)
                    color: window.mutedColor; font.pixelSize: 11
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        var ext = ""
                        var tabs = backend.docManager.openTabs
                        var idx  = backend.docManager.currentTabIndex
                        if (idx >= 0 && idx < tabs.length) {
                            var parts = tabs[idx].fileName.split('.')
                            if (parts.length > 1) ext = parts[parts.length - 1].toUpperCase()
                        }
                        return ext || "Plain Text"
                    }
                    color: window.mutedColor; font.pixelSize: 11
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════
    // Tab content loader — THE fix for empty tabs
    // When currentTabIndex changes we explicitly set editorArea.text
    // to break the old broken binding and load fresh content.
    // ══════════════════════════════════════════════════════════════
    Connections {
        target: backend.docManager
        function onCurrentContentChanged() {
            // Only overwrite if it differs — avoids cursor-jump while typing
            if (editorArea.text !== backend.docManager.currentContent) {
                var pos = editorArea.cursorPosition
                editorArea.text = backend.docManager.currentContent
                // Restore cursor to start on tab switch (can't know old pos)
                editorArea.cursorPosition = 0
            }
        }
        function onCurrentTabIndexChanged() {
            // Force-load on tab switch regardless of content equality check
            editorArea.text = backend.docManager.currentContent
            editorArea.cursorPosition = 0
            editorFlick.contentY = 0
            editorFlick.contentX = 0

            // Update syntax highlighter extension
            var tabs = backend.docManager.openTabs
            var idx  = backend.docManager.currentTabIndex
            if (idx >= 0 && idx < tabs.length) {
                var parts = tabs[idx].fileName.split('.')
                syntaxHL.fileExtension = parts.length > 1 ? parts[parts.length - 1] : "txt"
            }
        }
    }

    // ── Keyboard shortcuts ────────────────────────────────────────
    Shortcut { sequence: "Ctrl+S"; onActivated: backend.docManager.saveFile() }
    Shortcut { sequence: "Ctrl+W"; onActivated: { var i = backend.docManager.currentTabIndex; if(i >= 0) backend.docManager.closeTab(i) } }
    Shortcut { sequence: "Ctrl+B"; onActivated: window.sidebarVisible = !window.sidebarVisible }
    Shortcut { sequence: "Ctrl+O"; onActivated: { var f = fileDialog.getOpenFileName(); if(f) backend.docManager.openFile(f) } }

    Shortcut { sequence: StandardKey.Copy; onActivated: editorArea.copy() }
    Shortcut { sequence: StandardKey.Cut; onActivated: editorArea.cut() }
    Shortcut { sequence: StandardKey.Paste; onActivated: editorArea.paste() }
    Shortcut { sequence: StandardKey.SelectAll; onActivated: editorArea.selectAll() }
    Shortcut { sequence: StandardKey.Undo; onActivated: editorArea.undo() }
    Shortcut { sequence: StandardKey.Redo; onActivated: editorArea.redo() }

    // ── Which line is the cursor on (0-indexed) ───────────────────
    function currentLineIndex() {
        var t = editorArea.text.substring(0, editorArea.cursorPosition)
        var n = 0
        for (var i = 0; i < t.length; i++) if (t[i] === '\n') n++
        return n
    }

    // ── About dialog ──────────────────────────────────────────────
    Dialog {
        id: aboutDialog
        title: "About Momo"
        modal: true
        anchors.centerIn: parent
        background: Rectangle { color: "#1e1e2e"; border.color: window.borderColor; border.width: 1; radius: 8 }
        contentItem: Column {
            padding: 20; spacing: 8
            Text { text: "Momo Code Editor"; color: window.accentColor; font.pixelSize: 16; font.bold: true }
            Text { text: "A lightweight Qt/QML editor."; color: window.textColor; font.pixelSize: 13 }
        }
        standardButtons: Dialog.Ok
    }

    // ── Create File/Folder Dialog ─────────────────────────────────
    Dialog {
        id: createDialog
        property bool isCreatingFolder: false
        property string targetPath: "."
        title: isCreatingFolder ? "New Folder" : "New File"
        modal: true; anchors.centerIn: parent
        background: Rectangle { color: "#1e1e2e"; border.color: window.borderColor; border.width: 1; radius: 8 }
        
        contentItem: Column {
            padding: 20; spacing: 8
            Text { text: "Name:"; color: window.textColor; font.pixelSize: 13 }
            TextField {
                id: createInput
                width: 250; color: window.textColor; font.pixelSize: 13
                background: Rectangle { color: "#313244"; radius: 4 }
                onAccepted: createDialog.accept()
            }
        }
        
        onOpened: { console.log("Creation dialog opened for:", targetPath); createInput.text = ""; createInput.forceActiveFocus() }
        onAccepted: {
            if (createInput.text !== "") {
                let tgt = targetPath;
                if (!tgt || tgt === "") tgt = "."; 
                
                console.log("Creating", isCreatingFolder ? "folder" : "file", createInput.text, "in", tgt);

                if (isCreatingFolder) backend.docManager.createFolder(tgt, createInput.text)
                else backend.docManager.createFile(tgt, createInput.text)
                
                // Refresh
                let old = rootFileNode.folderPath
                rootFileNode.folderPath = ""
                rootFileNode.folderPath = old
            }
        }
        standardButtons: Dialog.Ok | Dialog.Cancel
    }

    // ── Autocomplete popup ────────────────────────────────────────
    Popup {
        id: autoCompletePopup
        width: 300; height: 180
        x: gutter.width + editorArea.cursorRectangle.x + 10 - editorFlick.contentX
        y: 30 + 35 + editorArea.cursorRectangle.y + editorArea.cursorRectangle.height + 4 - editorFlick.contentY
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle { color: "#181825"; border.color: window.borderColor; border.width: 1; radius: 8 }
        contentItem: ListView {
            id: suggestionList
            clip: true
            model: ["auto","bool","class","const","constexpr","continue","double",
                    "else","enum","float","for","if","int","namespace","public",
                    "private","return","std::cout","std::string"]
            delegate: ItemDelegate {
                width: ListView.view.width; height: 26
                contentItem: Row {
                    spacing: 10
                    Rectangle { width: 12; height: 12; radius: 2; color: window.accentColor; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: modelData; color: window.textColor; font.family: window.editorFont; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                }
                background: Rectangle { color: index === suggestionList.currentIndex || parent.hovered ? window.selectionColor : "transparent"; radius: 4 }
                onClicked: {
                    let cursor = editorArea.cursorPosition
                    let slice  = editorArea.text.substring(0, cursor)
                    let start  = Math.max(slice.lastIndexOf(' '), Math.max(slice.lastIndexOf('\n'), slice.lastIndexOf('\t'))) + 1
                    editorArea.text = editorArea.text.substring(0, start) + modelData + editorArea.text.substring(cursor)
                    editorArea.cursorPosition = start + modelData.length
                    autoCompletePopup.close(); editorArea.forceActiveFocus()
                }
            }
        }
    }
}
