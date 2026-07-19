using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

const string ModsRoot = @"C:\games\nefaram\mods";
const string GameData = @"C:\games\steamapps\common\Skyrim Special Edition\Data";
const string OutputRoot = @"C:\games\nefaram\mods\NEFARAM - Flawed Wardrobe";
const int TargetCount = 75;
const int TotalSourceCount = 300;

string[] sourceNames = [
    "The Amazing World of Bikini Armors REMASTERED.esp", "(Pumpkin)-TEWOBA-TheExpandedWorldofBikiniArmor.esp",
    "TAWOBA_dawn.esp", "TAWOBA_guards_addon.esp", "TAWOBA_sons.esp", "Ghaan Revealing Outfit Craftable.esp",
    "GirlHeavyArmor.esp", "StormcloakWarmaidenArmor.esp", "StalhrimBikini.esp", "Demon Hunter Armour.esp",
    "ralfetas-deze-armor.esp", "ralfetas-deze-clothing.esp", "Twilight Princess Armor.esp", "Elven Sentry Armor.esp",
    "Azure Knight Armor.esp", "DracaniaArmor.esp", "C5Kevs_Yumiko_Light_Tank_Armor_CBBE.esp", "[FB] Bishop Armor.esp",
    "ObiDruchiiArmor.esp", "Obi's Gladiator Armor.esp", "Iron Rose Armor.esp", "RoverArmor.esp", "ChronomancerArmor.esp",
    "RoyalVanguardArmor.esp", "[Enovilum] Vampire Temptress Armor.esp"
];

var normalEffects = new (string Label, uint Id)[] {
    ("Cracked", 0x000846), ("Leadfoot", 0x000845), ("Exhausting", 0x00084D),
    ("Noisy", 0x00081A), ("Uncouth", 0x00084F)
};
var adultEffects = new (string Label, uint Id)[] {
    ("Desiring", 0x03FC00), ("Shameless", 0x0406CB), ("Free Use", 0x0416F4),
    ("Mortal Pleasure", 0x041C5F), ("Feral", 0x041C66)
};

string? FindPlugin(string name)
{
    var gamePath = Path.Combine(GameData, name);
    if (File.Exists(gamePath)) return gamePath;
    return Directory.EnumerateFiles(ModsRoot, name, SearchOption.AllDirectories).FirstOrDefault();
}

ISkyrimModGetter Import(string path) => ModFactory<ISkyrimModGetter>.Importer(ModPath.FromPath(path), GameRelease.SkyrimSE);

if (args.Length > 0 && args[0] == "--inspect")
{
    var types = new[] { typeof(ConstructibleObject), typeof(ContainerEntry), typeof(ContainerItem), typeof(MiscItem),
        typeof(FormList), typeof(VirtualMachineAdapter), typeof(ScriptEntry), typeof(ScriptObjectProperty) };
    foreach (var type in types) {
        foreach (var ctor in type.GetConstructors()) Console.WriteLine($"{type.Name}|CTOR|{ctor}");
        foreach (var p in type.GetProperties()) Console.WriteLine($"{type.Name}|PROP|{p.Name}|{p.PropertyType}");
    }
    return;
}

