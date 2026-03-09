# VoiceSkill

Audio notifications for Claude Code. Get a **chime** when Claude needs your attention, or upgrade to **spoken summaries** that tell you exactly what it wants.

Claude Code doesn't ship with audio notifications — when it's waiting for permission or finishes a task, there's no sound. VoiceSkill fixes that with two modes:

**Tone mode** (default) — plays a chime sound on notifications. Simple, useful, works out of the box.

**Voice mode** — speaks a short summary instead: *"Wants to run bash in my-api"*. Perfect when you're wearing headphones and working across multiple sessions. Hear what Claude needs, decide if it's urgent, keep your flow.

## What You Get

### Tone Mode (default)
A chime plays whenever Claude Code:
- Needs permission to use a tool
- Finishes a task
- Has a question for you

No more silently waiting tabs. Install it and forget it.

### Voice Mode (`/voice on`)
Instead of a chime, you hear short spoken summaries:

| Event | What you hear |
|---|---|
| Permission prompt | "Wants to run bash in my-project" |
| Permission prompt | "Wants to edit a file in my-api" |
| Task complete | "Done in VoiceSkill" |
| Question dialog | "Question for you in my-project" |

Messages include the **project name** so you can tell which session is calling when running multiple Claude Code instances.

## Install

```bash
git clone https://github.com/MRiless/VoiceSkill.git
cd VoiceSkill
bash install.sh
```

Restart Claude Code. You'll immediately start hearing chimes on notifications.

**If you already have hooks in `~/.claude/settings.json`**, the installer won't overwrite them — it'll print the JSON snippet to add manually.

## Usage

After install, chime notifications work automatically. To upgrade to spoken summaries:

```
/voice on    Enable spoken notifications
/voice off   Switch back to chime (default)
/voice       Check current mode
```

Voice mode persists across sessions until you toggle it off.

## Requirements

- **Claude Code** (CLI)
- **Windows** (Git Bash / MSYS2) or **macOS**
- No internet, no API keys, no dependencies — uses your OS's built-in text-to-speech

## How It Works

VoiceSkill uses Claude Code's [hooks system](https://docs.anthropic.com/en/docs/claude-code/hooks) to intercept notification events. When a notification fires:

1. The hook script receives JSON on stdin with the event type and message
2. It checks `~/.claude/voice-notify.json` for the current mode
3. **Tone mode**: plays a chime sound
4. **Voice mode**: maps the notification to a short spoken phrase via the platform's built-in TTS (Windows SAPI / macOS `say`)

Everything runs in the background — never blocks Claude Code.

## Customization

### Custom chime sound

Set the `VOICE_NOTIFY_CHIME` environment variable to your preferred WAV file:

```bash
export VOICE_NOTIFY_CHIME="C:\\Users\\you\\Music\\my-chime.wav"
```

### Adding tool mappings

Edit `~/.claude/hooks/voice-notify.sh` and add cases to the `map_permission_message()` function:

```bash
MyTool)  echo "Wants to use MyTool" ;;
```

## Files

| File | Location | Purpose |
|---|---|---|
| `voice-notify.sh` | `~/.claude/hooks/` | Hook script — chimes or speaks |
| `voice.md` | `~/.claude/commands/` | `/voice` slash command |
| `voice-notify.json` | `~/.claude/` | Config (`tone` or `voice`) |

## Uninstall

```bash
rm ~/.claude/hooks/voice-notify.sh
rm ~/.claude/commands/voice.md
rm ~/.claude/voice-notify.json
```

Then remove the VoiceSkill hook entries from `~/.claude/settings.json`.

## Platform Support

| Platform | TTS Engine | Latency |
|---|---|---|
| Windows (Git Bash / MSYS2) | SAPI via cscript | ~500ms |
| macOS | `say` command | ~200ms |

Both use built-in, offline, free text-to-speech. No internet required.

## License

MIT
