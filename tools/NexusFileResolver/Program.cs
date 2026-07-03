using System.Globalization;
using System.Net.Http.Headers;
using System.Reflection;
using System.Runtime.Loader;
using System.Text;
using System.Text.Json;

var options = Options.Parse(args);
if (options.ShowHelp)
{
    Console.WriteLine("""
NexusFileResolver

Resolves Nexus file IDs from ModListCompare comparison.csv rows.

Usage:
  NexusFileResolver --comparison <comparison.csv> --bucket <bucket> --out <manifest.mods.txt> [--wabbajack <wabbajack-cli>]
""");
    return 0;
}

var rows = Csv.Read(options.ComparisonPath)
    .Where(row => row.Get("Bucket").Equals(options.Bucket, StringComparison.OrdinalIgnoreCase))
    .Where(row => row.Get("Status").StartsWith("Missing", StringComparison.OrdinalIgnoreCase))
    .ToList();

using var client = new HttpClient();
var auth = WabbajackNexusAuth.TryLoadOAuth(options.WabbajackPath);
var apiKey = Environment.GetEnvironmentVariable("NEXUS_API_KEY") ?? Environment.GetEnvironmentVariable("NEXUSMODS_API_KEY");
var token = auth?.AccessToken;
AddNexusHeaders(client, token, apiKey);

var cache = new Dictionary<string, JsonElement[]>(StringComparer.OrdinalIgnoreCase);
var output = new StringBuilder();
var resolved = 0;
var local = 0;
var unresolved = 0;

output.AppendLine($"separator \"{options.Bucket}\"");

foreach (var row in rows)
{
    var installName = row.Get("SourceMod");
    var archivePath = row.Get("ArchivePath");
    if (!string.IsNullOrWhiteSpace(archivePath))
    {
        output.AppendLine($"+ local path=\"{archivePath}\" install=\"{Escape(installName)}\"");
        local++;
        continue;
    }

    var nexusId = row.Get("NexusID");
    var nexusUrl = row.Get("NexusURL");
    var expectedFile = ExpectedFileName(row.Get("DownloadFile"));
    if (!long.TryParse(nexusId, NumberStyles.Integer, CultureInfo.InvariantCulture, out var modId) || modId <= 0)
    {
        WriteUnresolved(output, row, "missing Nexus mod id");
        unresolved++;
        continue;
    }

    if (!cache.TryGetValue(nexusId, out var files))
    {
        files = await GetFiles(client, modId);
        if (files.Length == 0 && !string.IsNullOrWhiteSpace(auth?.RefreshToken))
        {
            var refreshed = await WabbajackNexusAuth.TryRefreshAccessTokenAsync(auth.RefreshToken, CancellationToken.None);
            if (!string.IsNullOrWhiteSpace(refreshed))
            {
                token = refreshed;
                client.DefaultRequestHeaders.Clear();
                AddNexusHeaders(client, token, apiKey);
                files = await GetFiles(client, modId);
            }
        }

        cache[nexusId] = files;
    }

    var match = FindBestFile(files, installName, expectedFile);
    if (match is not null && match.Score >= 0.90)
    {
        var fileId = match.File.GetProperty("file_id").GetInt32();
        var url = string.IsNullOrWhiteSpace(nexusUrl)
            ? $"https://www.nexusmods.com/skyrimspecialedition/mods/{modId}?tab=files&file_id={fileId}"
            : $"{nexusUrl}?tab=files&file_id={fileId}";
        var downloadFileField = string.IsNullOrWhiteSpace(expectedFile) ? "" : $" download_file=\"{Escape(expectedFile)}\"";
        output.AppendLine($"+ nexus skyrimspecialedition {modId} file_id={fileId} url=\"{url}\" install=\"{Escape(installName)}\"{downloadFileField}");
        resolved++;
        continue;
    }

    WriteUnresolved(output, row, match is null ? "no files returned by Nexus" : $"best API match score {match.Score:0.000}");
    if (match is not null)
    {
        output.AppendLine($"# best candidate file_id={match.File.GetProperty("file_id").GetInt32()}: {match.File.GetProperty("file_name").GetString()}");
    }
    unresolved++;
}

Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(options.OutPath))!);
await File.WriteAllTextAsync(options.OutPath, output.ToString(), Encoding.UTF8);

