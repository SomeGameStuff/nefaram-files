import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

const projectRoot = path.resolve(import.meta.dirname, "..");
const sourceRoot = "C:\\Games\\nefaram\\mods\\MariaEdenProstitution\\scripts";
const outputRoot = path.join(projectRoot, "Final MO2 Mod", "Scripts");
const jobs = {
  "MariasUtils.pex": {
    "Das hat ": "",
    " nicht gefallen": " did not like that",
    " gefallen": " liked that",
    " ist sauer": " is angry",
  },
  "MEP_AnimalQuest.pex": {
    "Sprechen mit ": "Talk to ",
  },
  "MEP_DumbEffect.pex": {
    "Jetzt bist du dumm!": "You are stupid now!",
    "Verloren ": "Lost ",
  },
  "MEP_MiniNeedsAlias.pex": {
    "Du bist nun sÃ¼chtig nach Skooma": "You are now addicted to skooma",
  },
};

fs.mkdirSync(outputRoot, { recursive: true });
for (const [fileName, replacements] of Object.entries(jobs)) {
  const sourcePath = path.join(sourceRoot, fileName);
  const outputPath = path.join(outputRoot, fileName);
  const original = fs.readFileSync(sourcePath);
  const parsed = parsePex(original);
  const replacementHits = new Map(Object.keys(replacements).map(key => [key, 0]));
  const outputStrings = parsed.strings.map(value => {
    if (!Object.hasOwn(replacements, value)) return value;
    replacementHits.set(value, replacementHits.get(value) + 1);
    return replacements[value];
  });
  for (const [source, count] of replacementHits) {
    if (count !== 1) throw new Error(`${fileName}: expected one string-table entry for ${JSON.stringify(source)}, found ${count}`);
  }

  const chunks = [original.subarray(0, parsed.tableStart)];
  for (const value of outputStrings) {
    const bytes = Buffer.from(value, "utf8");
    if (bytes.length > 0xffff) throw new Error(`${fileName}: replacement string exceeds PEX limit`);
    const length = Buffer.allocUnsafe(2);
    length.writeUInt16BE(bytes.length);
    chunks.push(length, bytes);
  }
  chunks.push(original.subarray(parsed.tableEnd));
  const output = Buffer.concat(chunks);
  fs.writeFileSync(outputPath, output);

  const verified = parsePex(output);
  const changedIndexes = [];
  for (let index = 0; index < parsed.strings.length; index++) {
    if (parsed.strings[index] !== verified.strings[index]) changedIndexes.push(index);
  }
  if (changedIndexes.length !== Object.keys(replacements).length)
    throw new Error(`${fileName}: expected ${Object.keys(replacements).length} changed string entries, got ${changedIndexes.length}`);
  const originalTail = original.subarray(parsed.tableEnd);
  const outputTail = output.subarray(verified.tableEnd);
  if (!originalTail.equals(outputTail)) throw new Error(`${fileName}: data after string table changed`);

  console.log(JSON.stringify({
    file: fileName,
    string_count: parsed.strings.length,
    changed_string_indexes: changedIndexes,
    unchanged_tail_sha256: sha256(originalTail),
    output_sha256: sha256(output),
  }));
}

function parsePex(buffer) {
  if (buffer.length < 24 || buffer.readUInt32BE(0) !== 0xfa57c0de) throw new Error("Not a big-endian Skyrim PEX file");
  let offset = 16;
  for (let field = 0; field < 3; field++) offset = skipString(buffer, offset);
  const stringCount = buffer.readUInt16BE(offset);
  offset += 2;
  const tableStart = offset;
  const strings = [];
  for (let index = 0; index < stringCount; index++) {
    const length = buffer.readUInt16BE(offset);
    offset += 2;
    if (offset + length > buffer.length) throw new Error("PEX string table exceeds file length");
    strings.push(buffer.subarray(offset, offset + length).toString("utf8"));
    offset += length;
  }
  return { strings, tableStart, tableEnd: offset };
}

function skipString(buffer, offset) {
  const length = buffer.readUInt16BE(offset);
  const next = offset + 2 + length;
  if (next > buffer.length) throw new Error("PEX header string exceeds file length");
  return next;
}

function sha256(buffer) {
  return crypto.createHash("sha256").update(buffer).digest("hex").toUpperCase();
}
