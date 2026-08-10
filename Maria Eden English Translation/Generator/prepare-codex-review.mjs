import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

const projectRoot = path.resolve(import.meta.dirname, "..");
const catalogsDir = path.join(projectRoot, "Catalogs");
const reviewRoot = path.join(projectRoot, "Codex Review");
const inputDir = path.join(reviewRoot, "input");
const outputDir = path.join(reviewRoot, "output");
const draftPath = path.join(projectRoot, "Snapshots", "partial-20260809-180709", "translation-draft.json");
const draft = JSON.parse(fs.readFileSync(draftPath, "utf8"));
const unique = new Map();

for (const catalogName of fs.readdirSync(catalogsDir).filter(name => name.endsWith(".json")).sort()) {
  const entries = JSON.parse(fs.readFileSync(path.join(catalogsDir, catalogName), "utf8"));
  for (const entry of entries) {
    const contexts = unique.get(entry.Source) ?? new Set();
    for (const context of entry.Contexts ?? []) contexts.add(`${catalogName}:${context}`);
    unique.set(entry.Source, contexts);
  }
}

fs.mkdirSync(inputDir, { recursive: true });
fs.mkdirSync(outputDir, { recursive: true });
const items = [...unique.entries()]
  .sort(([a], [b]) => a.localeCompare(b, "de"))
  .map(([source, contexts], index) => ({
    id: `s${String(index).padStart(5, "0")}`,
    source,
    existing_draft: draft[source] ?? null,
    contexts: [...contexts].slice(0, 4),
  }));

const maxItems = 250;
const maxCharacters = 80000;
const batches = [];
for (let offset = 0; offset < items.length;) {
  const batchItems = [];
  let characters = 0;
  while (offset < items.length && batchItems.length < maxItems) {
    const item = items[offset];
    const size = JSON.stringify(item).length;
    if (batchItems.length && characters + size > maxCharacters) break;
    batchItems.push(item);
    characters += size;
    offset++;
  }
  const ordinal = batches.length;
  const contentHash = crypto.createHash("sha256").update(JSON.stringify(batchItems)).digest("hex").slice(0, 16);
  const batchId = `batch-${String(ordinal).padStart(3, "0")}-${contentHash}`;
  const batch = { batch_id: batchId, items: batchItems };
  const fileName = `batch-${String(ordinal).padStart(3, "0")}.json`;
  fs.writeFileSync(path.join(inputDir, fileName), JSON.stringify(batch, null, 2) + "\n", "utf8");
  batches.push({ file: fileName, batch_id: batchId, count: batchItems.length });
}

const manifest = { unique_strings: items.length, batch_count: batches.length, batches };
fs.writeFileSync(path.join(reviewRoot, "manifest.json"), JSON.stringify(manifest, null, 2) + "\n", "utf8");
console.log(JSON.stringify(manifest, null, 2));
