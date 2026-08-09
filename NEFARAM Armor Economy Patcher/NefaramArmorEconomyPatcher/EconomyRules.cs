using Mutagen.Bethesda.Skyrim;

namespace NefaramArmorEconomyPatcher;

internal static class EconomyRules
{
    private static readonly string[] OfficialExact =
    [
        "Skyrim.esm", "Update.esm", "Dawnguard.esm", "HearthFires.esm", "Dragonborn.esm", "_ResourcePack.esl"
    ];

    public static bool IsOfficial(string plugin) =>
        OfficialExact.Contains(plugin, StringComparer.OrdinalIgnoreCase) ||
        plugin.StartsWith("cc", StringComparison.OrdinalIgnoreCase);

    public static bool IsTemperingWorkbench(string editorId) =>
        editorId.Contains("ArmorTable", StringComparison.OrdinalIgnoreCase) ||
        editorId.Contains("SharpeningWheel", StringComparison.OrdinalIgnoreCase);

    public static string? PrimarySlot(IArmorGetter armor)
    {
        if (armor.BodyTemplate is null) return null;
        var raw = (uint)armor.BodyTemplate.FirstPersonFlags;
        var slots = new List<string>();
        Add(30, "Head"); Add(32, "Body"); Add(33, "Hands"); Add(37, "Feet"); Add(39, "Shield"); Add(35, "Amulet"); Add(36, "Ring");
        return slots.Count == 1 ? slots[0] : null;

        void Add(int slot, string name)
        {
            var bit = 1u << (slot - 30);
            if ((raw & bit) != 0) slots.Add(name);
        }
    }

    public static string ArmorType(IArmorGetter armor) => armor.BodyTemplate?.ArmorType switch
    {
        Mutagen.Bethesda.Skyrim.ArmorType.LightArmor => "Light",
        Mutagen.Bethesda.Skyrim.ArmorType.HeavyArmor => "Heavy",
        Mutagen.Bethesda.Skyrim.ArmorType.Clothing => "Clothing",
        _ => "Unknown"
    };

    public static string? MaterialFromKeywordIds(IEnumerable<string> keywordIds)
    {
        var candidates = keywordIds
            .Select(NormalizeMaterialKeyword)
            .Where(x => x is not null)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();
        return candidates.Count == 1 ? candidates[0] : null;
    }

    public static string? NormalizeMaterialKeyword(string editorId)
    {
        const string prefix = "ArmorMaterial";
        if (!editorId.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) return null;
        var value = editorId[prefix.Length..].Trim('_');
        return string.IsNullOrWhiteSpace(value) ? null : NormalizeMaterial(value);
    }

    public static string? IngredientCategory(string editorId, string name)
    {
        var text = (editorId + " " + name).Replace(" ", "", StringComparison.Ordinal).Replace("_", "", StringComparison.Ordinal);
        if (Contains(text, "LeatherStrips", "LeatherStrip")) return "LeatherStrips";
        if (Contains(text, "Leather", "Hide")) return "Leather";
        if (Contains(text, "IngotIron", "IronIngot")) return "Iron";
        if (Contains(text, "IngotSteel", "SteelIngot")) return "Steel";
        if (Contains(text, "Corundum")) return "Steel";
        if (Contains(text, "IngotDwarven", "DwarvenMetalIngot")) return "Dwarven";
        if (Contains(text, "IngotOrichalcum", "OrichalcumIngot")) return "Orcish";
        if (Contains(text, "IngotMoonstone", "MoonstoneIngot")) return "Elven";
        if (Contains(text, "IngotQuicksilver", "QuicksilverIngot")) return "Elven";
        if (Contains(text, "IngotMalachite", "MalachiteIngot")) return "Glass";
        if (Contains(text, "IngotEbony", "EbonyIngot")) return "Ebony";
        if (Contains(text, "DaedraHeart")) return "Daedric";
        if (Contains(text, "DragonBone")) return "Dragonplate";
        if (Contains(text, "DragonScale")) return "Dragonscale";
        if (Contains(text, "ChitinPlate", "Chitin")) return "Chitin";
        if (Contains(text, "NetchLeather")) return "NetchLeather";
        if (Contains(text, "Stalhrim")) return "Stalhrim";
        if (Contains(text, "IngotGold", "GoldIngot")) return "Gold";
        if (Contains(text, "IngotSilver", "SilverIngot")) return "Silver";
        if (Contains(text, "LinenWrap", "Cloth", "Cotton", "Silk")) return "Cloth";
        return null;
    }

    public static string? InferMaterialFromIngredients(IEnumerable<RecipeIngredient> ingredients)
    {
        var categories = ingredients
            .Where(x => x.Category is not null && !x.Category.Equals("LeatherStrips", StringComparison.OrdinalIgnoreCase))
            .GroupBy(x => NormalizeMaterial(x.Category!), StringComparer.OrdinalIgnoreCase)
            .Select(x => new { Material = x.Key, Score = x.Sum(y => Math.Max(1, y.Count) * Math.Max(1, y.UnitValue)) })
            .OrderByDescending(x => x.Score)
            .ToList();
        if (categories.Count == 0) return null;
        if (categories.Count > 1 && categories[0].Score < categories.Sum(x => x.Score) * 0.70) return null;
        return categories[0].Material;
    }

    public static string NormalizeMaterial(string value)
    {
        if (value.Equals("Hide", StringComparison.OrdinalIgnoreCase)) return "Leather";
        if (value.Equals("Scaled", StringComparison.OrdinalIgnoreCase)) return "Scale";
        if (value.Equals("Daedric", StringComparison.OrdinalIgnoreCase)) return "Daedric";
        return value;
    }

    public static bool IsOutlier(long value, long ingredientValue, long referenceValue, long referenceIngredientValue, Settings settings)
    {
        var ratio = SafeRatio(value, ingredientValue);
        var referenceRatio = SafeRatio(referenceValue, referenceIngredientValue);
        var requiredRatio = Math.Max(settings.MinimumExploitMarkupRatio, referenceRatio * settings.ValueOutlierFactor);
        return ratio >= requiredRatio && value - ingredientValue >= settings.MinimumGoldDifference;
    }

    public static uint ProposedValue(uint currentValue, uint referenceValue, long referenceIngredientValue, Settings settings)
    {
        var costBasedCap = (long)Math.Ceiling(referenceIngredientValue * settings.TargetCraftingMarkupRatio);
        var balancedCap = Math.Max((long)referenceValue, costBasedCap);
        return (uint)Math.Min(currentValue, Math.Clamp(balancedCap, 0, uint.MaxValue));
    }

    public static string Csv(string? value)
    {
        value ??= "";
        return value.Contains(',') || value.Contains('"') || value.Contains('\n') || value.Contains('\r')
            ? $"\"{value.Replace("\"", "\"\"")}\""
            : value;
    }

    private static bool Contains(string value, params string[] pieces) => pieces.Any(x => value.Contains(x, StringComparison.OrdinalIgnoreCase));
    private static double SafeRatio(double a, double b) => b <= 0 ? (a <= 0 ? 1 : double.PositiveInfinity) : a / b;
}
