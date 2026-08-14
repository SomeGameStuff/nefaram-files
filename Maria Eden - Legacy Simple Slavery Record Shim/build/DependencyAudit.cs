using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

if (args.Length == 0)
{
    Console.Error.WriteLine("Usage: DependencyAudit <plugin> [plugin ...]");
    return 2;
}

var targets = new HashSet<ModKey>
{
    ModKey.FromNameAndExtension("SimpleSlavery.esp"),
    ModKey.FromNameAndExtension("SimpleSlaveryRebuild.esp")
};

foreach (var argument in args)
{
    var path = Path.GetFullPath(argument);
    var modPath = new ModPath(ModKey.FromFileName(Path.GetFileName(path)), path);
    var mod = SkyrimMod.CreateFromBinary(modPath, SkyrimRelease.SkyrimSE);
    Console.WriteLine($"## {mod.ModKey}");
    foreach (var record in mod.EnumerateMajorRecords())
    {
        var links = record.EnumerateFormLinks()
            .Where(link => targets.Contains(link.FormKey.ModKey))
            .Select(link => link.FormKey)
            .Distinct()
            .OrderBy(key => key)
            .ToArray();
        if (!targets.Contains(record.FormKey.ModKey) && links.Length == 0)
            continue;
        Console.WriteLine($"{record.GetType().Name,-24} {record.FormKey,-38} EDID={record.EditorID ?? "<none>"} links={links.Length}");
        foreach (var link in links)
            Console.WriteLine($"  -> {link}");
    }
}

return 0;
