# VoiceSkill

Turn Claude Code's notification chime into spoken summaries. When Claude needs your attention, instead of a generic beep, you hear exactly what it wants — like a colleague tapping your shoulder.

**"Wants to run bash in my-api"** instead of *ding*.

Perfect for when you're wearing headphones and working across multiple terminal sessions. Hear what Claude needs, decide if it's urgent, and keep your flow.

## What You'll Hear

| Event | Example |
|---|---|
| Permission prompt | "Wants to run bash in my-project" |
| Permission prompt | "Wants to edit a file in my-api" |
| Task complete | "Done in VoiceSkill" |
| Question dialog | "Question for you in my-project" |

Messages include the **project name** so you can tell which session is asking when running multiple Claude Code instances.

## Requirements

- **Claude Code** (CLI)
- **Windows** (uses built-in SAPI text-to-speech) or **macOS** (uses built-in `say` command)
- No internet, no API keys, no dependencies

## Install

```bash
git clone https://github.com/MRiless/VoiceSkill.git
cd VoiceSkill
bash install.sh
```

The install script copies the hook and command files to `~/.claude/` and sets up the config.

**If you already have hooks in `~/.claude/settings.json`**, the installer won't overwrite them — it'll print the JSON snippet you need to add manually.

**If you're starting fresh**, it creates `settings.json` for you.

After installing, **restart Claude Code**.

## Usage

```
/voice on    Enable spoken notifications
/voice off   Switch back to chime tones (default)
/voice       Check current mode
```

Voice mode persists across sessions until you toggle it off.

## How It Works

VoiceSkill uses Claude Code's [hooks system](https://docs.anthropic.com/en/docs/claude-code/hooks) to intercept notification events. When a notification fires:

1. The hook script receives JSON on stdin with the event type and message
2. It checks `~/.claude/voice-notify.json` for the current mode
3. **Tone mode**: plays a chime sound (default behavior)
4. **Voice mode**: maps the notification to a short spoken phrase and speaks it via the platform's built-in TTS

The speech runs in the background so it never blocks Claude Code.

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
| `voice-notify.sh` | `~/.claude/hooks/` | Hook script — speaks or chimes |
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
