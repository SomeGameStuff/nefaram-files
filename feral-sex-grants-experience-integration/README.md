# Feral - Sex Grants Experience Integration

Optional progression and creature-kinship integration for **Sex Grants Experience 1.8.0** and Feral v13+.

- A SexLab or OStim scene grants ordinary Sex Grants Experience character XP only when any Feral shape was active when the scene began.
- A completed scene additionally grants 12 mastery when a starting creature participant matches that snapshotted Feral family. This is one award per scene, regardless of partner count, orgasms, animation changes, or duration.
- The scene-start snapshot remains valid if any duration-tier shape expires during the scene.
- Sex Grants Experience's existing scoring, victim, orgasm, multiplier, solo-scene, and cooldown settings remain authoritative for ordinary character XP after the Feral gate. They do **not** gate the separate 12-point Feral mastery award in the current implementation.

Example: start a SexLab scene in Wolf shape with a vanilla wolf participant. On scene end, Wolf gains 12 mastery. Transforming after the scene starts does not qualify it, and a wolf joining later is not checked. Dogs, werewolves, and custom wolf-like races are not implicit Wolf-family matches; add custom races to Feral's `SKSE\Plugins\Feral\Races.json`.

## Creature kinship

At mastery level 10 or higher, entering a shape temporarily neutralizes matching loaded creatures within 4096 units. The effect lowers each affected creature's current aggression to zero, stops combat, and restores the exact actor-value delta when removed. It does not permanently change factions or relationships. If the player or a player teammate attacks an affected creature, kinship breaks for that creature until the next transformation.

After 5 seconds in a qualifying shape, the controller checks every 15 seconds for a matching SexLab-valid creature within 1200 units. The creature must be alive, loaded, visible, out of combat, not commanded, not a teammate, and not already in a scene. SLO Aroused NG arousal favors candidates and raises the chance; elapsed checks provide a fallback that grows over the transformation. On success the creature approaches, then an **Accept / Refuse** prompt appears. Accept calls a consensual SexLab two-actor scene; Refuse starts nothing.

Only one prompt is allowed per transformation. An accepted scene starts a per-family cooldown of six game hours by default. Kinship is retained on the accepted partner if the shape expires mid-scene, then removed when the scene ends. The existing scene listener remains solely responsible for the +12 matching-family mastery award.

Feral's Settings page can toggle neutral kinship and approaches separately, set the minimum mastery level, select Rare/Occasional/Likely frequency, set the 1-24 game-hour accepted-scene cooldown, and request cleanup. The add-on does not manufacture creature animations, raise arousal, override SexLab actor validation, force nonconsensual scenes, or initiate OStim scenes.

This adapter adds progression, temporary matching-creature neutrality, and opt-in consensual SexLab approaches. It does not add animations, creature registration, animation selection, arousal changes, pregnancy, fertility, dialogue, or other adult mechanics. Sex Grants Experience 1.8.0 describes OStim as not supporting creature animations, so matching-creature progression normally depends on SexLab unless another OStim component supplies creature actors to scene events.

Install this mod after **Feral - Bodymorph Addon**, **Sex Grants Experience**, SexLab, SLO Aroused NG, PapyrusUtil, and powerofthree's Papyrus Extender in MO2. It overrides `SexLabExperience.pex` and `OStimExperience.pex`, and adds the ESL-flagged `FeralCreatureKinship.esp`, its start-game `SEQ`, three controller/effect scripts, and `SKSE\Plugins\Feral\SexIntegration.json`. The marker lets Feral's MCM report that the integration is installed and supplies the shared 12-mastery reward. Remove this integration to restore the original behavior.

The build is pinned to Sex Grants Experience 1.8.0 source hashes:

- `SexLabExperience.psc`: `28828B90595DB4B3DEDD0579CFF10395BC27FD1BCB6CFBF61E8874F043308579`
- `OStimExperience.psc`: `C4C992F74A29D8B46BA9DC47C5878D7CA2A133E732A1A49665817A459483C5F8`
- `SexLabExperience.pex`: `BB407477D4769DE2DD478EE7A5B5607AADDF4BADD35D8AE7BB7F85F87FF81E5D`
- `OStimExperience.pex`: `E4B179ABECBCB0BF731F01A845B3BB6895156EACB4D334EBCA2ACB0884DA7B09`