Console.WriteLine($"Rows: {rows.Count}");
Console.WriteLine($"Local archive entries: {local}");
Console.WriteLine($"Resolved Nexus entries: {resolved}");
Console.WriteLine($"Unresolved entries: {unresolved}");
Console.WriteLine($"Output: {Path.GetFullPath(options.OutPath)}");
return 0;

static async Task<JsonElement[]> GetFiles(HttpClient client, long modId)
{
    using var response = await client.GetAsync($"https://api.nexusmods.com/v1/games/skyrimspecialedition/mods/{modId}/files.json");
    if (!response.IsSuccessStatusCode)
    {
        Console.Error.WriteLine($"Nexus files request failed for mod {modId}: {(int)response.StatusCode} {response.ReasonPhrase}");
        return [];
    }

    await using var stream = await response.Content.ReadAsStreamAsync();
    using var document = await JsonDocument.ParseAsync(stream);
    if (!document.RootElement.TryGetProperty("files", out var files) || files.ValueKind != JsonValueKind.Array)
    {
        return [];
    }

    return files.EnumerateArray().Select(file => file.Clone()).ToArray();
}

static FileMatch? FindBestFile(JsonElement[] files, string installName, string expectedFile)
{
    FileMatch? best = null;
    foreach (var file in files)
    {
        var fileName = file.TryGetProperty("file_name", out var fileNameElement) ? fileNameElement.GetString() ?? "" : "";
        var displayName = file.TryGetProperty("name", out var nameElement) ? nameElement.GetString() ?? "" : "";

        var score = Math.Max(Score(expectedFile, fileName), Score(installName, displayName));
        score = Math.Max(score, Score(Path.GetFileNameWithoutExtension(expectedFile), Path.GetFileNameWithoutExtension(fileName)));
        if (best is null || score > best.Score)
        {
            best = new FileMatch(file, score);
        }
    }

    return best;
}

static double Score(string a, string b)
{
    var na = Normalize(a);
    var nb = Normalize(b);
    if (string.IsNullOrWhiteSpace(na) || string.IsNullOrWhiteSpace(nb))
    {
        return 0;
    }

    if (na.Equals(nb, StringComparison.OrdinalIgnoreCase))
    {
        return 1;
    }

    var aTokens = na.Split(' ', StringSplitOptions.RemoveEmptyEntries).ToHashSet(StringComparer.OrdinalIgnoreCase);
    var bTokens = nb.Split(' ', StringSplitOptions.RemoveEmptyEntries).ToHashSet(StringComparer.OrdinalIgnoreCase);
    var overlap = aTokens.Intersect(bTokens, StringComparer.OrdinalIgnoreCase).Count() / (double)Math.Max(aTokens.Count, bTokens.Count);
    var sequence = SequenceRatio(na, nb);
    return Math.Max(overlap, sequence);
}

static string Normalize(string value)
{
    value = Path.GetFileName(value.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar));
    value = Path.GetFileNameWithoutExtension(value).ToLowerInvariant();
    value = System.Text.RegularExpressions.Regex.Replace(value, @"\b(skyrim|special|edition|sse|se|ae|cbbe|3ba|bhunp|bodyslide|main|file)\b", " ");
    value = System.Text.RegularExpressions.Regex.Replace(value, @"\b\d{5,}\b", " ");
    value = System.Text.RegularExpressions.Regex.Replace(value, @"[^a-z0-9]+", " ");
    return System.Text.RegularExpressions.Regex.Replace(value, @"\s+", " ").Trim();
}

static double SequenceRatio(string a, string b)
{
    var previous = new int[b.Length + 1];
    var current = new int[b.Length + 1];
    for (var i = 1; i <= a.Length; i++)
    {
        for (var j = 1; j <= b.Length; j++)
        {
            current[j] = a[i - 1] == b[j - 1] ? previous[j - 1] + 1 : Math.Max(previous[j], current[j - 1]);
        }
        (previous, current) = (current, previous);
        Array.Clear(current);
    }

    return (2.0 * previous[b.Length]) / (a.Length + b.Length);
}

static string ExpectedFileName(string value)
{
    if (string.IsNullOrWhiteSpace(value))
    {
        return "";
    }

    value = value.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);
    return Path.GetFileName(value);
}

