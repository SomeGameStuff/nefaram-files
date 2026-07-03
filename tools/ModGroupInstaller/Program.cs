using System.Diagnostics;
using System.IO.Compression;
using System.Net.Http;
using System.Reflection;
using System.Runtime.Loader;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace ModGroupInstaller;

internal static class Program
{
    [STAThread]
    private static int Main(string[] args)
    {
        if (args.Length > 0)
        {
            return Cli.Run(args);
        }

        ApplicationConfiguration.Initialize();
        Application.Run(new MainForm());
        return 0;
    }
}

internal static class Cli
{
    public static int Run(string[] args)
    {
        try
        {
            var options = CliOptions.Parse(args);
            if (options.ShowHelp)
            {
                Console.WriteLine(CliOptions.HelpText);
                return 0;
            }

            var log = new ConsoleInstallLog();
            var request = new InstallRequest(options.Mo2Root!, options.Manifest!, options.Profile, options.DryRun, options.Overwrite, options.WabbajackCli, options.NexusApiKey);
            var result = new Installer(log).RunAsync(request, CancellationToken.None).GetAwaiter().GetResult();
            foreach (var line in result.Messages)
            {
                Console.WriteLine(line);
            }

            return result.Success ? 0 : 2;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine(ex.Message);
            return 1;
        }
    }
}

internal sealed record CliOptions(
    string? Mo2Root,
    string? Manifest,
    string? Profile,
    bool DryRun,
    bool Overwrite,
    string? WabbajackCli,
    string? NexusApiKey,
    bool ShowHelp)
{
    public const string HelpText = """
    ModGroupInstaller

    Usage:
      ModGroupInstaller.exe --mo2 <path> --manifest <file> [--profile <name>] [--dry-run] [--overwrite] [--wabbajack <path>] [--nexus-api-key <key>]

    Manifest examples:
      + local path="C:\mods\Example.zip" install="Example Mod"
      + manual url="https://example.com/Example.zip" install="Example Mod" sha256="..."
      + discord url="https://cdn.discordapp.com/..." install="Discord Mod" sha256="..."
      + nexus skyrimspecialedition 16495 file_id=123456 install="JContainers SE"
      + loverslab url="https://www.loverslab.com/files/file/11116-example" file="Example.zip" install="Example LL Mod"
      separator "Animation Mods"
    """;

    public static CliOptions Parse(string[] args)
    {
        string? mo2 = null;
        string? manifest = null;
        string? profile = null;
        string? wabbajack = null;
        string? nexusApiKey = null;
        var dryRun = false;
        var overwrite = false;

        for (var i = 0; i < args.Length; i++)
        {
            var arg = args[i];
            switch (arg)
            {
                case "-h":
                case "--help":
                case "/?":
                    return new CliOptions(null, null, null, false, false, null, null, true);
                case "--mo2":
                    mo2 = RequireValue(args, ref i, arg);
                    break;
                case "--manifest":
                    manifest = RequireValue(args, ref i, arg);
                    break;
                case "--profile":
                    profile = RequireValue(args, ref i, arg);
                    break;
                case "--wabbajack":
                    wabbajack = RequireValue(args, ref i, arg);
                    break;
                case "--nexus-api-key":
                    nexusApiKey = RequireValue(args, ref i, arg);
                    break;
                case "--dry-run":
                    dryRun = true;
                    break;
                case "--overwrite":
                    overwrite = true;
                    break;
                default:
                    throw new ArgumentException($"Unknown argument: {arg}");
            }
        }

        if (string.IsNullOrWhiteSpace(mo2) || string.IsNullOrWhiteSpace(manifest))
        {
            throw new ArgumentException("Both --mo2 and --manifest are required. Use --help for usage.");
        }

        return new CliOptions(mo2, manifest, profile, dryRun, overwrite, wabbajack, nexusApiKey, false);
    }

    private static string RequireValue(string[] args, ref int index, string argName)
    {
        if (index + 1 >= args.Length)
        {
            throw new ArgumentException($"{argName} requires a value.");
        }

        index++;
        return args[index];
    }
}

internal sealed class MainForm : Form
{
    private readonly TextBox _mo2Root = new() { Anchor = AnchorStyles.Left | AnchorStyles.Right };
    private readonly TextBox _manifest = new() { Anchor = AnchorStyles.Left | AnchorStyles.Right };
    private readonly ComboBox _profile = new() { Anchor = AnchorStyles.Left | AnchorStyles.Right, DropDownStyle = ComboBoxStyle.DropDownList };
    private readonly TextBox _wabbajack = new() { Anchor = AnchorStyles.Left | AnchorStyles.Right };
    private readonly TextBox _nexusApiKey = new() { Anchor = AnchorStyles.Left | AnchorStyles.Right, UseSystemPasswordChar = true };
    private readonly CheckBox _overwrite = new() { Text = "Overwrite existing mod folders" };
    private readonly TextBox _log = new() { Multiline = true, ScrollBars = ScrollBars.Vertical, ReadOnly = true, Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right };
    private readonly Button _dryRun = new() { Text = "Dry Run" };
    private readonly Button _install = new() { Text = "Install" };

