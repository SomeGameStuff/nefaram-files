using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Noggog;

const string outPath = @"C:\tmp\Spatial Storage Rings.esp";
var modKey = ModKey.FromNameAndExtension("Spatial Storage Rings.esp");
var skyrim = ModKey.FromNameAndExtension("Skyrim.esm");
var skyrimPath = ModPath.FromPath(@"C:\Games\nefaram\Game Root\Data\Skyrim.esm");
var skyrimMod = ModInstantiator<ISkyrimModGetter>.Importer(skyrimPath, GameRelease.SkyrimSE);

var mod = new SkyrimMod(modKey, SkyrimRelease.SkyrimSE);
mod.ModHeader.Flags = SkyrimModHeader.HeaderFlag.Small;
mod.ModHeader.MasterReferences.Add(new MasterReference { Master = skyrim });

FormKey Local(uint id) => FormKey.Factory($"{id:X6}:Spatial Storage Rings.esp");
FormKey Skyrim(uint id) => FormKey.Factory($"{id:X6}:Skyrim.esm");
FormLink<T> Link<T>(uint id) where T : class, IMajorRecordGetter => new(Local(id));
FormLinkNullable<T> NullableLink<T>(uint id) where T : class, IMajorRecordGetter => new(Local(id));

VirtualMachineAdapter Vmad(string scriptName) => new()
{
    Version = 5,
    ObjectFormat = 2,
    Scripts = { new ScriptEntry { Name = scriptName, Flags = ScriptEntry.Flag.Local } }
};

Effect Effect(uint mgefId) => new()
{
    BaseEffect = NullableLink<IMagicEffectGetter>(mgefId),
    Data = new EffectData { Magnitude = 0, Area = 0, Duration = 0 }
};

mod.Globals.AddReturn(new GlobalShort(Local(0x800), SkyrimRelease.SkyrimSE)
{
    EditorID = "SSR_CurrentStorageCapacity",
    RawFloat = 0
});

mod.Messages.AddReturn(new Message(Local(0x801), SkyrimRelease.SkyrimSE)
{
    EditorID = "SSR_MsgNoRingEquipped",
    Description = "Equip a Spatial Storage Ring to access spatial storage."
});

mod.Messages.AddReturn(new Message(Local(0x802), SkyrimRelease.SkyrimSE)
{
    EditorID = "SSR_MsgStorageFull",
    Description = "The spatial storage is full. Excess items were returned."
});

mod.Keywords.AddReturn(new Keyword(Local(0x810), SkyrimRelease.SkyrimSE)
{
    EditorID = "SSR_KeywordSpatialStorageRing"
});

MagicEffect Mgef(uint id, string edid, string name, string script)
{
    return mod.MagicEffects.AddReturn(new MagicEffect(Local(id), SkyrimRelease.SkyrimSE)
    {
        EditorID = edid,
        Name = name,
        CastType = CastType.ConstantEffect,
        TargetType = TargetType.Self,
        MagicSkill = ActorValue.None,
        Archetype = new MagicEffectArchetype { Type = MagicEffectArchetype.TypeEnum.Script },
        Flags = MagicEffect.Flag.HideInUI | MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoArea,
        VirtualMachineAdapter = Vmad(script)
    });
}

Mgef(0x803, "SSR_MGEF_OpenStorage", "Open Spatial Storage", "SSR_OpenStorageEffect");
Mgef(0x811, "SSR_MGEF_RingLesser", "Spatial Storage - Lesser", "SSR_RingLesserEffect");
Mgef(0x812, "SSR_MGEF_RingGreater", "Spatial Storage - Greater", "SSR_RingGreaterEffect");
Mgef(0x813, "SSR_MGEF_RingGrand", "Spatial Storage - Grand", "SSR_RingGrandEffect");
Mgef(0x814, "SSR_MGEF_RingInfinite", "Spatial Storage - Infinite", "SSR_RingInfiniteEffect");

mod.Spells.AddReturn(new Spell(Local(0x804), SkyrimRelease.SkyrimSE)
{
    EditorID = "SSR_PowerOpenSpatialStorage",
    Name = "Open Spatial Storage",
    Type = SpellType.LesserPower,
    CastType = CastType.FireAndForget,
    TargetType = TargetType.Self,
    Effects = { Effect(0x803) }
});

ObjectEffect Ench(uint id, string edid, string name, uint mgef)
{
    return mod.ObjectEffects.AddReturn(new ObjectEffect(Local(id), SkyrimRelease.SkyrimSE)
    {
        EditorID = edid,
        Name = name,
        EnchantType = ObjectEffect.EnchantTypeEnum.Enchantment,
        CastType = CastType.ConstantEffect,
        TargetType = TargetType.Self,
        Effects = { Effect(mgef) }
    });
}

Ench(0x821, "SSR_Ench_RingLesser", "Spatial Storage - Lesser", 0x811);
Ench(0x822, "SSR_Ench_RingGreater", "Spatial Storage - Greater", 0x812);
Ench(0x823, "SSR_Ench_RingGrand", "Spatial Storage - Grand", 0x813);
Ench(0x824, "SSR_Ench_RingInfinite", "Spatial Storage - Infinite", 0x814);

