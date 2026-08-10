using System.Collections;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Text;
using System.Text.Json;
using Mutagen.Bethesda.Plugins.Binary.Parameters;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

if (args.Length < 2)
    throw new ArgumentException("Usage: Generator --inventory <plugin> | --export <plugin> <catalog> | --apply <input> <output> <catalog> | --apply-map <input> <output> <map> | --validate <original> <translated> | --validate-map <original> <translated> <map>");

switch (args[0])
{
    case "--inventory" when args.Length == 2:
        Inventory(args[1]);
        break;
    case "--export" when args.Length == 3:
        ExportCatalog(args[1], args[2]);
        break;
    case "--apply" when args.Length == 4:
        ApplyCatalog(args[1], args[2], args[3]);
        break;
    case "--apply-map" when args.Length == 4:
        ApplyMap(args[1], args[2], args[3]);
        break;
    case "--validate" when args.Length == 3:
        Validate(args[1], args[2]);
        break;
    case "--validate-map" when args.Length == 4:
        ValidateMap(args[1], args[2], args[3]);
        break;
    default:
        throw new ArgumentException("Invalid arguments.");
}

static void Inventory(string pluginPath)
{
    var mod = SkyrimMod.CreateFromBinary(pluginPath, SkyrimRelease.SkyrimSE);
    var targets = CollectTargets(mod);
    foreach (var row in targets.Select(x => $"{x.Path}\t{x.Source}").Distinct().OrderBy(x => x, StringComparer.Ordinal))
        Console.WriteLine(row);
    Console.Error.WriteLine($"Translated string fields: {targets.Count}; unique strings: {targets.Select(x => x.Source).Distinct().Count()}");
}

static void ExportCatalog(string inputPath, string catalogPath)
{
    inputPath = Path.GetFullPath(inputPath);
    catalogPath = Path.GetFullPath(catalogPath);
    var mod = SkyrimMod.CreateFromBinary(inputPath, SkyrimRelease.SkyrimSE);
    var targets = CollectTargets(mod);
    var entries = targets
        .GroupBy(x => x.Source, StringComparer.Ordinal)
        .Select(group => new CatalogEntry(
            group.Key,
            "",
            group.Select(x => x.Path).Distinct(StringComparer.Ordinal).OrderBy(x => x, StringComparer.Ordinal).ToArray()))
        .OrderBy(x => x.Source, StringComparer.Ordinal)
        .ToArray();
    Directory.CreateDirectory(Path.GetDirectoryName(catalogPath)!);
    File.WriteAllText(catalogPath, JsonSerializer.Serialize(entries, new JsonSerializerOptions { WriteIndented = true }), new UTF8Encoding(false));
    Console.WriteLine($"Exported {entries.Length} unique strings ({targets.Count} fields) to {catalogPath}");
}

static void ApplyCatalog(string inputPath, string outputPath, string catalogPath)
{
    inputPath = Path.GetFullPath(inputPath);
    outputPath = Path.GetFullPath(outputPath);
    catalogPath = Path.GetFullPath(catalogPath);
    var mod = SkyrimMod.CreateFromBinary(inputPath, SkyrimRelease.SkyrimSE);
    var targets = CollectTargets(mod);
    var entries = JsonSerializer.Deserialize<CatalogEntry[]>(File.ReadAllText(catalogPath)) ?? [];
    var translations = entries
        .Where(x => !string.IsNullOrWhiteSpace(x.English))
        .ToDictionary(x => x.Source, x => x.English, StringComparer.Ordinal);

    var changed = 0;
    foreach (var target in targets)
    {
        if (!translations.TryGetValue(target.Source, out var translated) || string.Equals(target.Source, translated, StringComparison.Ordinal))
            continue;
        target.StringProperty.SetValue(target.Container, translated);
        changed++;
    }
    Directory.CreateDirectory(Path.GetDirectoryName(outputPath)!);
    WritePreservingMasters(mod, outputPath);
    Console.WriteLine($"Wrote {outputPath}; catalog translations={translations.Count}; changed fields={changed}");
}

static void ApplyMap(string inputPath, string outputPath, string mapPath)
{
    inputPath = Path.GetFullPath(inputPath);
    outputPath = Path.GetFullPath(outputPath);
    mapPath = Path.GetFullPath(mapPath);
    var translations = JsonSerializer.Deserialize<Dictionary<string, string>>(File.ReadAllText(mapPath))
        ?? new Dictionary<string, string>(StringComparer.Ordinal);
    var mod = SkyrimMod.CreateFromBinary(inputPath, SkyrimRelease.SkyrimSE);
    var targets = CollectTargets(mod);
    var changed = 0;
    foreach (var target in targets)
    {
        if (!translations.TryGetValue(target.Source, out var translated)
            || string.IsNullOrWhiteSpace(translated)
            || string.Equals(target.Source, translated, StringComparison.Ordinal))
            continue;
        target.StringProperty.SetValue(target.Container, translated);
        changed++;
    }
    Directory.CreateDirectory(Path.GetDirectoryName(outputPath)!);
    WritePreservingMasters(mod, outputPath);
    Console.WriteLine($"Wrote {outputPath}; map translations={translations.Count}; changed fields={changed}");
}

static void WritePreservingMasters(SkyrimMod mod, string outputPath)
{
    mod.WriteToBinary(outputPath, new BinaryWriteParameters
    {
        MastersListContent = MastersListContentOption.NoCheck,
        MastersListOrdering = MastersListOrderingOption.NoCheck,
    });
}

