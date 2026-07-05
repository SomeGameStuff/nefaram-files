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

var ownerHub = source.DialogTopics.First(x => x.EditorID == "cfl_Main_AskMasterIntro").DeepCopy();
var ownerHubInfo = ownerHub.Responses.First();
var responseExemplarTopic = source.DialogTopics.First(x => x.EditorID == "cfl_TaskOutfit_StartTopic");
var exemplarInfo = responseExemplarTopic.Responses.First();

var milkReady = AddGlobal("000800", "LEA_MilkTurnInReady");
var bodyPending = AddGlobal("000803", "LEA_BodyPotionPending");
var bodyShrink = AddGlobal("000804", "LEA_BodyPotionShrink");
var fertilityPending = AddGlobal("000805", "LEA_FertilityPending");
var milkActive = AddGlobal("000806", "LEA_MilkAssignmentActive");

AddTopic(
    "000801",
    "LEA_MilkTurnInTopic",
    "I brought the milk you ordered.",
    new[]
    {
        Info("000802", "LEA_MilkTurnInInfo", "Good. Hand it over. You remembered what you are for.", "LEA_TIF_MilkTurnIn", Condition(milkReady, 1f)),
    });

AddTopic(
    "000807",
    "LEA_MilkStatusTopic",
    "About my milk quota...",
    new[]
    {
        Info("000808", "LEA_MilkStatusInfo", "You still owe me milk. Tell me exactly what you have managed.", "LEA_TIF_MilkStatus", Condition(milkActive, 1f)),
    });

AddTopic(
    "000809",
    "LEA_BodyPotionAcceptTopic",
    "About the elixir you chose for me...",
    new[]
    {
        Info("00080A", "LEA_BodyPotionShrinkInfo", "Yes. Drink it now. I want you smaller and easier to keep.", "LEA_TIF_BodyPotionAccept", Condition(bodyPending, 1f), Condition(bodyShrink, 1f)),
        Info("00080B", "LEA_BodyPotionGrowInfo", "Yes. Drink it now. I want more of you to admire and use.", "LEA_TIF_BodyPotionAccept", Condition(bodyPending, 1f), Condition(bodyShrink, 0f)),
    });

AddTopic(
    "00080C",
    "LEA_BodyStatusTopic",
    "What do you want done to my body?",
    new[]
    {
        Info("00080D", "LEA_BodyStatusInfo", "I will decide when your body needs changing. When I have an elixir ready, you will ask and drink it properly.", null),
    });

AddTopic(
    "00080E",
    "LEA_FertilityAcceptTopic",
    "About the fertile dose...",
    new[]
    {
        Info("00080F", "LEA_FertilityAcceptInfo", "Good. Take it now, and let Fertility Mode decide what becomes of you.", "LEA_TIF_FertilityAccept", Condition(fertilityPending, 1f)),
    });

AddTopic(
    "000810",
    "LEA_FertilityStatusTopic",
    "Are you going to make me fertile?",
    new[]
    {
        Info("000811", "LEA_FertilityStatusInfo", "When I mix that into your dose, you will know. Until then, keep yourself ready for me.", null),
    });

patch.DialogTopics.Add(ownerHub);

patch.WriteToBinary(projectOutput);
PatchLeaTopicSubtype(projectOutput);
Directory.CreateDirectory(Path.GetDirectoryName(runtimeOutput)!);
File.Copy(projectOutput, runtimeOutput, overwrite: true);

Console.WriteLine($"Wrote {projectOutput}");
Console.WriteLine($"Copied {runtimeOutput}");

GlobalFloat AddGlobal(string localFormId, string editorId)
{
    var global = new GlobalFloat(FormKey.Factory(localFormId + ":" + PatchName), SkyrimRelease.SkyrimSE)
    {
        EditorID = editorId,
        RawFloat = 0f,
    };
    patch.Globals.Add(global);
    return global;
}

void AddTopic(string localFormId, string editorId, string prompt, IEnumerable<DialogResponses> infos)
{
    var topic = new DialogTopic(FormKey.Factory(localFormId + ":" + PatchName), SkyrimRelease.SkyrimSE)
    {
        EditorID = editorId,
        Name = prompt,
        Category = ownerHub.Category,
        Subtype = responseExemplarTopic.Subtype,
        Priority = ownerHub.Priority,
        TopicFlags = ownerHub.TopicFlags,
        Unknown = ownerHub.Unknown,
    };
    topic.Quest.SetTo(ownerHub.Quest.FormKey);
    topic.Branch.SetTo(ownerHub.Branch.FormKey);

    foreach (var info in infos)
        topic.Responses.Add(info);

    ownerHubInfo.LinkTo.Add(topic.ToLinkGetter());
    patch.DialogTopics.Add(topic);
}