    public MainForm()
    {
        Text = "MO2 Mod Group Installer";
        Width = 900;
        Height = 620;
        MinimumSize = new Size(760, 480);

        var root = new TableLayoutPanel { Dock = DockStyle.Fill, Padding = new Padding(12), ColumnCount = 3, RowCount = 8 };
        root.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 110));
        root.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        root.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 110));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 44));

        AddRow(root, 0, "MO2 root", _mo2Root, BrowseFolder("Select MO2 root", _mo2Root, refreshProfiles: true));
        AddRow(root, 1, "Manifest", _manifest, BrowseFile("Select manifest", _manifest, "Manifest files|*.txt;*.mods.txt;*.csv|All files|*.*"));
        AddRow(root, 2, "Profile", _profile, MakeButton("Refresh", (_, _) => RefreshProfiles()));
        AddRow(root, 3, "Wabbajack", _wabbajack, BrowseFile("Select wabbajack-cli.bat or wabbajack-cli.exe", _wabbajack, "Wabbajack CLI|wabbajack-cli.bat;wabbajack-cli.exe|All files|*.*"));
        AddRow(root, 4, "Nexus API key", _nexusApiKey, MakeButton("Use env", (_, _) => _nexusApiKey.Text = Environment.GetEnvironmentVariable("NEXUS_API_KEY") ?? Environment.GetEnvironmentVariable("NEXUSMODS_API_KEY") ?? ""));

        root.Controls.Add(_overwrite, 1, 5);
        root.SetColumnSpan(_overwrite, 2);
        root.Controls.Add(_log, 0, 6);
        root.SetColumnSpan(_log, 3);

        var buttons = new FlowLayoutPanel { FlowDirection = FlowDirection.RightToLeft, Dock = DockStyle.Fill };
        buttons.Controls.Add(_install);
        buttons.Controls.Add(_dryRun);
        root.Controls.Add(buttons, 0, 7);
        root.SetColumnSpan(buttons, 3);

        Controls.Add(root);

        _mo2Root.Text = Mo2Instance.FindNearestRoot(Directory.GetCurrentDirectory()) ?? Directory.GetCurrentDirectory();
        _wabbajack.Text = WabbajackCli.FindDefault(_mo2Root.Text) ?? "";
        RefreshProfiles();

        _dryRun.Click += async (_, _) => await ExecuteAsync(dryRun: true);
        _install.Click += async (_, _) => await ExecuteAsync(dryRun: false);
    }

    private static void AddRow(TableLayoutPanel root, int row, string label, Control input, Control button)
    {
        root.Controls.Add(new Label { Text = label, AutoSize = true, Anchor = AnchorStyles.Left }, 0, row);
        root.Controls.Add(input, 1, row);
        root.Controls.Add(button, 2, row);
    }

    private Button BrowseFolder(string title, TextBox target, bool refreshProfiles)
    {
        return MakeButton("Browse", (_, _) =>
        {
            using var dialog = new FolderBrowserDialog { Description = title, SelectedPath = Directory.Exists(target.Text) ? target.Text : Directory.GetCurrentDirectory() };
            if (dialog.ShowDialog(this) == DialogResult.OK)
            {
                target.Text = dialog.SelectedPath;
                if (refreshProfiles)
                {
                    RefreshProfiles();
                }
            }
        });
    }

    private Button BrowseFile(string title, TextBox target, string filter)
    {
        return MakeButton("Browse", (_, _) =>
        {
            using var dialog = new OpenFileDialog { Title = title, Filter = filter, CheckFileExists = true };
            if (File.Exists(target.Text))
            {
                dialog.FileName = target.Text;
            }

            if (dialog.ShowDialog(this) == DialogResult.OK)
            {
                target.Text = dialog.FileName;
            }
        });
    }

    private static Button MakeButton(string text, EventHandler handler)
    {
        var button = new Button { Text = text, Dock = DockStyle.Fill };
        button.Click += handler;
        return button;
    }

    private void RefreshProfiles()
    {
        _profile.Items.Clear();
        try
        {
            var mo2 = Mo2Instance.Load(_mo2Root.Text);
            foreach (var profile in mo2.Profiles)
            {
                _profile.Items.Add(profile);
            }

            if (mo2.SelectedProfile is not null && _profile.Items.Contains(mo2.SelectedProfile))
            {
                _profile.SelectedItem = mo2.SelectedProfile;
            }
            else if (_profile.Items.Count > 0)
            {
                _profile.SelectedIndex = 0;
            }
        }
        catch
        {
            _profile.Text = "";
        }
    }

    private async Task ExecuteAsync(bool dryRun)
    {
        ToggleButtons(false);
        _log.Clear();
        try
        {
            var log = new TextBoxInstallLog(_log);
            var request = new InstallRequest(_mo2Root.Text, _manifest.Text, _profile.SelectedItem?.ToString(), dryRun, _overwrite.Checked, string.IsNullOrWhiteSpace(_wabbajack.Text) ? null : _wabbajack.Text, string.IsNullOrWhiteSpace(_nexusApiKey.Text) ? null : _nexusApiKey.Text);
            var result = await new Installer(log).RunAsync(request, CancellationToken.None);
            foreach (var message in result.Messages)
            {
                log.Info(message);
            }
        }
        catch (Exception ex)
        {
            _log.AppendText(ex + Environment.NewLine);
        }
        finally
        {
            ToggleButtons(true);
        }
    }

    private void ToggleButtons(bool enabled)
    {
        _dryRun.Enabled = enabled;
        _install.Enabled = enabled;
    }
}

internal sealed record InstallRequest(string Mo2Root, string ManifestPath, string? Profile, bool DryRun, bool Overwrite, string? WabbajackCli, string? NexusApiKey);

internal sealed record InstallResult(bool Success, IReadOnlyList<string> Messages);

internal sealed class Installer(IInstallLog log)
{
    public async Task<InstallResult> RunAsync(InstallRequest request, CancellationToken token)
    {
        var messages = new List<string>();
        var mo2 = Mo2Instance.Load(request.Mo2Root);
        var profile = string.IsNullOrWhiteSpace(request.Profile) ? mo2.SelectedProfile : request.Profile;
        if (string.IsNullOrWhiteSpace(profile))
        {
            throw new InvalidOperationException("No target profile was selected and ModOrganizer.ini does not define selected_profile.");
        }

        var profilePath = Path.Combine(mo2.ProfilesPath, profile);
        var modlistPath = Path.Combine(profilePath, "modlist.txt");
        if (!File.Exists(modlistPath))
        {
            throw new FileNotFoundException("Target profile does not contain modlist.txt.", modlistPath);
        }

        var manifest = ManifestParser.ParseFile(request.ManifestPath);
        messages.Add($"MO2 root: {mo2.Root}");
        messages.Add($"Profile: {profile}");
        messages.Add($"Manifest entries: {manifest.Count}");

        var wabbajackCli = request.WabbajackCli;
        if (string.IsNullOrWhiteSpace(wabbajackCli))
        {
            wabbajackCli = WabbajackCli.FindDefault(mo2.Root);
        }

        messages.Add(wabbajackCli is null ? "Wabbajack CLI: not found; ZIP extraction only." : $"Wabbajack CLI: {wabbajackCli}");

        var desiredModlistEntries = new List<ModlistEntry>();
        var pendingSeparators = new List<ModlistEntry>();
        foreach (var entry in manifest)
        {
            token.ThrowIfCancellationRequested();
            switch (entry)
            {
                case SeparatorEntry separator:
                    pendingSeparators.Add(new ModlistEntry(true, $"{separator.Name}_separator"));
                    log.Info($"Separator: {separator.Name}");
                    break;
                case ModEntry mod:
                    if (await ProcessModAsync(mo2, mod, request, wabbajackCli, token))
                    {
                        if (pendingSeparators.Count > 0)
                        {
                            desiredModlistEntries.AddRange(pendingSeparators);
                            pendingSeparators.Clear();
                        }

                        desiredModlistEntries.Add(new ModlistEntry(mod.Enabled, mod.InstallName));
                    }
                    break;
            }
        }

        if (desiredModlistEntries.Count > 0)
        {
            await UpdateModlistAsync(modlistPath, desiredModlistEntries, request.DryRun, token);
        }
        else
        {
            log.Info("No installed or existing mods from this manifest; modlist was not changed.");
        }

        messages.Add(request.DryRun ? "Dry run completed. No files were changed." : "Install completed.");
        return new InstallResult(true, messages);
    }

