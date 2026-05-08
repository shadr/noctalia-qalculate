import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services.UI
import qs.Widgets

Variants {
    id: root

    property var pluginApi: null
    property bool isOpen: false
    property var targetScreen: null
    signal closeRequested()

    model: Quickshell.screens

    delegate: Loader {
        id: windowLoader

        required property ShellScreen modelData

        active: root.isOpen && root.targetScreen === modelData

        sourceComponent: PanelWindow {
            id: overlayWindow
            screen: windowLoader.modelData
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WlrLayershell.namespace: "noctalia-qalculate-overlay-" + (screen?.name || "unknown")
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            Shortcut {
                sequences: ["Escape"]
                enabled: windowLoader.active
                context: Qt.WindowShortcut
                onActivated: root.closeRequested()
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Color.mSurface, Settings.data.general.dimmerOpacity || 0.2)

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.closeRequested()
                }
            }

            NBox {
                id: panelBox
                width: 560 * Style.uiScaleRatio
                height: 600 * Style.uiScaleRatio
                anchors.centerIn: parent
                radius: Style.radiusL
                color: Color.mSurface

                PanelContent {
                    anchors.fill: parent
                    pluginApi: root.pluginApi
                    onRequestClose: function() {
                        root.closeRequested()
                    }
                }
            }
        }
    }
}
