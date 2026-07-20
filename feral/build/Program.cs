using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

if (args.Length > 1 && args[0] == "--inspect-magics")
{
    var terms = args.Skip(1).ToArray();
    var inspected = ModFactory<ISkyrimModGetter>.Importer(
        ModPath.FromPath(@"C:\Games\nefaram\Game Root\Data\Skyrim.esm"), GameRelease.SkyrimSE);
    foreach (var effect in inspected.MagicEffects.OrderBy(x => x.FormKey.ID))
        if (terms.Any(term => (effect.EditorID ?? "").Contains(term, StringComparison.OrdinalIgnoreCase)))
            Console.WriteLine($"MGEF|{effect.FormKey.ID:X6}|{effect.EditorID}|{effect.Archetype.Type}|{effect.Archetype.ActorValue}|{effect.CastType}|{effect.TargetType}|{effect.Flags}");
    foreach (var spell in inspected.Spells.OrderBy(x => x.FormKey.ID))
        if (terms.Any(term => (spell.EditorID ?? "").Contains(term, StringComparison.OrdinalIgnoreCase)))
            Console.WriteLine($"SPEL|{spell.FormKey.ID:X6}|{spell.EditorID}|{spell.Type}|{spell.TargetType}|{spell.Effects.Count}");
    return;
}

if (args.Length > 1 && args[0] == "--inspect-npcs")
{
    var terms = args.Skip(1).ToArray();
    var inspected = ModFactory<ISkyrimModGetter>.Importer(
        ModPath.FromPath(@"C:\Games\nefaram\Game Root\Data\Skyrim.esm"), GameRelease.SkyrimSE);
    foreach (var npc in inspected.Npcs.OrderBy(x => x.FormKey.ID))
        if (terms.Any(term => (npc.EditorID ?? "").Contains(term, StringComparison.OrdinalIgnoreCase)))
            Console.WriteLine($"NPC_|{npc.FormKey.ID:X6}|{npc.EditorID}|{npc.Name?.String}|{npc.Configuration.Flags}");
    return;
}

if (args.Length > 1 && args[0] == "--inspect-armors")
{
    var inspected = ModFactory<ISkyrimModGetter>.Importer(ModPath.FromPath(args[1]), GameRelease.SkyrimSE);
    foreach (var armor in inspected.Armors.OrderBy(x => x.FormKey.ID))
        Console.WriteLine($"{armor.FormKey.ID:X6}|{armor.EditorID}|{armor.Name?.String}");
    return;
}

if (args.Length > 1 && args[0] == "--inspect-shaders")
{
    var inspected = ModFactory<ISkyrimModGetter>.Importer(ModPath.FromPath(args[1]), GameRelease.SkyrimSE);
    foreach (var shader in inspected.EffectShaders.OrderBy(x => x.FormKey.ID))
        if ((shader.EditorID ?? "").Contains("Were", StringComparison.OrdinalIgnoreCase) ||
            (shader.EditorID ?? "").Contains("Transform", StringComparison.OrdinalIgnoreCase) ||
            (shader.EditorID ?? "").Contains("Spriggan", StringComparison.OrdinalIgnoreCase))
            Console.WriteLine($"{shader.FormKey.ID:X6}|{shader.EditorID}");
    return;
}

if (args.Length > 1 && args[0] == "--inspect-sounds")
{
    var inspected = ModFactory<ISkyrimModGetter>.Importer(ModPath.FromPath(args[1]), GameRelease.SkyrimSE);
    foreach (var sound in inspected.SoundDescriptors.OrderBy(x => x.FormKey.ID))
        if ((sound.EditorID ?? "").Contains("Werewolf", StringComparison.OrdinalIgnoreCase) &&
            ((sound.EditorID ?? "").Contains("Trans", StringComparison.OrdinalIgnoreCase) ||
             (sound.EditorID ?? "").Contains("Howl", StringComparison.OrdinalIgnoreCase)))
            Console.WriteLine($"{sound.FormKey.ID:X6}|{sound.EditorID}");
    return;
}

if (args.Length > 0 && args[0] == "--inspect-script-properties")
{
    foreach (var type in typeof(ScriptEntry).Assembly.GetTypes()
        .Where(x => x.Namespace == typeof(ScriptEntry).Namespace &&
                    x.Name.StartsWith("Script") && x.Name.Contains("Property")))
    {
        Console.WriteLine(type.FullName);
        foreach (var property in type.GetProperties())
            Console.WriteLine($"  {property.Name}: {property.PropertyType}");
    }
    return;
}