static void Validate(string originalPath, string translatedPath)
{
    var original = SkyrimMod.CreateFromBinary(originalPath, SkyrimRelease.SkyrimSE);
    var translated = SkyrimMod.CreateFromBinary(translatedPath, SkyrimRelease.SkyrimSE);
    var originalKeys = original.EnumerateMajorRecords().Select(x => x.FormKey).OrderBy(x => x).ToArray();
    var translatedKeys = translated.EnumerateMajorRecords().Select(x => x.FormKey).OrderBy(x => x).ToArray();
    if (!originalKeys.SequenceEqual(translatedKeys))
        throw new InvalidDataException("Record FormKey set changed during translation.");
    var originalMasters = original.ModHeader.MasterReferences.Select(x => x.Master.FileName.String).ToArray();
    var translatedMasters = translated.ModHeader.MasterReferences.Select(x => x.Master.FileName.String).ToArray();
    if (!originalMasters.SequenceEqual(translatedMasters, StringComparer.OrdinalIgnoreCase))
        throw new InvalidDataException($"Master list changed during translation. Original=[{string.Join(", ", originalMasters)}] Output=[{string.Join(", ", translatedMasters)}]");
    var sourceTargets = CollectTargets(original);
    var outputTargets = CollectTargets(translated);
    if (sourceTargets.Count != outputTargets.Count)
        throw new InvalidDataException("Translated-string field count changed.");
    Console.WriteLine($"Validated {Path.GetFileName(translatedPath)}: records={translatedKeys.Length}, textFields={outputTargets.Count}, masters={translatedMasters.Length}");
}

static void ValidateMap(string originalPath, string translatedPath, string mapPath)
{
    Validate(originalPath, translatedPath);
    var original = SkyrimMod.CreateFromBinary(originalPath, SkyrimRelease.SkyrimSE);
    var translated = SkyrimMod.CreateFromBinary(translatedPath, SkyrimRelease.SkyrimSE);
    var map = JsonSerializer.Deserialize<Dictionary<string, string>>(File.ReadAllText(mapPath))
        ?? new Dictionary<string, string>(StringComparer.Ordinal);
    var originalTargets = CollectTargets(original).ToDictionary(target => target.Path, StringComparer.Ordinal);
    var translatedTargets = CollectTargets(translated).ToDictionary(target => target.Path, StringComparer.Ordinal);
    var mismatches = new List<string>();
    foreach (var (path, sourceTarget) in originalTargets)
    {
        var expected = map.TryGetValue(sourceTarget.Source, out var english) ? english : sourceTarget.Source;
        if (!translatedTargets.TryGetValue(path, out var outputTarget))
            mismatches.Add($"Missing path: {path}");
        else if (!string.Equals(expected, outputTarget.Source, StringComparison.Ordinal))
            mismatches.Add($"{path}: expected {JsonSerializer.Serialize(expected)}, got {JsonSerializer.Serialize(outputTarget.Source)}");
        if (mismatches.Count >= 20) break;
    }
    if (mismatches.Count > 0)
        throw new InvalidDataException("Translation map validation failed:\n" + string.Join("\n", mismatches));
    Console.WriteLine($"Validated translation map for {Path.GetFileName(translatedPath)}: paths={originalTargets.Count}");
}

static List<TextTarget> CollectTargets(ISkyrimModGetter mod)
{
    var rows = new List<TextTarget>();
    foreach (var record in mod.EnumerateMajorRecords())
    {
        var visited = new HashSet<object>(ReferenceEqualityComparer.Instance);
        var identity = $"{record.GetType().Name}|{record.FormKey}|{record.EditorID ?? "(no EDID)"}";
        Walk(record, identity, 0, visited, rows);
    }
    return rows;
}

static void Walk(object? value, string path, int depth, HashSet<object> visited, List<TextTarget> rows)
{
    if (value is null || depth > 10)
        return;
    var type = value.GetType();
    if (type == typeof(string) || type.IsPrimitive || type.IsEnum || type.IsValueType || !visited.Add(value))
        return;

    if (type.Name.Contains("TranslatedString", StringComparison.OrdinalIgnoreCase))
    {
        var stringProperty = type.GetProperty("String", BindingFlags.Public | BindingFlags.Instance);
        var text = stringProperty?.GetValue(value)?.ToString() ?? "";
        if (!string.IsNullOrWhiteSpace(text) && stringProperty?.CanWrite == true)
            rows.Add(new TextTarget(value, stringProperty, path, text));
        return;
    }

    if (value is IEnumerable enumerable)
    {
        var index = 0;
        foreach (var item in enumerable)
            Walk(item, $"{path}[{index++}]", depth + 1, visited, rows);
        return;
    }

    if (!(type.Namespace ?? "").StartsWith("Mutagen.Bethesda", StringComparison.Ordinal))
        return;
    foreach (var property in type.GetProperties(BindingFlags.Public | BindingFlags.Instance))
    {
        if (!property.CanRead || property.GetIndexParameters().Length != 0 || property.Name is "FormKey" or "EditorID" or "Registration")
            continue;
        object? child;
        try { child = property.GetValue(value); }
        catch { continue; }
        Walk(child, path + "/" + property.Name, depth + 1, visited, rows);
    }
}

sealed record TextTarget(object Container, PropertyInfo StringProperty, string Path, string Source);
sealed record CatalogEntry(string Source, string English, string[] Contexts);

sealed class ReferenceEqualityComparer : IEqualityComparer<object>
{
    public static readonly ReferenceEqualityComparer Instance = new();
    public new bool Equals(object? x, object? y) => ReferenceEquals(x, y);
    public int GetHashCode(object obj) => RuntimeHelpers.GetHashCode(obj);
}
