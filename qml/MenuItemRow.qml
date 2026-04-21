// qml/MenuItemRow.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    property string label:    ""
    property string shortcut: ""
    signal activated()

    width:  parent ? parent.width : 200
    height: 30
    color:  hover.containsMouse ? "#313244" : "transparent"
    radius: 4

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        Text {
            width: parent.width - shortcutHint.implicitWidth - 12
            anchors.verticalCenter: parent.verticalCenter
            text:  root.label
            color: "#cdd6f4"
            font.pixelSize: 13
        }

        Text {
            id: shortcutHint
            anchors.verticalCenter: parent.verticalCenter
            text:  root.shortcut
            color: "#6c7086"
            font.pixelSize: 11
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.activated()
    }
}