if (args.Length > 0 && args[0] == "--inspect-races")
{
    var masters = new[]
    {
        @"C:\Games\nefaram\Game Root\Data\Skyrim.esm",
        @"C:\Games\nefaram\Game Root\Data\Dawnguard.esm",
        @"C:\Games\nefaram\Game Root\Data\Dragonborn.esm"
    };
    foreach (var path in masters)
    {
        var master = ModFactory<ISkyrimModGetter>.Importer(
            ModPath.FromPath(path), GameRelease.SkyrimSE);
        foreach (var race in master.Races.Where(x =>
            new[] { "wolf", "sabre", "bear", "skeever", "spider", "mudcrab", "deer", "elk", "stag", "troll" }
                .Any(term => (x.EditorID ?? "").Contains(term, StringComparison.OrdinalIgnoreCase))))
            Console.WriteLine($"{master.ModKey}|{race.FormKey.ID:X6}|{race.EditorID}|{race.Name?.String}");
    }
    return;
}

if (args.Length > 0 && args[0] == "--inspect-dollform-globals")
{
    var inspected = ModFactory<ISkyrimModGetter>.Importer(
        ModPath.FromPath(@"C:\Games\nefaram\mods\[NoDelete] Bodymorph Alterations\Dollform.esp"),
        GameRelease.SkyrimSE);
    foreach (var global in inspected.Globals.OrderBy(x => x.FormKey.ID))
        Console.WriteLine($"{global.FormKey.ID:X6}|{global.EditorID}");
    return;
}

if (args.Length > 0 && args[0] == "--inspect-dollform-effects")
{
    var inspected = ModFactory<ISkyrimModGetter>.Importer(
        ModPath.FromPath(@"C:\Games\nefaram\mods\[NoDelete] Bodymorph Alterations\Dollform.esp"),
        GameRelease.SkyrimSE);
    foreach (var effect in inspected.MagicEffects.Where(x =>
        (x.EditorID ?? "").Contains("form", StringComparison.OrdinalIgnoreCase)))
        Console.WriteLine($"{effect.FormKey.ID:X6}|{effect.EditorID}|{effect.Flags}|{effect.Archetype.Type}");
    foreach (var spell in inspected.Spells.Where(x =>
        (x.EditorID ?? "").Contains("form", StringComparison.OrdinalIgnoreCase)))
        Console.WriteLine($"SPELL|{spell.FormKey.ID:X6}|{spell.EditorID}|{spell.Effects.FirstOrDefault()?.Data?.Duration}");
    return;
}

var outputPath = args.Length > 0
    ? args[0]
    : @"C:\Users\antho\nefaram-files\feral\build-output\Feral.esp";

var modKey = ModKey.FromNameAndExtension("Feral.esp");
var mod = new SkyrimMod(modKey, SkyrimRelease.SkyrimSE);
mod.ModHeader.MasterReferences.Add(new MasterReference
{
    Master = ModKey.FromNameAndExtension("Skyrim.esm")
});
mod.ModHeader.MasterReferences.Add(new MasterReference
{
    Master = ModKey.FromNameAndExtension("Dollform.esp")
});

FormKey Local(uint id) => new(modKey, id);
FormLinkNullable<T> LocalLink<T>(uint id) where T : class, IMajorRecordGetter => new(Local(id));

VirtualMachineAdapter ScriptAdapter(string scriptName) => new()
{
    Version = 5,
    ObjectFormat = 2,
    Scripts =
    {
        new ScriptEntry
        {
            Name = scriptName,
            Flags = ScriptEntry.Flag.Local
        }
    }
};

VirtualMachineAdapter PassiveScriptAdapter(int family, int rank)
{
    var adapter = ScriptAdapter("cfl_FeralPassiveEffect");
    var script = adapter.Scripts.Single();
    script.Properties.Add(new ScriptIntProperty { Name = "Family", Data = family });
    script.Properties.Add(new ScriptIntProperty { Name = "Rank", Data = rank });
    return adapter;
}

VirtualMachineAdapter ShapeScriptAdapter(int family, int rank)
{
    var adapter = ScriptAdapter("cfl_FeralShapeEffect");
    var script = adapter.Scripts.Single();
    script.Properties.Add(new ScriptIntProperty { Name = "Family", Data = family });
    script.Properties.Add(new ScriptIntProperty { Name = "Rank", Data = rank });
    return adapter;
}

