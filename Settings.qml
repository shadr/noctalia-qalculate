import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    property var pluginApi: null
    property bool editOverlayLayer: pluginApi?.pluginSettings?.overlayLayer ??
                                    pluginApi?.manifest?.metadata?.defaultSettings?.overlayLayer ??
                                    false

    spacing: Style.marginM

    NToggle {
        Layout.fillWidth: true
        label: "Show above fullscreen"
        description: "Render Qalculate in an overlay window above fullscreen apps."
        checked: root.editOverlayLayer
        onToggled: checked => root.editOverlayLayer = checked
    }

    function saveSettings() {
        pluginApi.pluginSettings.overlayLayer = root.editOverlayLayer
        pluginApi.saveSettings()
    }
}
