using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Skyrim;

namespace WorldWardrobeGenerator;

internal sealed class GeneratorRules
{
    public string ProfilePath { get; set; } = @"<mo2-root>\profiles\NEFARAM";
    public string ModsRoot { get; set; } = @"<mo2-root>\mods";
    public string GameDataPath { get; set; } = @"<game-install>\Data";
    public string OutputPath { get; set; } = "build-output";
    public int LeafSize { get; set; } = 80;
    public int MaximumSourceMastersPerShard { get; set; } = 120;
    public int MaximumNewRecordsPerShard { get; set; } = 1900;
    public bool AllowPluginParseFailures { get; set; } = true;
    public List<string> ExcludedPlugins { get; set; } = [];
    public List<string> ExcludedPluginPatterns { get; set; } = [];
    public Dictionary<string, string> ForcedCategories { get; set; } = new(StringComparer.OrdinalIgnoreCase);
    public List<string> ExcludedForms { get; set; } = [];
    public List<string> IncludedSuspiciousForms { get; set; } = [];
    public List<string> NpcApprovedOutfits { get; set; } = [];
    public List<string> NpcDeniedOutfits { get; set; } = [];
    public Dictionary<string, string> NpcOutfitFactions { get; set; } = new(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, List<string>> LeveledListTargets { get; set; } = new(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, List<string>> MerchantContainerTargets { get; set; } = new(StringComparer.OrdinalIgnoreCase);
}

internal sealed record PluginSource(string Name, string Path, string ModName, int LoadIndex);

internal sealed class ArmorCandidate
{
    public required IArmorGetter Armor { get; init; }
    public required ISkyrimModGetter Owner { get; init; }
    public required PluginSource Source { get; init; }
    public required string Category { get; set; }
    public required string ClassificationReason { get; set; }
    public required string Slots { get; init; }
    public required string ArmorType { get; init; }
    public int Tier { get; set; }
    public List<string> Routes { get; } = [];
}

internal sealed record ExcludedArmor(
    string FormKey,
    string Plugin,
    string EditorId,
    string Name,
    string Reason);

internal sealed record OutfitCandidate(
    IOutfitGetter Outfit,
    string Category,
    string TargetFaction,
    string SourcePlugin,
    string Reason);

internal sealed record GeneratedPool(
    string Plugin,
    FormKey FormKey,
    string EditorId,
    string Category,
    int Tier,
    int ItemCount,
    int ChanceNone);

internal sealed record GeneratedRoute(
    string Plugin,
    FormKey FormKey,
    string EditorId,
    string RouteType,
    string RouteKey,
    int SourcePoolCount,
    int ChanceNone);
