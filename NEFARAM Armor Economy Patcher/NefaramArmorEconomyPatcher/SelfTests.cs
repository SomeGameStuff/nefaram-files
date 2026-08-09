namespace NefaramArmorEconomyPatcher;

internal static class SelfTests
{
    public static int Run()
    {
        var settings = new Settings { ValueOutlierFactor = 3, MinimumExploitMarkupRatio = 4, TargetCraftingMarkupRatio = 2, MinimumGoldDifference = 100 };
        Check(EconomyRules.IsOutlier(800, 20, 125, 50, settings), "800g armor from 20g materials must be an outlier");
        Check(!EconomyRules.IsOutlier(130, 55, 125, 50, settings), "near-reference armor must remain in range");
        Check(!EconomyRules.IsOutlier(500, 180, 5, 103, settings), "costly quest clothing must not be treated as a crafting exploit");
        Check(EconomyRules.ProposedValue(800, 125, 50, settings) == 125, "leather exploit value cap");
        Check(EconomyRules.ProposedValue(200, 1, 103, settings) == 200, "reasonable clothing value must not be reduced to one gold");
        Check(EconomyRules.IngredientCategory("LeatherStrips", "Leather Strips") == "LeatherStrips", "leather strips category");
        Check(EconomyRules.IngredientCategory("IngotEbony", "Ebony Ingot") == "Ebony", "ebony category");
        Check(EconomyRules.IsOfficial("Skyrim.esm") && EconomyRules.IsOfficial("ccBGSSSE001-Fish.esm"), "official plugin detection");
        Check(!EconomyRules.IsOfficial("SomeArmor.esp"), "added plugin detection");
        Check(EconomyRules.Csv("a,b") == "\"a,b\"", "CSV quoting");
        var report = AuditReport.Create(
        [
            new AuditRow { Status = "AutoFix", Plugin = "Example.esp", Name = "Expensive Boots", Patched = true },
            new AuditRow { Status = "ReportOnly", Plugin = "Example.esp", Name = "Enchanted Boots" },
            new AuditRow { Status = "WithinRange", Plugin = "Example.esp", Name = "Normal Boots" }
        ], false);
        Check(report.Summary.ProposedChanges == 1 && report.Summary.AppliedChanges == 1, "JSON report change summary");
        Check(report.Changes.Count == 1 && report.NeedsReview.Count == 1 && report.OtherRecords.Count == 1, "JSON report review sections");
        Console.WriteLine("All NEFARAM Armor Economy Patcher self-tests passed.");
        return 0;
    }

    private static void Check(bool condition, string name)
    {
        if (!condition) throw new InvalidOperationException($"Self-test failed: {name}");
    }
}
