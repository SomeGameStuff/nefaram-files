using System.Globalization;
using System.Text;
using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Synthesis;

namespace NefaramArmorEconomyPatcher;

public static class Program
{
    [STAThread]
    public static async Task<int> Main(string[] args)
    {
        if (args.Contains("--self-test", StringComparer.OrdinalIgnoreCase))
        {
            return SelfTests.Run();
        }

        return await SynthesisPipeline.Instance
            .AddPatch<ISkyrimMod, ISkyrimModGetter>(RunPatch)
            .SetTypicalOpen(GameRelease.SkyrimSE, "NEFARAM_ArmorEconomyPatch.esp")
            .Run(args);
    }

    private static void RunPatch(IPatcherState<ISkyrimMod, ISkyrimModGetter> state)
    {
        var settings = Settings.Load(state.ExtraSettingsDataPath ?? Path.Combine(AppContext.BaseDirectory, "Data"));
        var excludedPlugins = settings.ExcludedPlugins.ToHashSet(StringComparer.OrdinalIgnoreCase);
        var excludedForms = settings.ExcludedFormKeys.ToHashSet(StringComparer.OrdinalIgnoreCase);
        var applyOnly = settings.ApplyOnlyFormKeys.ToHashSet(StringComparer.OrdinalIgnoreCase);

        Console.WriteLine($"NEFARAM Armor Economy Patcher: {(settings.AuditOnly ? "AUDIT ONLY" : "APPLY")}");
        Console.WriteLine("Official records are reference-only and will never be overridden.");
        Console.WriteLine($"Active plugin count: {state.LoadOrder.ListedOrder.Count():N0}");

        var armors = state.LoadOrder.PriorityOrder.Armor().WinningOverrides()
            .ToDictionary(x => x.FormKey);
        var allArmorRecipes = state.LoadOrder.PriorityOrder.ConstructibleObject().WinningOverrides()
            .Where(x => !x.CreatedObject.IsNull && x.Items is { Count: > 0 } && armors.ContainsKey(x.CreatedObject.FormKey))
            .Select(x => BuildRecipeData(x, state))
            .Where(x => x is not null)
            .Cast<RecipeData>()
            .ToList();
        var temperingRecipeCount = allArmorRecipes.Count(x => EconomyRules.IsTemperingWorkbench(x.WorkbenchEditorId));
        var recipes = allArmorRecipes
            .Where(x => !EconomyRules.IsTemperingWorkbench(x.WorkbenchEditorId))
            .ToList();

        var recipesByOutput = recipes
            .GroupBy(x => x.Record.CreatedObject.FormKey)
            .ToDictionary(x => x.Key, x => x.ToList());

        var officialReferences = new List<ReferenceData>();
        foreach (var armor in armors.Values.Where(x => EconomyRules.IsOfficial(x.FormKey.ModKey.FileName.String) && x.ObjectEffect.IsNull))
        {
            if (!recipesByOutput.TryGetValue(armor.FormKey, out var armorRecipes)) continue;
            foreach (var recipe in armorRecipes)
            {
                var identified = Identify(armor, recipe, state);
                if (identified.Identity is not null)
                {
                    officialReferences.Add(new ReferenceData(armor, recipe, identified.Identity));
                }
            }
        }

        var referencesByIdentity = officialReferences
            .GroupBy(x => x.Identity)
            .ToDictionary(x => x.Key, x => SelectMedianReference(x.ToList()));
        var referencesByForm = officialReferences
            .GroupBy(x => x.Armor.FormKey)
            .ToDictionary(x => x.Key, x => SelectMedianReference(x.ToList()));

        Console.WriteLine($"Loaded {armors.Count:N0} winning armor records, {recipes.Count:N0} creation recipes, and {officialReferences.Count:N0} official reference recipes.");
        Console.WriteLine($"Excluded {temperingRecipeCount:N0} armor-table/sharpening-wheel recipes from the economy audit.");
        var addedRecipeCount = recipes.Count(x => !EconomyRules.IsOfficial(armors[x.Record.CreatedObject.FormKey].FormKey.ModKey.FileName.String));
        Console.WriteLine($"Found {addedRecipeCount:N0} recipes whose output FormKey belongs to a non-official plugin.");

        var rows = new List<AuditRow>();
        var pending = new List<(AuditRow Row, IArmorGetter Armor, RecipeData Recipe, ReferenceData Reference)>();

        foreach (var recipe in recipes.OrderBy(x => x.Record.CreatedObject.FormKey.ModKey.FileName.String).ThenBy(x => x.Record.FormKey.ID))
        {
            var armor = armors[recipe.Record.CreatedObject.FormKey];
            var plugin = armor.FormKey.ModKey.FileName.String;
            if (EconomyRules.IsOfficial(plugin)) continue;
            if (excludedPlugins.Contains(plugin) || excludedForms.Contains(armor.FormKey.ToString())) continue;

            var identified = Identify(armor, recipe, state);
            var row = NewRow(armor, recipe, identified);
            rows.Add(row);

            if (!armor.ObjectEffect.IsNull)
            {
                row.Status = "ReportOnly";
                row.Reason = "Enchanted output; intentionally excluded from automatic economy changes.";
                continue;
            }

            ReferenceData? reference = null;
            if (settings.ForcedReferenceMappings.TryGetValue(armor.FormKey.ToString(), out var forcedText))
            {
                if (!TryParseFormKey(forcedText, out var forcedKey) || !referencesByForm.TryGetValue(forcedKey, out reference))
                {
                    row.Status = "ConfigurationError";
                    row.Reason = $"Forced reference '{forcedText}' is not an official craftable armor reference.";
                    continue;
                }
                row.ClassificationSource = "ForcedMapping";
            }
            else if (identified.Identity is not null)
            {
                referencesByIdentity.TryGetValue(identified.Identity, out reference);
            }

            if (reference is null)
            {
                row.Status = "Ambiguous";
                row.Reason = identified.Reason ?? "No official reference matched armor type, one primary slot, and material.";
                continue;
            }

            PopulateReference(row, reference);
            var outlier = EconomyRules.IsOutlier(armor.Value, recipe.ValuePerOutput, reference.Armor.Value, reference.Recipe.ValuePerOutput, settings);
            if (!outlier)
            {
                row.Status = "WithinRange";
                row.Reason = "Value, recipe cost, and crafting markup are within configured outlier limits.";
                continue;
            }

            if (!CanCopyMaterials(reference.Recipe))
            {
                row.Status = "ReportOnly";
                row.Reason = "Reference contains unclassified crafting materials; recipe cannot be copied safely.";
                continue;
            }

            row.Status = "AutoFix";
            row.Reason = "Extreme crafted-value markup against both ingredient cost and a high-confidence official material/type/slot reference.";
            row.HighConfidence = true;
            row.ProposedValue = EconomyRules.ProposedValue(armor.Value, reference.Armor.Value, reference.Recipe.ValuePerOutput, settings);
            row.ProposedIngredients = DescribeProposedIngredients(recipe, reference.Recipe);
            pending.Add((row, armor, recipe, reference));
        }

        WriteReports(rows, settings);

        if (settings.AuditOnly)
        {
            Console.WriteLine($"Audit complete: {pending.Count:N0} high-confidence fixes proposed; no plugin records changed.");
            return;
        }

        var selected = pending
            .Where(x => applyOnly.Count == 0 || applyOnly.Contains(x.Armor.FormKey.ToString()))
            .ToList();
        var requiredMasters = selected
            .SelectMany(x => new[] { x.Armor.FormKey.ModKey, x.Recipe.Record.FormKey.ModKey }
                .Concat(x.Reference.Recipe.Ingredients.Select(y => y.FormKey.ModKey)))
            .Distinct()
            .Count();
        if (requiredMasters > settings.MaximumMasters)
        {
            throw new InvalidOperationException($"Refusing to generate patch: at least {requiredMasters} direct masters would be required, above MaximumMasters={settings.MaximumMasters}. The audit reports are still valid.");
        }

        foreach (var item in selected)
        {
            if (item.Row.ProposedValue is uint proposedValue && proposedValue != item.Armor.Value)
            {
                var armorOverride = state.PatchMod.Armors.GetOrAddAsOverride(item.Armor);
                armorOverride.Value = proposedValue;
            }

            var recipeOverride = state.PatchMod.ConstructibleObjects.GetOrAddAsOverride(item.Recipe.Record);
            ReplaceRecognizedMaterials(recipeOverride, item.Recipe, item.Reference.Recipe);
            item.Row.Patched = true;
        }

        WriteReports(rows, settings);
        Console.WriteLine($"Apply complete: patched {selected.Count:N0} armor value/recipe pairs. Review {state.PatchMod.ModKey.FileName} in xEdit before play.");
    }

