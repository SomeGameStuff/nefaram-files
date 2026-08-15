# Maria Eden Order Reminder Patch

Replaces Maria Eden's generic scene-loop barks (for example, “How much longer am I
supposed to wait?”) with scene-specific reminders of the action the player is meant
to perform.

The patch overrides dialogue topics only. It does not replay quest fragments or
scene scripts. Build output is generated from the winning English-translated
`MariaProstitution.esp` so the reminders remain compatible with that translation.

## Build

Run `Build.ps1`. The generated ESP and audit TSV are written under `build-output`.
