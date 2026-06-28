using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

const string PatchName = "Lola DOM Handler Patch.esp";

var root = FindPatchRoot();
var outputPath = Path.Combine(root, PatchName);
var replacementsPath = Path.Combine(root, "Build", "replacements.tsv");

var sourcePaths = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
{
    ["DiaryOfMine.esm"] = @"C:\Games\nefaram\mods\PAH Diary Of Mine\DiaryOfMine.esm",
    ["PAH_AndYouGetASlave.esp"] = @"C:\Games\nefaram\mods\PAH And You Get a Slave!\PAH_AndYouGetASlave.esp",
    ["PAH_HomeSweetHome.esp"] = @"C:\Games\nefaram\mods\PAH Home Sweet Home\PAH_HomeSweetHome.esp",
    ["cfl_LolaAddon.esp"] = @"C:\Games\nefaram\mods\[NoDelete] cfl_LolaAddon_\cfl_LolaAddon.esp",
};

var patches = LoadPatches(replacementsPath).ToArray();
var patchMod = new SkyrimMod(ModKey.FromNameAndExtension(PatchName), SkyrimRelease.SkyrimSE);
patchMod.ModHeader.Flags = SkyrimModHeader.HeaderFlag.Small;

foreach (var master in patches.Select(x => x.File).Distinct(StringComparer.OrdinalIgnoreCase))
    patchMod.ModHeader.MasterReferences.Add(new MasterReference { Master = ModKey.FromNameAndExtension(master) });

var mods = sourcePaths.ToDictionary(
    x => x.Key,
    x => ModInstantiator<ISkyrimModGetter>.Importer(ModPath.FromPath(x.Value), GameRelease.SkyrimSE),
    StringComparer.OrdinalIgnoreCase);

foreach (var byFile in patches.GroupBy(x => x.File, StringComparer.OrdinalIgnoreCase))
{
    var source = mods[byFile.Key];

    foreach (var byTopic in byFile.Where(x => x.Kind is "DIAL" or "INFO").GroupBy(x => TopicKey(source, x)))
    {
        var sourceTopic = source.DialogTopics.First(x => x.FormKey == byTopic.Key);
        var topic = sourceTopic.DeepCopy();
        foreach (var patch in byTopic)
            ApplyTopicPatch(topic, patch);
        patchMod.DialogTopics.Add(topic);
    }

    foreach (var patch in byFile.Where(x => x.Kind == "MESG"))
    {
        var key = FormKey.Factory(patch.FormKey);
        var message = source.Messages.First(x => x.FormKey == key).DeepCopy();
        ApplyMessagePatch(message, patch);

        var existing = patchMod.Messages.FirstOrDefault(x => x.FormKey == message.FormKey);
        if (existing == null)
            patchMod.Messages.Add(message);
        else
            ApplyMessagePatch(existing, patch);
    }
}

patchMod.WriteToBinary(outputPath);
Console.WriteLine($"Wrote {outputPath}");
Console.WriteLine($"Applied {patches.Length} text replacements.");

static IEnumerable<TextPatch> LoadPatches(string path)
{
    foreach (var line in File.ReadLines(path).Skip(1))
    {
        if (string.IsNullOrWhiteSpace(line))
            continue;

        var cols = line.Split('\t');
        if (cols.Length != 6)
            throw new InvalidOperationException($"Bad replacement row: {line}");

        yield return new TextPatch(
            File: cols[0],
            Kind: cols[1],
            FormKey: cols[2],
            ResponseIndex: string.IsNullOrWhiteSpace(cols[3]) ? null : int.Parse(cols[3]),
            Field: cols[4],
            Text: cols[5].Replace(@"\r", "\r").Replace(@"\n", "\n"));
    }
}

static string FindPatchRoot()
{
    var dir = new DirectoryInfo(AppContext.BaseDirectory);
    while (dir != null)
    {
        if (dir.Name.Equals("Lola DOM Handler Patch", StringComparison.OrdinalIgnoreCase))
            return dir.FullName;
        dir = dir.Parent;
    }

    return Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", ".."));
}

static FormKey TopicKey(ISkyrimModGetter mod, TextPatch patch)
{
    var key = FormKey.Factory(patch.FormKey);
    if (patch.Kind == "DIAL")
        return key;

    foreach (var topic in mod.DialogTopics)
        if (topic.Responses.Any(x => x.FormKey == key))
            return topic.FormKey;

    throw new InvalidOperationException($"Could not find parent topic for {patch.FormKey}");
}

static void ApplyTopicPatch(DialogTopic topic, TextPatch patch)
{
    var key = FormKey.Factory(patch.FormKey);
    if (patch.Kind == "DIAL")
    {
        topic.Name = patch.Text;
        return;
    }

    var info = topic.Responses.First(x => x.FormKey == key);
    if (patch.Field == "Prompt")
    {
        info.Prompt = patch.Text;
        return;
    }

    if (patch.Field != "Response.Text" || patch.ResponseIndex is null)
        throw new InvalidOperationException($"Unsupported INFO field {patch.Field} for {patch.FormKey}");

    info.Responses[patch.ResponseIndex.Value].Text = patch.Text;
}

static void ApplyMessagePatch(Message message, TextPatch patch)
{
    if (patch.Field == "Name")
        message.Name = patch.Text;
    else if (patch.Field == "Description")
        message.Description = patch.Text;
    else
        throw new InvalidOperationException($"Unsupported MESG field {patch.Field}");
}

record TextPatch(string File, string Kind, string FormKey, int? ResponseIndex, string Field, string Text);
