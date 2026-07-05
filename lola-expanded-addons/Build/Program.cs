using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

const string PatchName = "LolaExpandedAddons.esp";
const string SourcePluginName = "cfl_LolaAddon.esp";
const string SourcePluginPath = @"C:\Games\nefaram\mods\[NoDelete] cfl_LolaAddon_\cfl_LolaAddon.esp";

var projectRoot = FindProjectRoot();
var projectOutput = Path.Combine(projectRoot, PatchName);
var runtimeOutput = @"C:\Games\nefaram\mods\[NoDelete] 360 Lola Expanded Addons\LolaExpandedAddons.esp";

var source = ModInstantiator<ISkyrimModGetter>.Importer(
    ModPath.FromPath(SourcePluginPath),
    GameRelease.SkyrimSE);

var patch = new SkyrimMod(ModKey.FromNameAndExtension(PatchName), SkyrimRelease.SkyrimSE);
patch.ModHeader.Flags = SkyrimModHeader.HeaderFlag.Small;
patch.ModHeader.MasterReferences.Add(new MasterReference { Master = ModKey.FromNameAndExtension(SourcePluginName) });

var readyGlobal = new GlobalFloat(FormKey.Factory("000800:" + PatchName), SkyrimRelease.SkyrimSE)
{
    EditorID = "LEA_MilkTurnInReady",
    RawFloat = 0f,
};
patch.Globals.Add(readyGlobal);

var ownerHub = source.DialogTopics.First(x => x.EditorID == "cfl_Main_AskMasterIntro").DeepCopy();
var ownerHubInfo = ownerHub.Responses.First();
var exemplarTopic = source.DialogTopics.First(x => x.EditorID == "cfl_TaskOutfit_StartTopic");
var exemplarInfo = exemplarTopic.Responses.First();

var milkTopic = new DialogTopic(FormKey.Factory("000801:" + PatchName), SkyrimRelease.SkyrimSE)
{
    EditorID = "LEA_MilkTurnInTopic",
    Name = "I brought the milk you ordered.",
    Category = exemplarTopic.Category,
    Subtype = exemplarTopic.Subtype,
    Priority = exemplarTopic.Priority,
    TopicFlags = exemplarTopic.TopicFlags,
    Unknown = exemplarTopic.Unknown,
};
milkTopic.Quest.SetTo(exemplarTopic.Quest.FormKey);
milkTopic.Branch.SetTo(exemplarTopic.Branch.FormKey);

var milkInfo = new DialogResponses(FormKey.Factory("000802:" + PatchName), SkyrimRelease.SkyrimSE)
{
    EditorID = "LEA_MilkTurnInInfo",
    Prompt = "",
    Flags = exemplarInfo.Flags.DeepCopy(),
};
milkInfo.Responses.Add(new DialogResponse
{
    ResponseNumber = 0,
    Emotion = Emotion.Happy,
    EmotionValue = 50,
    Text = "Good. Hand it over. You remembered what you are for.",
});
milkInfo.Conditions.Add(new ConditionFloat
{
    CompareOperator = CompareOperator.EqualTo,
    ComparisonValue = 1f,
    Data = new GetGlobalValueConditionData
    {
        Global = new FormLinkOrIndex<IGlobalGetter>(null!, readyGlobal.FormKey),
    },
});
milkInfo.VirtualMachineAdapter = new DialogResponsesAdapter
{
    Version = 5,
    ObjectFormat = 2,
    ScriptFragments = new ScriptFragments
    {
        FileName = "LEA_TIF_MilkTurnIn",
        OnBegin = new ScriptFragment
        {
            ScriptName = "LEA_TIF_MilkTurnIn",
            FragmentName = "Fragment_0",
            ExtraBindDataVersion = 1,
        },
    },
};
milkInfo.VirtualMachineAdapter.Scripts.Add(new ScriptEntry
{
    Name = "LEA_TIF_MilkTurnIn",
    Flags = ScriptEntry.Flag.Local,
});

milkTopic.Responses.Add(milkInfo);
ownerHubInfo.LinkTo.Add(milkTopic.ToLinkGetter());

patch.DialogTopics.Add(ownerHub);
patch.DialogTopics.Add(milkTopic);

patch.WriteToBinary(projectOutput);
Directory.CreateDirectory(Path.GetDirectoryName(runtimeOutput)!);
File.Copy(projectOutput, runtimeOutput, overwrite: true);

Console.WriteLine($"Wrote {projectOutput}");
Console.WriteLine($"Copied {runtimeOutput}");

static string FindProjectRoot()
{
    var dir = new DirectoryInfo(AppContext.BaseDirectory);
    while (dir != null)
    {
        if (dir.Name.Equals("lola-expanded-addons", StringComparison.OrdinalIgnoreCase))
            return dir.FullName;
        dir = dir.Parent;
    }

    return Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", ".."));
}
