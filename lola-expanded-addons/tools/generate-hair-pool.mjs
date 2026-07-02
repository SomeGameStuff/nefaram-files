import fs from "node:fs";
import path from "node:path";

const root = process.argv[2] ?? "C:/Games/nefaram";
const profile = process.argv[3] ?? "NEFARAM";
const outPath = process.argv[4] ??
  path.join(root, "mods", "Lola Expanded Addons", "SKSE", "Plugins", "LolaExpandedAddons", "HairPool.json");

const pluginPattern = /hair|ks|dint|xing|fuse|hhairstyles|bdor|laezel|nefaram_hair/i;

function readActivePlugins() {
  const pluginsPath = path.join(root, "profiles", profile, "plugins.txt");
  return fs.readFileSync(pluginsPath, "utf8")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.startsWith("*"))
    .map((line) => line.slice(1))
    .filter((name) => pluginPattern.test(name));
}

function walk(dir, found = new Map()) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(full, found);
    } else if (/\.(esm|esp|esl)$/i.test(entry.name)) {
      const key = entry.name.toLowerCase();
      if (!found.has(key)) {
        found.set(key, full);
      }
    }
  }
  return found;
}

function u32(buf, offset) {
  return buf.readUInt32LE(offset);
}

function str(buf, offset, length) {
  return buf.toString("ascii", offset, offset + length);
}

function readZString(buf, offset, length) {
  return buf.toString("utf8", offset, offset + length).replace(/\0.*$/, "");
}

function parseHeadParts(pluginName, pluginPath) {
  const buf = fs.readFileSync(pluginPath);
  const records = [];

  function parseRange(start, end) {
    let offset = start;
    while (offset + 24 <= end) {
      const type = str(buf, offset, 4);
      const size = u32(buf, offset + 4);
      if (type === "GRUP") {
        if (size < 24 || offset + size > buf.length) {
          break;
        }
        parseRange(offset + 24, offset + size);
        offset += size;
        continue;
      }

      if (offset + 24 + size > buf.length) {
        offset += 1;
        continue;
      }

      if (type === "HDPT") {
        const form = u32(buf, offset + 12);
        const dataStart = offset + 24;
        const dataEnd = dataStart + size;
        let edid = "";
        let full = "";
        let headPartType = -1;

        let subOffset = dataStart;
        while (subOffset + 6 <= dataEnd) {
          const subType = str(buf, subOffset, 4);
          const subSize = buf.readUInt16LE(subOffset + 4);
          const valueOffset = subOffset + 6;
          if (valueOffset + subSize > dataEnd) {
            break;
          }
          if (subType === "EDID") {
            edid = readZString(buf, valueOffset, subSize);
          } else if (subType === "FULL") {
            full = readZString(buf, valueOffset, subSize);
          } else if (subType === "PNAM" && subSize >= 4) {
            headPartType = buf.readUInt32LE(valueOffset);
          }
          subOffset = valueOffset + subSize;
        }

        const baseName = (full || edid).trim();
        if (baseName && headPartType === 3) {
          records.push({
            name: baseName,
            plugin: pluginName,
            formId: form & 0x00ffffff,
            edid,
          });
        }
      }

      offset += 24 + size;
    }
  }

  parseRange(0, buf.length);
  return records;
}

const activePlugins = readActivePlugins();
const pluginFiles = walk(path.join(root, "mods"));
const usedNames = new Set();
const names = [];
const plugins = [];
const formIds = [];
const sources = [];

for (const plugin of activePlugins) {
  const pluginPath = pluginFiles.get(plugin.toLowerCase());
  if (!pluginPath) {
    continue;
  }

  const records = parseHeadParts(plugin, pluginPath);
  for (const record of records) {
    let displayName = record.name;
    if (usedNames.has(displayName.toLowerCase()) && record.edid) {
      displayName = `${record.name} (${record.edid})`;
    }
    if (usedNames.has(displayName.toLowerCase())) {
      displayName = `${record.name} [${record.plugin}:${record.formId.toString(16).padStart(6, "0")}]`;
    }
    if (usedNames.has(displayName.toLowerCase())) {
      continue;
    }
    usedNames.add(displayName.toLowerCase());
    names.push(displayName);
    plugins.push(record.plugin);
    formIds.push(record.formId);
    sources.push(`${record.plugin}|0x${record.formId.toString(16).padStart(6, "0")}|${record.edid}`);
  }
}

const output = {
  generatedBy: "Lola Expanded Addons hair pool generator",
  generatedFromProfile: profile,
  names,
  plugins,
  formIds,
  sources,
};

fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, `${JSON.stringify(output, null, 2)}\n`, "utf8");
console.log(`Wrote ${names.length} hair headpart candidate(s) to ${outPath}`);
