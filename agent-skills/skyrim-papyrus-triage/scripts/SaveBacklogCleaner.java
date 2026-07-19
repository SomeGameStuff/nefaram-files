import java.nio.file.Path;
import java.util.function.Predicate;

import resaver.ProgressModel;
import resaver.ess.ESS;
import resaver.ess.ModelBuilder;
import resaver.ess.papyrus.Papyrus;

public class SaveBacklogCleaner {
    private static boolean isTarget(String text) {
        return text != null && (text.startsWith("SPEWeaponSpeedScript") || text.startsWith("SPEOnHitEvent"));
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("Usage: SaveBacklogCleaner <input.ess> <output.ess>");
            System.exit(2);
        }

        Path input = Path.of(args[0]);
        Path output = Path.of(args[1]);

        ESS.Result result = ESS.readESS(input, new ModelBuilder(new ProgressModel()));
        Papyrus p = result.ESS.getPapyrus();

        int activeBefore = p.getActiveScripts().size();
        int stacksBefore = p.getSuspendedStacks().size();
        int messagesBefore = p.getFunctionMessages().size();

        Predicate<Object> target = v -> isTarget(String.valueOf(v));

        int removedActive = 0;
        var activeIterator = p.getActiveScripts().entrySet().iterator();
        while (activeIterator.hasNext()) {
            if (target.test(activeIterator.next().getValue())) {
                activeIterator.remove();
                removedActive++;
            }
        }

        int removedStacks1 = 0;
        var stack1Iterator = p.getSuspendedStacks1().entrySet().iterator();
        while (stack1Iterator.hasNext()) {
            if (target.test(stack1Iterator.next().getValue())) {
                stack1Iterator.remove();
                removedStacks1++;
            }
        }

        int removedStacks2 = 0;
        var stack2Iterator = p.getSuspendedStacks2().entrySet().iterator();
        while (stack2Iterator.hasNext()) {
            if (target.test(stack2Iterator.next().getValue())) {
                stack2Iterator.remove();
                removedStacks2++;
            }
        }

        int messagesBeforeRemove = p.getFunctionMessages().size();
        p.getFunctionMessages().removeIf(target::test);
        int removedMessages = messagesBeforeRemove - p.getFunctionMessages().size();

        ESS.writeESS(result.ESS, output);

        System.out.println("Input: " + input);
        System.out.println("Output: " + output);
        System.out.println("Active scripts: " + activeBefore + " -> " + p.getActiveScripts().size()
                + " (removed " + removedActive + ")");
        System.out.println("Suspended stacks: " + stacksBefore + " -> " + p.getSuspendedStacks().size()
                + " (removed " + (removedStacks1 + removedStacks2) + ")");
        System.out.println("Function messages: " + messagesBefore + " -> " + p.getFunctionMessages().size()
                + " (removed " + removedMessages + ")");
    }
}