VirtualMachineAdapter TechniqueScriptAdapter(int family)
{
    var adapter = ScriptAdapter("cfl_FeralTechniqueEffect");
    adapter.Scripts.Single().Properties.Add(new ScriptIntProperty { Name = "Family", Data = family });
    return adapter;
}

MagicEffect AddScriptEffect(uint id, string editorId, string name, string scriptName)
{
    var effect = new MagicEffect(Local(id), SkyrimRelease.SkyrimSE)
    {
        EditorID = editorId,
        Name = name,
        CastType = CastType.FireAndForget,
        TargetType = TargetType.Self,
        MagicSkill = ActorValue.None,
        Archetype = new MagicEffectArchetype
        {
            Type = MagicEffectArchetype.TypeEnum.Script
        },
        Flags = MagicEffect.Flag.HideInUI | MagicEffect.Flag.NoArea |
                MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoMagnitude,
        VirtualMachineAdapter = ScriptAdapter(scriptName)
    };
    mod.MagicEffects.Add(effect);
    return effect;
}

Effect Effect(uint magicEffectId, int duration = 0) => new()
{
    BaseEffect = LocalLink<IMagicEffectGetter>(magicEffectId),
    Data = new EffectData
    {
        Magnitude = 0,
        Area = 0,
        Duration = duration
    }
};

void AddPower(uint id, string editorId, string name, uint magicEffectId)
{
    mod.Spells.Add(new Spell(Local(id), SkyrimRelease.SkyrimSE)
    {
        EditorID = editorId,
        Name = name,
        Type = SpellType.LesserPower,
        CastType = CastType.FireAndForget,
        TargetType = TargetType.Self,
        ChargeTime = 0,
        BaseCost = 0,
        Effects = { Effect(magicEffectId) }
    });
}

AddScriptEffect(0x81A, "cfl_MGEFFeralClaim", "Claim soul (retired)", "cfl_FeralClaimEffect");
AddPower(0x81B, "cfl_SpellClaimSoul", "Claim soul (retired)", 0x81A);
AddScriptEffect(0x81C, "cfl_MGEFFeralAspect", "Feral act", "cfl_FeralAspectEffect");
AddPower(0x81D, "cfl_SpellFeralAct", "Feral act", 0x81C);

var familyNames = new[]
{
    "Wolf", "Sabre Cat", "Bear", "Skeever", "Spider", "Mudcrab", "Stag", "Troll"
};
for (var family = 1; family <= 8; family++)
{
    for (var rank = 1; rank <= 3; rank++)
    {
        var index = (family - 1) * 3 + (rank - 1);
        var effectId = 0x900u + (uint)index;
        var spellId = 0x920u + (uint)index;
        var compactName = familyNames[family - 1].Replace(" ", "");
        mod.MagicEffects.Add(new MagicEffect(Local(effectId), SkyrimRelease.SkyrimSE)
        {
            EditorID = $"cfl_MGEFFeralPassive{compactName}{rank}",
            Name = $"Feral {familyNames[family - 1]} rank {rank}",
            CastType = CastType.ConstantEffect,
            TargetType = TargetType.Self,
            MagicSkill = ActorValue.None,
            Archetype = new MagicEffectArchetype
            {
                Type = MagicEffectArchetype.TypeEnum.Script
            },
            Flags = MagicEffect.Flag.HideInUI | MagicEffect.Flag.NoArea |
                    MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoMagnitude,
            VirtualMachineAdapter = PassiveScriptAdapter(family, rank)
        });
        mod.Spells.Add(new Spell(Local(spellId), SkyrimRelease.SkyrimSE)
        {
            EditorID = $"cfl_AbilityFeral{compactName}{rank}",
            Name = $"Feral {familyNames[family - 1]} rank {rank}",
            Type = SpellType.Ability,
            CastType = CastType.ConstantEffect,
            TargetType = TargetType.Self,
            ChargeTime = 0,
            BaseCost = 0,
            Effects = { Effect(effectId) }
        });
    }
}

