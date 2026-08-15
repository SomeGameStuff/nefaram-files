using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Binary.Parameters;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

const string PatchName = "NEFARAM_MariaEdenOrderReminders.esp";
var inputPath = args.Length > 0 ? Path.GetFullPath(args[0]) : throw new ArgumentException("Usage: Generator <winning MariaProstitution.esp> <output ESP> [report TSV]");
var outputPath = args.Length > 1 ? Path.GetFullPath(args[1]) : throw new ArgumentException("An output path is required.");
var reportPath = args.Length > 2 ? Path.GetFullPath(args[2]) : Path.ChangeExtension(outputPath, ".tsv");

var source = ModFactory<ISkyrimModGetter>.Importer(ModPath.FromPath(inputPath), GameRelease.SkyrimSE);
if (!source.ModKey.FileName.String.Equals("MariaProstitution.esp", StringComparison.OrdinalIgnoreCase))
    throw new InvalidDataException($"Expected MariaProstitution.esp, got {source.ModKey}.");

var sharedSpeedups = new HashSet<uint>
{
    0x2FAD91, 0x2FAD92, 0x2FAD93, 0x2FAD9E, 0x2FAD9F,
    0x44E70F, 0x45382F, 0x453830, 0x453831,
};
var infos = source.EnumerateMajorRecords().OfType<IDialogResponsesGetter>().ToDictionary(x => x.FormKey);
var topics = source.DialogTopics.ToDictionary(x => x.FormKey);

bool IsGeneric(IDialogResponsesGetter info) => info.ResponseData.FormKeyNullable is FormKey fk
    && fk.ModKey == source.ModKey && sharedSpeedups.Contains(fk.ID);
bool IsSpeedTopic(IDialogTopicGetter topic) => topic.Responses.Any(IsGeneric);

var excludedTopics = new HashSet<uint> { 0x2FACED }; // Ordinary conversation response, not a timed reminder bark.
var speedTopics = source.DialogTopics.Where(x => IsSpeedTopic(x) && !excludedTopics.Contains(x.FormKey.ID)).ToDictionary(x => x.FormKey);
var sceneUses = source.Scenes
    .SelectMany(scene => scene.Actions
        .Where(action => action.Topic.FormKeyNullable is FormKey key && speedTopics.ContainsKey(key))
        .Select(action => (Scene: scene, Action: action)))
    .ToDictionary(x => x.Action.Topic.FormKey);

var manual = ManualReminders(source.ModKey);
var patch = new SkyrimMod(ModKey.FromNameAndExtension(PatchName), SkyrimRelease.SkyrimSE);
patch.ModHeader.Flags = SkyrimModHeader.HeaderFlag.Small;
foreach (var master in source.ModHeader.MasterReferences)
    patch.ModHeader.MasterReferences.Add(new MasterReference { Master = master.Master });
patch.ModHeader.MasterReferences.Add(new MasterReference { Master = source.ModKey });

var report = new List<string> { "Topic\tScene\tChangedInfos\tReminder\tDerivation" };
var changedInfoKeys = new HashSet<FormKey>();
foreach (var (topicKey, sourceTopic) in speedTopics.OrderBy(x => x.Key.ID))
{
    var sceneUse = sceneUses.GetValueOrDefault(topicKey);
    var sceneName = sceneUse.Scene?.EditorID ?? "(not used by a scene)";
    var (reminder, derivation) = ResolveReminder(topicKey, sourceTopic, sceneUse, manual, speedTopics, topics, infos, IsGeneric);
    if (string.IsNullOrWhiteSpace(reminder))
        throw new InvalidDataException($"Could not derive reminder for {topicKey} ({sceneName}).");

    reminder = NormalizeReminder(reminder);
    var topic = sourceTopic.DeepCopy();
    var changed = 0;
    foreach (var info in topic.Responses.Where(x => IsGeneric(x)).ToArray())
    {
        var dataKey = info.ResponseData.FormKey;
        var exemplar = infos[dataKey].Responses.FirstOrDefault()?.DeepCopy()
            ?? throw new InvalidDataException($"Shared response {dataKey} has no response text.");
        exemplar.Text = reminder;
        info.ResponseData.SetTo((FormKey?)null);
        info.Responses.Clear();
        info.Responses.Add(exemplar);
        changedInfoKeys.Add(info.FormKey);
        changed++;
    }
    patch.DialogTopics.Add(topic);
    report.Add($"{topicKey.ID:X6}\t{sceneName}\t{changed}\t{Escape(reminder)}\t{derivation}");
}