static void WriteUnresolved(StringBuilder output, CsvRow row, string reason)
{
    if (!string.IsNullOrWhiteSpace(row.Get("NexusURL")))
    {
        output.AppendLine($"# nexus page: {row.Get("NexusURL")}");
    }
    if (!string.IsNullOrWhiteSpace(row.Get("DownloadFile")))
    {
        output.AppendLine($"# expected archive: {row.Get("DownloadFile")}");
    }
    output.AppendLine($"# unresolved ({reason}): {row.Get("SourceMod")} ({row.Get("Category")})");
}

static string Escape(string value) => value.Replace("\\", "\\\\").Replace("\"", "\\\"");

static void AddNexusHeaders(HttpClient client, string? token, string? apiKey)
{
    if (!string.IsNullOrWhiteSpace(apiKey))
    {
        client.DefaultRequestHeaders.Add("apikey", apiKey);
    }
    else if (!string.IsNullOrWhiteSpace(token))
    {
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
    }
    else
    {
        throw new InvalidOperationException("Missing Nexus auth. Set NEXUS_API_KEY or log into Nexus through Wabbajack.");
    }

    client.DefaultRequestHeaders.UserAgent.ParseAdd("NexusFileResolver/0.1");
    client.DefaultRequestHeaders.Add("Application-Name", "NexusFileResolver");
    client.DefaultRequestHeaders.Add("Application-Version", "0.1");
    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
}

internal sealed record FileMatch(JsonElement File, double Score);

internal sealed class Options
{
    public string ComparisonPath { get; private init; } = "";
    public string Bucket { get; private init; } = "";
    public string OutPath { get; private init; } = "";
    public string? WabbajackPath { get; private init; }
    public bool ShowHelp { get; private init; }

    public static Options Parse(string[] args)
    {
        var options = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        for (var i = 0; i < args.Length; i++)
        {
            if (args[i] is "--help" or "-h")
            {
                return new Options { ShowHelp = true };
            }
            if (!args[i].StartsWith("--", StringComparison.Ordinal))
            {
                continue;
            }
            if (i + 1 >= args.Length)
            {
                throw new ArgumentException($"Missing value for {args[i]}");
            }
            options[args[i]] = args[++i];
        }

        return new Options
        {
            ComparisonPath = Require(options, "--comparison"),
            Bucket = Require(options, "--bucket"),
            OutPath = Require(options, "--out"),
            WabbajackPath = options.GetValueOrDefault("--wabbajack")
        };
    }

    private static string Require(Dictionary<string, string> options, string key)
    {
        if (!options.TryGetValue(key, out var value) || string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException($"{key} is required.");
        }
        return value;
    }
}

internal sealed class CsvRow(Dictionary<string, string> values)
{
    public string Get(string key) => values.GetValueOrDefault(key, "");
}

internal static class Csv
{
    public static IReadOnlyList<CsvRow> Read(string path)
    {
        var lines = File.ReadAllLines(path, Encoding.UTF8);
        if (lines.Length == 0)
        {
            return [];
        }

        var headers = Split(lines[0]);
        return lines.Skip(1)
            .Where(line => !string.IsNullOrWhiteSpace(line))
            .Select(line => Split(line))
            .Select(values => headers.Select((header, index) => new { header, value = index < values.Count ? values[index] : "" })
                .ToDictionary(pair => pair.header, pair => pair.value, StringComparer.OrdinalIgnoreCase))
            .Select(row => new CsvRow(row))
            .ToList();
    }

    private static List<string> Split(string line)
    {
        var result = new List<string>();
        var current = new StringBuilder();
        var quoted = false;
        for (var i = 0; i < line.Length; i++)
        {
            var ch = line[i];
            if (ch == '"')
            {
                if (quoted && i + 1 < line.Length && line[i + 1] == '"')
                {
                    current.Append('"');
                    i++;
                }
                else
                {
                    quoted = !quoted;
                }
            }
            else if (ch == ',' && !quoted)
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
                using var document = JsonDocument.Parse(reader.ReadToEnd());
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
            client.DefaultRequestHeaders.UserAgent.ParseAdd("NexusFileResolver/0.1");
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
                Console.Error.WriteLine($"Nexus token refresh failed: {(int)response.StatusCode} {response.ReasonPhrase}");
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