if (args.Length > 0 && args[0] == "--validate")
{
    var totalVariants = 0;
    var totalResults = 0;
    var totalRefitFlawed = 0;
    var totalRefitClean = 0;
    var validationStrips = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x0800E4);
    var validationCharcoal = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x033761);
    foreach (var validateShard in new[] { "A", "B", "C", "D" }) {
        var path = Path.Combine(OutputRoot, $"NEFARAM_FlawedWardrobe_Catalogue{validateShard}.esl");
        var catalogue = Import(path);
        var expectedLists = validateShard == "D" ? 85 : 75;
        var expectedMisc = validateShard == "D" ? 76 : 75;
        var expectedRecipes = validateShard == "D" ? 76 : 75;
        if (!catalogue.ModHeader.Flags.HasFlag(SkyrimModHeader.HeaderFlag.Small)) throw new InvalidDataException($"{validateShard}: ESL small flag is missing.");
        if (catalogue.Armors.Count != 750 || catalogue.FormLists.Count != expectedLists ||
            catalogue.MiscItems.Count != expectedMisc || catalogue.ConstructibleObjects.Count != expectedRecipes)
            throw new InvalidDataException($"{validateShard}: unexpected record counts.");
        var newRecordCount = catalogue.Armors.Count + catalogue.FormLists.Count + catalogue.MiscItems.Count + catalogue.ConstructibleObjects.Count;
        if (newRecordCount >= 4096) throw new InvalidDataException($"{validateShard}: {newRecordCount} records exceeds ESL capacity.");
        if (catalogue.EnumerateMajorRecords().Any(x => x.FormKey.ID > 0xFFF)) throw new InvalidDataException($"{validateShard}: a new FormID exceeds the light-plugin range.");

        var armorKeys = catalogue.Armors.Select(x => x.FormKey).ToHashSet();
        var armorByKey = catalogue.Armors.ToDictionary(x => x.FormKey);
        if (catalogue.ConstructibleObjects.Any(x => armorKeys.Contains(x.CreatedObject.FormKey)))
            throw new InvalidDataException($"{validateShard}: found a forbidden direct variant recipe.");
        foreach (var list in catalogue.FormLists.Where(x => x.EditorID?.StartsWith("NFW_Results_", StringComparison.Ordinal) == true)) {
            if (list.Items.Count != 10 || list.Items.Any(x => !armorKeys.Contains(x.FormKey)))
                throw new InvalidDataException($"{validateShard}: {list.EditorID} does not contain ten local variants.");
            var normalCount = list.Items.Count(x => armorByKey[x.FormKey].ObjectEffect.FormKey.ModKey.FileName.String.Equals("disenchantments.esl", StringComparison.OrdinalIgnoreCase));
            var adultCount = list.Items.Count(x => armorByKey[x.FormKey].ObjectEffect.FormKey.ModKey.FileName.String.Equals("SLER.esp", StringComparison.OrdinalIgnoreCase));
            if (normalCount != 5 || adultCount != 5) throw new InvalidDataException($"{validateShard}: {list.EditorID} is not a 5/5 effect pool.");
            totalResults += list.Items.Count;
        }
        foreach (var item in catalogue.MiscItems.Where(x => x.EditorID?.StartsWith("NFW_WorkOrder_", StringComparison.Ordinal) == true)) {
            var script = item.VirtualMachineAdapter?.Scripts.SingleOrDefault(x => x.Name == "NFW_CraftResult");
            var resultProperty = script?.Properties.OfType<IScriptObjectPropertyGetter>().SingleOrDefault(x => x.Name == "Results");
            var suffix = item.EditorID!["NFW_WorkOrder_".Length..];
            var expectedResult = catalogue.FormLists.Single(x => x.EditorID == $"NFW_Results_{suffix}");
            var recipe = catalogue.ConstructibleObjects.Single(x => x.EditorID == $"NFW_Recipe_WorkOrder_{suffix}");
            if (resultProperty == null || resultProperty.Object.FormKey != expectedResult.FormKey || recipe.CreatedObject.FormKey != item.FormKey)
                throw new InvalidDataException($"{validateShard}: {item.EditorID} has invalid VMAD data.");
            var recipeItems = recipe.Items ?? throw new InvalidDataException($"{validateShard}: {recipe.EditorID} has no ingredients.");
            if (!recipeItems.Any(x => x.Item.Item.FormKey == validationStrips && x.Item.Count >= 2) ||
                !recipeItems.Any(x => x.Item.Item.FormKey == validationCharcoal && x.Item.Count >= 1))
                throw new InvalidDataException($"{validateShard}: {recipe.EditorID} is missing its surcharge.");
        }
        if (validateShard == "D") {
            foreach (var tier in new[] { 25, 40, 60, 80, 100 }) {
                var flawed = catalogue.FormLists.Single(x => x.EditorID == $"NFW_RefitFlawed{tier}");
                var clean = catalogue.FormLists.Single(x => x.EditorID == $"NFW_RefitClean{tier}");
                if (flawed.Items.Count != clean.Items.Count) throw new InvalidDataException($"D: refit tier {tier} lists are not parallel.");
                totalRefitFlawed += flawed.Items.Count;
                totalRefitClean += clean.Items.Count;
            }
            var refit = catalogue.MiscItems.Single(x => x.EditorID == "NFW_RefitToken");
            var refitScript = refit.VirtualMachineAdapter?.Scripts.SingleOrDefault(x => x.Name == "NFW_RefitController");
            if (refitScript == null || refitScript.Properties.Count != 12) throw new InvalidDataException("D: refit controller VMAD is invalid.");
            foreach (var requiredMaster in new[] { "NEFARAM_FlawedWardrobe_CatalogueA.esl", "NEFARAM_FlawedWardrobe_CatalogueB.esl", "NEFARAM_FlawedWardrobe_CatalogueC.esl" })
                if (!catalogue.ModHeader.MasterReferences.Any(x => x.Master.FileName.String.Equals(requiredMaster, StringComparison.OrdinalIgnoreCase)))
                    throw new InvalidDataException($"D: missing master {requiredMaster}.");
        }
        totalVariants += catalogue.Armors.Count;
        Console.WriteLine($"Validated shard {validateShard}: {newRecordCount} new records.");
    }
    if (totalVariants != 3000 || totalResults != 3000 || totalRefitFlawed != 3000 || totalRefitClean != 3000)
        throw new InvalidDataException($"Aggregate mismatch: variants={totalVariants}, results={totalResults}, refit={totalRefitFlawed}/{totalRefitClean}.");
    Console.WriteLine("Validation passed: 3,000 variants, 300 ten-item result pools, no direct variant recipes, and 3,000 parallel refit mappings.");
    return;
}

