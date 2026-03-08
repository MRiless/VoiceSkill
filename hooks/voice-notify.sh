#!/usr/bin/env bash
# voice-notify.sh — Claude Code notification hook
# Speaks tool-specific summaries (voice mode) or plays chime (tone mode)
# Config: ~/.claude/voice-notify.json  {"mode":"tone"} or {"mode":"voice"}

set -eo pipefail

CONFIG_FILE="$HOME/.claude/voice-notify.json"
CHIME_WAV="${VOICE_NOTIFY_CHIME:-C:\\Windows\\Media\\Windows Notify System Generic.wav}"
TMPVBS=""
trap 'rm -f "$TMPVBS"' EXIT

# --- Read stdin (JSON from Claude Code) ---
INPUT=$(cat 2>/dev/null) || true
if [[ -z "$INPUT" ]]; then
  exit 0
fi

# --- Parse JSON fields with sed (no jq dependency) ---
extract_field() {
  echo "$INPUT" | sed -n 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1
}

HOOK_EVENT=$(extract_field "hook_event_name")
NOTIFY_TYPE=$(extract_field "notification_type")
MESSAGE=$(extract_field "message")
CWD=$(extract_field "cwd")

# --- Read config (default to tone on any failure) ---
MODE="tone"
if [[ -f "$CONFIG_FILE" ]]; then
  FILE_MODE=$(sed -n 's/.*"mode"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_FILE" 2>/dev/null | head -1)
  if [[ "$FILE_MODE" == "voice" ]]; then
    MODE="voice"
  fi
fi

# --- Detect platform ---
OS=$(uname -s)
play_tone() {
  case "$OS" in
    MINGW*|MSYS*|CYGWIN*)
      powershell.exe -Command "(New-Object Media.SoundPlayer '$CHIME_WAV').PlaySync()" &
      ;;
    Darwin)
      afplay ~/Music/chime.wav &
      ;;
  esac
}

speak() {
  local text="$1"
  case "$OS" in
    MINGW*|MSYS*|CYGWIN*)
      TMPVBS=$(mktemp /tmp/voice-notify.XXXXXX.vbs)
      cat > "$TMPVBS" << VBSEOF
Dim oVoice
Set oVoice = CreateObject("SAPI.SpVoice")
oVoice.Rate = 3
oVoice.Volume = 100
oVoice.Speak "$text"
VBSEOF
      local winpath
      winpath=$(cygpath -w "$TMPVBS")
      # Run in subshell so cscript finishes before file cleanup
      (cscript //nologo "$winpath"; rm -f "$TMPVBS") &
      TMPVBS=""  # Subshell owns cleanup now
      ;;
    Darwin)
      say -r 190 "$text" &
      ;;
  esac
}

# --- Map tool name to spoken phrase ---
map_permission_message() {
  local tool
  # Extract tool name: "Claude needs your permission to use <Tool>"
  tool=$(echo "$MESSAGE" | sed -n 's/.*permission to use \([A-Za-z]*\).*/\1/p')

  case "$tool" in
    Bash)        echo "Wants to run bash" ;;
    Edit)        echo "Wants to edit a file" ;;
    Write)       echo "Wants to write a file" ;;
    Read)        echo "Wants to read a file" ;;
    Glob)        echo "Wants to search files" ;;
    Grep)        echo "Wants to search files" ;;
    Agent)       echo "Launching an agent" ;;
    WebFetch)    echo "Wants to fetch a webpage" ;;
    WebSearch)   echo "Wants to search the web" ;;
    Skill)       echo "Wants to use a skill" ;;
    ToolSearch)  echo "Wants to find a tool" ;;
    "")          echo "Needs attention" ;;
    *)           echo "Needs permission for $tool" ;;
  esac
}

# --- Determine what to say ---
# --- Extract project name from cwd for context ---
PROJECT=""
if [[ -n "$CWD" ]]; then
  PROJECT=$(basename "$CWD")
fi

SAY=""
case "$HOOK_EVENT" in
  Stop)
    if [[ -n "$PROJECT" ]]; then
      SAY="Done in $PROJECT"
    else
      SAY="Done"
    fi
    ;;
  Notification)
    case "$NOTIFY_TYPE" in
      permission_prompt)
        SAY=$(map_permission_message)
        if [[ -n "$PROJECT" ]]; then
          SAY="$SAY in $PROJECT"
        fi
        ;;
      elicitation_dialog)
        if [[ -n "$PROJECT" ]]; then
          SAY="Question for you in $PROJECT"
        else
          SAY="Question for you"
        fi
        ;;
      *)
        SAY="Notification"
        ;;
    esac
    ;;
  *)
    SAY="Notification"
    ;;
esac

# --- Dispatch based on mode ---
if [[ "$MODE" == "voice" ]]; then
  if ! speak "$SAY" 2>/dev/null; then
    # TTS failed — fall back to tone
    play_tone
  fi
else
  play_tone
fi
