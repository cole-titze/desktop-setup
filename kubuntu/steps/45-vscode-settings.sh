#!/usr/bin/env bash
set -euo pipefail

echo "==> Configuring VS Code settings"

SETTINGS_DIR="$HOME/.config/Code/User"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

mkdir -p "$SETTINGS_DIR"

cat > "$SETTINGS_FILE" <<'EOF'
{
    "workbench.colorTheme": "Default Dark Modern",
    "workbench.iconTheme": "vs-seti",
    "workbench.startupEditor": "none",

    "editor.fontSize": 14,
    "editor.fontFamily": "'SF Mono', 'JetBrains Mono NL', 'Roboto Mono', 'Consolas', 'Courier New', monospace",
    "editor.fontLigatures": false,
    "editor.lineNumbers": "on",
    "editor.wordWrap": "on",
    "editor.minimap.enabled": true,
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "editor.formatOnSave": true,
    "editor.formatOnPaste": true,

    "files.autoSave": "off",
    "files.trimTrailingWhitespace": true,

    "terminal.integrated.fontSize": 14,

    "explorer.confirmDelete": true,
    "explorer.confirmDragAndDrop": true,

    "git.autofetch": false,
    "git.confirmSync": false,

    "extensions.autoUpdate": true
}
EOF

echo "45-vscode-settings complete"