    private static RecipeData? BuildRecipeData(IConstructibleObjectGetter recipe, IPatcherState<ISkyrimMod, ISkyrimModGetter> state)
    {
        var ingredients = new List<RecipeIngredient>();
        foreach (var entry in recipe.Items ?? [])
        {
            if (!entry.Item.Item.TryResolve(state.LinkCache, out var item)) return null;
            var editorId = item.EditorID ?? "";
            var name = ItemName(item);
            var value = ItemValue(item);
            ingredients.Add(new RecipeIngredient(item.FormKey, editorId, name, entry.Item.Count, value, EconomyRules.IngredientCategory(editorId, name)));
        }
        var workbenchEditorId = "";
        if (!recipe.WorkbenchKeyword.IsNull && recipe.WorkbenchKeyword.TryResolve(state.LinkCache, out var workbench))
        {
            workbenchEditorId = workbench.EditorID ?? "";
        }
        return new RecipeData(recipe, workbenchEditorId, ingredients);
    }

    private static (ArmorIdentity? Identity, string Source, string? Reason) Identify(
        IArmorGetter armor,
        RecipeData recipe,
        IPatcherState<ISkyrimMod, ISkyrimModGetter> state)
    {
        var armorType = EconomyRules.ArmorType(armor);
        if (armorType == "Unknown") return (null, "", "Unsupported armor type.");
        var slot = EconomyRules.PrimarySlot(armor);
        if (slot is null) return (null, "", "No single supported primary slot (30, 32, 33, 35, 36, 37, or 39). Modular/accessory pieces remain report-only.");

        var keywordIds = new List<string>();
        foreach (var link in armor.Keywords ?? [])
        {
            if (link.TryResolve(state.LinkCache, out var keyword)) keywordIds.Add(keyword.EditorID ?? "");
        }

        var material = EconomyRules.MaterialFromKeywordIds(keywordIds);
        var source = "Keyword";
        if (material is null)
        {
            material = EconomyRules.InferMaterialFromIngredients(recipe.Ingredients);
            source = "RecipeIngredients";
        }
        if (material is null) return (null, source, "Material could not be inferred unambiguously from keywords or recipe ingredients.");
        return (new ArmorIdentity(armorType, slot, material), source, null);
    }