string ShapeDescription(int family)
{
    return family switch
    {
        1 => "+12% speed, +35% stamina regeneration, +15 unarmed damage, -15% magic resistance",
        2 => "+25 sneak, +25 unarmed damage, +10% attack speed, -25 health",
        3 => "+100 armor, +50 health, +25 stagger resistance, -20 sneak",
        4 => "+60% poison/disease resistance, +20 sneak, +30 carry weight, -15% fire resistance",
        5 => "+80% poison resistance, +30 unarmed damage, +15% speed, -20% stamina regeneration",
        6 => "+140 armor, +20 block, +30 stagger resistance, -8% speed",
        7 => "+15% speed, +80 stamina, +20 archery, -20 armor",
        8 => "+2 health regeneration, +25 melee damage, +60 health, -40% fire resistance, -8% speed",
        _ => ""
    };
}
for (var family = 1; family <= 8; family++)
{
    for (var rank = 1; rank <= 3; rank++)
    {
        var index = (family - 1) * 3 + (rank - 1);
        var effectId = 0x980u + (uint)index;
        var spellId = 0x9A0u + (uint)index;
        var compactName = familyNames[family - 1].Replace(" ", "");
        var duration = rank switch { 1 => 120, 2 => 300, _ => 600 };
        var effectName = $"Feral shape: {familyNames[family - 1]}";
        var description = $"Take the {familyNames[family - 1]} shape for {duration} seconds: {ShapeDescription(family)}. Strength scales with {familyNames[family - 1]} mastery (25% at level 1, 100% at level 100). Duration increases at mastery milestones. Cast again while transformed to revert. See the Feral MCM Progression and Families pages for details.";
        mod.MagicEffects.Add(new MagicEffect(Local(effectId), SkyrimRelease.SkyrimSE)
        {
            EditorID = $"cfl_MGEFFeralShape{compactName}{rank}",
            Name = effectName,
            Description = description,
            CastType = CastType.FireAndForget,
            TargetType = TargetType.Self,
            MagicSkill = ActorValue.None,
            Archetype = new MagicEffectArchetype { Type = MagicEffectArchetype.TypeEnum.Script },
            Flags = MagicEffect.Flag.Recover | MagicEffect.Flag.NoArea | MagicEffect.Flag.NoMagnitude,
            VirtualMachineAdapter = ShapeScriptAdapter(family, rank)
        });
        mod.Spells.Add(new Spell(Local(spellId), SkyrimRelease.SkyrimSE)
        {
            EditorID = $"cfl_SpellFeralShape{compactName}{rank}",
            Name = $"Feral shape: {familyNames[family - 1]}",
            Type = SpellType.LesserPower,
            CastType = CastType.FireAndForget,
            TargetType = TargetType.Self,
            ChargeTime = 0,
            BaseCost = 0,
            Effects = { Effect(effectId, duration) }
        });
    }
}

// Duration tiers four and five use fresh records so the original save-compatible
// tier-one through tier-three FormIDs remain stable.
for (var family = 1; family <= 8; family++)
{
    for (var rank = 4; rank <= 5; rank++)
    {
        var index = (family - 1) * 2 + (rank - 4);
        var effectId = 0xA30u + (uint)index;
        var spellId = 0xA40u + (uint)index;
        var compactName = familyNames[family - 1].Replace(" ", "");
        var duration = rank == 4 ? 900 : 1200;
        mod.MagicEffects.Add(new MagicEffect(Local(effectId), SkyrimRelease.SkyrimSE)
        {
            EditorID = $"cfl_MGEFFeralShape{compactName}{rank}",
            Name = $"Feral shape: {familyNames[family - 1]}",
            Description = $"Take the {familyNames[family - 1]} shape for {duration} seconds: {ShapeDescription(family)}. Strength scales with {familyNames[family - 1]} mastery (25% at level 1, 100% at level 100). Duration increases at mastery milestones. Cast again while transformed to revert. See the Feral MCM Progression and Families pages for details.",
            CastType = CastType.FireAndForget,
            TargetType = TargetType.Self,
            MagicSkill = ActorValue.None,
            Archetype = new MagicEffectArchetype { Type = MagicEffectArchetype.TypeEnum.Script },
            Flags = MagicEffect.Flag.Recover | MagicEffect.Flag.NoArea | MagicEffect.Flag.NoMagnitude,
            VirtualMachineAdapter = ShapeScriptAdapter(family, rank)
        });
        mod.Spells.Add(new Spell(Local(spellId), SkyrimRelease.SkyrimSE)
        {
            EditorID = $"cfl_SpellFeralShape{compactName}{rank}",
            Name = $"Feral shape: {familyNames[family - 1]}",
            Type = SpellType.LesserPower,
            CastType = CastType.FireAndForget,
            TargetType = TargetType.Self,
            ChargeTime = 0,
            BaseCost = 0,
            Effects = { Effect(effectId, duration) }
        });
    }
}