DialogResponses Info(string localFormId, string editorId, string responseText, string? scriptName, params ConditionFloat[] conditions)
{
    var info = new DialogResponses(FormKey.Factory(localFormId + ":" + PatchName), SkyrimRelease.SkyrimSE)
    {
        EditorID = editorId,
        Prompt = "",
        Flags = exemplarInfo.Flags.DeepCopy(),
    };
    info.Responses.Add(new DialogResponse
    {
        ResponseNumber = 0,
        Emotion = Emotion.Happy,
        EmotionValue = 50,
        Text = responseText,
    });

    foreach (var condition in conditions)
        info.Conditions.Add(condition);

    if (!string.IsNullOrWhiteSpace(scriptName))
    {
        info.VirtualMachineAdapter = new DialogResponsesAdapter
        {
            Version = 5,
            ObjectFormat = 2,
            ScriptFragments = new ScriptFragments
            {
                FileName = scriptName,
                OnBegin = new ScriptFragment
                {
                    ScriptName = scriptName,
                    FragmentName = "Fragment_0",
                    ExtraBindDataVersion = 1,
                },
            },
        };
        info.VirtualMachineAdapter.Scripts.Add(new ScriptEntry
        {
            Name = scriptName,
            Flags = ScriptEntry.Flag.Local,
        });
    }

    return info;
}

ConditionFloat Condition(GlobalFloat global, float value)
{
    return new ConditionFloat
    {
        CompareOperator = CompareOperator.EqualTo,
        ComparisonValue = value,
        Data = new GetGlobalValueConditionData
        {
            Global = new FormLinkOrIndex<IGlobalGetter>(null!, global.FormKey),
        },
    };
}

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

static void PatchLeaTopicSubtype(string pluginPath)
{
    var data = File.ReadAllBytes(pluginPath);
    var patched = 0;

    WalkRecords(0, data.Length, record =>
    {
        if (ReadTag(data, record.Offset) != "DIAL")
            return;

        var recordDataStart = record.Offset + 24;
        var recordDataEnd = recordDataStart + record.Size;
        var editorId = "";
        int? subtypeValueOffset = null;

        for (var pos = recordDataStart; pos + 6 <= recordDataEnd;)
        {
            var fieldType = ReadTag(data, pos);
            var fieldSize = BitConverter.ToUInt16(data, pos + 4);
            var valueOffset = pos + 6;
            var next = valueOffset + fieldSize;
            if (next > recordDataEnd)
                break;

            if (fieldType == "EDID")
                editorId = ReadZString(data, valueOffset, fieldSize);
            else if (fieldType == "SNAM" && fieldSize == 4)
                subtypeValueOffset = valueOffset;

            pos = next;
        }

        if (!editorId.StartsWith("LEA_", StringComparison.Ordinal))
            return;
        if (subtypeValueOffset == null)
            throw new InvalidOperationException($"Generated topic {editorId} has no SNAM field.");

        data[subtypeValueOffset.Value + 0] = (byte)'C';
        data[subtypeValueOffset.Value + 1] = (byte)'U';
        data[subtypeValueOffset.Value + 2] = (byte)'S';
        data[subtypeValueOffset.Value + 3] = (byte)'T';
        patched++;
    });

    if (patched != 6)
        throw new InvalidOperationException($"Expected to patch 6 LEA dialogue topic subtypes, patched {patched}.");

    File.WriteAllBytes(pluginPath, data);
    return;

    void WalkRecords(int start, int end, Action<(int Offset, uint Size)> handleRecord)
    {
        for (var pos = start; pos + 24 <= end;)
        {
            var type = ReadTag(data, pos);
            var size = BitConverter.ToUInt32(data, pos + 4);
            if (type == "GRUP")
            {
                WalkRecords(pos + 24, pos + checked((int)size), handleRecord);
                pos += checked((int)size);
            }
            else
            {
                handleRecord((pos, size));
                pos += 24 + checked((int)size);
            }
        }
    }

    static string ReadTag(byte[] bytes, int offset) => System.Text.Encoding.ASCII.GetString(bytes, offset, 4);

    static string ReadZString(byte[] bytes, int offset, int length)
    {
        var end = offset;
        var max = offset + length;
        while (end < max && bytes[end] != 0)
            end++;
        return System.Text.Encoding.UTF8.GetString(bytes, offset, end - offset);
    }
}