    private static ReferenceData SelectMedianReference(List<ReferenceData> references)
    {
        var ordered = references.OrderBy(x => x.Armor.Value).ThenBy(x => x.Recipe.ValuePerOutput).ToList();
        return ordered[(ordered.Count - 1) / 2];
    }

    private static AuditRow NewRow(IArmorGetter armor, RecipeData recipe, (ArmorIdentity? Identity, string Source, string? Reason) identified) => new()
    {
        FormKey = armor.FormKey.ToString(),
        Plugin = armor.FormKey.ModKey.FileName.String,
        EditorId = armor.EditorID ?? "",
        Name = armor.Name?.String ?? "",
        ArmorType = identified.Identity?.ArmorType ?? EconomyRules.ArmorType(armor),
        Slot = identified.Identity?.Slot ?? EconomyRules.PrimarySlot(armor) ?? "Ambiguous",
        Material = identified.Identity?.Material ?? "Ambiguous",
        ClassificationSource = identified.Source,
        RecipeFormKey = recipe.Record.FormKey.ToString(),
        RecipeEditorId = recipe.Record.EditorID ?? "",
        WorkbenchEditorId = recipe.WorkbenchEditorId,
        RecipeOutputCount = recipe.OutputCount,
        Ingredients = DescribeIngredients(recipe.Ingredients),
        OriginalValue = armor.Value,
        OriginalIngredientValue = recipe.ValuePerOutput
    };

    private static void PopulateReference(AuditRow row, ReferenceData reference)
    {
        row.ReferenceValue = reference.Armor.Value;
        row.ReferenceIngredientValue = reference.Recipe.ValuePerOutput;
        row.ReferenceFormKey = reference.Armor.FormKey.ToString();
    }

