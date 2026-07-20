using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

var outputPath = args.Length > 0
    ? args[0]
    : @"C:\Users\antho\nefaram-files\feral-sex-grants-experience-integration\FeralCreatureKinship.esp";

var modKey = ModKey.FromNameAndExtension("FeralCreatureKinship.esp");
var mod = new SkyrimMod(modKey, SkyrimRelease.SkyrimSE);
mod.ModHeader.Flags = SkyrimModHeader.HeaderFlag.Small;
foreach (var master in new[] { "Skyrim.esm", "Feral.esp", "SexLab.esm", "SexLabAroused.esm", "SexGrantsExperience.esp" })
{
    mod.ModHeader.MasterReferences.Add(new MasterReference
    {
        Master = ModKey.FromNameAndExtension(master)
    });
}

FormKey Local(uint id) => new(modKey, id);
FormLinkNullable<T> LocalLink<T>(uint id) where T : class, IMajorRecordGetter => new(Local(id));

VirtualMachineAdapter EffectScript(string scriptName) => new()
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

QuestAdapter QuestScript(string scriptName) => new()
{
    Version = 5,
    ObjectFormat = 2,
    FileName = scriptName,
    Scripts =
    {
        new ScriptEntry
        {
            Name = scriptName,
            Flags = ScriptEntry.Flag.Local
        }
    }
};

Effect EffectLink(uint effectId) => new()
{
    BaseEffect = LocalLink<IMagicEffectGetter>(effectId),
    Data = new EffectData { Magnitude = 0, Area = 0, Duration = 0 }
};

MagicEffect AddScriptEffect(uint id, string editorId, string name, string scriptName)
{
    var effect = new MagicEffect(Local(id), SkyrimRelease.SkyrimSE)
    {
        EditorID = editorId,
        Name = name,
        Description = "Temporary Feral creature-kinship behavior.",
        CastType = CastType.ConstantEffect,
        TargetType = TargetType.Self,
        MagicSkill = ActorValue.None,
        Archetype = new MagicEffectArchetype
        {
            Type = MagicEffectArchetype.TypeEnum.Script
        },
        Flags = MagicEffect.Flag.HideInUI | MagicEffect.Flag.NoArea |
                MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoMagnitude |
                MagicEffect.Flag.Recover,
        VirtualMachineAdapter = EffectScript(scriptName)
    };
    mod.MagicEffects.Add(effect);
    return effect;
}

AddScriptEffect(0x800, "cfl_MGEFFeralKinship", "Feral kinship",
    "cfl_FeralKinshipEffect");
mod.Spells.Add(new Spell(Local(0x801), SkyrimRelease.SkyrimSE)
{
    EditorID = "cfl_AbilityFeralKinship",
    Name = "Feral kinship",
    Type = SpellType.Ability,
    CastType = CastType.ConstantEffect,
    TargetType = TargetType.Self,
    ChargeTime = 0,
    BaseCost = 0,
    Effects = { EffectLink(0x800) }
});

AddScriptEffect(0x802, "cfl_MGEFFeralKinshipApproach", "Feral approach",
    "cfl_FeralKinshipApproachEffect");
mod.Spells.Add(new Spell(Local(0x804), SkyrimRelease.SkyrimSE)
{
    EditorID = "cfl_AbilityFeralKinshipApproach",
    Name = "Feral approach",
    Type = SpellType.Ability,
    CastType = CastType.ConstantEffect,
    TargetType = TargetType.Self,
    ChargeTime = 0,
    BaseCost = 0,
    Effects = { EffectLink(0x802) }
});

var prompt = new Message(Local(0x805), SkyrimRelease.SkyrimSE)
{
    EditorID = "cfl_MSGFeralKinshipApproach",
    Name = "Feral kinship",
    Description = "The creature approaches with unmistakable interest.",
    Flags = Message.Flag.MessageBox
};
prompt.MenuButtons.Add(new MessageButton { Text = "Accept" });
prompt.MenuButtons.Add(new MessageButton { Text = "Refuse" });
mod.Messages.Add(prompt);

mod.Quests.Add(new Quest(Local(0x803), SkyrimRelease.SkyrimSE)
{
    EditorID = "cfl_FeralKinshipControllerQuest",
    Name = "Feral Creature Kinship",
    Flags = Quest.Flag.StartGameEnabled,
    Priority = 20,
    QuestFormVersion = 65,
    VirtualMachineAdapter = QuestScript("cfl_FeralKinshipController")
});

Directory.CreateDirectory(Path.GetDirectoryName(outputPath)!);
mod.WriteToBinary(outputPath);

var built = ModFactory<ISkyrimModGetter>.Importer(
    ModPath.FromPath(outputPath), GameRelease.SkyrimSE);
if (!built.ModHeader.Flags.HasFlag(SkyrimModHeader.HeaderFlag.Small))
    throw new InvalidOperationException("Kinship plugin is not ESL flagged.");
if (built.MagicEffects.Count != 2 || built.Spells.Count != 2 ||
    built.Messages.Count != 1 || built.Quests.Count != 1)
    throw new InvalidOperationException("Kinship plugin record-count validation failed.");
var builtQuest = built.Quests.Single(x => x.FormKey.ID == 0x803);
if (!builtQuest.Flags.HasFlag(Quest.Flag.StartGameEnabled) ||
    builtQuest.VirtualMachineAdapter?.Scripts.SingleOrDefault()?.Name != "cfl_FeralKinshipController")
    throw new InvalidOperationException("Kinship controller quest validation failed.");
var builtPrompt = built.Messages.Single(x => x.FormKey.ID == 0x805);
if (!builtPrompt.Flags.HasFlag(Message.Flag.MessageBox) || builtPrompt.MenuButtons.Count != 2)
    throw new InvalidOperationException("Kinship prompt validation failed.");
for (uint id = 0x800; id <= 0x802; id += 2)
{
    var effect = built.MagicEffects.Single(x => x.FormKey.ID == id);
    var spellId = id == 0x800 ? 0x801u : 0x804u;
    var spell = built.Spells.Single(x => x.FormKey.ID == spellId);
    if (spell.Type != SpellType.Ability || spell.Effects.Single().BaseEffect.FormKey != effect.FormKey)
        throw new InvalidOperationException($"Kinship ability validation failed for {spellId:X3}.");
}

Console.WriteLine("Feral Creature Kinship plugin built and validated: ESL flag, 2 abilities, prompt, and start-game controller quest.");
