import QtQuick
import QtQuick.Controls

Window {
    id: rootWindow

    readonly property url startupView: "StartupView.qml"

    visible: true
    title: qsTr("Qt Quick 3D Particles3D Testbed")
    color: "black"

    Loader {
        id: loader
        anchors.fill: parent

        // Load the startupView directly without passing additional properties
        Component.onCompleted: loader.source = rootWindow.startupView
    }
}
