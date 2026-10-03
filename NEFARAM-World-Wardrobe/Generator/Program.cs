using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using WorldWardrobeGenerator;

Console.OutputEncoding = Encoding.UTF8;

var projectRoot = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", ".."));
var rulesPath = GetArgumentValue("--rules") ?? Path.Combine(projectRoot, "Generator", "rules.json");
var rules = JsonSerializer.Deserialize<GeneratorRules>(File.ReadAllText(rulesPath), new JsonSerializerOptions
{
    PropertyNameCaseInsensitive = true
}) ?? throw new InvalidDataException($"Could not deserialize {rulesPath}.");
rules.ProfilePath = ExpandConfiguredPath(rules.ProfilePath, rulesPath);
rules.ModsRoot = ExpandConfiguredPath(rules.ModsRoot, rulesPath);
rules.GameDataPath = ExpandConfiguredPath(rules.GameDataPath, rulesPath);
rules.OutputPath = ExpandConfiguredPath(rules.OutputPath, rulesPath);
ValidateRules(rules, rulesPath);

var inspectTargets = args.Any(x => x.Equals("--inspect-targets", StringComparison.OrdinalIgnoreCase));
var validateOnly = args.Any(x => x.Equals("--validate", StringComparison.OrdinalIgnoreCase));
var validateProfile = args.Any(x => x.Equals("--validate-profile", StringComparison.OrdinalIgnoreCase));

var profilePluginNames = File.ReadLines(Path.Combine(rules.ProfilePath, "plugins.txt"))
    .Where(x => x.StartsWith('*'))
    .Select(x => x[1..].Trim())
    .Where(x => x.Length > 0)
    .ToArray();
var implicitMasters = new[] { "Skyrim.esm", "Update.esm", "Dawnguard.esm", "HearthFires.esm", "Dragonborn.esm", "_ResourcePack.esl" }
    .Where(x => File.Exists(Path.Combine(rules.GameDataPath, x)) && !profilePluginNames.Contains(x, StringComparer.OrdinalIgnoreCase));
var activePluginNames = implicitMasters.Concat(profilePluginNames)
    .Select((name, index) => (Name: name, Index: index))
    .ToArray();
var enabledMods = File.ReadLines(Path.Combine(rules.ProfilePath, "modlist.txt"))
    .Where(x => x.StartsWith('+'))
    .Select((x, index) => (Name: x[1..], Priority: index))
    .ToArray();

var pluginSources = DiscoverPluginSources(rules, activePluginNames, enabledMods);
var skyrimSource = pluginSources.GetValueOrDefault("Skyrim.esm")
    ?? throw new FileNotFoundException("Skyrim.esm is active but its physical file could not be resolved.");
var skyrim = Import(skyrimSource.Path);

if (inspectTargets)
{
    PrintTargetCandidates(skyrim);
    return;
}

if (validateOnly || validateProfile)
{
    ValidateOutput(rules.OutputPath, pluginSources);
    if (validateProfile) ValidateProfileActivation(rules, activePluginNames);
    return;
}

if (Directory.Exists(rules.OutputPath)) Directory.Delete(rules.OutputPath, recursive: true);
Directory.CreateDirectory(rules.OutputPath);
var keywordNames = skyrim.Keywords
    .Where(x => !string.IsNullOrWhiteSpace(x.EditorID))
    .ToDictionary(x => x.FormKey, x => x.EditorID!, EqualityComparer<FormKey>.Default);
var excludedForms = rules.ExcludedForms.ToHashSet(StringComparer.OrdinalIgnoreCase);
var suspiciousIncludes = rules.IncludedSuspiciousForms.ToHashSet(StringComparer.OrdinalIgnoreCase);
var existingSpidSources = DiscoverExistingSpidSourcePlugins(rules.ModsRoot, enabledMods.Select(x => x.Name));

var candidates = new List<ArmorCandidate>();
var excluded = new List<ExcludedArmor>();
var importedPlugins = new Dictionary<string, ISkyrimModGetter>(StringComparer.OrdinalIgnoreCase);
var failures = new List<string>();
var scanned = 0;

foreach (var active in activePluginNames)
{
    if (!pluginSources.TryGetValue(active.Name, out var source))
    {
        failures.Add($"{active.Name}: active plugin file not found");
        continue;
    }
    if (IsPluginExcluded(active.Name, rules)) continue;

    try
    {
        var plugin = Import(source.Path);
        importedPlugins[active.Name] = plugin;
        foreach (var keyword in plugin.Keywords)
            if (!string.IsNullOrWhiteSpace(keyword.EditorID)) keywordNames[keyword.FormKey] = keyword.EditorID!;

        foreach (var armor in plugin.Armors.Where(x => x.FormKey.ModKey == plugin.ModKey))
        {
            var key = ToConfigKey(armor.FormKey);
            var editorId = armor.EditorID ?? "";
            var name = armor.Name?.String ?? "";
            var exclusion = EligibilityFailure(armor, key, editorId, name, excludedForms, suspiciousIncludes);
            if (exclusion is not null)
            {
                excluded.Add(new(key, active.Name, editorId, name, exclusion));
                continue;
            }

            var (category, reason) = Classify(armor, active.Name, keywordNames, rules.ForcedCategories);
            candidates.Add(new ArmorCandidate
            {
                Armor = armor,
                Owner = plugin,
                Source = source,
                Category = category,
                ClassificationReason = reason,
                Slots = Slots(armor),
                ArmorType = armor.BodyTemplate!.ArmorType.ToString(),
                Tier = 1
            });
        }
    }
    catch (Exception ex)
    {
        failures.Add($"{active.Name}: {ex.GetType().Name}: {OneLine(ex.Message)}");
    }

    scanned++;
    if (scanned % 200 == 0) Console.WriteLine($"Scanned {scanned} non-official active plugins; {candidates.Count} eligible armor records...");
}

if (failures.Count > 0 && !rules.AllowPluginParseFailures)
    throw new InvalidDataException($"Plugin scan had {failures.Count} failures. See the console output or enable allowPluginParseFailures.");
if (candidates.Count == 0) throw new InvalidDataException("The active load order yielded no eligible added armor records.");