mod.MagicEffects.Add(new MagicEffect(Local(0x9C0), SkyrimRelease.SkyrimSE)
{
    EditorID = "cfl_MGEFFeralReturnToSelf",
    Name = "Return to self (retired)",
    Description = "Retired. Recast the active Feral shape to end it early. Kept only so existing saves can safely drop the old power.",
    CastType = CastType.FireAndForget,
    TargetType = TargetType.Self,
    MagicSkill = ActorValue.None,
    Archetype = new MagicEffectArchetype { Type = MagicEffectArchetype.TypeEnum.Script },
    Flags = MagicEffect.Flag.HideInUI | MagicEffect.Flag.NoArea |
            MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoMagnitude,
    VirtualMachineAdapter = ScriptAdapter("cfl_FeralRevertEffect")
});
mod.Spells.Add(new Spell(Local(0x9C1), SkyrimRelease.SkyrimSE)
{
    EditorID = "cfl_SpellFeralReturnToSelf",
    Name = "Return to self (retired)",
    Type = SpellType.LesserPower,
    CastType = CastType.FireAndForget,
    TargetType = TargetType.Self,
    ChargeTime = 0,
    BaseCost = 0,
    Effects = { Effect(0x9C0) }
});

var techniqueNames = new[]
{
    "Dread howl", "Vanish and pounce", "Maul", "Plague spit",
    "Web snare", "Fortress", "Stampede", "Monstrous regeneration"
};

mod.MagicEffects.Add(new MagicEffect(Local(0xA20), SkyrimRelease.SkyrimSE)
{
    EditorID = "cfl_MGEFFeralWitnessFear",
    Name = "Feral dread",
    CastType = CastType.FireAndForget,
    TargetType = TargetType.TargetActor,
    MagicSkill = ActorValue.None,
    Archetype = new MagicEffectArchetype
    {
        Type = MagicEffectArchetype.TypeEnum.Demoralize,
        ActorValue = ActorValue.Confidence
    },
    Flags = MagicEffect.Flag.Recover | MagicEffect.Flag.NoArea |
            MagicEffect.Flag.PowerAffectsDuration
});
mod.Spells.Add(new Spell(Local(0xA21), SkyrimRelease.SkyrimSE)
{
    EditorID = "cfl_SpellFeralWitnessFear",
    Name = "Feral dread",
    Type = SpellType.Spell,
    CastType = CastType.FireAndForget,
    TargetType = TargetType.TargetActor,
    ChargeTime = 0,
    BaseCost = 0,
    Effects =
    {
        new Effect
        {
            BaseEffect = LocalLink<IMagicEffectGetter>(0xA20),
            Data = new EffectData { Magnitude = 50, Area = 0, Duration = 10 }
        }
    }
});
var techniqueDescriptions = new[]
{
    "Terrifies nearby living enemies. Apex mastery strengthens the howl.",
    "Vanishes and greatly increases attack damage for 20 seconds.",
    "Greatly increases unarmed damage and stagger resistance for 20 seconds.",
    "Launches a concentrated poison attack; apex mastery uses stronger venom.",
    "Launches a paralysis snare at the target under the crosshair.",
    "Becomes nearly immovable for 20 seconds, trading speed for armor and block.",
    "Surges forward with greatly increased speed, stamina recovery, and archery for 20 seconds.",
    "Regenerates with monstrous speed for 20 seconds while becoming severely vulnerable to fire."
};
for (var family = 1; family <= 8; family++)
{
    var index = family - 1;
    var effectId = 0xA00u + (uint)index;
    var spellId = 0xA10u + (uint)index;
    mod.MagicEffects.Add(new MagicEffect(Local(effectId), SkyrimRelease.SkyrimSE)
    {
        EditorID = $"cfl_MGEFFeralTechnique{familyNames[index].Replace(" ", "")}",
        Name = techniqueNames[index],
        Description = techniqueDescriptions[index] + " Requires the matching active shape at mastery level 50; 60-second cooldown.",
        CastType = CastType.FireAndForget,
        TargetType = TargetType.Self,
        MagicSkill = ActorValue.None,
        Archetype = new MagicEffectArchetype { Type = MagicEffectArchetype.TypeEnum.Script },
        Flags = MagicEffect.Flag.Recover | MagicEffect.Flag.NoArea | MagicEffect.Flag.NoMagnitude,
        VirtualMachineAdapter = TechniqueScriptAdapter(family)
    });
    mod.Spells.Add(new Spell(Local(spellId), SkyrimRelease.SkyrimSE)
    {
        EditorID = $"cfl_SpellFeralTechnique{familyNames[index].Replace(" ", "")}",
        Name = $"Feral: {techniqueNames[index]}",
        Type = SpellType.LesserPower,
        CastType = CastType.FireAndForget,
        TargetType = TargetType.Self,
        ChargeTime = 0,
        BaseCost = 0,
        Effects = { Effect(effectId, 20) }
    });
}