Armor Ring(uint id, string edid, string name, uint ench, uint value)
{
    var armor = new Armor(Local(id), SkyrimRelease.SkyrimSE)
    {
        EditorID = edid,
        Name = name,
        ObjectEffect = NullableLink<IObjectEffectGetter>(ench),
        Value = value,
        Weight = 0.25f,
        BodyTemplate = new BodyTemplate
        {
            FirstPersonFlags = BipedObjectFlag.Ring,
            ArmorType = ArmorType.Clothing
        },
        WorldModel = new GenderedItem<ArmorModel>(
            female: new ArmorModel { Model = new Model { File = @"Armor\AmuletsandRings\GoldDiamondRingGO.nif" } },
            male: new ArmorModel { Model = new Model { File = @"Armor\AmuletsandRings\GoldDiamondRingGO.nif" } })
    };
    armor.Keywords ??= new();
    armor.Keywords.Add(Link<IKeywordGetter>(0x810));
    return mod.Armors.AddReturn(armor);
}

Ring(0x831, "SSR_RingLesser", "Spatial Storage Ring - Lesser", 0x821, 100);
Ring(0x832, "SSR_RingGreater", "Spatial Storage Ring - Greater", 0x822, 1000);
Ring(0x833, "SSR_RingGrand", "Spatial Storage Ring - Grand", 0x823, 5000);
Ring(0x834, "SSR_RingInfinite", "Spatial Storage Ring - Infinite", 0x824, 20000);

mod.Containers.AddReturn(new Container(Local(0x805), SkyrimRelease.SkyrimSE)
{
    EditorID = "SSR_SpatialStorageContainer",
    Name = "Spatial Storage",
    Model = new Model { File = @"Clutter\Common\Chest01.nif" }
});

var cell = new Cell(Local(0x80E), SkyrimRelease.SkyrimSE)
{
    EditorID = "SSR_SpatialStorageCell",
    Name = "Spatial Storage Holding Cell",
    Flags = Cell.Flag.IsInteriorCell
};
cell.Persistent.Add(new PlacedObject(Local(0x80F), SkyrimRelease.SkyrimSE)
{
    EditorID = "SSR_SpatialStorageRef",
    Base = NullableLink<IPlaceableObjectGetter>(0x805),
    VirtualMachineAdapter = Vmad("SSR_StorageContainerScript"),
    Placement = new Placement
    {
        Position = new P3Float(0, 0, 0),
        Rotation = new P3Float(0, 0, 0)
    }
});
var block = new CellBlock { BlockNumber = 0, GroupType = GroupTypeEnum.InteriorCellBlock };
var subBlock = new CellSubBlock { BlockNumber = 0, GroupType = GroupTypeEnum.InteriorCellSubBlock };
subBlock.Cells.Add(cell);
block.SubBlocks.Add(subBlock);
mod.Cells.Add(block);

var ringList = mod.LeveledItems.AddReturn(new LeveledItem(Local(0x840), SkyrimRelease.SkyrimSE)
{
    EditorID = "SSR_LItemSpatialStorageRings",
    Flags = LeveledItem.Flag.CalculateFromAllLevelsLessThanOrEqualPlayer,
    Entries = new()
});
foreach (var (ring, level) in new[] { (0x831u, (short)1), (0x832u, (short)12), (0x833u, (short)24), (0x834u, (short)36) })
{
    ringList.Entries.Add(new LeveledItemEntry
    {
        Data = new LeveledItemEntryData
        {
            Reference = Link<IItemGetter>(ring),
            Level = level,
            Count = 1
        }
    });
}

void PatchVendorList(uint skyrimFormId, string expectedEditorId, short level)
{
    var src = skyrimMod.LeveledItems.FirstOrDefault(x => x.FormKey == Skyrim(skyrimFormId));
    if (src == null)
        throw new InvalidOperationException($"Missing Skyrim leveled list {expectedEditorId} {skyrimFormId:X6}");
    if (!string.Equals(src.EditorID, expectedEditorId, StringComparison.Ordinal))
        throw new InvalidOperationException($"Expected {expectedEditorId} at {skyrimFormId:X6}, found {src.EditorID}");

    var patched = new LeveledItem(src.FormKey, SkyrimRelease.SkyrimSE)
    {
        EditorID = src.EditorID,
        ChanceNone = src.ChanceNone,
        Flags = src.Flags,
        Entries = new()
    };

    foreach (var entry in src.Entries ?? Enumerable.Empty<ILeveledItemEntryGetter>())
    {
        if (entry.Data == null)
            continue;
        patched.Entries.Add(new LeveledItemEntry
        {
            Data = new LeveledItemEntryData
            {
                Reference = new FormLink<IItemGetter>(entry.Data.Reference.FormKey),
                Level = entry.Data.Level,
                Count = entry.Data.Count,
                Unknown = entry.Data.Unknown,
                Unknown2 = entry.Data.Unknown2
            }
        });
    }

    patched.Entries.Add(new LeveledItemEntry
    {
        Data = new LeveledItemEntryData
        {
            Reference = Link<IItemGetter>(0x840),
            Level = level,
            Count = 1
        }
    });
    mod.LeveledItems.AddReturn(patched);
}

PatchVendorList(0x09AF0A, "LItemMiscVendorMiscItems75", 1);
PatchVendorList(0x0A3F66, "LItemMiscVendorJewelry25", 1);
PatchVendorList(0x0C44A8, "LItemMiscVendorJewelry100", 12);

Directory.CreateDirectory(Path.GetDirectoryName(outPath)!);
mod.WriteToBinary(outPath);
Console.WriteLine(outPath);