AssignValueQuartiles(candidates);
var shards = BuildShards(candidates, rules.MaximumSourceMastersPerShard);
var pools = new List<GeneratedPool>();
var outputPlugins = new List<string>();

for (var shardIndex = 0; shardIndex < shards.Count; shardIndex++)
{
    var shardItems = shards[shardIndex];
    var pluginName = $"NEFARAM_WorldWardrobe_Catalogue{shardIndex + 1:D2}.esp";
    var outputPlugin = BuildCatalogue(pluginName, shardItems, rules, pools);
    var outputFile = Path.Combine(rules.OutputPath, pluginName);
    outputPlugin.WriteToBinary(outputFile);
    outputPlugins.Add(outputFile);
    Console.WriteLine($"Built {pluginName}: {shardItems.Count} source items, {outputPlugin.LeveledItems.Count} generated lists, {outputPlugin.ModHeader.MasterReferences.Count} masters.");
}

var targetLists = ResolveLeveledTargets(skyrim, rules.LeveledListTargets);
ValidateContainerTargets(skyrim, rules.MerchantContainerTargets);
var router = BuildRouter(pools, targetLists, rules.MerchantContainerTargets);
var routerPath = Path.Combine(rules.OutputPath, router.Mod.ModKey.FileName.String);
router.Mod.WriteToBinary(routerPath);
outputPlugins.Add(routerPath);
Console.WriteLine($"Built {router.Mod.ModKey}: {router.Mod.LeveledItems.Count} consolidated routes over {pools.Count} source pools.");
WriteSkyPatcherConfig(rules.OutputPath, router.WorldRoutes, targetLists, candidates);
WriteCidConfig(rules.OutputPath, router.CategoryRoutes, rules.MerchantContainerTargets, candidates);

var outfits = SelectNpcOutfits(importedPlugins, candidates, existingSpidSources, rules);
ValidateNpcTargets(skyrim, outfits);
WriteSpidConfig(rules.OutputPath, outfits, candidates);
WriteReports(rules.OutputPath, candidates, excluded, failures, pools, outfits, outputPlugins);
File.Copy(Path.Combine(projectRoot, "README.md"), Path.Combine(rules.OutputPath, "README.md"), overwrite: true);
ValidateOutput(rules.OutputPath, pluginSources);

Console.WriteLine($"World Wardrobe complete: {candidates.Count} eligible items from {candidates.Select(x => x.Source.Name).Distinct(StringComparer.OrdinalIgnoreCase).Count()} plugins; {excluded.Count} excluded records; {pools.Count} category/tier pools; {outfits.Count} curated NPC outfits; {failures.Count} plugin scan failures.");

string? GetArgumentValue(string name)
{
    for (var i = 0; i < args.Length - 1; i++)
        if (args[i].Equals(name, StringComparison.OrdinalIgnoreCase)) return Path.GetFullPath(args[i + 1]);
    return null;
}

static void ValidateRules(GeneratorRules value, string path)
{
    if (!Directory.Exists(value.ProfilePath)) throw new DirectoryNotFoundException($"ProfilePath in {path} does not exist: {value.ProfilePath}");
    if (!Directory.Exists(value.ModsRoot)) throw new DirectoryNotFoundException($"ModsRoot in {path} does not exist: {value.ModsRoot}");
    if (!Directory.Exists(value.GameDataPath)) throw new DirectoryNotFoundException($"GameDataPath in {path} does not exist: {value.GameDataPath}");
    if (value.LeafSize is < 1 or > 100) throw new InvalidDataException("leafSize must be between 1 and 100.");
    if (value.MaximumSourceMastersPerShard is < 1 or > 200) throw new InvalidDataException("maximumSourceMastersPerShard must be between 1 and 200.");
    if (value.MaximumNewRecordsPerShard is < 100 or > 2000) throw new InvalidDataException("maximumNewRecordsPerShard must be between 100 and 2000.");
}

static string ExpandConfiguredPath(string value, string rulesPath)
{
    var expanded = Environment.ExpandEnvironmentVariables(value);
    return Path.IsPathRooted(expanded)
        ? expanded
        : Path.GetFullPath(Path.Combine(Path.GetDirectoryName(rulesPath)!, expanded));
}

static ISkyrimModGetter Import(string path) =>
    ModFactory<ISkyrimModGetter>.Importer(ModPath.FromPath(path), GameRelease.SkyrimSE);

static Dictionary<string, PluginSource> DiscoverPluginSources(
    GeneratorRules rules,
    (string Name, int Index)[] activePlugins,
    (string Name, int Priority)[] enabledMods)
{
    var activeSet = activePlugins.Select(x => x.Name).ToHashSet(StringComparer.OrdinalIgnoreCase);
    var enabledPriority = enabledMods.ToDictionary(x => x.Name, x => x.Priority, StringComparer.OrdinalIgnoreCase);
    var choices = new Dictionary<string, List<PluginSource>>(StringComparer.OrdinalIgnoreCase);

    foreach (var plugin in activePlugins)
    {
        var gamePath = Path.Combine(rules.GameDataPath, plugin.Name);
        if (File.Exists(gamePath)) Add(new(plugin.Name, gamePath, "<Game Data>", plugin.Index));
    }

    foreach (var path in Directory.EnumerateFiles(rules.ModsRoot, "*.*", SearchOption.AllDirectories)
        .Where(IsPluginFile))
    {
        var name = Path.GetFileName(path);
        if (!activeSet.Contains(name)) continue;
        var relative = Path.GetRelativePath(rules.ModsRoot, path);
        var modName = relative.Split(Path.DirectorySeparatorChar)[0];
        if (!enabledPriority.TryGetValue(modName, out var priority)) continue;
        Add(new(name, path, modName, priority));
    }

    var resolved = new Dictionary<string, PluginSource>(StringComparer.OrdinalIgnoreCase);
    foreach (var active in activePlugins)
    {
        if (!choices.TryGetValue(active.Name, out var candidates)) continue;
        resolved[active.Name] = candidates
            .OrderBy(x => x.ModName == "<Game Data>" ? int.MaxValue : x.LoadIndex)
            .ThenBy(x => x.Path, StringComparer.OrdinalIgnoreCase)
            .First();
    }
    return resolved;

    void Add(PluginSource source)
    {
        if (!choices.TryGetValue(source.Name, out var list)) choices[source.Name] = list = [];
        list.Add(source);
    }
}