    private static bool CanCopyMaterials(RecipeData reference) =>
        reference.Ingredients.Any(x => x.Category is not null) &&
        reference.Ingredients.Where(x => x.Category is not null).All(x => EconomyRules.IsOfficial(x.FormKey.ModKey.FileName.String));

    private static void ReplaceRecognizedMaterials(ConstructibleObject recipe, RecipeData target, RecipeData reference)
    {
        recipe.Items ??= [];
        for (var index = recipe.Items.Count - 1; index >= 0; index--)
        {
            var existing = recipe.Items[index];
            if (target.Ingredients.Any(x => x.FormKey == existing.Item.Item.FormKey && x.Category is not null))
            {
                recipe.Items.RemoveAt(index);
            }
        }

        foreach (var ingredient in reference.Ingredients.Where(x => x.Category is not null))
        {
            var scaledCount = Math.Max(1, (int)Math.Ceiling((double)ingredient.Count * target.OutputCount / reference.OutputCount));
            recipe.Items.Add(new ContainerEntry
            {
                Item = new ContainerItem
                {
                    Item = new FormLink<IItemGetter>(ingredient.FormKey),
                    Count = scaledCount
                }
            });
        }
    }

    private static string DescribeProposedIngredients(RecipeData target, RecipeData reference)
    {
        var preserved = target.Ingredients.Where(x => x.Category is null);
        var replacements = reference.Ingredients
            .Where(x => x.Category is not null)
            .Select(x => x with { Count = Math.Max(1, (int)Math.Ceiling((double)x.Count * target.OutputCount / reference.OutputCount)) });
        return DescribeIngredients(preserved.Concat(replacements));
    }

    private static string DescribeIngredients(IEnumerable<RecipeIngredient> ingredients) => string.Join("; ", ingredients.Select(x => $"{x.Count}x {(string.IsNullOrWhiteSpace(x.Name) ? x.EditorId : x.Name)} [{x.FormKey}]"));

    private static int ItemValue(IItemGetter item) => item switch
    {
        IArmorGetter x => checked((int)x.Value),
        IWeaponGetter x => checked((int)(x.BasicStats?.Value ?? 0)),
        IMiscItemGetter x => checked((int)x.Value),
        IIngredientGetter x => checked((int)x.Value),
        IIngestibleGetter x => checked((int)x.Value),
        IBookGetter x => checked((int)x.Value),
        ISoulGemGetter x => checked((int)x.Value),
        _ => 0
    };

    private static string ItemName(IItemGetter item) => item switch
    {
        IArmorGetter x => x.Name?.String ?? "",
        IWeaponGetter x => x.Name?.String ?? "",
        IMiscItemGetter x => x.Name?.String ?? "",
        IIngredientGetter x => x.Name?.String ?? "",
        IIngestibleGetter x => x.Name?.String ?? "",
        IBookGetter x => x.Name?.String ?? "",
        ISoulGemGetter x => x.Name?.String ?? "",
        _ => ""
    };

    private static bool TryParseFormKey(string text, out FormKey key)
    {
        try { key = FormKey.Factory(text); return true; }
        catch { key = default; return false; }
    }

    private static void WriteReports(IReadOnlyList<AuditRow> rows, Settings settings)
    {
        var directory = settings.ReportDirectory;
        Directory.CreateDirectory(directory);
        var jsonPath = Path.Combine(directory, "armor-economy-audit.json");
        var csvPath = Path.Combine(directory, "armor-economy-audit.csv");
        var report = AuditReport.Create(rows, settings.AuditOnly);
        File.WriteAllText(jsonPath, JsonSerializer.Serialize(report, Settings.JsonOptions()), new UTF8Encoding(false));

        var properties = typeof(AuditRow).GetProperties();
        using var writer = new StreamWriter(csvPath, false, new UTF8Encoding(false));
        writer.WriteLine(string.Join(',', properties.Select(x => EconomyRules.Csv(x.Name))));
        foreach (var row in rows)
        {
            writer.WriteLine(string.Join(',', properties.Select(x => EconomyRules.Csv(Convert.ToString(x.GetValue(row), CultureInfo.InvariantCulture)))));
        }
        Console.WriteLine($"Wrote {rows.Count:N0} audit rows to {csvPath} and {jsonPath}.");
    }
}