if (args.Length == 0 || !int.TryParse(args[0], out var sourceOffset) || sourceOffset is < 0 or > 225 || sourceOffset % TargetCount != 0)
    throw new ArgumentException("Pass one shard offset: 0, 75, 150, or 225.");

var shard = new[] { "A", "B", "C", "D" }[sourceOffset / TargetCount];
var outputName = $"NEFARAM_FlawedWardrobe_Catalogue{shard}.esl";
var outputPath = Path.Combine(OutputRoot, outputName);
var skyrimKey = ModKey.FromNameAndExtension("Skyrim.esm");
var stripsKey = new FormKey(skyrimKey, 0x0800E4);
var charcoalKey = new FormKey(skyrimKey, 0x033761);
var forgeKey = new FormKey(skyrimKey, 0x088105);

var importedSources = new List<ISkyrimModGetter>();
var keywordNames = new Dictionary<FormKey, string>();
var skyrim = Import(FindPlugin("Skyrim.esm") ?? throw new FileNotFoundException("Skyrim.esm not found."));
foreach (var keyword in skyrim.Keywords)
    if (!string.IsNullOrWhiteSpace(keyword.EditorID)) keywordNames[keyword.FormKey] = keyword.EditorID;

foreach (var sourceName in sourceNames) {
    var path = FindPlugin(sourceName) ?? throw new FileNotFoundException($"Required source plugin not found: {sourceName}");
    var source = Import(path);
    importedSources.Add(source);
    foreach (var keyword in source.Keywords)
        if (!string.IsNullOrWhiteSpace(keyword.EditorID)) keywordNames[keyword.FormKey] = keyword.EditorID;
}

int TierFor(IArmorGetter armor)
{
    var terms = new List<string> { armor.EditorID ?? "", armor.Name?.String ?? "" };
    if (armor.Keywords != null) {
        foreach (var keyword in armor.Keywords)
            if (keywordNames.TryGetValue(keyword.FormKey, out var name)) terms.Add(name);
    }
    var text = string.Join(' ', terms).ToLowerInvariant();
    if (text.Contains("daedric") || text.Contains("dragon")) return 100;
    if (text.Contains("glass") || text.Contains("ebony")) return 80;
    if (text.Contains("elven") || text.Contains("advanced") || text.Contains("scaled") || text.Contains("plate")) return 60;
    if (text.Contains("steel") || text.Contains("dwarven") || text.Contains("orcish") || text.Contains("stalhrim")) return 40;
    return 25;
}

var eligibleBySource = new List<(ISkyrimModGetter Owner, List<IArmorGetter> Armors)>();
foreach (var source in importedSources) {
    var eligible = new List<IArmorGetter>();
    foreach (var armor in source.Armors) {
        if (string.IsNullOrWhiteSpace(armor.EditorID) || string.IsNullOrWhiteSpace(armor.Name?.String)) continue;
        if (armor.BodyTemplate == null || armor.Armature == null || armor.Armature.Count == 0) continue;
        var search = $"{armor.EditorID} {armor.Name.String}".ToLowerInvariant();
        if (search.Contains("shield") || search.Contains("invisible") || search.Contains("dummy") || search.Contains("placeholder")) continue;
        eligible.Add(armor);
    }
    eligibleBySource.Add((source, eligible));
}
var selected = new List<(IArmorGetter Armor, ISkyrimModGetter Owner)>();
foreach (var source in eligibleBySource)
    selected.AddRange(source.Armors.Take(12).Select(armor => (armor, source.Owner)));
foreach (var source in eligibleBySource) {
    if (selected.Count >= TotalSourceCount) break;
    selected.AddRange(source.Armors.Skip(12).Take(TotalSourceCount - selected.Count).Select(armor => (armor, source.Owner)));
}
if (selected.Count != TotalSourceCount)
    throw new InvalidOperationException($"Expected {TotalSourceCount} source armors but selected {selected.Count}.");
