import java.nio.file.Path;
import java.util.Comparator;
import java.util.Map;
import java.util.function.Function;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import resaver.ProgressModel;
import resaver.ess.ESS;
import resaver.ess.ModelBuilder;
import resaver.ess.papyrus.Papyrus;

public class SaveDependencyInspector {
    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.err.println("Usage: SaveDependencyInspector <save.ess>");
            System.exit(2);
        }
        Pattern relevant = Pattern.compile("(?i)(simpleslavery|sslv|ssradd|^ssr_)");
        ESS.Result result = ESS.readESS(Path.of(args[0]), new ModelBuilder(new ProgressModel()));
        Papyrus p = result.ESS.getPapyrus();
        Map<String, Long> counts = p.getScriptInstances().values().stream()
                .map(v -> v.getScriptName().toString())
                .filter(name -> relevant.matcher(name).find())
                .collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));
        System.out.println("Matching Simple Slavery/Rebuild script instances: " + counts.values().stream().mapToLong(Long::longValue).sum());
        counts.entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue(Comparator.reverseOrder()))
                .forEach(e -> System.out.printf("%6d  %s%n", e.getValue(), e.getKey()));
    }
}