Directory.CreateDirectory(Path.GetDirectoryName(outputPath)!);
Directory.CreateDirectory(Path.GetDirectoryName(reportPath)!);
patch.WriteToBinary(outputPath, new BinaryWriteParameters
{
    MastersListContent = MastersListContentOption.NoCheck,
    MastersListOrdering = MastersListOrderingOption.NoCheck,
});
File.WriteAllLines(reportPath, report);
ValidateOutput(outputPath, source.ModKey, speedTopics.Count, changedInfoKeys);
Console.WriteLine($"Wrote {outputPath}");
Console.WriteLine($"Patched {speedTopics.Count} reminder topics and {report.Skip(1).Sum(x => int.Parse(x.Split('\t')[2]))} generic response records.");
Console.WriteLine($"Report: {reportPath}");

static (string Text, string Derivation) ResolveReminder(
    FormKey topicKey,
    IDialogTopicGetter topic,
    (ISceneGetter Scene, ISceneActionGetter Action) sceneUse,
    IReadOnlyDictionary<FormKey, string> manual,
    IReadOnlyDictionary<FormKey, IDialogTopicGetter> speedTopics,
    IReadOnlyDictionary<FormKey, IDialogTopicGetter> topics,
    IReadOnlyDictionary<FormKey, IDialogResponsesGetter> infos,
    Func<IDialogResponsesGetter, bool> isGeneric)
{
    if (manual.TryGetValue(topicKey, out var explicitText))
        return (explicitText, "manual scene-specific mapping");

    var contextual = topic.Responses.Where(x => !isGeneric(x))
        .SelectMany(x => ResolvedTexts(x, infos))
        .FirstOrDefault(IsUsefulText);
    if (!string.IsNullOrWhiteSpace(contextual))
        return (contextual, "contextual response in reminder topic");

    if (sceneUse.Scene is not null)
    {
        var candidates = sceneUse.Scene.Actions
            .Where(x => x.Type == SceneAction.TypeEnum.Dialog
                && x.ActorID == sceneUse.Action.ActorID
                && x.Topic.FormKeyNullable is FormKey
                && (x.StartPhase < sceneUse.Action.StartPhase || (x.StartPhase == sceneUse.Action.StartPhase && x.Index < sceneUse.Action.Index)))
            .OrderByDescending(x => x.StartPhase).ThenByDescending(x => x.Index);
        foreach (var candidate in candidates)
        {
            var key = candidate.Topic.FormKey;
            if (speedTopics.ContainsKey(key) || !topics.TryGetValue(key, out var priorTopic)) continue;
            var text = priorTopic.Responses.SelectMany(x => ResolvedTexts(x, infos)).FirstOrDefault(IsUsefulText);
            if (!string.IsNullOrWhiteSpace(text))
                return (text, $"preceding scene dialogue {key.ID:X6}");
        }
    }

    return ("Repeat the last order now.", "safe fallback");
}

static IEnumerable<string> ResolvedTexts(IDialogResponsesGetter info, IReadOnlyDictionary<FormKey, IDialogResponsesGetter> infos)
{
    if (info.Responses.Count > 0)
        return info.Responses.Select(x => x.Text.String ?? "");
    if (info.ResponseData.FormKeyNullable is FormKey key && infos.TryGetValue(key, out var data))
        return data.Responses.Select(x => x.Text.String ?? "");
    return [];
}

