# Feral v9 consolidated playtest

Use a disposable copy of the current save.

1. Load, wait 30 seconds, and confirm Status, Instincts, and Settings display v9 automatic harvesting, mastery, fatigue, continuous expression, milestone kits, human response, notoriety, and XP mode. Confirm Claim Soul and retired stage powers are absent.
2. Personally kill one supported family and confirm its essence is harvested immediately, its count and mastery increase once, and no cast is required. Confirm follower, NPC-versus-NPC, and unsupported kills produce no Feral work or notification.
3. Migrate the existing save and verify historical counts became sensible rarity-weighted mastery levels without losing any count.
4. For every family, test levels 24/25, 49/50, 74/75, and 99/100. Verify traits appear at 25/75, one technique appears at 50, the same technique becomes Apex at 100, and reset removes it.
5. Cast at levels 1, 50, and 100. Confirm expression, statistics, morph magnitude, and marking opacity grow smoothly from 25% to 100%; milestone trait deltas apply and restore exactly.
6. Cast every family shape. Verify its exact combat kit, distinct silhouette, detailed body marking, visible Active Effect, entry shader/sound, and shared Bodymorph lock.
7. End a shape before 10 seconds and confirm no use mastery. End after roughly 10-29 seconds and confirm elapsed-time mastery is awarded once. Let a full shape expire and confirm it grants at most 12 mastery and, with Feral Path active, at most 12 character XP.
8. Cast all eight techniques in their matching shapes. Verify mismatched/unmorphed casts fail, level-100 magnitude is stronger, the 60-second cooldown works, and Return to Self ends active technique buffs without leaving actor values behind.
9. Use Return to Self and natural 120-second expiration. Confirm stats, `Feral.Shapes` morph keys, tattoo, optional cosmetic, active storage, and lock clear exactly once without a long freeze or repeated body rebuild.
10. Rapidly cast a shape, end it, wait through fatigue, and cast the same and then a different shape. Confirm a late cleanup never removes the newer shape, statistics return exactly to baseline, and the shared lock displays the correct family/token throughout.
11. Confirm a new shape is blocked for 15 seconds after cleanup and the MCM countdown reaches Ready.
12. Confirm Bodymorph forms block Feral and Feral blocks Bodymorph, with names 101-108 displayed correctly even though the raw lock includes an ownership token.
13. Test Off, Balanced, and Hardcore XP modes. Verify harvest and shape-use XP, Balanced quest/discovery/clear rewards, Hardcore suppression, and exact restoration when switched Off.
14. With the optional integration enabled, verify: no-morph SexLab/OStim scenes grant no Sex Grants Experience XP; any start-of-scene Feral shape permits ordinary XP; only a matching creature grants 12 family mastery; a shape expiring mid-scene remains qualified; upstream orgasm/victim/cooldown settings still apply.
15. Test Human Response Off, Reactions, and Full. Confirm unwitnessed/blocked-LOS shapes add nothing, multiple potential witnesses add only 5 per cast, witnessed human kills add 15, and quiet days decay notoriety lazily.
16. Force notoriety 40/60/80/100. Confirm witness fear, once-per-day guard bounty, three-day hunter cooldown, no duplicate live hunter groups, elite level-100 group, and cleanup after hunters die.
17. Disable Feral while transformed, save/reload, die while transformed, and run MCM cleanup. Confirm no permanent base/trait/technique stats, overlays, cosmetics, stale lock, hunter duplication, pending corpse list, or duplicate mastery award remains.
18. Capture front/side/back screenshots at levels 1, 50, and 100 for each family, with extra level-25/75 samples where interpolation looks uneven. Treat excessive coverage, UV seams, stretching, and weak contrast as art blockers rather than assuming the flat contact sheet proves in-game quality.