// Keep the original quest record as an inert compatibility shell.  Saves made
// with the early build can retain its already-initialized VM instance, so the
// corrected MCM must use a fresh form to guarantee that OnInit runs.
var legacyQuest = new Quest(Local(0x81E), SkyrimRelease.SkyrimSE)
{
    EditorID = "cfl_FeralMCMQuestLegacy",
    Name = "Feral MCM (Legacy)",
    Priority = 0,
    QuestFormVersion = 65
};
mod.Quests.Add(legacyQuest);

var quest = new Quest(Local(0x950), SkyrimRelease.SkyrimSE)
{
    EditorID = "cfl_FeralMCMQuest",
    Name = "Feral MCM",
    Flags = Quest.Flag.StartGameEnabled,
    Priority = 0,
    QuestFormVersion = 65,
    VirtualMachineAdapter = new QuestAdapter
    {
        Version = 5,
        ObjectFormat = 2,
        FileName = "cfl_FeralMCM",
        Scripts =
        {
            new ScriptEntry
            {
                Name = "cfl_FeralMCM",
                Flags = ScriptEntry.Flag.Local
            }
        }
    }
};
mod.Quests.Add(quest);

Directory.CreateDirectory(Path.GetDirectoryName(outputPath)!);
mod.WriteToBinary(outputPath);

var built = ModFactory<ISkyrimModGetter>.Importer(
    ModPath.FromPath(outputPath), GameRelease.SkyrimSE);
if (built.MagicEffects.Count != 76 || built.Spells.Count != 76 || built.Quests.Count != 2)
    throw new InvalidOperationException("Feral record-count validation failed.");
var builtLegacyQuest = built.Quests.Single(x => x.FormKey.ID == 0x81E);
var builtQuest = built.Quests.Single(x => x.FormKey.ID == 0x950);
if (builtLegacyQuest.Flags.HasFlag(Quest.Flag.StartGameEnabled) ||
    builtLegacyQuest.VirtualMachineAdapter != null)
    throw new InvalidOperationException("Legacy Feral MCM quest is not inert.");
if (builtQuest.EditorID != "cfl_FeralMCMQuest" ||
    builtQuest.VirtualMachineAdapter?.Scripts.SingleOrDefault()?.Name != "cfl_FeralMCM" ||
    !builtQuest.Flags.HasFlag(Quest.Flag.StartGameEnabled))
    throw new InvalidOperationException("Feral MCM quest validation failed.");
if (built.Spells.Single(x => x.FormKey.ID == 0x81B).Name?.String != "Claim soul (retired)" ||
    built.Spells.Single(x => x.FormKey.ID == 0x81D).Name?.String != "Feral act")
    throw new InvalidOperationException("Feral power validation failed.");
if (built.MagicEffects.Single(x => x.FormKey.ID == 0xA20).Archetype.Type != MagicEffectArchetype.TypeEnum.Demoralize ||
    built.Spells.Single(x => x.FormKey.ID == 0xA21).Effects.Single().Data?.Duration != 10)
    throw new InvalidOperationException("Human witness fear validation failed.");

for (var family = 1; family <= 8; family++)
{
    for (var rank = 1; rank <= 3; rank++)
    {
        var index = (family - 1) * 3 + (rank - 1);
        var effect = built.MagicEffects.Single(x => x.FormKey.ID == 0x900u + index);
        var spell = built.Spells.Single(x => x.FormKey.ID == 0x920u + index);
        var script = effect.VirtualMachineAdapter?.Scripts.SingleOrDefault();
        var scriptFamily = script?.Properties.OfType<IScriptIntPropertyGetter>()
            .SingleOrDefault(x => x.Name == "Family")?.Data;
        var scriptRank = script?.Properties.OfType<IScriptIntPropertyGetter>()
            .SingleOrDefault(x => x.Name == "Rank")?.Data;
        if (script?.Name != "cfl_FeralPassiveEffect" || scriptFamily != family || scriptRank != rank ||
            spell.Type != SpellType.Ability || spell.Effects.Single().BaseEffect.FormKey != effect.FormKey)
            throw new InvalidOperationException($"Passive validation failed for family {family}, rank {rank}.");
    }
}