    private async Task<bool> ProcessModAsync(Mo2Instance mo2, ModEntry mod, InstallRequest request, string? wabbajackCli, CancellationToken token)
    {
        var destination = Path.Combine(mo2.ModsPath, SafePathName(mod.InstallName));
        if (Directory.Exists(destination))
        {
            if (!request.Overwrite)
            {
                log.Info($"Skip existing mod folder: {mod.InstallName}");
                if (!request.DryRun && mod.Source == ModSource.Nexus)
                {
                    WriteNexusMetaIni(destination, mod);
                }
                return true;
            }

            log.Info(request.DryRun ? $"Would overwrite: {mod.InstallName}" : $"Overwriting: {mod.InstallName}");
            if (!request.DryRun)
            {
                Directory.Delete(destination, recursive: true);
            }
        }

        if (mod.Source == ModSource.Nexus)
        {
            var archive = await ResolveNexusArchiveAsync(mo2, mod, request, token);
            if (archive is null)
            {
                return request.DryRun;
            }

            if (mod.Sha256 is not null && !request.DryRun)
            {
                var actual = await Hash.Sha256Async(archive, token);
                if (!string.Equals(actual, mod.Sha256, StringComparison.OrdinalIgnoreCase))
                {
                    throw new InvalidOperationException($"SHA256 mismatch for {mod.InstallName}. Expected {mod.Sha256}, got {actual}.");
                }
            }

            log.Info(request.DryRun ? $"Would extract {archive} -> {destination}" : $"Extracting {mod.InstallName}");
            if (!request.DryRun)
            {
                Directory.CreateDirectory(destination);
                await ArchiveExtractor.ExtractAsync(archive, destination, wabbajackCli, token);
                NormalizeExtractedModFolder(destination);
                WriteNexusMetaIni(destination, mod);
            }

            return true;
        }

        if (mod.Source == ModSource.LoversLab)
        {
            log.Warn($"{mod.Source} entry requires manual acquisition in v1: {mod.InstallName}");
            log.Warn($"  {mod.Url ?? mod.Describe()}");
            return request.DryRun;
        }

        if (mod.Source == ModSource.Manual && mod.Url is not null && !IsDirectDownload(mod.Url))
        {
            log.Warn($"Manual browser download required: {mod.InstallName}");
            log.Warn($"  {mod.Url}");
            return request.DryRun;
        }

        var archivePath = await ResolveArchiveAsync(mo2, mod, request.DryRun, token);
        if (archivePath is null)
        {
            log.Warn($"No installable archive for: {mod.InstallName}");
            return request.DryRun;
        }

        if (mod.Sha256 is not null && !request.DryRun)
        {
            var actual = await Hash.Sha256Async(archivePath, token);
            if (!string.Equals(actual, mod.Sha256, StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException($"SHA256 mismatch for {mod.InstallName}. Expected {mod.Sha256}, got {actual}.");
            }
        }

        log.Info(request.DryRun ? $"Would extract {archivePath} -> {destination}" : $"Extracting {mod.InstallName}");
        if (!request.DryRun)
        {
            Directory.CreateDirectory(destination);
            await ArchiveExtractor.ExtractAsync(archivePath, destination, wabbajackCli, token);
            NormalizeExtractedModFolder(destination);
        }

        return true;
    }

    private static void WriteNexusMetaIni(string destination, ModEntry mod)
    {
        var modId = mod.Fields.GetValueOrDefault("mod_id");
        var fileId = mod.Fields.GetValueOrDefault("file_id");
        if (string.IsNullOrWhiteSpace(modId) || string.IsNullOrWhiteSpace(fileId))
        {
            return;
        }

        var version = mod.Fields.GetValueOrDefault("version") ?? "";
        var installationFile = mod.Fields.GetValueOrDefault("download_file") ?? mod.FileName ?? "";
        if (!string.IsNullOrWhiteSpace(installationFile))
        {
            installationFile = Path.GetFileName(installationFile.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar));
        }

        var lines = new[]
        {
            "[General]",
            "gameName=SkyrimSE",
            $"modid={modId}",
            $"version={version}",
            $"newestVersion={version}",
            "category=\"\"",
            "nexusFileStatus=1",
            $"installationFile={installationFile}",
            "repository=Nexus",
            "ignoredVersion=",
            "comments=",
            "notes=",
            "url=",
            "hasCustomURL=false",
            $"lastNexusQuery={DateTime.UtcNow:yyyy-MM-ddTHH:mm:ssZ}",
            "converted=false",
            "validated=false",
            "tracked=0",
            "endorsed=0",
            "nexusCategory=0",
            "",
            "[installedFiles]",
            $"1\\modid={modId}",
            $"1\\fileid={fileId}",
            "size=1",
            ""
        };

        File.WriteAllLines(Path.Combine(destination, "meta.ini"), lines, Encoding.UTF8);
    }

    private static void NormalizeExtractedModFolder(string destination)
    {
        var files = Directory.EnumerateFiles(destination).ToList();
        var directories = Directory.EnumerateDirectories(destination).ToList();
        if (files.Count != 0 || directories.Count != 1)
        {
            return;
        }

        var wrapper = directories[0];
        if (!LooksLikeModDataRoot(wrapper))
        {
            return;
        }

        foreach (var childFile in Directory.EnumerateFiles(wrapper))
        {
            File.Move(childFile, Path.Combine(destination, Path.GetFileName(childFile)));
        }

        foreach (var childDirectory in Directory.EnumerateDirectories(wrapper))
        {
            Directory.Move(childDirectory, Path.Combine(destination, Path.GetFileName(childDirectory)));
        }

        Directory.Delete(wrapper);
    }

    private static bool LooksLikeModDataRoot(string path)
    {
        var knownDirectories = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "CalienteTools", "Meshes", "Textures", "Scripts", "SKSE", "Interface", "Sound", "Seq", "MCM", "Fomod"
        };

