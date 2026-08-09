using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Skyrim;

namespace NefaramArmorEconomyPatcher;

internal sealed record RecipeIngredient(FormKey FormKey, string EditorId, string Name, int Count, int UnitValue, string? Category)
{
    public long TotalValue => (long)Count * UnitValue;
}

internal sealed record RecipeData(IConstructibleObjectGetter Record, string WorkbenchEditorId, IReadOnlyList<RecipeIngredient> Ingredients)
{
    public long TotalValue => Ingredients.Sum(x => x.TotalValue);
    public int OutputCount => Math.Max(1, (int)(Record.CreatedObjectCount ?? 1));
    public long ValuePerOutput => (long)Math.Ceiling((double)TotalValue / OutputCount);
}

internal sealed record ArmorIdentity(string ArmorType, string Slot, string Material)
{
    public override string ToString() => $"{ArmorType}|{Slot}|{Material}";
}

internal sealed record ReferenceData(IArmorGetter Armor, RecipeData Recipe, ArmorIdentity Identity);

internal sealed class AuditRow
{
    public string Status { get; set; } = "";
    public string Reason { get; set; } = "";
    public string FormKey { get; set; } = "";
    public string Plugin { get; set; } = "";
    public string EditorId { get; set; } = "";
    public string Name { get; set; } = "";
    public string ArmorType { get; set; } = "";
    public string Slot { get; set; } = "";
    public string Material { get; set; } = "";
    public string ClassificationSource { get; set; } = "";
    public string RecipeFormKey { get; set; } = "";
    public string RecipeEditorId { get; set; } = "";
    public string WorkbenchEditorId { get; set; } = "";
    public int RecipeOutputCount { get; set; }
    public string Ingredients { get; set; } = "";
    public uint OriginalValue { get; set; }
    public long OriginalIngredientValue { get; set; }
    public uint? ReferenceValue { get; set; }
    public long? ReferenceIngredientValue { get; set; }
    public string ReferenceFormKey { get; set; } = "";
    public uint? ProposedValue { get; set; }
    public string ProposedIngredients { get; set; } = "";
    public bool HighConfidence { get; set; }
    public bool Patched { get; set; }
}

internal sealed class AuditReport
{
    public int SchemaVersion { get; init; } = 1;
    public string GeneratedUtc { get; init; } = DateTime.UtcNow.ToString("O");
    public string Mode { get; init; } = "";
    public AuditSummary Summary { get; init; } = new();
    public IReadOnlyList<PluginChangeCount> ChangesByPlugin { get; init; } = [];
    public IReadOnlyDictionary<string, string> StatusGuide { get; init; } = new Dictionary<string, string>();
    public IReadOnlyList<AuditRow> Changes { get; init; } = [];
    public IReadOnlyList<AuditRow> NeedsReview { get; init; } = [];
    public IReadOnlyList<AuditRow> OtherRecords { get; init; } = [];

    public static AuditReport Create(IReadOnlyList<AuditRow> rows, bool auditOnly)
    {
        static IOrderedEnumerable<AuditRow> Sort(IEnumerable<AuditRow> source) => source
            .OrderBy(x => x.Plugin, StringComparer.OrdinalIgnoreCase)
            .ThenBy(x => x.Name, StringComparer.OrdinalIgnoreCase)
            .ThenBy(x => x.FormKey, StringComparer.OrdinalIgnoreCase);

        var changes = Sort(rows.Where(x => x.Status == "AutoFix")).ToList();
        var needsReview = Sort(rows.Where(x => x.Status is "ReportOnly" or "ConfigurationError")).ToList();
        var otherRecords = rows.Except(changes).Except(needsReview)
            .OrderBy(x => x.Status, StringComparer.OrdinalIgnoreCase)
            .ThenBy(x => x.Plugin, StringComparer.OrdinalIgnoreCase)
            .ThenBy(x => x.Name, StringComparer.OrdinalIgnoreCase)
            .ThenBy(x => x.FormKey, StringComparer.OrdinalIgnoreCase)
            .ToList();

        return new AuditReport
        {
            Mode = auditOnly ? "audit-only" : "apply",
            Summary = new AuditSummary
            {
                TotalRecords = rows.Count,
                ProposedChanges = changes.Count,
                AppliedChanges = changes.Count(x => x.Patched),
                NeedsReview = needsReview.Count,
                OtherRecords = otherRecords.Count,
                StatusCounts = new SortedDictionary<string, int>(
                    rows.GroupBy(x => x.Status).ToDictionary(x => x.Key, x => x.Count()),
                    StringComparer.OrdinalIgnoreCase)
            },
            ChangesByPlugin = changes
                .GroupBy(x => x.Plugin, StringComparer.OrdinalIgnoreCase)
                .Select(x => new PluginChangeCount(x.Key, x.Count()))
                .OrderByDescending(x => x.Count)
                .ThenBy(x => x.Plugin, StringComparer.OrdinalIgnoreCase)
                .ToList(),
            StatusGuide = new Dictionary<string, string>
            {
                ["AutoFix"] = "High-confidence outlier. See changes for the before/after values and recipes.",
                ["ReportOnly"] = "Potential issue intentionally left unchanged; inspect needsReview if desired.",
                ["ConfigurationError"] = "A configured reference could not be used; correct settings before applying.",
                ["WithinRange"] = "Comparable to the official reference and left unchanged.",
                ["Ambiguous"] = "Could not be classified safely and left unchanged."
            },
            Changes = changes,
            NeedsReview = needsReview,
            OtherRecords = otherRecords
        };
    }
}

internal sealed class AuditSummary
{
    public int TotalRecords { get; init; }
    public int ProposedChanges { get; init; }
    public int AppliedChanges { get; init; }
    public int NeedsReview { get; init; }
    public int OtherRecords { get; init; }
    public IReadOnlyDictionary<string, int> StatusCounts { get; init; } = new Dictionary<string, int>();
}

internal sealed record PluginChangeCount(string Plugin, int Count);
