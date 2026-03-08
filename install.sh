#!/usr/bin/env bash
# install.sh — Install VoiceSkill for Claude Code
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing VoiceSkill..."

# Create directories
mkdir -p "$HOME/.claude/hooks"
mkdir -p "$HOME/.claude/commands"

# Copy hook script
cp "$SCRIPT_DIR/hooks/voice-notify.sh" "$HOME/.claude/hooks/voice-notify.sh"
chmod +x "$HOME/.claude/hooks/voice-notify.sh"
echo "  Installed hook:    ~/.claude/hooks/voice-notify.sh"

# Copy slash command
cp "$SCRIPT_DIR/commands/voice.md" "$HOME/.claude/commands/voice.md"
echo "  Installed command: ~/.claude/commands/voice.md"

# Create config with default (tone) if it doesn't exist
if [[ ! -f "$HOME/.claude/voice-notify.json" ]]; then
  echo '{"mode":"tone"}' > "$HOME/.claude/voice-notify.json"
  echo "  Created config:   ~/.claude/voice-notify.json (default: tone)"
else
  echo "  Config exists:    ~/.claude/voice-notify.json (unchanged)"
fi

# Check if settings.json exists and needs hook registration
SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$SETTINGS" ]]; then
  if grep -q "voice-notify.sh" "$SETTINGS" 2>/dev/null; then
    echo "  Hooks already registered in settings.json"
  else
    echo ""
    echo "  NOTE: You need to add the hooks to your ~/.claude/settings.json"
    echo "  Add the following to your \"hooks\" section (or create one):"
    echo ""
    cat "$SCRIPT_DIR/hooks.json"
    echo ""
  fi
else
  # Create settings.json with hooks
  cp "$SCRIPT_DIR/hooks.json" "$SETTINGS"
  echo "  Created settings: ~/.claude/settings.json with hooks"
fi

echo ""
echo "Done! Restart Claude Code, then:"
echo "  /voice on   — enable spoken notifications"
echo "  /voice off  — switch back to chime tones"
echo "  /voice      — check current mode"