        return Directory.EnumerateFiles(path, "*.esp").Any()
            || Directory.EnumerateFiles(path, "*.esm").Any()
            || Directory.EnumerateFiles(path, "*.esl").Any()
            || Directory.EnumerateFiles(path, "*.bsa").Any()
            || Directory.EnumerateDirectories(path).Select(Path.GetFileName).Any(name => name is not null && knownDirectories.Contains(name));
    }

    private async Task<string?> ResolveNexusArchiveAsync(Mo2Instance mo2, ModEntry mod, InstallRequest request, CancellationToken token)
    {
        var apiKey = request.NexusApiKey
            ?? Environment.GetEnvironmentVariable("NEXUS_API_KEY")
            ?? Environment.GetEnvironmentVariable("NEXUSMODS_API_KEY");
        var wabbajackOAuth = string.IsNullOrWhiteSpace(apiKey) ? WabbajackNexusAuth.TryLoadOAuth(request.WabbajackCli) : null;
        var bearerToken = wabbajackOAuth?.AccessToken;
        if (string.IsNullOrWhiteSpace(apiKey) && string.IsNullOrWhiteSpace(bearerToken))
        {
            log.Warn($"Nexus auth required to download: {mod.InstallName}");
            log.Warn("  Pass --nexus-api-key, set NEXUS_API_KEY, or log in through Wabbajack first.");
            return null;
        }

        var game = mod.Fields.GetValueOrDefault("game") ?? "skyrimspecialedition";
        var modId = mod.Fields.GetValueOrDefault("mod_id");
        var fileId = mod.Fields.GetValueOrDefault("file_id");
        if (string.IsNullOrWhiteSpace(modId) || string.IsNullOrWhiteSpace(fileId))
        {
            throw new FormatException($"Nexus entry requires game/mod_id/file_id: {mod.InstallName}");
        }

        var cached = FindCachedNexusArchive(mo2.DownloadSearchPaths, modId, fileId, mod.Fields.GetValueOrDefault("download_file"));
        if (cached is not null)
        {
            log.Info($"Using cached Nexus archive: {cached}");
            return cached;
        }

        var linkEndpoint = $"https://api.nexusmods.com/v1/games/{Uri.EscapeDataString(game)}/mods/{Uri.EscapeDataString(modId)}/files/{Uri.EscapeDataString(fileId)}/download_link.json";
        log.Info(request.DryRun ? $"Would request Nexus download link: mod {modId}, file {fileId}" : $"Requesting Nexus download link: mod {modId}, file {fileId}");
        if (request.DryRun)
        {
            return Path.Combine(mo2.DownloadsPath, $"nexus-{modId}-{fileId}.archive");
        }

        Directory.CreateDirectory(mo2.DownloadsPath);
        using var client = CreateNexusClient(apiKey, bearerToken);
        var linkResponse = await client.GetAsync(linkEndpoint, token);
        var linkBody = await linkResponse.Content.ReadAsStringAsync(token);
        if (linkResponse.StatusCode == System.Net.HttpStatusCode.Unauthorized &&
            string.IsNullOrWhiteSpace(apiKey) &&
            !string.IsNullOrWhiteSpace(wabbajackOAuth?.RefreshToken))
        {
            linkResponse.Dispose();
            log.Info("Wabbajack Nexus token is expired; refreshing OAuth token.");
            bearerToken = await WabbajackNexusAuth.TryRefreshAccessTokenAsync(wabbajackOAuth.RefreshToken, token);
            if (!string.IsNullOrWhiteSpace(bearerToken))
            {
                using var refreshedClient = CreateNexusClient(null, bearerToken);
                linkResponse = await refreshedClient.GetAsync(linkEndpoint, token);
                linkBody = await linkResponse.Content.ReadAsStringAsync(token);
            }
        }

        if (!linkResponse.IsSuccessStatusCode)
        {
            linkResponse.Dispose();
            if ((linkResponse.StatusCode == System.Net.HttpStatusCode.Forbidden && IsManualNexusDownloadRequired(linkBody)) ||
                (linkResponse.StatusCode == System.Net.HttpStatusCode.Unauthorized && IsExpiredNexusToken(linkBody)))
            {
                return await WaitForManualNexusDownloadAsync(mo2, mod, game, modId, fileId, request.DryRun, token);
            }

            throw new InvalidOperationException($"Nexus download-link request failed for {mod.InstallName}: {(int)linkResponse.StatusCode} {linkResponse.ReasonPhrase}{Environment.NewLine}{linkBody}");
        }

        var downloadUrl = NexusJson.FindFirstHttpUri(linkBody) ?? throw new InvalidOperationException($"Nexus did not return a download URI for {mod.InstallName}.");
        linkResponse.Dispose();
        var fileName = mod.FileName;
        log.Info($"Downloading Nexus archive for {mod.InstallName}");
        using var archiveResponse = await client.GetAsync(downloadUrl, HttpCompletionOption.ResponseHeadersRead, token);
        archiveResponse.EnsureSuccessStatusCode();
        fileName ??= TryGetContentDispositionFileName(archiveResponse) ?? Path.GetFileName(new Uri(downloadUrl).AbsolutePath);
        if (string.IsNullOrWhiteSpace(fileName))
        {
            fileName = $"nexus-{modId}-{fileId}.archive";
        }

        var archivePath = Path.Combine(mo2.DownloadsPath, SanitizeFileName(fileName));
        await using var input = await archiveResponse.Content.ReadAsStreamAsync(token);
        await using var output = File.Create(archivePath);
        await input.CopyToAsync(output, token);
        return archivePath;
    }

    private async Task<string?> WaitForManualNexusDownloadAsync(Mo2Instance mo2, ModEntry mod, string game, string modId, string fileId, bool dryRun, CancellationToken token)
    {
        var pageUrl = mod.Url ?? $"https://www.nexusmods.com/{game}/mods/{modId}?tab=files&file_id={fileId}";
        log.Warn($"Nexus requires browser/manual download for non-premium account: {mod.InstallName}");
        log.Warn($"  {pageUrl}");

        if (dryRun)
        {
            log.Info($"Would open browser and wait for archive in: {string.Join("; ", mo2.DownloadSearchPaths)}");
            return Path.Combine(mo2.DownloadsPath, $"nexus-{modId}-{fileId}.archive");
        }

        foreach (var path in mo2.DownloadSearchPaths)
        {
            Directory.CreateDirectory(path);
        }

        var waitStarted = DateTime.UtcNow;
        var before = SnapshotDownloads(mo2.DownloadSearchPaths);
        OpenUrl(pageUrl);
        log.Info($"Waiting up to 20 minutes for download to appear in: {string.Join("; ", mo2.DownloadSearchPaths)}");
        log.Info("Use the Nexus page to download the file. The installer will continue when a new complete archive appears.");

        var deadline = DateTimeOffset.UtcNow.AddMinutes(20);
        while (DateTimeOffset.UtcNow < deadline)
        {
            token.ThrowIfCancellationRequested();
            var candidate = FindNewCompleteArchive(mo2.DownloadSearchPaths, before, waitStarted);
            if (candidate is not null)
            {
                log.Info($"Detected manual download: {candidate}");
                return candidate;
            }

            await Task.Delay(TimeSpan.FromSeconds(3), token);
        }

        log.Warn($"Timed out waiting for manual Nexus download: {mod.InstallName}");
        return null;
    }

    private async Task<string?> ResolveArchiveAsync(Mo2Instance mo2, ModEntry mod, bool dryRun, CancellationToken token)
    {
        if (mod.LocalPath is not null)
        {
            var path = Path.GetFullPath(mod.LocalPath);
            if (!File.Exists(path))
            {
                throw new FileNotFoundException($"Local archive not found for {mod.InstallName}.", path);
            }

            return path;
        }

        if (mod.Url is null)
        {
            return null;
        }

        var fileName = mod.FileName ?? Path.GetFileName(new Uri(mod.Url).AbsolutePath);
        if (string.IsNullOrWhiteSpace(fileName))
        {
            fileName = $"{SafePathName(mod.InstallName)}.download";
        }

        var destination = Path.Combine(mo2.DownloadsPath, fileName);
        if (File.Exists(destination))
        {
            log.Info($"Using cached archive: {destination}");
            return destination;
        }

        log.Info(dryRun ? $"Would download {mod.Url} -> {destination}" : $"Downloading {mod.Url}");
        if (dryRun)
        {
            return destination;
        }

        Directory.CreateDirectory(mo2.DownloadsPath);
        using var client = new HttpClient();
        using var response = await client.GetAsync(mod.Url, HttpCompletionOption.ResponseHeadersRead, token);
        response.EnsureSuccessStatusCode();
        await using var input = await response.Content.ReadAsStreamAsync(token);
        await using var output = File.Create(destination);
        await input.CopyToAsync(output, token);
        return destination;
    }

    private async Task UpdateModlistAsync(string modlistPath, IReadOnlyList<ModlistEntry> desiredEntries, bool dryRun, CancellationToken token)
    {
        var lines = await File.ReadAllLinesAsync(modlistPath, token);
        var header = lines.Where(line => line.StartsWith("#", StringComparison.Ordinal)).ToList();
        var existing = lines.Where(line => !line.StartsWith("#", StringComparison.Ordinal) && !string.IsNullOrWhiteSpace(line)).ToList();
        var desiredNames = new HashSet<string>(desiredEntries.Select(entry => entry.Name), StringComparer.OrdinalIgnoreCase);
        var preserved = existing.Where(line => !desiredNames.Contains(line.TrimStart('+', '-'))).ToList();
        var desiredLines = desiredEntries.Select(entry => $"{(entry.Enabled ? "+" : "-")}{entry.Name}").ToList();
        var newLines = header.Concat(desiredLines).Concat(preserved).ToArray();

        log.Info(dryRun ? $"Would update modlist: {modlistPath}" : $"Updating modlist: {modlistPath}");
        foreach (var line in desiredLines)
        {
            log.Info($"  {line}");
        }

        if (dryRun)
        {
            return;
        }

        var backup = $"{modlistPath}.{DateTime.Now:yyyyMMdd-HHmmss}.bak";
        File.Copy(modlistPath, backup, overwrite: false);
        await File.WriteAllLinesAsync(modlistPath, newLines, Encoding.UTF8, token);
        log.Info($"Backed up original modlist: {backup}");
    }

    private static bool IsDirectDownload(string url)
    {
        if (!Uri.TryCreate(url, UriKind.Absolute, out var uri))
        {
            return false;
        }

        var extension = Path.GetExtension(uri.AbsolutePath);
        return extension.Equals(".zip", StringComparison.OrdinalIgnoreCase)
            || extension.Equals(".7z", StringComparison.OrdinalIgnoreCase)
            || extension.Equals(".rar", StringComparison.OrdinalIgnoreCase)
            || extension.Equals(".fomod", StringComparison.OrdinalIgnoreCase);
    }

    private static HttpClient CreateNexusClient(string? apiKey, string? bearerToken)
    {
        var client = new HttpClient();
        if (!string.IsNullOrWhiteSpace(apiKey))
        {
            client.DefaultRequestHeaders.TryAddWithoutValidation("apikey", apiKey);
        }
        else if (!string.IsNullOrWhiteSpace(bearerToken))
        {
            client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", bearerToken);
        }

        client.DefaultRequestHeaders.UserAgent.ParseAdd("ModGroupInstaller/0.1");
        return client;
    }

    private static bool IsManualNexusDownloadRequired(string responseBody)
    {
        return responseBody.Contains("without visting nexusmods.com", StringComparison.OrdinalIgnoreCase)
            || responseBody.Contains("without visiting nexusmods.com", StringComparison.OrdinalIgnoreCase)
            || responseBody.Contains("premium users only", StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsExpiredNexusToken(string responseBody)
    {
        return responseBody.Contains("Token has expired", StringComparison.OrdinalIgnoreCase)
            || responseBody.Contains("token is expired", StringComparison.OrdinalIgnoreCase);
    }

    private static Dictionary<string, (long Length, DateTime LastWrite)> SnapshotDownloads(IEnumerable<string> downloadPaths)
    {
        return downloadPaths
            .Where(Directory.Exists)
            .SelectMany(Directory.EnumerateFiles)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToDictionary(path => path, path =>
            {
                var info = new FileInfo(path);
                return (info.Length, info.LastWriteTimeUtc);
            }, StringComparer.OrdinalIgnoreCase);
    }

    private static string? FindNewCompleteArchive(IEnumerable<string> downloadPaths, IReadOnlyDictionary<string, (long Length, DateTime LastWrite)> before, DateTime waitStarted)
    {
        var candidates = downloadPaths
            .Where(Directory.Exists)
            .SelectMany(Directory.EnumerateFiles)
            .Where(IsArchivePath)
            .Select(path => new FileInfo(path))
            .Where(info => !before.ContainsKey(info.FullName))
            .Where(info => info.CreationTimeUtc >= waitStarted.AddSeconds(-5) || info.LastWriteTimeUtc >= waitStarted.AddSeconds(-5))
            .OrderByDescending(info => info.LastWriteTimeUtc)
            .ToList();

        foreach (var info in candidates)
        {
            if (IsFileStable(info.FullName))
            {
                return info.FullName;
            }
        }

        return null;
    }

    private static bool IsArchivePath(string path)
    {
        var extension = Path.GetExtension(path);
        return extension.Equals(".zip", StringComparison.OrdinalIgnoreCase)
            || extension.Equals(".7z", StringComparison.OrdinalIgnoreCase)
            || extension.Equals(".rar", StringComparison.OrdinalIgnoreCase)
            || extension.Equals(".fomod", StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsFileStable(string path)
    {
        try
        {
            var first = new FileInfo(path).Length;
            Thread.Sleep(1000);
            var secondInfo = new FileInfo(path);
            if (first != secondInfo.Length)
            {
                return false;
            }

            using var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read);
            return stream.Length > 0;
        }
        catch
        {
            return false;
        }
    }

    private static void OpenUrl(string url)
    {
        Process.Start(new ProcessStartInfo
        {
            FileName = url,
            UseShellExecute = true
        });
    }

    private static string? FindCachedNexusArchive(IEnumerable<string> downloadPaths, string modId, string fileId, string? downloadFile)
    {
        var expectedFileName = string.IsNullOrWhiteSpace(downloadFile) ? null : Path.GetFileName(downloadFile.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar));
        if (!string.IsNullOrWhiteSpace(expectedFileName))
        {
            var exact = downloadPaths
                .Where(Directory.Exists)
                .SelectMany(Directory.EnumerateFiles)
                .Where(IsArchivePath)
                .Where(path => Path.GetFileName(path).Equals(expectedFileName, StringComparison.OrdinalIgnoreCase))
                .OrderByDescending(File.GetLastWriteTimeUtc)
                .FirstOrDefault();

            if (exact is not null)
            {
                return exact;
            }
        }

        var idPattern = $"-{modId}-";
        var candidates = downloadPaths
            .Where(Directory.Exists)
            .SelectMany(Directory.EnumerateFiles)
            .Where(IsArchivePath)
            .Where(path =>
            {
                var name = Path.GetFileName(path);
                return name.Contains(fileId, StringComparison.OrdinalIgnoreCase) ||
                    (string.IsNullOrWhiteSpace(expectedFileName) && name.Contains(idPattern, StringComparison.OrdinalIgnoreCase));
            })
            .OrderByDescending(File.GetLastWriteTimeUtc)
            .ToList();

        return candidates.FirstOrDefault();
    }

    private static string? TryGetContentDispositionFileName(HttpResponseMessage response)
    {
        var value = response.Content.Headers.ContentDisposition?.FileNameStar ?? response.Content.Headers.ContentDisposition?.FileName;
        return value?.Trim('"');
    }

    private static string SanitizeFileName(string value)
    {
        var invalid = Path.GetInvalidFileNameChars();
        var chars = value.Select(ch => invalid.Contains(ch) ? '_' : ch).ToArray();
        return new string(chars).Trim();
    }

    private static string SafePathName(string value)
    {
        var invalid = Path.GetInvalidFileNameChars();
        var chars = value.Select(ch => invalid.Contains(ch) ? '_' : ch).ToArray();
        return new string(chars).Trim();
    }
}

internal sealed record ModlistEntry(bool Enabled, string Name);

internal sealed class Mo2Instance
{
    public required string Root { get; init; }
    public required string ModsPath { get; init; }
    public required string ProfilesPath { get; init; }
    public required string DownloadsPath { get; init; }
    public required IReadOnlyList<string> DownloadSearchPaths { get; init; }
    public required IReadOnlyList<string> Profiles { get; init; }
    public string? SelectedProfile { get; init; }

    public static Mo2Instance Load(string root)
    {
        root = Path.GetFullPath(root);
        var iniPath = Path.Combine(root, "ModOrganizer.ini");
        if (!File.Exists(Path.Combine(root, "ModOrganizer.exe")) || !File.Exists(iniPath))
        {
            throw new InvalidOperationException($"Not a portable MO2 root: {root}");
        }

        var settings = Ini.ReadFlat(iniPath);
        var profilesPath = Path.Combine(root, "profiles");
        var modsPath = Path.Combine(root, "mods");
        var mo2DownloadsPath = DecodeQtByteArray(settings.GetValueOrDefault("Settings.download_directory")) ?? Path.Combine(root, "downloads");
        var wabbajackDownloadsPath = WabbajackSettings.TryFindDownloadLocationForInstall(root);
        var downloadsPath = wabbajackDownloadsPath ?? mo2DownloadsPath;
        var downloadSearchPaths = BuildDownloadSearchPaths(downloadsPath, mo2DownloadsPath);
        var selectedProfile = DecodeQtByteArray(settings.GetValueOrDefault("General.selected_profile"));
        var profiles = Directory.Exists(profilesPath)
            ? Directory.GetDirectories(profilesPath).Select(Path.GetFileName).Where(name => !string.IsNullOrWhiteSpace(name)).Cast<string>().OrderBy(name => name).ToList()
            : [];

        if (!Directory.Exists(modsPath))
        {
            throw new InvalidOperationException($"MO2 mods directory not found: {modsPath}");
        }

        if (!Directory.Exists(profilesPath))
        {
            throw new InvalidOperationException($"MO2 profiles directory not found: {profilesPath}");
        }

        return new Mo2Instance
        {
            Root = root,
            ModsPath = modsPath,
            ProfilesPath = profilesPath,
            DownloadsPath = downloadsPath,
            DownloadSearchPaths = downloadSearchPaths,
            Profiles = profiles,
            SelectedProfile = selectedProfile
        };
    }

    private static IReadOnlyList<string> BuildDownloadSearchPaths(params string?[] primaryPaths)
    {
        var paths = new List<string>();
        foreach (var path in primaryPaths)
        {
            AddPath(path);
        }

        AddPath(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Downloads"));
        return paths;

        void AddPath(string? path)
        {
            if (string.IsNullOrWhiteSpace(path))
            {
                return;
            }

            var fullPath = Path.GetFullPath(path);
            if (!paths.Contains(fullPath, StringComparer.OrdinalIgnoreCase))
            {
                paths.Add(fullPath);
            }
        }
    }

    public static string? FindNearestRoot(string start)
    {
        var current = new DirectoryInfo(Path.GetFullPath(start));
        while (current is not null)
        {
            if (File.Exists(Path.Combine(current.FullName, "ModOrganizer.exe")) &&
                File.Exists(Path.Combine(current.FullName, "ModOrganizer.ini")) &&
                Directory.Exists(Path.Combine(current.FullName, "mods")) &&
                Directory.Exists(Path.Combine(current.FullName, "profiles")))
            {
                return current.FullName;
            }

            current = current.Parent;
        }

        return null;
    }

    private static string? DecodeQtByteArray(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        const string prefix = "@ByteArray(";
        if (value.StartsWith(prefix, StringComparison.Ordinal) && value.EndsWith(")", StringComparison.Ordinal))
        {
            return value[prefix.Length..^1].Replace(@"\\", @"\");
        }

        return value;
    }
}

internal static class Ini
{
    public static Dictionary<string, string> ReadFlat(string path)
    {
        var result = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        var section = "";
        foreach (var rawLine in File.ReadLines(path))
        {
            var line = rawLine.Trim();
            if (line.Length == 0 || line.StartsWith(";", StringComparison.Ordinal) || line.StartsWith("#", StringComparison.Ordinal))
            {
                continue;
            }

            if (line.StartsWith("[", StringComparison.Ordinal) && line.EndsWith("]", StringComparison.Ordinal))
            {
                section = line[1..^1];
                continue;
            }

            var equals = line.IndexOf('=');
            if (equals <= 0)
            {
                continue;
            }

            result[$"{section}.{line[..equals]}"] = line[(equals + 1)..];
        }

        return result;
    }
}

internal static class WabbajackSettings
{
    public static string? TryFindDownloadLocationForInstall(string installRoot)
    {
        try
        {
            var settingsDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Wabbajack", "saved_settings");
            if (!Directory.Exists(settingsDir))
            {
                return null;
            }

            var normalizedInstallRoot = NormalizePath(installRoot);
            return Directory.EnumerateFiles(settingsDir, "install-settings-*.json")
                .Select(path => TryReadInstallSettings(path))
                .Where(settings => settings is not null)
                .Cast<WabbajackInstallSettings>()
                .Where(settings => NormalizePath(settings.InstallLocation) == normalizedInstallRoot)
                .OrderByDescending(settings => settings.LastWriteTimeUtc)
                .Select(settings => settings.DownloadLocation)
                .FirstOrDefault(path => !string.IsNullOrWhiteSpace(path));
        }
        catch
        {
            return null;
        }
    }

    private static WabbajackInstallSettings? TryReadInstallSettings(string path)
    {
        try
        {
            using var document = JsonDocument.Parse(File.ReadAllText(path));
            var root = document.RootElement;
            if (!root.TryGetProperty("InstallLocation", out var installLocation) ||
                !root.TryGetProperty("DownloadLocation", out var downloadLocation))
            {
                return null;
            }

            return new WabbajackInstallSettings(
                installLocation.GetString() ?? "",
                downloadLocation.GetString() ?? "",
                File.GetLastWriteTimeUtc(path));
        }
        catch
        {
            return null;
        }
    }

    private static string NormalizePath(string path)
    {
        return Path.GetFullPath(path).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar).ToUpperInvariant();
    }

    private sealed record WabbajackInstallSettings(string InstallLocation, string DownloadLocation, DateTime LastWriteTimeUtc);
}

internal enum ModSource
{
    Local,
    Manual,
    Discord,
    Nexus,
    LoversLab
}

internal abstract record ManifestEntry;
internal sealed record SeparatorEntry(string Name) : ManifestEntry;
internal sealed record ModEntry(
    bool Enabled,
    ModSource Source,
    string InstallName,
    string? Url,
    string? LocalPath,
    string? FileName,
    string? Sha256,
    IReadOnlyDictionary<string, string> Fields) : ManifestEntry
{
    public string Describe() => string.Join(" ", Fields.Select(pair => $"{pair.Key}={pair.Value}"));
}

internal static class ManifestParser
{
    public static IReadOnlyList<ManifestEntry> ParseFile(string path)
    {
        if (!File.Exists(path))
        {
            throw new FileNotFoundException("Manifest file not found.", path);
        }

        var lines = File.ReadAllLines(path);
        var extension = Path.GetExtension(path);
        var firstContentLine = lines.FirstOrDefault(line => !string.IsNullOrWhiteSpace(line)) ?? "";
        if (extension.Equals(".csv", StringComparison.OrdinalIgnoreCase) || LooksLikeCsvManifest(firstContentLine))
        {
            return ParseCsv(lines);
        }

        return lines
            .Select((line, index) => ParseLine(line, index + 1))
            .Where(entry => entry is not null)
            .Cast<ManifestEntry>()
            .ToList();
    }

    private static ManifestEntry? ParseLine(string line, int lineNumber)
    {
        line = StripComment(line).Trim();
        if (string.IsNullOrWhiteSpace(line))
        {
            return null;
        }

        var tokens = Tokenize(line);
        if (tokens.Count == 0)
        {
            return null;
        }

        if (tokens[0].Equals("separator", StringComparison.OrdinalIgnoreCase))
        {
            if (tokens.Count < 2)
            {
                throw new FormatException($"Line {lineNumber}: separator requires a name.");
            }

            return new SeparatorEntry(tokens[1]);
        }

        var enabled = tokens[0] switch
        {
            "+" => true,
            "-" => false,
            _ => throw new FormatException($"Line {lineNumber}: expected '+' or '-'.")
        };

        if (tokens.Count < 2)
        {
            throw new FormatException($"Line {lineNumber}: missing source.");
        }

        var source = ParseSource(tokens[1], lineNumber);
        var fields = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        var positionals = new List<string>();
        for (var i = 2; i < tokens.Count; i++)
        {
            var token = tokens[i];
            var equals = token.IndexOf('=');
            if (equals > 0)
            {
                fields[token[..equals]] = token[(equals + 1)..].Trim('"');
            }
            else
            {
                positionals.Add(token);
            }
        }

        var installName = Get(fields, "install") ?? Get(fields, "name") ?? positionals.LastOrDefault();
        if (string.IsNullOrWhiteSpace(installName))
        {
            throw new FormatException($"Line {lineNumber}: mod entry requires install=\"...\".");
        }

        var url = Get(fields, "url");
        var localPath = Get(fields, "path");
        if (source == ModSource.Local && localPath is null && positionals.Count > 0)
        {
            localPath = positionals[0];
        }

        if (source == ModSource.Nexus)
        {
            if (positionals.Count > 0) fields.TryAdd("game", positionals[0]);
            if (positionals.Count > 1) fields.TryAdd("mod_id", positionals[1]);
        }

        return new ModEntry(enabled, source, installName, url, localPath, Get(fields, "file"), Get(fields, "sha256"), fields);
    }

    private static IReadOnlyList<ManifestEntry> ParseCsv(string[] lines)
    {
        if (lines.Length == 0)
        {
            return [];
        }

        var headers = SplitCsv(lines[0]);
        var entries = new List<ManifestEntry>();
        foreach (var line in lines.Skip(1))
        {
            if (string.IsNullOrWhiteSpace(line))
            {
                continue;
            }

            var values = SplitCsv(line);
            var row = headers.Select((header, index) => new { header, value = index < values.Count ? values[index] : "" })
                .ToDictionary(pair => pair.header, pair => pair.value, StringComparer.OrdinalIgnoreCase);
            var name = First(row, "ModName", "#Mod_Name", "SharedMod", "LocalMatch");
            if (string.IsNullOrWhiteSpace(name))
            {
                continue;
            }

            if (name.EndsWith("_separator", StringComparison.OrdinalIgnoreCase))
            {
                entries.Add(new SeparatorEntry(name[..^10]));
                continue;
            }

            var status = First(row, "Status", "Mod_Status", "#Mod_Status", "LocalProfileStatus");
            var enabled = !status.StartsWith("-", StringComparison.Ordinal) && !status.Contains("disabled", StringComparison.OrdinalIgnoreCase);
            var nexusId = First(row, "NexusID", "NexusId");
            var url = First(row, "NexusURL", "Url");
            var source = string.IsNullOrWhiteSpace(nexusId) && string.IsNullOrWhiteSpace(url) ? ModSource.Manual : ModSource.Nexus;
            var fields = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                ["mod_id"] = nexusId,
                ["version"] = First(row, "Version"),
                ["download_file"] = First(row, "DownloadFile")
            };
            entries.Add(new ModEntry(enabled, source, name, string.IsNullOrWhiteSpace(url) ? null : url, null, First(row, "DownloadFile"), null, fields));
        }

        return entries;
    }

    private static ModSource ParseSource(string value, int lineNumber)
    {
        return value.ToLowerInvariant() switch
        {
            "local" => ModSource.Local,
            "manual" => ModSource.Manual,
            "discord" => ModSource.Discord,
            "nexus" => ModSource.Nexus,
            "loverslab" or "ll" => ModSource.LoversLab,
            _ => throw new FormatException($"Line {lineNumber}: unknown source '{value}'.")
        };
    }

    private static bool LooksLikeCsvManifest(string firstContentLine)
    {
        if (!firstContentLine.Contains(',', StringComparison.Ordinal))
        {
            return false;
        }

        return firstContentLine.Contains("ModName", StringComparison.OrdinalIgnoreCase)
            || firstContentLine.Contains("Mod_Name", StringComparison.OrdinalIgnoreCase)
            || firstContentLine.Contains("SharedMod", StringComparison.OrdinalIgnoreCase);
    }

    private static string? Get(Dictionary<string, string> fields, string key) => fields.TryGetValue(key, out var value) && !string.IsNullOrWhiteSpace(value) ? value : null;

    private static string First(IReadOnlyDictionary<string, string> row, params string[] names)
    {
        foreach (var name in names)
        {
            if (row.TryGetValue(name, out var value))
            {
                return value.Trim();
            }
        }

        return "";
    }

    private static string StripComment(string line)
    {
        var inQuote = false;
        for (var i = 0; i < line.Length; i++)
        {
            if (line[i] == '"')
            {
                inQuote = !inQuote;
            }
            else if (line[i] == '#' && !inQuote)
            {
                return line[..i];
            }
        }

        return line;
    }

    private static List<string> Tokenize(string line)
    {
        var matches = Regex.Matches(line, @"([^\s""]+=""[^""]*"")|""([^""]*)""|(\S+)");
        return matches.Select(match =>
        {
            if (match.Groups[1].Success)
            {
                return match.Groups[1].Value;
            }

            return match.Groups[2].Success ? match.Groups[2].Value : match.Groups[3].Value;
        }).ToList();
    }

    private static List<string> SplitCsv(string line)
    {
        var result = new List<string>();
        var current = new StringBuilder();
        var inQuote = false;
        for (var i = 0; i < line.Length; i++)
        {
            var ch = line[i];
            if (ch == '"' && i + 1 < line.Length && line[i + 1] == '"')
            {
                current.Append('"');
                i++;
            }
            else if (ch == '"')
            {
                inQuote = !inQuote;
            }
            else if (ch == ',' && !inQuote)
            {
                result.Add(current.ToString());
                current.Clear();
            }
            else
            {
                current.Append(ch);
            }
        }

        result.Add(current.ToString());
        return result;
    }
}

internal static class ArchiveExtractor
{
    public static async Task ExtractAsync(string archive, string destination, string? wabbajackCli, CancellationToken token)
    {
        if (wabbajackCli is not null && File.Exists(wabbajackCli))
        {
            await RunWabbajackExtractAsync(wabbajackCli, archive, destination, token);
            return;
        }

        if (Path.GetExtension(archive).Equals(".zip", StringComparison.OrdinalIgnoreCase))
        {
            ZipFile.ExtractToDirectory(archive, destination, overwriteFiles: true);
            return;
        }

        throw new InvalidOperationException($"Cannot extract {archive}. Configure Wabbajack CLI for non-ZIP archives.");
    }

    private static async Task RunWabbajackExtractAsync(string cli, string archive, string destination, CancellationToken token)
    {
        var start = new ProcessStartInfo
        {
            UseShellExecute = false,
            RedirectStandardError = true,
            RedirectStandardOutput = true
        };

        if (Path.GetExtension(cli).Equals(".bat", StringComparison.OrdinalIgnoreCase) || Path.GetExtension(cli).Equals(".cmd", StringComparison.OrdinalIgnoreCase))
        {
            start.FileName = Environment.GetEnvironmentVariable("COMSPEC") ?? "cmd.exe";
            start.ArgumentList.Add("/c");
            start.ArgumentList.Add(cli);
        }
        else
        {
            start.FileName = cli;
        }

        start.ArgumentList.Add("extract");
        start.ArgumentList.Add("--input");
        start.ArgumentList.Add(archive);
        start.ArgumentList.Add("--output");
        start.ArgumentList.Add(destination);

        using var process = Process.Start(start) ?? throw new InvalidOperationException("Failed to start Wabbajack CLI.");
        var outputTask = process.StandardOutput.ReadToEndAsync(token);
        var errorTask = process.StandardError.ReadToEndAsync(token);
        await process.WaitForExitAsync(token);
        if (process.ExitCode != 0)
        {
            var output = await outputTask;
            var error = await errorTask;
            throw new InvalidOperationException($"Wabbajack extraction failed with exit code {process.ExitCode}.{Environment.NewLine}{output}{Environment.NewLine}{error}");
        }
    }
}

internal static class WabbajackCli
{
    public static string? FindDefault(string mo2Root)
    {
        var candidates = new[]
        {
            Path.Combine(mo2Root, "..", "wabbajack", "wabbajack-cli.bat"),
            Path.Combine(mo2Root, "..", "Wabbajack", "wabbajack-cli.bat"),
            Path.Combine(mo2Root, "..", "wabbajack", "4.2.1.4", "wabbajack-cli.exe"),
            Path.Combine(mo2Root, "..", "Wabbajack", "4.2.1.4", "wabbajack-cli.exe")
        };

        return candidates.Select(Path.GetFullPath).FirstOrDefault(File.Exists);
    }
}

internal static class WabbajackNexusAuth
{
    public static WabbajackOAuth? TryLoadOAuth(string? wabbajackCli)
    {
        try
        {
            var servicesDll = FindServicesDll(wabbajackCli);
            if (servicesDll is null)
            {
                return null;
            }

            var encryptedPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Wabbajack", "encrypted", "nexus-oauth-info");
            if (!File.Exists(encryptedPath))
            {
                return null;
            }

            var wabbajackDir = Path.GetDirectoryName(servicesDll)!;
            var loadContext = new AssemblyLoadContext("WabbajackAuthReader", isCollectible: true);
            loadContext.Resolving += (_, name) =>
            {
                var dll = Path.Combine(wabbajackDir, name.Name + ".dll");
                return File.Exists(dll) ? loadContext.LoadFromAssemblyPath(dll) : null;
            };

            try
            {
                var assembly = loadContext.LoadFromAssemblyPath(servicesDll);
                var protectedData = assembly.GetType("Wabbajack.Services.OSIntegrated.ProtectedData");
                var unprotect = protectedData?.GetMethod("UnProtect", BindingFlags.Public | BindingFlags.Static);
                if (unprotect is null)
                {
                    return null;
                }

                using var input = File.OpenRead(encryptedPath);
                var valueTask = unprotect.Invoke(null, [input, "nexus-oauth-info"]);
                if (valueTask is null)
                {
                    return null;
                }

                var asTask = valueTask.GetType().GetMethod("AsTask", BindingFlags.Public | BindingFlags.Instance);
                var task = asTask?.Invoke(valueTask, null) as Task<Stream>;
                if (task is null)
                {
                    return null;
                }

                using var decrypted = task.GetAwaiter().GetResult();
                using var reader = new StreamReader(decrypted, Encoding.UTF8);
                var json = reader.ReadToEnd();
                using var document = JsonDocument.Parse(json);
                if (document.RootElement.TryGetProperty("oauth", out var oauth) &&
                    oauth.TryGetProperty("access_token", out var accessToken) &&
                    accessToken.ValueKind == JsonValueKind.String)
                {
                    var refreshToken = oauth.TryGetProperty("refresh_token", out var refresh) && refresh.ValueKind == JsonValueKind.String
                        ? refresh.GetString()
                        : null;
                    return new WabbajackOAuth(accessToken.GetString(), refreshToken);
                }

                return null;
            }
            finally
            {
                loadContext.Unload();
            }
        }
        catch
        {
            return null;
        }
    }

    public static async Task<string?> TryRefreshAccessTokenAsync(string refreshToken, CancellationToken token)
    {
        try
        {
            using var client = new HttpClient();
            client.DefaultRequestHeaders.UserAgent.ParseAdd("ModGroupInstaller/0.1");
            using var content = new FormUrlEncodedContent(new Dictionary<string, string>
            {
                ["grant_type"] = "refresh_token",
                ["refresh_token"] = refreshToken,
                ["client_id"] = "wabbajack"
            });

            using var response = await client.PostAsync("https://users.nexusmods.com/oauth/token", content, token);
            var body = await response.Content.ReadAsStringAsync(token);
            if (!response.IsSuccessStatusCode)
            {
                return null;
            }

            using var document = JsonDocument.Parse(body);
            return document.RootElement.TryGetProperty("access_token", out var accessToken) && accessToken.ValueKind == JsonValueKind.String
                ? accessToken.GetString()
                : null;
        }
        catch
        {
            return null;
        }
    }

    private static string? FindServicesDll(string? wabbajackCli)
    {
        var candidates = new List<string>();
        if (!string.IsNullOrWhiteSpace(wabbajackCli))
        {
            var cliPath = Path.GetFullPath(wabbajackCli);
            var dir = Path.GetDirectoryName(cliPath);
            if (dir is not null)
            {
                candidates.Add(Path.Combine(dir, "Wabbajack.Services.OSIntegrated.dll"));
                candidates.AddRange(Directory.Exists(dir)
                    ? Directory.GetDirectories(dir).Select(path => Path.Combine(path, "Wabbajack.Services.OSIntegrated.dll"))
                    : []);
            }
        }

        var defaultRoot = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), "..", "wabbajack"));
        if (Directory.Exists(defaultRoot))
        {
            candidates.Add(Path.Combine(defaultRoot, "Wabbajack.Services.OSIntegrated.dll"));
            candidates.AddRange(Directory.GetDirectories(defaultRoot).Select(path => Path.Combine(path, "Wabbajack.Services.OSIntegrated.dll")));
        }

        var localRoot = Path.Combine(Path.GetPathRoot(Environment.CurrentDirectory) ?? "C:\\", "Games", "wabbajack");
        if (Directory.Exists(localRoot))
        {
            candidates.AddRange(Directory.GetDirectories(localRoot).Select(path => Path.Combine(path, "Wabbajack.Services.OSIntegrated.dll")));
        }

        return candidates
            .Where(File.Exists)
            .OrderByDescending(path => File.GetLastWriteTimeUtc(path))
            .FirstOrDefault();
    }
}