static bool IsUsefulText(string text) => !string.IsNullOrWhiteSpace(text) && text.Trim() != "!";

static string NormalizeReminder(string text)
{
    text = text.Replace('\r', ' ').Replace('\n', ' ').Trim();
    while (text.Contains("  ")) text = text.Replace("  ", " ");
    if (text.Length > 220) text = text[..217].TrimEnd() + "...";
    return text.StartsWith("Reminder", StringComparison.OrdinalIgnoreCase) ? text : "Reminder: " + text;
}

static string Escape(string text) => text.Replace("\t", " ").Replace("\r", " ").Replace("\n", " ");

static void ValidateOutput(string outputPath, ModKey sourceKey, int expectedTopics, IReadOnlySet<FormKey> changedInfoKeys)
{
    var output = ModFactory<ISkyrimModGetter>.Importer(ModPath.FromPath(outputPath), GameRelease.SkyrimSE);
    if ((output.ModHeader.Flags & SkyrimModHeader.HeaderFlag.Small) == 0)
        throw new InvalidDataException("Output is not ESL-flagged.");
    if (!output.ModHeader.MasterReferences.Any(x => x.Master == sourceKey))
        throw new InvalidDataException($"Output is missing master {sourceKey}.");
    if (output.DialogTopics.Count != expectedTopics)
        throw new InvalidDataException($"Expected {expectedTopics} DIAL overrides, found {output.DialogTopics.Count}.");
    var outputInfos = output.EnumerateMajorRecords().OfType<IDialogResponsesGetter>().ToDictionary(x => x.FormKey);
    foreach (var key in changedInfoKeys)
    {
        if (!outputInfos.TryGetValue(key, out var info))
            throw new InvalidDataException($"Missing patched INFO {key}.");
        if (info.ResponseData.FormKeyNullable is not null || info.Responses.Count != 1 ||
            !(info.Responses[0].Text.String ?? "").StartsWith("Reminder:", StringComparison.Ordinal))
            throw new InvalidDataException($"Patched INFO {key} did not serialize as a direct reminder response.");
    }
    var unexpected = output.EnumerateMajorRecords()
        .Where(x => x is not IDialogTopicGetter && x is not IDialogResponsesGetter)
        .Select(x => x.GetType().Name).Distinct().ToArray();
    if (unexpected.Length > 0)
        throw new InvalidDataException("Unexpected record types: " + string.Join(", ", unexpected));
    Console.WriteLine($"Validated ESL patch: topics={expectedTopics}, reminder INFOs={changedInfoKeys.Count}, masters={output.ModHeader.MasterReferences.Count}.");
}

