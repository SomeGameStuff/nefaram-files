# Repository privacy and portability

The repository is public. Never commit a path, username, hostname, drive layout,
download filename, local archive name, save/log location, secret filename, or other
detail that identifies a particular computer.

Use portable terms such as `<repo-root>`, `<mo2-root>`, `<game-data>`,
`<vanilla-source>`, and `<local-download>` in documentation and examples. Build
tools must take machine-specific locations from command-line parameters, environment
variables, or ignored local configuration files. Generated reports and comparison
outputs that can contain local paths stay ignored and are not release content.

Common local build inputs use names such as `NEFARAM_MO2_ROOT`,
`NEFARAM_GAME_DATA`, `NEFARAM_PAPYRUS_COMPILER`, `NEFARAM_VANILLA_SOURCE`, and
`NEFARAM_TEXCONV`; their values belong in the local environment, never in tracked
files.

Before committing, scan tracked text with a drive-path and home-directory search, and
review the complete diff for usernames, hostnames, personal folders, and machine
inventory. This rule applies to source, documentation, logs, reports, examples,
skills, and release metadata.
