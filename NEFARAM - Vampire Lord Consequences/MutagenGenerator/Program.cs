using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

static IFormLink<ISkyrimMajorRecordGetter> Link(string plugin, uint localFormId)
{
    return new FormLink<ISkyrimMajorRecordGetter>(new FormKey(ModKey.FromNameAndExtension(plugin), localFormId));
}

static IFormLink<ISkyrimMajorRecordGetter> LinkRecord(ISkyrimMajorRecordGetter record)
{
    return new FormLink<ISkyrimMajorRecordGetter>(record.FormKey);
}

static GlobalFloat AddGlobal(SkyrimMod mod, string editorId, float value)
{
    var global = new GlobalFloat(mod, editorId)
    {
        RawFloat = value
    };
    mod.Globals.Add(global);
    return global;
}

static void AddObjectProperty(ScriptEntry script, string name, IFormLinkGetter<ISkyrimMajorRecordGetter> link)
{
    script.Properties.Add(new ScriptObjectProperty
    {
        Name = name,
        Object = new FormLink<ISkyrimMajorRecordGetter>(link.FormKey),
        Alias = -1
    });
}

var outPath = args.Length > 0
    ? args[0]
    : @"C:\Games\nefaram\mods\NEFARAM - Vampire Lord Consequences\NEFARAM - Vampire Lord Consequences.esp";

var mod = new SkyrimMod(ModKey.FromNameAndExtension("NEFARAM - Vampire Lord Consequences.esp"), SkyrimRelease.SkyrimSE);
mod.ModHeader.Flags |= SkyrimModHeader.HeaderFlag.Small;
mod.ModHeader.MasterReferences.Add(new MasterReference { Master = ModKey.FromNameAndExtension("Skyrim.esm") });
mod.ModHeader.MasterReferences.Add(new MasterReference { Master = ModKey.FromNameAndExtension("Update.esm") });
mod.ModHeader.MasterReferences.Add(new MasterReference { Master = ModKey.FromNameAndExtension("Dawnguard.esm") });

var heat = AddGlobal(mod, "NVLC_Heat", 0);
var humanity = AddGlobal(mod, "NVLC_Humanity", 100);
var corruption = AddGlobal(mod, "NVLC_Corruption", 0);
var lastTransform = AddGlobal(mod, "NVLC_LastTransformTime", 0);
var crashSeverity = AddGlobal(mod, "NVLC_CrashSeverity", 0);

var quest = new Quest(mod, "NVLC_ControllerQuest")
{
    Name = "NEFARAM Vampire Lord Consequences Controller",
    Flags = Quest.Flag.StartGameEnabled,
    Priority = 0,
    QuestFormVersion = 65,
    VirtualMachineAdapter = new QuestAdapter
    {
        Version = 5,
        ObjectFormat = 2,
        FileName = "NVLC_Controller"
    }
};
mod.Quests.Add(quest);

var script = new ScriptEntry { Name = "NVLC_Controller" };
quest.VirtualMachineAdapter.Scripts.Add(script);

AddObjectProperty(script, "DLC1VampireBeastRace", Link("Dawnguard.esm", 0x00283A));
AddObjectProperty(script, "LocTypeCity", Link("Skyrim.esm", 0x013168));
AddObjectProperty(script, "LocTypeTown", Link("Skyrim.esm", 0x013166));
AddObjectProperty(script, "LocTypeHabitation", Link("Skyrim.esm", 0x013167));
AddObjectProperty(script, "ActorTypeNPC", Link("Skyrim.esm", 0x013794));
AddObjectProperty(script, "GameDaysPassed", Link("Skyrim.esm", 0x000039));
AddObjectProperty(script, "NVLC_Heat", LinkRecord(heat));
AddObjectProperty(script, "NVLC_Humanity", LinkRecord(humanity));
AddObjectProperty(script, "NVLC_Corruption", LinkRecord(corruption));
AddObjectProperty(script, "NVLC_LastTransformTime", LinkRecord(lastTransform));
AddObjectProperty(script, "NVLC_CrashSeverity", LinkRecord(crashSeverity));
AddObjectProperty(script, "NVLC_DawnguardHunter", Link("Dawnguard.esm", 0x003476));

Directory.CreateDirectory(Path.GetDirectoryName(outPath)!);
mod.WriteToBinary(outPath);
Console.WriteLine(outPath);