static bool IsPluginFile(string path) => Path.GetExtension(path).Equals(".esp", StringComparison.OrdinalIgnoreCase) ||
    Path.GetExtension(path).Equals(".esm", StringComparison.OrdinalIgnoreCase) ||
    Path.GetExtension(path).Equals(".esl", StringComparison.OrdinalIgnoreCase);

static bool IsPluginExcluded(string plugin, GeneratorRules rules)
{
    if (rules.ExcludedPlugins.Contains(plugin, StringComparer.OrdinalIgnoreCase)) return true;
    return rules.ExcludedPluginPatterns.Any(pattern => GlobMatches(plugin, pattern));
}

static bool GlobMatches(string value, string pattern)
{
    var regex = "^" + Regex.Escape(pattern).Replace("\\*", ".*").Replace("\\?", ".") + "$";
    return Regex.IsMatch(value, regex, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
}

static string? EligibilityFailure(
    IArmorGetter armor,
    string key,
    string editorId,
    string name,
    HashSet<string> explicitExcludes,
    HashSet<string> suspiciousIncludes)
{
    if (explicitExcludes.Contains(key) || explicitExcludes.Contains(editorId)) return "explicitly excluded by rules";
    if (armor.IsDeleted) return "deleted record";
    if (armor.MajorFlags.HasFlag(Armor.MajorFlag.NonPlayable)) return "non-playable record";
    if (string.IsNullOrWhiteSpace(editorId)) return "missing EditorID";
    if (string.IsNullOrWhiteSpace(name)) return "missing display name";
    if (armor.BodyTemplate is null) return "missing body template";
    if (armor.Armature is null || armor.Armature.Count == 0) return "missing armor addon/model links";

    var search = $"{editorId} {name}";
    if (!suspiciousIncludes.Contains(key) && !suspiciousIncludes.Contains(editorId) &&
        Regex.IsMatch(search, @"(^|[^a-z])(invisible|dummy|placeholder|test|debug|naked|skin)([^a-z]|$)", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant))
        return "suspicious invisible/test/skin record; add to includedSuspiciousForms to force inclusion";
    return null;
}

static (string Category, string Reason) Classify(
    IArmorGetter armor,
    string plugin,
    Dictionary<FormKey, string> keywordNames,
    Dictionary<string, string> overrides)
{
    var key = ToConfigKey(armor.FormKey);
    if (overrides.TryGetValue(key, out var forced) ||
        (!string.IsNullOrWhiteSpace(armor.EditorID) && overrides.TryGetValue(armor.EditorID!, out forced)))
        return (forced, "forced category rule");

    var keywordText = armor.Keywords is null ? "" : string.Join(' ', armor.Keywords.Select(x => keywordNames.GetValueOrDefault(x.FormKey, "")));
    var text = $"{plugin} {armor.EditorID} {armor.Name?.String} {keywordText}";
    if (ContainsAny(text, "imperial", "legion")) return ("ImperialGear", "Imperial/Legion term or keyword");
    if (ContainsAny(text, "stormcloak", "sons of skyrim")) return ("StormcloakGear", "Stormcloak term or keyword");
    if (ContainsAny(text, "forsworn")) return ("ForswornGear", "Forsworn term or keyword");
    if (ContainsAny(text, "vampire")) return ("VampireGear", "vampire term or keyword");
    if (ContainsAny(text, "thalmor")) return ("ThalmorGear", "Thalmor term or keyword");
    if (ContainsAny(text, "vigilant", "dawnguard", "guard", "brotherhood", "thieves guild", "companions"))
        return ("FactionGear", "other faction term or keyword");
    if (ContainsAny(text, "mage", "wizard", "witch", "warlock", "sorcer", "necrom", "priest", "monk", "temple", "cleric", "robe"))
        return ("MageReligious", "mage/religious term or robe");
    if (ContainsAny(text, "dress", "gown", "noble", "royal", "queen", "princess", "wedding", "formal", "finecloth", "fine cloth", "court"))
        return ("FineClothing", "fine-clothing term");

    return armor.BodyTemplate!.ArmorType switch
    {
        ArmorType.LightArmor => ("LightArmor", "light armor body type"),
        ArmorType.HeavyArmor => ("HeavyArmor", "heavy armor body type"),
        ArmorType.Clothing when HasBodySlot(armor) => ("CommonClothing", "clothing body type"),
        ArmorType.Clothing => ("Oddities", "clothing accessory/non-body slot"),
        _ => ("Oddities", "unclassified armor type")
    };
}

static bool ContainsAny(string text, params string[] terms) =>
    terms.Any(x => text.Contains(x, StringComparison.OrdinalIgnoreCase));

static string Slots(IArmorGetter armor)
{
    if (armor.BodyTemplate is null) return "";
    var raw = (uint)armor.BodyTemplate.FirstPersonFlags;
    var slots = new List<int>();
    for (var slot = 30; slot <= 61; slot++)
        if ((raw & (1u << (slot - 30))) != 0) slots.Add(slot);
    return string.Join('+', slots);
}

static bool HasBodySlot(IArmorGetter armor)
{
    if (armor.BodyTemplate is null) return false;
    return (((uint)armor.BodyTemplate.FirstPersonFlags) & (1u << 2)) != 0;
}

static void AssignValueQuartiles(List<ArmorCandidate> candidates)
{
    foreach (var category in candidates.GroupBy(x => x.Category, StringComparer.OrdinalIgnoreCase))
    {
        var ordered = category.OrderBy(x => x.Armor.Value).ThenBy(x => x.Armor.FormKey).ToArray();
        for (var index = 0; index < ordered.Length; index++)
            ordered[index].Tier = Math.Min(4, (index * 4 / Math.Max(1, ordered.Length)) + 1);
    }
}

static List<List<ArmorCandidate>> BuildShards(List<ArmorCandidate> candidates, int masterLimit)
{
    var sourceGroups = candidates
        .GroupBy(x => x.Source.Name, StringComparer.OrdinalIgnoreCase)
        .OrderBy(x => x.Key, StringComparer.OrdinalIgnoreCase)
        .ToArray();
    var shards = new List<List<ArmorCandidate>>();
    var current = new List<ArmorCandidate>();
    var masters = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
    foreach (var group in sourceGroups)
    {
        if (current.Count > 0 && masters.Count + 1 > masterLimit)
        {
            shards.Add(current);
            current = [];
            masters.Clear();
        }
        masters.Add(group.Key);
        current.AddRange(group.OrderBy(x => x.Armor.FormKey.ID));
    }
    if (current.Count > 0) shards.Add(current);
    return shards;
}

static SkyrimMod BuildCatalogue(
    string pluginName,
    List<ArmorCandidate> items,
    GeneratorRules rules,
    List<GeneratedPool> generatedPools)
{
    var mod = new SkyrimMod(ModKey.FromNameAndExtension(pluginName), SkyrimRelease.SkyrimSE);
    mod.ModHeader.Flags |= SkyrimModHeader.HeaderFlag.Small;
    foreach (var master in items.Select(x => x.Armor.FormKey.ModKey).Distinct().OrderBy(x => x.FileName.String, StringComparer.OrdinalIgnoreCase))
        mod.ModHeader.MasterReferences.Add(new MasterReference { Master = master });

    foreach (var group in items.GroupBy(x => (x.Category, x.Tier)).OrderBy(x => x.Key.Category).ThenBy(x => x.Key.Tier))
    {
        var sourceItems = group.OrderBy(x => x.Source.Name, StringComparer.OrdinalIgnoreCase).ThenBy(x => x.Armor.FormKey.ID).ToArray();
        var leaves = new List<LeveledItem>();
        for (var offset = 0; offset < sourceItems.Length; offset += rules.LeafSize)
        {
            var leaf = new LeveledItem(mod.GetNextFormKey(), SkyrimRelease.SkyrimSE)
            {
                EditorID = $"NWW_{group.Key.Category}_T{group.Key.Tier}_Leaf{leaves.Count + 1:D2}",
                ChanceNone = new Noggog.Percent(0),
                Flags = LeveledItem.Flag.CalculateFromAllLevelsLessThanOrEqualPlayer,
                Entries = new()
            };
            foreach (var item in sourceItems.Skip(offset).Take(rules.LeafSize))
            {
                leaf.Entries.Add(new LeveledItemEntry
                {
                    Data = new LeveledItemEntryData
                    {
                        Reference = new FormLink<IItemGetter>(item.Armor.FormKey),
                        Level = 1,
                        Count = 1
                    }
                });
            }
            mod.LeveledItems.Add(leaf);
            leaves.Add(leaf);
        }

        var chanceNone = group.Key.Tier switch { 1 => 75, 2 => 85, 3 => 92, _ => 97 };
        var root = new LeveledItem(mod.GetNextFormKey(), SkyrimRelease.SkyrimSE)
        {
            EditorID = $"NWW_{group.Key.Category}_T{group.Key.Tier}_Pool",
            ChanceNone = new Noggog.Percent(chanceNone / 100d),
            Flags = LeveledItem.Flag.CalculateFromAllLevelsLessThanOrEqualPlayer,
            Entries = new()
        };
        foreach (var leaf in leaves)
        {
            root.Entries.Add(new LeveledItemEntry
            {
                Data = new LeveledItemEntryData
                {
                    Reference = new FormLink<IItemGetter>(leaf.FormKey),
                    Level = TierLevel(group.Key.Tier),
                    Count = 1
                }
            });
        }
        mod.LeveledItems.Add(root);
        generatedPools.Add(new(pluginName, root.FormKey, root.EditorID!, group.Key.Category, group.Key.Tier, sourceItems.Length, chanceNone));
        foreach (var item in sourceItems) item.Routes.Add($"{group.Key.Category} tier {group.Key.Tier} world/economy pool");
    }

    var newRecords = mod.EnumerateMajorRecords().Count();
    if (newRecords > rules.MaximumNewRecordsPerShard)
        throw new InvalidDataException($"{pluginName} generated {newRecords} records, exceeding maximumNewRecordsPerShard={rules.MaximumNewRecordsPerShard}.");
    return mod;
}

static (SkyrimMod Mod, List<GeneratedRoute> WorldRoutes, List<GeneratedRoute> CategoryRoutes) BuildRouter(
    List<GeneratedPool> pools,
    Dictionary<string, List<(string Plugin, uint FormId, string EditorId)>> leveledTargets,
    Dictionary<string, List<string>> containerTargets)
{
    const string pluginName = "NEFARAM_WorldWardrobe_Router.esp";
    var mod = new SkyrimMod(ModKey.FromNameAndExtension(pluginName), SkyrimRelease.SkyrimSE);
    mod.ModHeader.Flags |= SkyrimModHeader.HeaderFlag.Small;
    foreach (var master in pools.Select(x => ModKey.FromNameAndExtension(x.Plugin)).Distinct().OrderBy(x => x.FileName.String, StringComparer.OrdinalIgnoreCase))
        mod.ModHeader.MasterReferences.Add(new MasterReference { Master = master });

    var worldRoutes = new List<GeneratedRoute>();
    var allTargets = leveledTargets.Values.SelectMany(x => x).DistinctBy(x => (x.Plugin, x.FormId)).OrderBy(x => x.EditorId).ToArray();
    foreach (var target in allTargets)
    {
        var categories = leveledTargets.Where(x => x.Value.Any(y => y.Plugin.Equals(target.Plugin, StringComparison.OrdinalIgnoreCase) && y.FormId == target.FormId))
            .Select(x => x.Key).ToHashSet(StringComparer.OrdinalIgnoreCase);
        var routePools = pools.Where(x => categories.Contains(x.Category)).OrderBy(x => x.Tier).ThenBy(x => x.Plugin).ToArray();
        var route = AddRoute($"NWW_Route_LL_{SanitizeEditorId(target.EditorId)}", routePools, chanceNone: 50);
        worldRoutes.Add(new(pluginName, route.FormKey, route.EditorID!, "leveled-list", target.EditorId, routePools.Length, 50));
    }

    var categoryRoutes = new List<GeneratedRoute>();
    foreach (var category in containerTargets.Keys.OrderBy(x => x, StringComparer.OrdinalIgnoreCase))
    {
        var routePools = pools.Where(x => x.Category.Equals(category, StringComparison.OrdinalIgnoreCase)).OrderBy(x => x.Tier).ThenBy(x => x.Plugin).ToArray();
        if (routePools.Length == 0) continue;
        var route = AddRoute($"NWW_Route_CID_{SanitizeEditorId(category)}", routePools, chanceNone: 25);
        categoryRoutes.Add(new(pluginName, route.FormKey, route.EditorID!, "container", category, routePools.Length, 25));
    }
    return (mod, worldRoutes, categoryRoutes);

    LeveledItem AddRoute(string editorId, GeneratedPool[] routePools, int chanceNone)
    {
        var route = new LeveledItem(mod.GetNextFormKey(), SkyrimRelease.SkyrimSE)
        {
            EditorID = editorId,
            ChanceNone = new Noggog.Percent(chanceNone / 100d),
            Flags = LeveledItem.Flag.CalculateFromAllLevelsLessThanOrEqualPlayer,
            Entries = new()
        };
        foreach (var pool in routePools)
        {
            route.Entries.Add(new LeveledItemEntry
            {
                Data = new LeveledItemEntryData
                {
                    Reference = new FormLink<IItemGetter>(pool.FormKey),
                    Level = TierLevel(pool.Tier),
                    Count = 1
                }
            });
        }
        if (route.Entries.Count == 0) throw new InvalidDataException($"Router {editorId} has no source pools.");
        mod.LeveledItems.Add(route);
        return route;
    }
}

static string SanitizeEditorId(string value) => Regex.Replace(value, "[^A-Za-z0-9_]", "_");

static short TierLevel(int tier) => tier switch { 1 => 1, 2 => 8, 3 => 18, _ => 30 };

static Dictionary<string, List<(string Plugin, uint FormId, string EditorId)>> ResolveLeveledTargets(
    ISkyrimModGetter skyrim,
    Dictionary<string, List<string>> configured)
{
    var byEditor = skyrim.LeveledItems
        .Where(x => !string.IsNullOrWhiteSpace(x.EditorID))
        .ToDictionary(x => x.EditorID!, StringComparer.OrdinalIgnoreCase);
    var resolved = new Dictionary<string, List<(string, uint, string)>>(StringComparer.OrdinalIgnoreCase);
    foreach (var category in configured)
    {
        var targets = new List<(string, uint, string)>();
        foreach (var editorId in category.Value)
        {
            if (!byEditor.TryGetValue(editorId, out var record))
                throw new InvalidDataException($"Configured Skyrim leveled-list target does not exist: {category.Key} -> {editorId}. Run --inspect-targets.");
            targets.Add((record.FormKey.ModKey.FileName.String, record.FormKey.ID, editorId));
        }
        resolved[category.Key] = targets;
    }
    return resolved;
}

static void ValidateContainerTargets(ISkyrimModGetter skyrim, Dictionary<string, List<string>> configured)
{
    var editorIds = skyrim.Containers.Where(x => !string.IsNullOrWhiteSpace(x.EditorID))
        .Select(x => x.EditorID!).ToHashSet(StringComparer.OrdinalIgnoreCase);
    foreach (var target in configured.SelectMany(x => x.Value).Distinct(StringComparer.OrdinalIgnoreCase))
        if (!editorIds.Contains(target)) throw new InvalidDataException($"Configured Skyrim merchant container target does not exist: {target}. Run --inspect-targets.");
}

static void WriteSkyPatcherConfig(
    string outputRoot,
    List<GeneratedRoute> routes,
    Dictionary<string, List<(string Plugin, uint FormId, string EditorId)>> targets,
    List<ArmorCandidate> candidates)
{
    var directory = Path.Combine(outputRoot, "SKSE", "Plugins", "SkyPatcher", "leveledList", "NEFARAM World Wardrobe");
    Directory.CreateDirectory(directory);
    var path = Path.Combine(directory, "NEFARAM_WorldWardrobe.ini");
    var lines = new List<string>
    {
        "; Generated by NEFARAM World Wardrobe. Do not edit; change Generator/rules.json and rebuild.",
        "; Each generated list is nested and capped at 80 direct entries.",
        ""
    };
    var allTargets = targets.Values.SelectMany(x => x).DistinctBy(x => (x.Plugin, x.FormId)).ToDictionary(x => x.EditorId, StringComparer.OrdinalIgnoreCase);
    foreach (var route in routes.OrderBy(x => x.RouteKey, StringComparer.OrdinalIgnoreCase))
    {
        var target = allTargets[route.RouteKey];
        lines.Add($"; One consolidated route ({route.SourcePoolCount} source pools, {route.ChanceNone}% chance none) -> {target.EditorId}");
        lines.Add($"filterByLLs={target.Plugin}|{target.FormId:X}:addToLLs={route.Plugin}|{route.FormKey.ID:X}~1~1");
    }
    File.WriteAllLines(path, lines, new UTF8Encoding(false));
    foreach (var item in candidates)
        if (targets.ContainsKey(item.Category)) item.Routes.Add("SkyPatcher leveled-list injection");
}

static void WriteCidConfig(
    string outputRoot,
    List<GeneratedRoute> routes,
    Dictionary<string, List<string>> targets,
    List<ArmorCandidate> candidates)
{
    var path = Path.Combine(outputRoot, "NEFARAM_WorldWardrobe_CID.ini");
    var lines = new List<string>
    {
        "[General]",
        "; Generated by NEFARAM World Wardrobe. Exact merchant containers only; no generic container bases.",
        "; Values are generated leveled pools, so the pool's level gate and chance-none control stock.",
        ""
    };
    foreach (var route in routes.OrderBy(x => x.RouteKey, StringComparer.OrdinalIgnoreCase))
    {
        if (!targets.TryGetValue(route.RouteKey, out var containers)) continue;
        foreach (var container in containers.Distinct(StringComparer.OrdinalIgnoreCase))
            lines.Add($"{container} = 0x{route.FormKey.ID:X}~{route.Plugin}|1");
    }
    File.WriteAllLines(path, lines, new UTF8Encoding(false));
    foreach (var item in candidates)
        if (targets.ContainsKey(item.Category)) item.Routes.Add("CID specialist merchant stock");
}

static HashSet<string> DiscoverExistingSpidSourcePlugins(string modsRoot, IEnumerable<string> enabledModNames)
{
    var result = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
    var pluginPattern = new Regex(@"~([^|,;]+\.(?:esp|esm|esl))", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
    foreach (var modName in enabledModNames)
    {
        var modPath = Path.Combine(modsRoot, modName);
        if (!Directory.Exists(modPath)) continue;
        foreach (var ini in Directory.EnumerateFiles(modPath, "*_DISTR.ini", SearchOption.AllDirectories))
        {
            foreach (var line in File.ReadLines(ini))
                foreach (Match match in pluginPattern.Matches(line)) result.Add(match.Groups[1].Value.Trim());
        }
    }
    return result;
}

static List<OutfitCandidate> SelectNpcOutfits(
    Dictionary<string, ISkyrimModGetter> plugins,
    List<ArmorCandidate> candidates,
    HashSet<string> existingSpidSources,
    GeneratorRules rules)
{
    var armorByForm = candidates.ToDictionary(x => x.Armor.FormKey);
    var approved = rules.NpcApprovedOutfits.ToHashSet(StringComparer.OrdinalIgnoreCase);
    var denied = rules.NpcDeniedOutfits.ToHashSet(StringComparer.OrdinalIgnoreCase);
    var discovered = new List<OutfitCandidate>();

    foreach (var pluginPair in plugins.OrderBy(x => x.Key, StringComparer.OrdinalIgnoreCase))
    {
        var plugin = pluginPair.Value;
        foreach (var outfit in plugin.Outfits.Where(x => x.FormKey.ModKey == plugin.ModKey && !string.IsNullOrWhiteSpace(x.EditorID)))
        {
            var key = ToConfigKey(outfit.FormKey);
            if (denied.Contains(key) || denied.Contains(outfit.EditorID!)) continue;
            if (outfit.Items is null || outfit.Items.Count == 0) continue;
            var resolved = outfit.Items.Select(x => armorByForm.GetValueOrDefault(x.FormKey)).Where(x => x is not null).Cast<ArmorCandidate>().ToArray();
            if (resolved.Length == 0 || !resolved.Any(x => HasBodySlot(x.Armor))) continue;
            var explicitApproval = approved.Contains(key) || approved.Contains(outfit.EditorID!);
            if (!explicitApproval) continue;
            if (!explicitApproval && existingSpidSources.Contains(pluginPair.Key)) continue;
            if (!explicitApproval && resolved.Length != outfit.Items.Count) continue;
            if (resolved.SelectMany(x => x.Slots.Split('+', StringSplitOptions.RemoveEmptyEntries)).GroupBy(x => x).Any(x => x.Count() > 1)) continue;

            var category = resolved.GroupBy(x => x.Category).OrderByDescending(x => x.Count()).First().Key;
            var faction = category switch
            {
                "LightArmor" => "BanditFaction",
                "HeavyArmor" => "BanditFaction",
                "MageReligious" => "WarlockFaction",
                "ImperialGear" => "ImperialFaction",
                "StormcloakGear" => "StormcloakFaction",
                "ForswornGear" => "ForswornFaction",
                "VampireGear" => "VampireFaction",
                "ThalmorGear" => "ThalmorFaction",
                _ => ""
            };
            if (rules.NpcOutfitFactions.TryGetValue(key, out var forcedFaction) || rules.NpcOutfitFactions.TryGetValue(outfit.EditorID!, out forcedFaction))
                faction = forcedFaction;
            if (faction.Length == 0) faction = "BanditFaction";
            discovered.Add(new(outfit, category, faction, pluginPair.Key, explicitApproval ? "explicit rules approval" : "complete existing outfit record"));
        }
    }

    var selected = new List<OutfitCandidate>();
    foreach (var pool in discovered.GroupBy(x => (x.Category, x.TargetFaction)))
    {
        selected.AddRange(pool
            .OrderByDescending(x => approved.Contains(ToConfigKey(x.Outfit.FormKey)) || approved.Contains(x.Outfit.EditorID!))
            .ThenBy(x => x.SourcePlugin, StringComparer.OrdinalIgnoreCase)
            .ThenBy(x => x.Outfit.EditorID, StringComparer.OrdinalIgnoreCase)
            .Take(4));
    }
    return selected;
}

static void WriteSpidConfig(string outputRoot, List<OutfitCandidate> outfits, List<ArmorCandidate> candidates)
{
    var path = Path.Combine(outputRoot, "zz_NEFARAM_WorldWardrobe_DISTR.ini");
    var lines = new List<string>
    {
        "; Generated late-loading fallback outfits. Existing focused SPID outfit packs should win first.",
        "; Generic, non-unique adult NPC templates only; each approved pool is capped at four 1% entries.",
        ""
    };
    foreach (var outfit in outfits.OrderBy(x => x.TargetFaction).ThenBy(x => x.SourcePlugin).ThenBy(x => x.Outfit.EditorID))
    {
        lines.Add($"; {outfit.Category}: {outfit.Outfit.EditorID} ({outfit.Reason})");
        lines.Add($"Outfit = 0x{outfit.Outfit.FormKey.ID:X}~{outfit.SourcePlugin}|ActorTypeNPC|{outfit.TargetFaction}|NONE|-U/-C|NONE|1");
        foreach (var item in outfit.Outfit.Items!)
        {
            var candidate = candidates.FirstOrDefault(x => x.Armor.FormKey == item.FormKey);
            candidate?.Routes.Add($"SPID NPC outfit {outfit.Outfit.EditorID}");
        }
    }
    File.WriteAllLines(path, lines, new UTF8Encoding(false));
}

static void ValidateNpcTargets(ISkyrimModGetter skyrim, List<OutfitCandidate> outfits)
{
    var factionIds = skyrim.Factions.Where(x => !string.IsNullOrWhiteSpace(x.EditorID))
        .Select(x => x.EditorID!).ToHashSet(StringComparer.OrdinalIgnoreCase);
    foreach (var faction in outfits.Select(x => x.TargetFaction).Distinct(StringComparer.OrdinalIgnoreCase))
        if (!factionIds.Contains(faction)) throw new InvalidDataException($"Configured SPID target faction does not exist in Skyrim.esm: {faction}");
    var keywordIds = skyrim.Keywords.Where(x => !string.IsNullOrWhiteSpace(x.EditorID))
        .Select(x => x.EditorID!).ToHashSet(StringComparer.OrdinalIgnoreCase);
    foreach (var keyword in new[] { "ActorTypeNPC" })
        if (!keywordIds.Contains(keyword)) throw new InvalidDataException($"Required SPID filter keyword does not exist in Skyrim.esm: {keyword}");
}

static void WriteReports(
    string outputRoot,
    List<ArmorCandidate> candidates,
    List<ExcludedArmor> excluded,
    List<string> failures,
    List<GeneratedPool> pools,
    List<OutfitCandidate> outfits,
    List<string> plugins)
{
    var coveragePath = Path.Combine(outputRoot, "coverage.csv");
    var coverage = new List<string> { "FormKey,Plugin,EditorID,Name,Category,Tier,Value,ArmorType,Slots,Classification,Routes" };
    coverage.AddRange(candidates.OrderBy(x => x.Source.LoadIndex).ThenBy(x => x.Armor.FormKey.ID).Select(x => string.Join(',', new[]
    {
        Csv(ToConfigKey(x.Armor.FormKey)), Csv(x.Source.Name), Csv(x.Armor.EditorID), Csv(x.Armor.Name?.String), Csv(x.Category),
        x.Tier.ToString(), x.Armor.Value.ToString(), Csv(x.ArmorType), Csv(x.Slots), Csv(x.ClassificationReason), Csv(string.Join("; ", x.Routes.Distinct()))
    })));
    File.WriteAllLines(coveragePath, coverage, new UTF8Encoding(false));

    var excludedPath = Path.Combine(outputRoot, "excluded.csv");
    var excludedLines = new List<string> { "FormKey,Plugin,EditorID,Name,Reason" };
    excludedLines.AddRange(excluded.OrderBy(x => x.Plugin).ThenBy(x => x.FormKey).Select(x =>
        string.Join(',', Csv(x.FormKey), Csv(x.Plugin), Csv(x.EditorId), Csv(x.Name), Csv(x.Reason))));
    File.WriteAllLines(excludedPath, excludedLines, new UTF8Encoding(false));

    var uncovered = candidates.Where(x => x.Routes.Count == 0).ToArray();
    var summary = new StringBuilder();
    summary.AppendLine("# NEFARAM World Wardrobe Coverage").AppendLine();
    summary.AppendLine($"- Eligible added armor/clothing records: **{candidates.Count}**");
    summary.AppendLine($"- Source plugins represented: **{candidates.Select(x => x.Source.Name).Distinct(StringComparer.OrdinalIgnoreCase).Count()}**");
    summary.AppendLine($"- Excluded records: **{excluded.Count}**");
    summary.AppendLine($"- Plugin scan failures: **{failures.Count}**");
    summary.AppendLine($"- Generated catalog plugins: **{plugins.Count}**");
    summary.AppendLine($"- Generated world/economy pools: **{pools.Count}**");
    summary.AppendLine($"- Curated fallback NPC outfits: **{outfits.Count}**");
    summary.AppendLine($"- Eligible records without an acquisition route: **{uncovered.Length}**").AppendLine();
    summary.AppendLine("## Categories").AppendLine();
    foreach (var category in candidates.GroupBy(x => x.Category).OrderBy(x => x.Key))
        summary.AppendLine($"- {category.Key}: {category.Count()}");
    summary.AppendLine().AppendLine("## Scan failures").AppendLine();
    if (failures.Count == 0) summary.AppendLine("None.");
    else foreach (var failure in failures) summary.AppendLine($"- {failure}");
    summary.AppendLine().AppendLine("## Safety exclusions").AppendLine();
    foreach (var reason in excluded.GroupBy(x => x.Reason).OrderByDescending(x => x.Count()))
        summary.AppendLine($"- {reason.Key}: {reason.Count()}");
    File.WriteAllText(Path.Combine(outputRoot, "coverage.md"), summary.ToString(), new UTF8Encoding(false));

    if (uncovered.Length > 0)
        throw new InvalidDataException($"Coverage invariant failed: {uncovered.Length} eligible records have no acquisition route. See {coveragePath}.");
}

static void ValidateOutput(string outputRoot, Dictionary<string, PluginSource> availableSources)
{
    if (!Directory.Exists(outputRoot)) throw new DirectoryNotFoundException($"Build output not found: {outputRoot}");
    var pluginPaths = Directory.EnumerateFiles(outputRoot, "NEFARAM_WorldWardrobe_*.esp", SearchOption.TopDirectoryOnly).OrderBy(x => x).ToArray();
    if (pluginPaths.Length == 0) throw new InvalidDataException("No generated World Wardrobe catalog plugins were found.");
    var allEditorIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
    foreach (var path in pluginPaths)
    {
        var plugin = Import(path);
        if (plugin.ModHeader.Flags.HasFlag(SkyrimModHeader.HeaderFlag.Master)) throw new InvalidDataException("Catalogue must be an ESL-flagged ESP, not a master.");
        if (!plugin.ModHeader.Flags.HasFlag(SkyrimModHeader.HeaderFlag.Small)) throw new InvalidDataException($"{Path.GetFileName(path)} is not ESL-flagged.");
        if (plugin.ModHeader.MasterReferences.Count > 200) throw new InvalidDataException($"{Path.GetFileName(path)} has too many masters: {plugin.ModHeader.MasterReferences.Count}.");
        if (plugin.EnumerateMajorRecords().Count() > 2000) throw new InvalidDataException($"{Path.GetFileName(path)} exceeds the safe ESL record budget.");
        foreach (var master in plugin.ModHeader.MasterReferences)
            if (!availableSources.ContainsKey(master.Master.FileName.String) && !File.Exists(Path.Combine(outputRoot, master.Master.FileName.String)))
                throw new InvalidDataException($"{Path.GetFileName(path)} has unavailable master {master.Master}.");
        foreach (var record in plugin.EnumerateMajorRecords())
            if (!string.IsNullOrWhiteSpace(record.EditorID) && !allEditorIds.Add($"{plugin.ModKey}|{record.EditorID}")) throw new InvalidDataException($"Duplicate generated EditorID in {plugin.ModKey}: {record.EditorID}");
        foreach (var list in plugin.LeveledItems)
        {
            if (list.Entries is null || list.Entries.Count == 0) throw new InvalidDataException($"Empty generated leveled list: {plugin.ModKey}|{list.EditorID}");
            if (list.EditorID?.Contains("_Leaf", StringComparison.OrdinalIgnoreCase) == true && list.Entries.Count > 80)
                throw new InvalidDataException($"Generated leaf exceeds 80 entries: {plugin.ModKey}|{list.EditorID}");
        }
    }

    foreach (var required in new[]
    {
        Path.Combine(outputRoot, "coverage.csv"),
        Path.Combine(outputRoot, "coverage.md"),
        Path.Combine(outputRoot, "excluded.csv"),
        Path.Combine(outputRoot, "README.md"),
        Path.Combine(outputRoot, "NEFARAM_WorldWardrobe_CID.ini"),
        Path.Combine(outputRoot, "zz_NEFARAM_WorldWardrobe_DISTR.ini"),
        Path.Combine(outputRoot, "SKSE", "Plugins", "SkyPatcher", "leveledList", "NEFARAM World Wardrobe", "NEFARAM_WorldWardrobe.ini")
    })
        if (!File.Exists(required)) throw new FileNotFoundException("Required generated output is missing.", required);
    Console.WriteLine($"Validated {pluginPaths.Length} generated catalog plugins and all required reports/configuration files.");
}

static void ValidateProfileActivation(GeneratorRules rules, (string Name, int Index)[] activePlugins)
{
    var enabledMods = File.ReadLines(Path.Combine(rules.ProfilePath, "modlist.txt"))
        .Where(x => x.StartsWith('+')).Select(x => x[1..]).ToHashSet(StringComparer.OrdinalIgnoreCase);
    foreach (var requiredMod in new[] { "[NoDelete] NEFARAM - World Wardrobe", "[NoDelete] 000 SkyPatcher - SE (unsure if needed)", "Address Library for SKSE Plugins" })
        if (!enabledMods.Contains(requiredMod)) throw new InvalidDataException($"Required MO2 mod is not enabled in the active profile: {requiredMod}");

    var order = activePlugins.ToDictionary(x => x.Name, x => x.Index, StringComparer.OrdinalIgnoreCase);
    var generated = Directory.EnumerateFiles(rules.OutputPath, "NEFARAM_WorldWardrobe_*.esp", SearchOption.TopDirectoryOnly).OrderBy(x => x).ToArray();
    foreach (var path in generated)
    {
        var name = Path.GetFileName(path);
        if (!order.TryGetValue(name, out var pluginIndex)) throw new InvalidDataException($"Generated plugin is not active in plugins.txt: {name}");
        var plugin = Import(path);
        foreach (var master in plugin.ModHeader.MasterReferences)
        {
            if (!order.TryGetValue(master.Master.FileName.String, out var masterIndex))
                throw new InvalidDataException($"Active generated plugin {name} has an inactive master: {master.Master}");
            if (masterIndex >= pluginIndex)
                throw new InvalidDataException($"Master order violation: {master.Master} ({masterIndex}) must load before {name} ({pluginIndex}).");
        }
    }

    var runtimeRoot = Path.Combine(rules.ModsRoot, "[NoDelete] NEFARAM - World Wardrobe");
    foreach (var source in Directory.EnumerateFiles(rules.OutputPath, "*", SearchOption.AllDirectories))
    {
        var relative = Path.GetRelativePath(rules.OutputPath, source);
        var installed = Path.Combine(runtimeRoot, relative);
        if (!File.Exists(installed)) throw new FileNotFoundException($"Runtime deployment is missing {relative}.", installed);
        if (!File.ReadAllBytes(source).SequenceEqual(File.ReadAllBytes(installed)))
            throw new InvalidDataException($"Runtime deployment differs from build output: {relative}");
    }
    Console.WriteLine($"Validated active profile enablement, master ordering, and byte-identical runtime deployment for {generated.Length} generated plugins.");
}

static void PrintTargetCandidates(ISkyrimModGetter skyrim)
{
    Console.WriteLine("LEVELED ITEM CANDIDATES");
    foreach (var list in skyrim.LeveledItems
        .Where(x => !string.IsNullOrWhiteSpace(x.EditorID) && ContainsAny(x.EditorID!, "armor", "clothes", "bandit", "boss", "vendor", "warlock", "draugr", "forsworn"))
        .OrderBy(x => x.EditorID))
        Console.WriteLine($"{list.FormKey.ID:X6}|{list.EditorID}|entries={list.Entries?.Count ?? 0}|none={list.ChanceNone}");
    Console.WriteLine();
    Console.WriteLine("CONTAINER CANDIDATES");
    foreach (var container in skyrim.Containers
        .Where(x => !string.IsNullOrWhiteSpace(x.EditorID) && ContainsAny(x.EditorID!, "merchant", "palace", "jarl", "radiant", "warmaiden", "bitsandpieces", "belethor"))
        .OrderBy(x => x.EditorID))
        Console.WriteLine($"{container.FormKey.ID:X6}|{container.EditorID}|items={container.Items?.Count ?? 0}");
}

static string ToConfigKey(FormKey key) => $"0x{key.ID:X}~{key.ModKey.FileName.String}";
static string OneLine(string value) => value.Replace('\r', ' ').Replace('\n', ' ').Trim();
static string Csv(string? value)
{
    value ??= "";
    return value.IndexOfAny([',', '"', '\r', '\n']) >= 0 ? $"\"{value.Replace("\"", "\"\"")}\"" : value;
}
