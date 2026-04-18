import QtQuick
import Quickshell.Io
import qs.Services.UI

Item {
  property var pluginApi: null

  IpcHandler {
    target: "plugin:qalculate"

    function showPanel() {
        // Need to get screen reference asynchronously
      pluginApi.withCurrentScreen(screen => {
        pluginApi.openPanel(screen);
      });
    }
  }
}
