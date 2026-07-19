using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

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
            new[] { "wolf", "sabre", "bear", "skeever", "spider", "mudcrab", "horse", "troll" }
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

AddScriptEffect(0x81A, "cfl_MGEFFeralClaim", "Claim Soul", "cfl_FeralClaimEffect");
AddPower(0x81B, "cfl_SpellClaimSoul", "Claim Soul", 0x81A);
AddScriptEffect(0x81C, "cfl_MGEFFeralAspect", "Feral Act", "cfl_FeralAspectEffect");
AddPower(0x81D, "cfl_SpellFeralAct", "Feral Act", 0x81C);

var familyNames = new[]
{
    "Wolf", "Sabre Cat", "Bear", "Skeever", "Spider", "Mudcrab", "Horse", "Troll"
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
            Name = $"Feral {familyNames[family - 1]} Rank {rank}",
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
            Name = $"Feral {familyNames[family - 1]} Rank {rank}",
            Type = SpellType.Ability,
            CastType = CastType.ConstantEffect,
            TargetType = TargetType.Self,
            ChargeTime = 0,
            BaseCost = 0,
            Effects = { Effect(effectId) }
        });
    }
}

double ShapeScale(int rank) => rank == 1 ? 0.50 : rank == 2 ? 0.75 : 1.00;
string Value(double value) => value.ToString("0.##", System.Globalization.CultureInfo.InvariantCulture);
string ShapeDescription(int family, int rank)
{
    var scale = ShapeScale(rank);
    return family switch
    {
        1 => $"+{Value(15 * scale)}% speed and +{Value(25 * scale)}% stamina regeneration",
        2 => $"+{Value(15 * scale)} Sneak and +{Value(15 * scale)} unarmed damage",
        3 => $"+{Value(80 * scale)} armor and +{Value(40 * scale)} Health",
        4 => $"+{Value(50 * scale)}% poison and disease resistance",
        5 => $"+{Value(75 * scale)}% poison resistance",
        6 => $"+{Value(65 * scale)} armor",
        7 => $"+{Value(20 * scale)}% speed and +{Value(60 * scale)} Stamina",
        8 => $"+{Value(2 * scale)} Health regeneration and -{Value(35 * scale)}% fire resistance",
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
        var percent = rank == 1 ? 50 : rank == 2 ? 75 : 100;
        mod.MagicEffects.Add(new MagicEffect(Local(effectId), SkyrimRelease.SkyrimSE)
        {
            EditorID = $"cfl_MGEFFeralShape{compactName}{rank}",
            Name = $"Feral Shape: {familyNames[family - 1]} (Rank {rank})",
            Description = $"{percent}% expression: {ShapeDescription(family, rank)}. Applies a reversible {familyNames[family - 1]} body morph for 120 seconds.",
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
            Name = $"Feral Shape: {familyNames[family - 1]}",
            Type = SpellType.LesserPower,
            CastType = CastType.FireAndForget,
            TargetType = TargetType.Self,
            ChargeTime = 0,
            BaseCost = 0,
            Effects = { Effect(effectId, 120) }
        });
    }
}

mod.MagicEffects.Add(new MagicEffect(Local(0x9C0), SkyrimRelease.SkyrimSE)
{
    EditorID = "cfl_MGEFFeralReturnToSelf",
    Name = "Return to Self",
    Description = "Ends the current Feral transformation and clears its temporary body changes.",
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
    Name = "Return to Self",
    Type = SpellType.LesserPower,
    CastType = CastType.FireAndForget,
    TargetType = TargetType.Self,
    ChargeTime = 0,
    BaseCost = 0,
    Effects = { Effect(0x9C0) }
});

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
if (built.MagicEffects.Count != 51 || built.Spells.Count != 51 || built.Quests.Count != 2)
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
if (built.Spells.Single(x => x.FormKey.ID == 0x81B).Name?.String != "Claim Soul" ||
    built.Spells.Single(x => x.FormKey.ID == 0x81D).Name?.String != "Feral Act")
    throw new InvalidOperationException("Feral power validation failed.");

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
        if (script?.Name != "cfl_FeralShapeEffect" || scriptFamily != family || scriptRank != rank ||
            spell.Type != SpellType.LesserPower || spell.Effects.Single().Data?.Duration != 120 ||
            !effect.Flags.HasFlag(MagicEffect.Flag.Recover) ||
            effect.Flags.HasFlag(MagicEffect.Flag.HideInUI) || string.IsNullOrWhiteSpace(effect.Description?.String))
            throw new InvalidOperationException($"Shape validation failed for family {family}, rank {rank}.");
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
    ("Skyrim.esm", 0x0131FD, "HorseRace"), ("Skyrim.esm", 0x0DE505, "CartHorseRace"),
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
    foreach (var familyName in new[] { "Wolf", "SabreCat", "Bear", "Skeever", "Spider", "Mudcrab", "Horse", "Troll" })
    {
        var plugins = raceConfig.RootElement.GetProperty(familyName + "Plugins");
        var formIds = raceConfig.RootElement.GetProperty(familyName + "FormIDs");
        if (plugins.ValueKind != System.Text.Json.JsonValueKind.Array ||
            formIds.ValueKind != System.Text.Json.JsonValueKind.Array ||
            plugins.GetArrayLength() != formIds.GetArrayLength())
            throw new InvalidOperationException($"Race config arrays are invalid for {familyName}.");
    }
}

Console.WriteLine($"Validated {outputPath}: 51 MGEF, 51 SPEL, 1 start-game QUST.");
