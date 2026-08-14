using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

const string PluginName = "MariaEdenKeyConfig.esp";
const string MariaBasePath = @"C:\Games\nefaram\mods\MariaEdenProstitution\MariaBase.esm";

if (args.Length > 1 && args[0].Equals("--validate", StringComparison.OrdinalIgnoreCase))
{
    var built = ModFactory<ISkyrimModGetter>.Importer(ModPath.FromPath(args[1]), GameRelease.SkyrimSE);
    var inspectedQuest = built.Quests.Single(x => x.EditorID == "MEPK_MCMQuest");
    var scripts = inspectedQuest.VirtualMachineAdapter?.Scripts.Select(x => x.Name).ToArray() ?? [];
    if (!built.ModHeader.Flags.HasFlag(SkyrimModHeader.HeaderFlag.Small))
        throw new InvalidDataException("Plugin is not ESL-flagged.");
    if (!inspectedQuest.Flags.HasFlag(Quest.Flag.StartGameEnabled))
        throw new InvalidDataException("MCM quest is not start-game enabled.");
    if (scripts.Length != 1 || scripts[0] != "MEPK_MCM")
        throw new InvalidDataException("MCM quest script attachment is incorrect.");
    var mariaProperty = inspectedQuest.VirtualMachineAdapter!.Scripts.Single().Properties
        .OfType<ScriptObjectProperty>().SingleOrDefault(x => x.Name == "MariaMainQuest");
    if (mariaProperty == null || !mariaProperty.Object.FormKey.ModKey.FileName.String.Equals("MariaBase.esm", StringComparison.OrdinalIgnoreCase))
        throw new InvalidDataException("MariaMainQuest script property is missing or points at the wrong master.");
    if (inspectedQuest.FormKey.ID > 0xFFF)
        throw new InvalidDataException("Quest FormID is outside the ESL compact range.");
    if (!built.ModHeader.MasterReferences.Any(x => x.Master.FileName.String.Equals("MariaBase.esm", StringComparison.OrdinalIgnoreCase)))
        throw new InvalidDataException("MariaBase.esm master is missing.");
    Console.WriteLine($"Validated {built.ModKey}: ESL={built.ModHeader.Flags.HasFlag(SkyrimModHeader.HeaderFlag.Small)}, quest={inspectedQuest.FormKey.ID:X3}, script={scripts[0]}, MariaMain={mariaProperty.Object.FormKey}");
    return;
}

var output = args.Length > 0
    ? args[0]
    : Path.Combine(Directory.GetParent(AppContext.BaseDirectory)!.Parent!.Parent!.Parent!.Parent!.FullName, PluginName);

var mod = new SkyrimMod(ModKey.FromNameAndExtension(PluginName), SkyrimRelease.SkyrimSE);
mod.ModHeader.Flags |= SkyrimModHeader.HeaderFlag.Small;
mod.ModHeader.MasterReferences.Add(new MasterReference { Master = ModKey.FromNameAndExtension("Skyrim.esm") });
mod.ModHeader.MasterReferences.Add(new MasterReference { Master = ModKey.FromNameAndExtension("MariaBase.esm") });

var mariaBase = ModFactory<ISkyrimModGetter>.Importer(ModPath.FromPath(MariaBasePath), GameRelease.SkyrimSE);
var mariaMain = mariaBase.Quests.SingleOrDefault(x => string.Equals(x.EditorID, "MariaMain", StringComparison.OrdinalIgnoreCase))
    ?? throw new InvalidDataException("Could not find the MariaMain quest in MariaBase.esm.");

var quest = new Quest(mod, "MEPK_MCMQuest")
{
    Name = "Maria Eden Key Configuration MCM",
    Flags = Quest.Flag.StartGameEnabled,
    Priority = 0,
    QuestFormVersion = 65,
    VirtualMachineAdapter = new QuestAdapter
    {
        Version = 5,
        ObjectFormat = 2,
        FileName = "MEPK_MCM"
    }
};
var mcmScript = new ScriptEntry { Name = "MEPK_MCM" };
mcmScript.Properties.Add(new ScriptObjectProperty
{
    Name = "MariaMainQuest",
    Object = new FormLink<ISkyrimMajorRecordGetter>(mariaMain.FormKey),
    Alias = -1
});
quest.VirtualMachineAdapter.Scripts.Add(mcmScript);
mod.Quests.Add(quest);

Directory.CreateDirectory(Path.GetDirectoryName(output)!);
mod.WriteToBinary(output);
Console.WriteLine($"Generated {output}");
