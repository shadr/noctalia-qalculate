import QtQuick
import qs.Commons

Item {
    id: root

    property var pluginApi: null

    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true

    property real contentPreferredWidth: 560 * Style.uiScaleRatio
    property real contentPreferredHeight: 600 * Style.uiScaleRatio

    anchors.fill: parent

    readonly property bool panelAnchorVerticalCenter: true

    PanelContent {
        id: panelContainer
        anchors.fill: parent
        pluginApi: root.pluginApi
        onRequestClose: function() {
            if (root.pluginApi?.panelOpenScreen) {
                root.pluginApi.closePanel(root.pluginApi.panelOpenScreen)
            }
        }
    }
}
