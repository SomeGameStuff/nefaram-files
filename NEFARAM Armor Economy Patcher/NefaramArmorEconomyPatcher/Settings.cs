using System.Text.Json;

namespace NefaramArmorEconomyPatcher;

public sealed class Settings
{
    public bool AuditOnly { get; set; } = true;
    public double ValueOutlierFactor { get; set; } = 3.0;
    public double MinimumExploitMarkupRatio { get; set; } = 4.0;
    public double TargetCraftingMarkupRatio { get; set; } = 2.0;
    public int MinimumGoldDifference { get; set; } = 100;
    public int MaximumMasters { get; set; } = 240;
    public string ReportDirectory { get; set; } = @"C:\Users\antho\nefaram-files\artifacts";
    public List<string> ExcludedPlugins { get; set; } = [];
    public List<string> ExcludedFormKeys { get; set; } = [];
    public List<string> ApplyOnlyFormKeys { get; set; } = [];
    public Dictionary<string, string> ForcedReferenceMappings { get; set; } = new(StringComparer.OrdinalIgnoreCase);

    public static Settings Load(string extraSettingsPath)
    {
        var path = Path.Combine(extraSettingsPath, "settings.json");
        if (!File.Exists(path))
        {
            Directory.CreateDirectory(extraSettingsPath);
            var bundled = Path.Combine(AppContext.BaseDirectory, "Data", "settings.json");
            File.Copy(bundled, path);
        }

        var settings = JsonSerializer.Deserialize<Settings>(File.ReadAllText(path), JsonOptions())
            ?? throw new InvalidDataException($"Could not deserialize {path}.");
        settings.ForcedReferenceMappings = new Dictionary<string, string>(settings.ForcedReferenceMappings, StringComparer.OrdinalIgnoreCase);
        settings.Validate(path);
        return settings;
    }

    public static JsonSerializerOptions JsonOptions() => new()
    {
        WriteIndented = true,
        PropertyNameCaseInsensitive = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };

    private void Validate(string path)
    {
        if (ValueOutlierFactor <= 1) throw new InvalidDataException($"ValueOutlierFactor in {path} must be greater than 1.");
        if (MinimumExploitMarkupRatio <= 1) throw new InvalidDataException($"MinimumExploitMarkupRatio in {path} must be greater than 1.");
        if (TargetCraftingMarkupRatio <= 0 || TargetCraftingMarkupRatio >= MinimumExploitMarkupRatio) throw new InvalidDataException($"TargetCraftingMarkupRatio in {path} must be positive and lower than MinimumExploitMarkupRatio.");
        if (MinimumGoldDifference < 0) throw new InvalidDataException($"MinimumGoldDifference in {path} cannot be negative.");
        if (MaximumMasters is < 1 or > 253) throw new InvalidDataException($"MaximumMasters in {path} must be between 1 and 253.");
        if (string.IsNullOrWhiteSpace(ReportDirectory)) throw new InvalidDataException($"ReportDirectory in {path} is required.");
    }
}
