# Feral v5 consolidated playtest

Use a disposable copy of the current save.

1. Load, wait 30 seconds, and confirm Status, Instincts, and Settings display v5 pending-essence, fatigue, expression, XP mode, and cosmetic fields.
2. Kill several supported creatures personally during one fight. Confirm every essence is queued, follower kills are ignored, and one Claim Soul cast harvests the entire queue.
3. Confirm each corpse expires independently at 60/180/300-second window settings and cannot be claimed twice.
4. For every family, use developer tools to set one claim below each rarity-specific threshold, simulate a claim, and verify ranks and power replacement.
5. At intermediate counts, verify the MCM expression percentage, stats, and morph intensity increase with every claim rather than only at ranks.
6. Cast every rank-1/2/3 shape. Verify its exact combat kit, distinct silhouette, matching staged body texture, visible Active Effect, entry shader/sound, and shared Bodymorph lock.
7. At rank-3 Stag, confirm TDN elk horns equip only when available, are removed afterward, and pre-owned/pre-equipped items are never deleted.
8. Use Return to Self and natural 120-second expiration. Confirm stats, `Feral.Shapes` morph keys, tattoo, optional cosmetic, active storage, and lock clear exactly once without a long freeze or repeated body rebuild.
9. Rapidly cast a shape, end it, wait through fatigue, and cast the same and then a different shape. Confirm a late cleanup never removes the newer shape, statistics return exactly to baseline, and the shared lock displays the correct family/token throughout.
10. Confirm a new shape is blocked for 15 seconds after cleanup and the MCM countdown reaches Ready.
11. Confirm Bodymorph forms block Feral and Feral blocks Bodymorph, with names 101-108 displayed correctly even though the raw lock now includes an ownership token.
12. Test Off, Balanced, and Hardcore XP modes. Verify Balanced preserves quest/discovery/clear rewards, Hardcore suppresses them, and Off restores the exact snapshot.
13. Disable Feral while transformed, save/reload, die while transformed, and run MCM cleanup. Confirm no permanent stats, overlays, cosmetics, or stale lock remain.
14. Capture front/side/back screenshots for all 24 visual stages. Treat excessive coverage, UV seams, stretching, and weak contrast as art blockers rather than assuming the flat contact sheet proves in-game quality.
