import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets

Item {
    id: root

    property var pluginApi: null

    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true

    property real contentPreferredWidth: 560 * Style.uiScaleRatio
    property real contentPreferredHeight: 600 * Style.uiScaleRatio

    anchors.fill: parent

    readonly property bool panelAnchorVerticalCenter: true;

    property string result: "";
    property string answer: "";
    property string warning: "";
    property string error: "";

    ListModel {
        id: historyModel
    }

    FileView {
        id: historyFile
        path: Quickshell.env("HOME") + "/.config/noctalia-qalculate/history.json"
        onLoadedChanged: {
            if (loaded) {
                var data = JSON.parse(text())
                if (Array.isArray(data)) {
                    data.forEach(function(item) {
                        historyModel.append(item)
                    })
                }
            }
        }
    }

    function saveHistory() {
        var items = []
        for (var i = 0; i < historyModel.count; i++) {
            items.push(historyModel.get(i))
        }
        try {
            historyFile.setText(JSON.stringify(items, null, 2))
        } catch(e) {}
    }

    function extractAnswer(res) {
        if (!res || res.startsWith("warning")) return "";
        var parts = res.split("=");
        if (parts.length < 2) return "";
        var val = parts[parts.length - 1].trim();
        if (val.startsWith("≈ ")) val = val.substring(2);
        if (val.startsWith("approx. ")) val = val.substring(8);
        return val;
    }

    function storeQalcOutput(output)  {
        var result = ""
        var answer = ""
        var warning = ""
        var error = ""
        output = output.trim()
        if (output.includes("\n")) {
            var parts = output.trim().split("\n")
            result = parts[1]
            if (parts[0].startsWith("warning")) {
                warning = parts[0].substring(9)
            } else if (parts[0].startsWith("error")) {
                error = parts[0].substring(7)
            }
        } else {
            result = output.trim()
        }

        var parts = result.split("=");
        if (parts.length >= 2) {
            var val = parts[parts.length - 1].trim();
            if (val.startsWith("≈ ")) val = val.substring(2);
            if (val.startsWith("approx. ")) val = val.substring(8);
            answer = val
        }

        root.result = result;
        root.answer = answer;
        root.warning = warning;
        root.error = error;
    }

    Timer {
        id: debounceTimer
        interval: 100
        onTriggered: runCalculation()
    }

    Process {
        id: calcProc
        running: false

        stdout: StdioCollector {
            onTextChanged: {
                root.storeQalcOutput(text)
            }
        }
    }

    function runCalculation() {
        if (searchInput.text == "") {
            result = "";
            answer = "";
            warning = "";
            error = "";
            return;
        }
        calcProc.command = ["qalc", "-s", "update_exchange_rates 1days", "-s", "decimal comma off", searchInput.text]
        calcProc.running = true;
    }

    function updateResults() {
        debounceTimer.restart()
    }

    function copyAnswer() {
        if (answer) {
            copyToClipboard(answer)
        }
    }

    function handleKeyPress(event) {
        if (event.key === Qt.Key_C && event.modifiers & Qt.ControlModifier) {
            event.accepted = true
            copyAnswer()
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (searchInput.text.trim() !== "" && answer !== "") {
                historyModel.insert(0, { expression: searchInput.text, result: answer })
                saveHistory()
            }
        }
    }

    Process { id: panelClipProc }
    function copyToClipboard(text) {
        if (!text || text === "") return
        panelClipProc.exec({ command: ["bash", "-c", "printf '%s' " + text + " | wl-copy 2>/dev/null"] })
    }

    function removeHistoryEntry(index) {
        historyView.model.remove(index)
        saveHistory()
    }

    function copyHistoryEntry(index) {
        var entry = historyView.model.get(index)
        copyToClipboard(entry.result)
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
            placeholderText: "Enter an expression..."
            radius: Style.iRadiusM
            onTextChanged: updateResults()

            Component.onCompleted: {
                if (searchInput.inputItem) {
                    searchInput.inputItem.forceActiveFocus()
                    searchInput.inputItem.Keys.onPressed.connect(function (event) {
                        root.handleKeyPress(event)
                    })
                }
            }
        }

        NText {
            id: resultText
            Layout.preferredWidth: parent.width
            wrapMode: Text.WrapAnywhere
            color: Color.mPrimary
            font.family: "Monospace"
            font.pointSize: Style.fontSizeM
            text: root.result
        }

        NText {
            id: warningText
            Layout.preferredWidth: parent.width
            visible: root.warning != ""
            text: root.warning
            color: Color.mSecondary
            font.family: "Monospace"
            font.pointSize: Style.fontSizeM
        }

        NText {
            id: errorText
            Layout.preferredWidth: parent.width
            visible: root.error != ""
            text: root.error
            color: Color.mError
            font.family: "Monospace"
            font.pointSize: Style.fontSizeM
        }


        NListView {
            id: historyView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 420 * Style.uiScaleRatio

            reserveScrollbarSpace: false
            gradientColor: Settings.data.ui.panelBackgroundOpacity < 1 ? "transparent" : Color.mSurface
            spacing: Style.marginS
            model: historyModel
            clip: true

            delegate: NBox {
                width: historyView.width
                color: Color.mSurfaceVariant
                height: 60
                radius: Style.iRadiusS

                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.margins: Style.marginL
                    anchors.right: parent.right

                    RowLayout {
                        NText {
                            text: expression
                            font.family: "Monospace"
                            font.pointSize: Style.fontSizeL
                            color: Color.mSecondary
                            Layout.alignment: Qt.AlignLeft
                        }

                        NText {
                            text: " = "
                            font.family: "Monospace"
                            font.pointSize: Style.fontSizeL
                            Layout.alignment: Qt.AlignLeft
                        }

                        NText {
                            text: result
                            font.family: "Monospace"
                            font.pointSize: Style.fontSizeL
                            color: Color.mSecondary
                            Layout.alignment: Qt.AlignLeft
                        }
                    }

                    RowLayout {
                        anchors.margins: Style.marginS
                        spacing: Style.marginS
                        Layout.alignment: Qt.AlignRight

                        NIconButton {
                            icon: "copy"
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            onClicked: copyHistoryEntry(index)
                        }

                        NIconButton {
                            icon: "trash"
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            onClicked: removeHistoryEntry(index)
                        }
                    }
                }
            }
        }
    }
}