var allTargets = selected.Select((target, index) =>
    (target.Armor, target.Owner, Index: index, Tier: TierFor(target.Armor))).ToList();
var targets = allTargets.Skip(sourceOffset).Take(TargetCount).ToArray();

var mod = new SkyrimMod(ModKey.FromNameAndExtension(outputName), SkyrimRelease.SkyrimSE);
mod.ModHeader.Flags |= SkyrimModHeader.HeaderFlag.Small;
var masterKeys = new HashSet<ModKey> {
    skyrimKey, ModKey.FromNameAndExtension("Update.esm"),
    ModKey.FromNameAndExtension("disenchantments.esl"), ModKey.FromNameAndExtension("SLER.esp")
};
foreach (var target in targets) {
    masterKeys.Add(target.Owner.ModKey);
    foreach (var master in target.Owner.ModHeader.MasterReferences) masterKeys.Add(master.Master);
}
if (shard == "D") {
    masterKeys.Add(ModKey.FromNameAndExtension("NEFARAM_FlawedWardrobe_CatalogueA.esl"));
    masterKeys.Add(ModKey.FromNameAndExtension("NEFARAM_FlawedWardrobe_CatalogueB.esl"));
    masterKeys.Add(ModKey.FromNameAndExtension("NEFARAM_FlawedWardrobe_CatalogueC.esl"));
}
foreach (var key in masterKeys.OrderBy(x => x.FileName.String, StringComparer.OrdinalIgnoreCase))
    mod.ModHeader.MasterReferences.Add(new MasterReference { Master = key });

var effects = normalEffects.Select(x => (x.Label, Key: new FormKey(ModKey.FromNameAndExtension("disenchantments.esl"), x.Id)))
    .Concat(adultEffects.Select(x => (x.Label, Key: new FormKey(ModKey.FromNameAndExtension("SLER.esp"), x.Id))))
    .ToArray();
var localVariants = new Dictionary<string, Armor>(StringComparer.OrdinalIgnoreCase);

VirtualMachineAdapter ScriptAdapter(string scriptName, params (string Name, FormKey Form)[] properties)
{
    var adapter = new VirtualMachineAdapter { Version = 5, ObjectFormat = 2 };
    var script = new ScriptEntry { Name = scriptName };
    foreach (var property in properties)
        script.Properties.Add(new ScriptObjectProperty {
            Name = property.Name,
            Object = new FormLink<ISkyrimMajorRecordGetter>(property.Form)
        });
    adapter.Scripts.Add(script);
    return adapter;
}

void AddItem(ConstructibleObject recipe, FormKey item, int count)
{
    recipe.Items!.Add(new ContainerEntry {
        Item = new ContainerItem { Item = new FormLink<IItemGetter>(item), Count = count }
    });
}

foreach (var target in targets) {
    var results = new FormList(mod.GetNextFormKey(), SkyrimRelease.SkyrimSE) {
        EditorID = $"NFW_Results_{target.Index:D3}"
    };
    mod.FormLists.Add(results);
    for (var effectIndex = 0; effectIndex < effects.Length; effectIndex++) {
        var effect = effects[effectIndex];
        var editorId = $"NFW_Armor_{target.Index:D3}_{effectIndex:D2}_{effect.Label.Replace(" ", "")}";
        var copy = mod.Armors.DuplicateInAsNewRecord(target.Armor, editorId);
        copy.Name = $"Flawed {target.Armor.Name!.String} - {effect.Label}";
        copy.ObjectEffect = new FormLinkNullable<IObjectEffectGetter>(effect.Key);
        results.Items.Add(new FormLink<ISkyrimMajorRecordGetter>(copy.FormKey));
        localVariants[editorId] = copy;
    }

    var workOrder = new MiscItem(mod.GetNextFormKey(), SkyrimRelease.SkyrimSE) {
        EditorID = $"NFW_WorkOrder_{target.Index:D3}",
        Name = $"Flawed Work Order: {target.Armor.Name!.String}",
        Value = 0,
        Weight = 0,
        VirtualMachineAdapter = ScriptAdapter("NFW_CraftResult", ("Results", results.FormKey))
    };
    mod.MiscItems.Add(workOrder);

    var recipe = new ConstructibleObject(mod.GetNextFormKey(), SkyrimRelease.SkyrimSE) {
        EditorID = $"NFW_Recipe_WorkOrder_{target.Index:D3}",
        CreatedObject = new FormLinkNullable<IConstructibleGetter>(workOrder.FormKey),
        CreatedObjectCount = 1,
        Items = new(),
        WorkbenchKeyword = new FormLinkNullable<IKeywordGetter>(forgeKey)
    };
    var sourceRecipe = target.Owner.ConstructibleObjects.FirstOrDefault(x =>
        x.CreatedObject.FormKey == target.Armor.FormKey && x.Items != null && x.Items.Count > 0);
    if (sourceRecipe != null) {
        foreach (var entry in sourceRecipe.Items!)
            AddItem(recipe, entry.Item.Item.FormKey, entry.Item.Count);
    }
    AddItem(recipe, stripsKey, 2);
    AddItem(recipe, charcoalKey, 1);
    mod.ConstructibleObjects.Add(recipe);
}

