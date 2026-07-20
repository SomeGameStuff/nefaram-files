# Feral - Sex Grants Experience Integration

Optional loose-script integration for **Sex Grants Experience 1.8.0** and Feral v12+.

- A SexLab or OStim scene grants ordinary Sex Grants Experience character XP only when any Feral shape was active when the scene began.
- A completed scene additionally grants 12 mastery when a creature participant matches that snapshotted Feral family.
- The scene-start snapshot remains valid if any duration-tier shape expires during the scene.
- Sex Grants Experience's existing scoring, victim, orgasm, multiplier, solo-scene, and cooldown settings remain authoritative after the Feral gate.

Install this mod after both **Feral - Bodymorph Addon** and **Sex Grants Experience** in MO2. It overrides only `SexLabExperience.pex` and `OStimExperience.pex` and adds `SKSE\Plugins\Feral\SexIntegration.json`. The marker lets Feral's MCM report that the integration is installed and supplies the shared 12-mastery reward. Remove this integration to restore the original behavior.

The build is pinned to Sex Grants Experience 1.8.0 source hashes:

- `SexLabExperience.psc`: `28828B90595DB4B3DEDD0579CFF10395BC27FD1BCB6CFBF61E8874F043308579`
- `OStimExperience.psc`: `C4C992F74A29D8B46BA9DC47C5878D7CA2A133E732A1A49665817A459483C5F8`
- `SexLabExperience.pex`: `BB407477D4769DE2DD478EE7A5B5607AADDF4BADD35D8AE7BB7F85F87FF81E5D`
- `OStimExperience.pex`: `E4B179ABECBCB0BF731F01A845B3BB6895156EACB4D334EBCA2ACB0884DA7B09`
