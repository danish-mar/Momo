// qml/ContextMenuItem.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

MenuItem {
    id: root
    property string shortcut: ""

    height: 28

    contentItem: Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        Text {
            width: parent.width - scHint.implicitWidth - 12
            anchors.verticalCenter: parent.verticalCenter
            text:  root.text
            color: "#cdd6f4"
            font.pixelSize: 13
        }
        Text {
            id: scHint
            anchors.verticalCenter: parent.verticalCenter
            text:  root.shortcut
            color: "#6c7086"
            font.pixelSize: 11
        }
    }

    background: Rectangle {
        color: root.highlighted ? "#313244" : "transparent"
        radius: 4
    }
}