for (var family = 1; family <= 8; family++)
{
    var effect = built.MagicEffects.Single(x => x.FormKey.ID == 0xA00u + (uint)(family - 1));
    var spell = built.Spells.Single(x => x.FormKey.ID == 0xA10u + (uint)(family - 1));
    var script = effect.VirtualMachineAdapter?.Scripts.SingleOrDefault();
    var scriptFamily = script?.Properties.OfType<IScriptIntPropertyGetter>()
        .SingleOrDefault(x => x.Name == "Family")?.Data;
    if (script?.Name != "cfl_FeralTechniqueEffect" || scriptFamily != family ||
        spell.Type != SpellType.LesserPower || spell.Effects.Single().Data?.Duration != 20 ||
        spell.Effects.Single().BaseEffect.FormKey != effect.FormKey)
        throw new InvalidOperationException($"Technique validation failed for family {family}.");
}

for (var family = 1; family <= 8; family++)
{
    for (var rank = 1; rank <= 3; rank++)
    {
        var index = (family - 1) * 3 + (rank - 1);
        var effect = built.MagicEffects.Single(x => x.FormKey.ID == 0x980u + index);
        var spell = built.Spells.Single(x => x.FormKey.ID == 0x9A0u + index);
        var script = effect.VirtualMachineAdapter?.Scripts.SingleOrDefault();
        var scriptFamily = script?.Properties.OfType<IScriptIntPropertyGetter>()
            .SingleOrDefault(x => x.Name == "Family")?.Data;
        var scriptRank = script?.Properties.OfType<IScriptIntPropertyGetter>()
            .SingleOrDefault(x => x.Name == "Rank")?.Data;
        var expectedDuration = rank switch { 1 => 120, 2 => 300, _ => 600 };
        if (script?.Name != "cfl_FeralShapeEffect" || scriptFamily != family || scriptRank != rank ||
            spell.Type != SpellType.LesserPower || spell.Effects.Single().Data?.Duration != expectedDuration ||
            !effect.Flags.HasFlag(MagicEffect.Flag.Recover) ||
            effect.Flags.HasFlag(MagicEffect.Flag.HideInUI) || string.IsNullOrWhiteSpace(effect.Description?.String))
            throw new InvalidOperationException($"Shape validation failed for family {family}, rank {rank}.");
    }
}

for (var family = 1; family <= 8; family++)
{
    for (var rank = 4; rank <= 5; rank++)
    {
        var index = (family - 1) * 2 + (rank - 4);
        var effect = built.MagicEffects.Single(x => x.FormKey.ID == 0xA30u + index);
        var spell = built.Spells.Single(x => x.FormKey.ID == 0xA40u + index);
        var script = effect.VirtualMachineAdapter?.Scripts.SingleOrDefault();
        var scriptFamily = script?.Properties.OfType<IScriptIntPropertyGetter>()
            .SingleOrDefault(x => x.Name == "Family")?.Data;
        var scriptRank = script?.Properties.OfType<IScriptIntPropertyGetter>()
            .SingleOrDefault(x => x.Name == "Rank")?.Data;
        var expectedDuration = rank == 4 ? 900 : 1200;
        if (script?.Name != "cfl_FeralShapeEffect" || scriptFamily != family || scriptRank != rank ||
            spell.Type != SpellType.LesserPower || spell.Effects.Single().Data?.Duration != expectedDuration ||
            !effect.Flags.HasFlag(MagicEffect.Flag.Recover) || effect.Flags.HasFlag(MagicEffect.Flag.HideInUI) ||
            string.IsNullOrWhiteSpace(effect.Description?.String))
            throw new InvalidOperationException($"Extended shape validation failed for family {family}, rank {rank}.");
    }
}

