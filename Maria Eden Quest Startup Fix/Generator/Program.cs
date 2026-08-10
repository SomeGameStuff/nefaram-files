using System.Collections;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

const string PatchName = "NEFARAM_MariaEdenQuestStartupFix.esp";

if (args.Length != 2)
    throw new ArgumentException("Usage: Generator <winning-MariaProstitution.esp> <output.esp>");

var sourcePath = Path.GetFullPath(args[0]);
var outputPath = Path.GetFullPath(args[1]);
var source = SkyrimMod.CreateFromBinary(sourcePath, SkyrimRelease.SkyrimSE);

var patch = new SkyrimMod(ModKey.FromNameAndExtension(PatchName), SkyrimRelease.SkyrimSE);
patch.ModHeader.Flags |= SkyrimModHeader.HeaderFlag.Small;

foreach (var master in source.ModHeader.MasterReferences.Select(x => x.Master))
    patch.ModHeader.MasterReferences.Add(new MasterReference { Master = master });
patch.ModHeader.MasterReferences.Add(new MasterReference { Master = source.ModKey });

var foodTracker = CopyQuest("MEPFoodTracker");
var foodMaster = FindAlias(foodTracker, "master");
var foodConditions = GetList(foodMaster, "Conditions");
var sceneConditions = foodConditions.Cast<object>()
    .Where(IsInSceneCondition)
    .ToArray();
if (sceneConditions.Length != 1)
    throw new InvalidDataException($"Expected one IsInScene condition on MEPFoodTracker/master; found {sceneConditions.Length}.");
foodConditions.Remove(sceneConditions[0]);
patch.Quests.Add(foodTracker);

var pimpSlaves = CopyQuest("MEPPimpSlaves");
var slave2 = FindAlias(pimpSlaves, "slave2");
SetEnumFlag(slave2, "Flags", "Optional");
patch.Quests.Add(pimpSlaves);

Directory.CreateDirectory(Path.GetDirectoryName(outputPath)!);
patch.WriteToBinary(outputPath);

var check = SkyrimMod.CreateFromBinary(outputPath, SkyrimRelease.SkyrimSE);
if (!check.ModHeader.Flags.HasFlag(SkyrimModHeader.HeaderFlag.Small))
    throw new InvalidDataException("Generated plugin is not ESL flagged.");
if (check.Quests.Count != 2)
    throw new InvalidDataException($"Expected exactly 2 QUST overrides; found {check.Quests.Count}.");

var checkedFood = check.Quests.Single(x => x.EditorID == "MEPFoodTracker");
if (GetList(FindAlias(checkedFood, "master"), "Conditions").Cast<object>().Any(IsInSceneCondition))
    throw new InvalidDataException("MEPFoodTracker/master still has an IsInScene condition.");
var checkedSlave2 = FindAlias(check.Quests.Single(x => x.EditorID == "MEPPimpSlaves"), "slave2");
if (!HasEnumFlag(checkedSlave2, "Flags", "Optional"))
    throw new InvalidDataException("MEPPimpSlaves/slave2 is not optional.");

Console.WriteLine($"Built and validated {outputPath}");
Console.WriteLine("Overrides: MEPFoodTracker (removed master IsInScene condition), MEPPimpSlaves (slave2 optional).");

Quest CopyQuest(string editorId)
{
    var sourceQuest = source.Quests.SingleOrDefault(x => x.EditorID == editorId)
        ?? throw new InvalidDataException($"Quest {editorId} was not found in {sourcePath}.");
    return sourceQuest.DeepCopy();
}

static object FindAlias(Quest quest, string name)
{
    return quest.Aliases.Cast<object>().SingleOrDefault(alias =>
        string.Equals(
            alias.GetType().GetProperty("Name")?.GetValue(alias)?.ToString(),
            name,
            StringComparison.OrdinalIgnoreCase))
        ?? throw new InvalidDataException($"Alias {name} was not found on {quest.EditorID}.");
}

static IList GetList(object owner, string propertyName)
{
    var value = owner.GetType().GetProperty(propertyName)?.GetValue(owner);
    return value as IList
        ?? throw new InvalidDataException($"{owner.GetType().Name}.{propertyName} is not a mutable list.");
}

static bool IsInSceneCondition(object condition)
{
    var data = condition.GetType().GetProperty("Data")?.GetValue(condition);
    return data?.GetType().Name == "IsInSceneConditionData";
}

static void SetEnumFlag(object owner, string propertyName, string flagName)
{
    var property = owner.GetType().GetProperty(propertyName)
        ?? throw new InvalidDataException($"Missing {owner.GetType().Name}.{propertyName}.");
    var current = property.GetValue(owner)
        ?? throw new InvalidDataException($"{owner.GetType().Name}.{propertyName} is null.");
    var enumType = current.GetType();
    var flag = Enum.Parse(enumType, flagName);
    var combined = Convert.ToUInt64(current) | Convert.ToUInt64(flag);
    property.SetValue(owner, Enum.ToObject(enumType, combined));
}

static bool HasEnumFlag(object owner, string propertyName, string flagName)
{
    var property = owner.GetType().GetProperty(propertyName)
        ?? throw new InvalidDataException($"Missing {owner.GetType().Name}.{propertyName}.");
    var current = property.GetValue(owner)
        ?? throw new InvalidDataException($"{owner.GetType().Name}.{propertyName} is null.");
    var enumType = current.GetType();
    var flag = Enum.Parse(enumType, flagName);
    return (Convert.ToUInt64(current) & Convert.ToUInt64(flag)) != 0;
}
