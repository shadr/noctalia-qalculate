import QtQuick
import Quickshell.Io

Item {
    id: root

    property var pluginApi: null
    property bool overlayOpen: false
    property var overlayScreen: null

    readonly property bool useOverlayMode: pluginApi?.pluginSettings?.overlayLayer ?? false

    function showPluginPanel(screen) {
        if (useOverlayMode) {
            pluginApi.closePanel(screen)
            overlayScreen = screen
            overlayOpen = true
        } else {
            overlayOpen = false
            overlayScreen = null
            pluginApi.openPanel(screen)
        }
    }

    function closePluginPanel(screen) {
        if (useOverlayMode) {
            overlayOpen = false
            overlayScreen = null
            pluginApi.closePanel(screen)
        } else {
            pluginApi.closePanel(screen)
        }
    }

    OverlayPanel {
        pluginApi: root.pluginApi
        isOpen: root.overlayOpen
        targetScreen: root.overlayScreen
        onCloseRequested: {
            root.overlayOpen = false
            root.overlayScreen = null
        }
    }

    IpcHandler {
        target: "plugin:qalculate"

        function showPanel() {
            pluginApi.withCurrentScreen(screen => {
                root.showPluginPanel(screen)
            })
        }

        function closePanel() {
            pluginApi.withCurrentScreen(screen => {
                root.closePluginPanel(screen)
            })
        }
    }
}