if (shard == "D") {
    var earlierVariants = new Dictionary<string, IArmorGetter>(StringComparer.OrdinalIgnoreCase);
    foreach (var earlierShard in new[] { "A", "B", "C" }) {
        var earlierPath = Path.Combine(OutputRoot, $"NEFARAM_FlawedWardrobe_Catalogue{earlierShard}.esl");
        if (!File.Exists(earlierPath)) throw new FileNotFoundException("Generate shards A-C before D.", earlierPath);
        var earlier = Import(earlierPath);
        foreach (var armor in earlier.Armors)
            if (!string.IsNullOrWhiteSpace(armor.EditorID)) earlierVariants[armor.EditorID] = armor;
    }

    var flawedLists = new Dictionary<int, FormList>();
    var cleanLists = new Dictionary<int, FormList>();
    foreach (var tier in new[] { 25, 40, 60, 80, 100 }) {
        var flawed = new FormList(mod.GetNextFormKey(), SkyrimRelease.SkyrimSE) { EditorID = $"NFW_RefitFlawed{tier}" };
        var clean = new FormList(mod.GetNextFormKey(), SkyrimRelease.SkyrimSE) { EditorID = $"NFW_RefitClean{tier}" };
        mod.FormLists.Add(flawed);
        mod.FormLists.Add(clean);
        flawedLists[tier] = flawed;
        cleanLists[tier] = clean;
    }
    foreach (var target in allTargets) {
        for (var effectIndex = 0; effectIndex < effects.Length; effectIndex++) {
            var editorId = $"NFW_Armor_{target.Index:D3}_{effectIndex:D2}_{effects[effectIndex].Label.Replace(" ", "")}";
            IArmorGetter variant = localVariants.TryGetValue(editorId, out var local)
                ? local
                : earlierVariants.TryGetValue(editorId, out var prior)
                    ? prior
                    : throw new InvalidOperationException($"Missing generated variant {editorId}.");
            flawedLists[target.Tier].Items.Add(new FormLink<ISkyrimMajorRecordGetter>(variant.FormKey));
            cleanLists[target.Tier].Items.Add(new FormLink<ISkyrimMajorRecordGetter>(target.Armor.FormKey));
        }
    }
    var refitProperties = new List<(string Name, FormKey Form)>();
    foreach (var tier in new[] { 25, 40, 60, 80, 100 }) {
        refitProperties.Add(($"Flawed{tier}", flawedLists[tier].FormKey));
        refitProperties.Add(($"Clean{tier}", cleanLists[tier].FormKey));
    }
    refitProperties.Add(("LeatherStrips", stripsKey));
    refitProperties.Add(("Charcoal", charcoalKey));
    var refitToken = new MiscItem(mod.GetNextFormKey(), SkyrimRelease.SkyrimSE) {
        EditorID = "NFW_RefitToken",
        Name = "Refit One Carried Flawed Item",
        Value = 0,
        Weight = 0,
        VirtualMachineAdapter = ScriptAdapter("NFW_RefitController", refitProperties.ToArray())
    };
    mod.MiscItems.Add(refitToken);
    var refitRecipe = new ConstructibleObject(mod.GetNextFormKey(), SkyrimRelease.SkyrimSE) {
        EditorID = "NFW_Recipe_RefitOne",
        CreatedObject = new FormLinkNullable<IConstructibleGetter>(refitToken.FormKey),
        CreatedObjectCount = 1,
        Items = new(),
        WorkbenchKeyword = new FormLinkNullable<IKeywordGetter>(forgeKey)
    };
    AddItem(refitRecipe, stripsKey, 2);
    AddItem(refitRecipe, charcoalKey, 1);
    mod.ConstructibleObjects.Add(refitRecipe);
}

Directory.CreateDirectory(OutputRoot);
mod.WriteToBinary(outputPath);
Console.WriteLine($"Created {outputPath}: {targets.Length * effects.Length} variants, {targets.Length} work orders, {targets.Length} work-order recipes{(shard == "D" ? ", and one refit recipe" : "")}.");
