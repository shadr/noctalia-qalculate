# Noctalia Qalculate

A Noctalia plugin that provides a quick calculator panel powered by qalculate.

<p align="center">
  <img src="/assets/preview.png" alt="Screenshot of the calculator panel with an input text box and history entries visible" />
</p>

## Features

- Uses amazing [libqalculate](https://github.com/qalculate/libqalculate)
- Persistent expression history
- Copy results to clipboard

## Requirements

- [qalc](https://github.com/qalculate/libqalculate)

## Installation

1. Clone this repository into your Noctalia plugins directory:

```sh
cd ~/.local/share/noctalia/plugins/
git clone https://github.com/shadr/noctalia-qalculate
```

2. Enable the plugin in Noctalia settings

3. Bind a key to open the calculator panel

## Usage

### IPC Command

The plugin exposes an IPC endpoint to show the calculator panel:

```sh
noctalia-shell ipc call plugin:qalculate showPanel
```

### Keyboard Shortcuts

Once the panel is open:

- **Enter** - Save current calculation to history
- **Ctrl+C** - Copy result to clipboard
- **Esc** - Close panel

## Key Binding Examples

#### Niri

```
binds {
    Mod+A { spawn "noctalia-shell" "ipc" "call" "plugin:qalculate" "showPanel"; }
}
```

#### Hyprland

```
bind = Mod+A, exec, noctalia-shell ipc call plugin:qalculate showPanel
```

## License

MIT License - See [LICENSE](LICENSE) for details.
