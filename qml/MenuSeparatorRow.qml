// qml/MenuSeparatorRow.qml
import QtQuick 2.15

Rectangle {
    width:  parent ? parent.width : 200
    height: 9
    color:  "transparent"

    Rectangle {
        anchors.centerIn: parent
        width:  parent.width - 16
        height: 1
        color:  "#313244"
    }
}