static Dictionary<FormKey, string> ManualReminders(ModKey mod) => new()
{
    [new(mod, 0x0B3204)] = "Reminder: pleasure yourself.",
    [new(mod, 0x23E746)] = "Reminder: clean yourself up before you are taken back.",
    [new(mod, 0x2FAEDE)] = "Reminder: take off your clothes.",
    [new(mod, 0x2FAF0A)] = "Reminder: keep licking the floor and spread your thighs.",
    [new(mod, 0x2FAF22)] = "Reminder: get on your knees and lick his penis clean.",
    [new(mod, 0x9BBCE7)] = "Reminder: shave your pubic hair.",
    [new(mod, 0x9BBCFE)] = "Reminder: shave your armpits.",
    [new(mod, 0x9BBD0A)] = "Reminder: shave your legs.",
    [new(mod, 0x9BBD14)] = "Reminder: shave your arms.",
    [new(mod, 0x2FB67C)] = "Reminder: get into the position you were ordered to take.",
    [new(mod, 0x48793E)] = "Reminder: use, wear, or drink the item you were just given.",
    [new(mod, 0x2FFA78)] = "Reminder: expose and show your breasts.",
    [new(mod, 0x3145E6)] = "Reminder: get down on all fours and lick or kiss the ordered feet.",
    [new(mod, 0x3321E3)] = "Reminder: correct your outfit—wear your assigned clothes, or strip if you were ordered to be naked.",
    [new(mod, 0x3321E9)] = "Reminder: correct your outfit—wear your assigned clothes, or strip if you were ordered to be naked.",
    [new(mod, 0x3321F1)] = "Reminder: correct your outfit—wear your assigned clothes, or strip if you were ordered to be naked.",
    [new(mod, 0x3321F7)] = "Reminder: correct your outfit—wear your assigned clothes, or strip if you were ordered to be naked.",
    [new(mod, 0x36537F)] = "Reminder: use the device and get into the ordered position.",
    [new(mod, 0x38DD33)] = "Reminder: go to your new owner and kneel before them.",
    [new(mod, 0x6A0AAB)] = "Reminder: get onto the gallows and into the ordered position.",
    [new(mod, 0x42C690)] = "Reminder: go to the next guest.",
    [new(mod, 0x42C697)] = "Reminder: go to the final guest.",
    [new(mod, 0x4811D3)] = "Reminder: move to the device and follow the current package order.",
    [new(mod, 0x533DC9)] = "Reminder: lie down and open your mouth.",
    [new(mod, 0x565468)] = "Reminder: put on the clothes you were given.",
    [new(mod, 0x57E9F0)] = "Reminder: put on your assigned clothes.",
    [new(mod, 0x57E9FA)] = "Reminder: put on your assigned clothes.",
    [new(mod, 0x7A74EB)] = "Reminder: get inside the place you were shown.",
    [new(mod, 0x7B67FD)] = "Reminder: come out now.",
    [new(mod, 0x7B6803)] = "Reminder: get down on your knees.",
    [new(mod, 0x7B6817)] = "Reminder: put on the item you were given.",
    [new(mod, 0x7BB93C)] = "Reminder: get down on your knees.",
    [new(mod, 0x7D9FDE)] = "Reminder: put on the shoes you were given.",
    [new(mod, 0x7D9FFA)] = "Reminder: put on the shoes you were given.",
    [new(mod, 0x7DA017)] = "Reminder: put on the shoes you were given.",
    [new(mod, 0x80CADB)] = "Reminder: get back to work now.",
    [new(mod, 0x83F60B)] = "Reminder: put the basket around your neck.",
    [new(mod, 0x998415)] = "Reminder: keep dancing and follow the last performance instruction.",
    [new(mod, 0x998431)] = "Reminder: keep masturbating, then perform the ordered climax.",
    [new(mod, 0xBC112C)] = "Reminder: drink the potion you were given.",
    [new(mod, 0x9BBD5C)] = "Reminder: drink what you were given.",
    [new(mod, 0x9B6B83)] = "Reminder: shave the body hair you were told to remove.",
    [new(mod, 0xCC8965)] = "Reminder: use the makeup bag to fix your nails.",
    [new(mod, 0xCC8973)] = "Reminder: use the makeup bag to fix your hair.",
    [new(mod, 0xCC897F)] = "Reminder: use the makeup bag on your eyelids.",
    [new(mod, 0xCC899B)] = "Reminder: use the makeup bag on your lips.",
    [new(mod, 0xD149C9)] = "Reminder: use the makeup bag to apply eyeliner.",
    [new(mod, 0xB65C9D)] = "Reminder: come here now.",
    [new(mod, 0xB93147)] = "Reminder: use your tongue on the spot you were shown.",
    [new(mod, 0xDE46D4)] = "Reminder: come over to the waiting client.",
    [new(mod, 0xDFDD11)] = "Reminder: come here now.",
    [new(mod, 0xE07FA6)] = "Reminder: come here now.",
    [new(mod, 0xE62752)] = "Reminder: follow your escort to the device.",
    [new(mod, 0xE7C89A)] = "Reminder: kneel over the bowl and lick it clean when ordered.",
};
