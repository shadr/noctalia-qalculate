import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets

Item {
    id: root

    // Plugin API (injected by PluginPanelSlot)
    property var pluginApi: null

    // SmartPanel properties (required for panel behavior)
    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true

    // Preferred dimensions
    property real contentPreferredWidth: 680 * Style.uiScaleRatio
    property real contentPreferredHeight: 540 * Style.uiScaleRatio

    anchors.fill: parent

    readonly property bool panelAnchorVerticalCenter: true;

    property string result: "";
    property bool calculationFailed: false;

    Process {
        id: calcProc

        stdout: StdioCollector {
            onTextChanged: {
                root.result = text.trim()
                root.calculationFailed = root.result.startsWith("warning")
            }
        }
    }

    function updateResults() {
        if (searchInput.text == "") return;

        calcProc.command = ["qalc", "-s", "update_exchange_rates 1days", searchInput.text]
        calcProc.running = true;
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Style.marginL
        spacing: Style.marginM

        NTextInput {
            id: searchInput
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            fontSize: Style.fontSizeM
            fontFamily: "Monospace"
            radius: Style.iRadiusM
            onTextChanged: updateResults()

            Component.onCompleted: {
                if (searchInput.inputItem) {
                    searchInput.inputItem.forceActiveFocus()
                }
            }
        }

        NText {
            id: resultText
            text: root.result
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            color: root.calculationFailed ? "red" : Color.mPrimary
            font.family: "Monospace"
        }
    }
}
