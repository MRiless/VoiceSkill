Toggle voice notifications on or off. Voice mode speaks tool-specific summaries through your headphones instead of playing a chime tone.

## Instructions

Parse the argument: "$ARGUMENTS"

- If the argument is "on":
  1. Run this bash command: `echo '{"mode":"voice"}' > ~/.claude/voice-notify.json`
  2. Respond: "Voice notifications on. You'll hear spoken summaries instead of chimes. `/voice off` to switch back."

- If the argument is "off":
  1. Run this bash command: `echo '{"mode":"tone"}' > ~/.claude/voice-notify.json`
  2. Respond: "Voice notifications off. Back to chime tones. `/voice on` to re-enable."

- If no argument or empty:
  1. Run this bash command: `cat ~/.claude/voice-notify.json 2>/dev/null || echo '{"mode":"tone"}'`
  2. Report the current mode: "Voice notifications are currently **[mode]**. `/voice on` or `/voice off` to toggle."
