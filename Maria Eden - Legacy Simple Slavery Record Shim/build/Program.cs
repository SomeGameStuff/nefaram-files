using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

if (args.Length < 3)
{
    Console.Error.WriteLine("Usage: RecordShimBuilder <SimpleSlavery.esp> <SimpleSlaveryRebuild.esp> <output-directory> [dependent-plugin ...]");
    return 2;
}

var outputDirectory = Path.GetFullPath(args[2]);
Directory.CreateDirectory(outputDirectory);
var builtRecords = new Dictionary<ModKey, HashSet<FormKey>>();

foreach (var inputArgument in args.Take(2))
{
    var inputPath = Path.GetFullPath(inputArgument);
    var fileName = Path.GetFileName(inputPath);
    var modPath = new ModPath(ModKey.FromFileName(fileName), inputPath);
    var mod = SkyrimMod.CreateFromBinary(modPath, SkyrimRelease.SkyrimSE);

    var originalFormKeys = mod.EnumerateMajorRecords().Select(x => x.FormKey).OrderBy(x => x).ToArray();
    var originalMasters = mod.ModHeader.MasterReferences.Select(x => x.Master).ToArray();
    var outputPath = Path.Combine(outputDirectory, fileName);
    File.Copy(inputPath, outputPath, overwrite: true);

    var checkPath = new ModPath(ModKey.FromFileName(fileName), outputPath);
    var check = SkyrimMod.CreateFromBinary(checkPath, SkyrimRelease.SkyrimSE);
    var outputFormKeys = check.EnumerateMajorRecords().Select(x => x.FormKey).OrderBy(x => x).ToArray();
    var outputMasters = check.ModHeader.MasterReferences.Select(x => x.Master).ToArray();
    if (!originalFormKeys.SequenceEqual(outputFormKeys))
        throw new InvalidOperationException($"{fileName}: FormKey set changed during build.");
    if (!originalMasters.SequenceEqual(outputMasters))
        throw new InvalidOperationException($"{fileName}: master list changed during build.");
    var inputHash = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(inputPath)));
    var outputHash = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(outputPath)));
    if (!StringComparer.Ordinal.Equals(inputHash, outputHash))
        throw new InvalidOperationException($"{fileName}: output is not an exact binary copy.");

    builtRecords[check.ModKey] = outputFormKeys.ToHashSet();

    Console.WriteLine($"Built {fileName}: exact binary record provider, records={outputFormKeys.Length}, masters={outputMasters.Length}, sha256={outputHash}");
}

foreach (var dependentArgument in args.Skip(3))
{
    var dependentPath = Path.GetFullPath(dependentArgument);
    var dependentName = Path.GetFileName(dependentPath);
    var dependentModPath = new ModPath(ModKey.FromFileName(dependentName), dependentPath);
    var dependent = SkyrimMod.CreateFromBinary(dependentModPath, SkyrimRelease.SkyrimSE);
    var checkedOverrides = 0;
    var checkedLinks = 0;

    foreach (var record in dependent.EnumerateMajorRecords())
    {
        if (!builtRecords.TryGetValue(record.FormKey.ModKey, out var available))
            continue;
        checkedOverrides++;
        if (!available.Contains(record.FormKey))
            throw new InvalidOperationException($"{dependentName}: override {record.FormKey} has no origin record in the shim.");
    }

    foreach (var link in dependent.EnumerateFormLinks())
    {
        if (!builtRecords.TryGetValue(link.FormKey.ModKey, out var available))
            continue;
        checkedLinks++;
        if (!available.Contains(link.FormKey))
            throw new InvalidOperationException($"{dependentName}: link {link.FormKey} has no target record in the shim.");
    }

    Console.WriteLine($"Validated {dependentName}: {checkedOverrides} override record(s) and {checkedLinks} record link(s) resolve against the shim.");
}

return 0;