internal sealed record WabbajackOAuth(string? AccessToken, string? RefreshToken);

internal static class NexusJson
{
    public static string? FindFirstHttpUri(string json)
    {
        using var document = JsonDocument.Parse(json);
        return FindFirstHttpUri(document.RootElement);
    }

    private static string? FindFirstHttpUri(JsonElement element)
    {
        switch (element.ValueKind)
        {
            case JsonValueKind.Object:
                foreach (var property in element.EnumerateObject())
                {
                    if ((property.NameEquals("URI") || property.NameEquals("uri") || property.NameEquals("url")) &&
                        property.Value.ValueKind == JsonValueKind.String)
                    {
                        var value = property.Value.GetString();
                        if (value is not null && value.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                        {
                            return value;
                        }
                    }

                    var nested = FindFirstHttpUri(property.Value);
                    if (nested is not null)
                    {
                        return nested;
                    }
                }

                break;
            case JsonValueKind.Array:
                foreach (var item in element.EnumerateArray())
                {
                    var nested = FindFirstHttpUri(item);
                    if (nested is not null)
                    {
                        return nested;
                    }
                }

                break;
        }

        return null;
    }
}

internal static class Hash
{
    public static async Task<string> Sha256Async(string path, CancellationToken token)
    {
        await using var stream = File.OpenRead(path);
        var hash = await SHA256.HashDataAsync(stream, token);
        return Convert.ToHexString(hash).ToLowerInvariant();
    }
}

internal interface IInstallLog
{
    void Info(string message);
    void Warn(string message);
}

internal sealed class ConsoleInstallLog : IInstallLog
{
    public void Info(string message) => Console.WriteLine(message);
    public void Warn(string message) => Console.WriteLine("WARN: " + message);
}

internal sealed class TextBoxInstallLog(TextBox textBox) : IInstallLog
{
    public void Info(string message) => Append(message);
    public void Warn(string message) => Append("WARN: " + message);

    private void Append(string message)
    {
        if (textBox.InvokeRequired)
        {
            textBox.Invoke(() => Append(message));
            return;
        }

        textBox.AppendText(message + Environment.NewLine);
    }
}
