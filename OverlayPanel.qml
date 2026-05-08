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

            // Match launcher overlay blur behavior.
            BackgroundEffect.blurRegion: Settings.data.general.enableBlurBehind ? panelBlurRegion : null
            Region {
                id: panelBlurRegion

                Region {
                    x: Math.round(panelContainer.x)
                    y: Math.round(panelContainer.y)
                    width: Math.round(panelContainer.width)
                    height: Math.round(panelContainer.height)
                    radius: Style.radiusL
                    topLeftCorner: CornerState.Normal
                    topRightCorner: CornerState.Normal
                    bottomLeftCorner: CornerState.Normal
                    bottomRightCorner: CornerState.Normal
                }
            }

            Shortcut {
                sequences: ["Escape"]
                enabled: windowLoader.active
                context: Qt.WindowShortcut
                onActivated: root.closeRequested()
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Color.mSurface, Settings.data.general.dimmerOpacity)

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.closeRequested()
                }
            }

            NDropShadow {
                source: panelContainer
                anchors.fill: panelContainer
                autoPaddingEnabled: true
            }

            Item {
                id: panelContainer
                width: 560 * Style.uiScaleRatio
                height: 600 * Style.uiScaleRatio
                anchors.centerIn: parent
                clip: false

                NBox {
                    id: panelSurface
                    anchors.fill: parent
                    radius: Style.radiusL
                    color: Qt.alpha(Color.mSurface, Color.adaptiveOpacity(Settings.data.ui.panelBackgroundOpacity))
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    radius: Style.radiusL
                    border.color: Style.boxBorderColor
                    border.width: Style.borderS
                }

                Item {
                    id: panelBox
                    anchors.fill: parent

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
}