var officialMasters = new Dictionary<string, ISkyrimModGetter>(StringComparer.OrdinalIgnoreCase)
{
    ["Skyrim.esm"] = ModFactory<ISkyrimModGetter>.Importer(
        ModPath.FromPath(@"C:\Games\nefaram\Game Root\Data\Skyrim.esm"), GameRelease.SkyrimSE),
    ["Dawnguard.esm"] = ModFactory<ISkyrimModGetter>.Importer(
        ModPath.FromPath(@"C:\Games\nefaram\Game Root\Data\Dawnguard.esm"), GameRelease.SkyrimSE),
    ["Dragonborn.esm"] = ModFactory<ISkyrimModGetter>.Importer(
        ModPath.FromPath(@"C:\Games\nefaram\Game Root\Data\Dragonborn.esm"), GameRelease.SkyrimSE)
};
var expectedRaces = new (string Plugin, uint Id, string EditorId)[]
{
    ("Skyrim.esm", 0x01320A, "WolfRace"),
    ("Skyrim.esm", 0x013200, "SabreCatRace"), ("Skyrim.esm", 0x013202, "SabreCatSnowyRace"),
    ("Dawnguard.esm", 0x00D0B6, "DLC1SabreCatGlowRace"),
    ("Skyrim.esm", 0x0131E7, "BearBrownRace"), ("Skyrim.esm", 0x0131E8, "BearBlackRace"),
    ("Skyrim.esm", 0x0131E9, "BearSnowRace"),
    ("Skyrim.esm", 0x013201, "SkeeverRace"), ("Skyrim.esm", 0x0C3EDF, "SkeeverWhiteRace"),
    ("Skyrim.esm", 0x0131F8, "FrostbiteSpiderRace"), ("Skyrim.esm", 0x053477, "FrostbiteSpiderRaceLarge"),
    ("Skyrim.esm", 0x04E507, "FrostbiteSpiderRaceGiant"),
    ("Dragonborn.esm", 0x014449, "DLC2ExpSpiderBaseRace"), ("Dragonborn.esm", 0x027483, "DLC2ExpSpiderPackmuleRace"),
    ("Skyrim.esm", 0x0BA545, "MudcrabRace"), ("Dragonborn.esm", 0x01B647, "DLC2MudcrabSolstheimRace"),
    ("Skyrim.esm", 0x0131ED, "ElkRace"), ("Skyrim.esm", 0x0CF89B, "DeerRace"),
    ("Skyrim.esm", 0x104F45, "WhiteStagRace"), ("Dawnguard.esm", 0x00D0B2, "DLC1DeerGlowRace"),
    ("Skyrim.esm", 0x013205, "TrollRace"), ("Skyrim.esm", 0x013206, "TrollFrostRace"),
    ("Dawnguard.esm", 0x0117F4, "DLC1TrollFrostRaceArmored"), ("Dawnguard.esm", 0x0117F5, "DLC1TrollRaceArmored")
};
foreach (var expected in expectedRaces)
{
    var race = officialMasters[expected.Plugin].Races.SingleOrDefault(x => x.FormKey.ID == expected.Id);
    if (race?.EditorID != expected.EditorId)
        throw new InvalidOperationException($"Race validation failed: {expected.Plugin} {expected.Id:X6} expected {expected.EditorId}, found {race?.EditorID ?? "missing"}.");
}

var dollform = ModFactory<ISkyrimModGetter>.Importer(
    ModPath.FromPath(@"C:\Games\nefaram\mods\[NoDelete] Bodymorph Alterations\Dollform.esp"),
    GameRelease.SkyrimSE);
var horseTier = dollform.Globals.SingleOrDefault(x => x.FormKey.ID == 0x802);
var trollTier = dollform.Globals.SingleOrDefault(x => x.FormKey.ID == 0x805);
if (horseTier?.EditorID != "cfl_HorseformMarkTier" || trollTier?.EditorID != "cfl_TrollformMarkTier")
    throw new InvalidOperationException("Bodymorph tier-global validation failed.");

using (var raceConfig = System.Text.Json.JsonDocument.Parse(File.ReadAllText(
    @"C:\Users\antho\nefaram-files\feral\config\Races.json")))
{
    foreach (var familyName in new[] { "Wolf", "SabreCat", "Bear", "Skeever", "Spider", "Mudcrab", "Stag", "Horse", "Troll" })
    {
        var plugins = raceConfig.RootElement.GetProperty(familyName + "Plugins");
        var formIds = raceConfig.RootElement.GetProperty(familyName + "FormIDs");
        if (plugins.ValueKind != System.Text.Json.JsonValueKind.Array ||
            formIds.ValueKind != System.Text.Json.JsonValueKind.Array ||
            plugins.GetArrayLength() != formIds.GetArrayLength())
            throw new InvalidOperationException($"Race config arrays are invalid for {familyName}.");
    }
}

Console.WriteLine($"Validated {outputPath}: 76 MGEF, 76 SPEL, 1 start-game QUST.");
