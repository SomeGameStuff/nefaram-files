import java.nio.file.Path;
import java.util.Comparator;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import resaver.ProgressModel;
import resaver.ess.ESS;
import resaver.ess.ModelBuilder;
import resaver.ess.papyrus.Papyrus;

public class SaveScriptLagInspector {
    private static String clean(Object value) {
        if (value == null) return "<null>";
        return value.toString().replaceAll("<[^>]+>", "").replaceAll("\\s+", " ").trim();
    }

    private static void top(String title, java.util.stream.Stream<String> stream) {
        System.out.println();
        System.out.println(title);
        stream.filter(s -> s != null && !s.isBlank())
                .collect(Collectors.groupingBy(Function.identity(), Collectors.counting()))
                .entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue(Comparator.reverseOrder()))
                .limit(25)
                .forEach(e -> System.out.printf("%6d  %s%n", e.getValue(), e.getKey()));
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.err.println("Usage: SaveScriptLagInspector <save.ess>");
            System.exit(2);
        }

        ESS.Result result = ESS.readESS(Path.of(args[0]), new ModelBuilder(new ProgressModel()));
        Papyrus p = result.ESS.getPapyrus();

        System.out.println("Save: " + args[0]);
        System.out.println("Papyrus bytes: " + p.calculateSize());
        System.out.println("Scripts: " + p.getScripts().size());
        System.out.println("Script instances: " + p.getScriptInstances().size());
        System.out.println("References: " + p.getReferences().size());
        System.out.println("Arrays: " + p.getArrays().size());
        System.out.println("Active scripts: " + p.getActiveScripts().size());
        System.out.println("Function messages: " + p.getFunctionMessages().size());
        System.out.println("Suspended stacks total: " + p.getSuspendedStacks().size());
        System.out.println("Suspended stacks 1: " + p.getSuspendedStacks1().size());
        System.out.println("Suspended stacks 2: " + p.getSuspendedStacks2().size());
        System.out.println("Unbinds: " + p.getUnbinds().size());
        System.out.println("Unknown IDs: " + p.getUnknownIDList().size());
        System.out.println("Unattached instances: " + p.countUnattachedInstances());
        System.out.println("Undefined elements: " + p.countUndefinedElements());

        top("Top script instances", p.getScriptInstances().values().stream().map(v -> clean(v.getScriptName())));
        top("Top references", p.getReferences().values().stream().map(v -> clean(v.getScriptName())));
        top("Top active scripts / threads", p.getActiveScripts().values().stream().map(SaveScriptLagInspector::clean));
        top("Top function messages", p.getFunctionMessages().stream().map(SaveScriptLagInspector::clean));
        top("Top suspended stacks", p.getSuspendedStacks().values().stream().map(SaveScriptLagInspector::clean));
    }
}
