import fs from "node:fs";
import path from "node:path";

const projectRoot = path.resolve(import.meta.dirname, "..");
const reviewRoot = path.join(projectRoot, "Codex Review");
const inputDir = path.join(reviewRoot, "input");
const outputDir = path.join(reviewRoot, "output");
const manifest = JSON.parse(fs.readFileSync(path.join(reviewRoot, "manifest.json"), "utf8"));
const finalMap = {};
const classified = [];

for (const batch of manifest.batches) {
  const input = JSON.parse(fs.readFileSync(path.join(inputDir, batch.file), "utf8"));
  const output = JSON.parse(fs.readFileSync(path.join(outputDir, batch.file), "utf8"));
  if (input.batch_id !== output.batch_id) throw new Error(`Batch mismatch: ${batch.file}`);
  const outputById = new Map(output.translations.map(item => [item.id, item]));
  for (const item of input.items) {
    const result = outputById.get(item.id);
    if (!result) throw new Error(`Missing ${item.id} in ${batch.file}`);
    if (Object.hasOwn(finalMap, item.source)) throw new Error(`Duplicate source: ${item.source}`);
    finalMap[item.source] = result.english;
    classified.push({ ...item, english: result.english, classification: result.classification });
  }
}

if (Object.keys(finalMap).length !== manifest.unique_strings)
  throw new Error(`Expected ${manifest.unique_strings} strings, merged ${Object.keys(finalMap).length}`);

const overridesPath = path.join(reviewRoot, "manual-overrides.json");
if (fs.existsSync(overridesPath)) {
  const overrides = JSON.parse(fs.readFileSync(overridesPath, "utf8"));
  for (const [source, english] of Object.entries(overrides)) {
    if (!Object.hasOwn(finalMap, source)) throw new Error(`Manual override source is absent: ${source}`);
    finalMap[source] = english;
    const item = classified.find(row => row.source === source);
    item.english = english;
    item.classification = "translated";
  }
}

const germanPattern = /[äöüÄÖÜß]|\b(aber|alle|also|auf|aus|bei|bist|das|dein|deine|dem|den|der|des|die|dir|doch|durch|eine|einen|einer|für|ganz|habe|haben|hier|kein|keine|machen|mein|meine|muss|nicht|noch|oder|schon|sein|soll|und|uns|von|vor|wenn|werde|werden|wie|wird|zum|zur|kerker|bordell|stall|schlafzimmer|keller|gefängnis|sklavenmarkt|tempel|taverne|gasthaus|höhle|festung|schloss|haus|kammer|zimmer|zelle|stadt|dorf|mine|verlies|eingang|ausgang|tür|lager|ruine|palast|hafen)\b/i;
const strongGermanOutputPattern = /[äöüÄÖÜß]|\b(nicht|noch|dass|dein|deine|dir|doch|durch|einen|einer|für|habe|haben|hier|kein|keine|machen|muss|schon|soll|und|wenn|werde|werden|wird|zum|zur|kerker|bordell|schlafzimmer|gefängnis|sklavenmarkt|gasthaus|höhle|eingang|ausgang|tür)\b/i;
const locationContextPattern = /:(Cell|Location|Worldspace|Door|Activator)\|/;
const unchangedLikelyGerman = classified.filter(item => item.source === item.english && germanPattern.test(item.source));
const translatedWithGermanResidue = classified.filter(item => item.source !== item.english && strongGermanOutputPattern.test(item.english));
const locationFacing = classified.filter(item => item.contexts.some(context => locationContextPattern.test(context)));
const unchangedLocationLikelyGerman = locationFacing.filter(item => item.source === item.english && germanPattern.test(item.source));

const orderedMap = Object.fromEntries(Object.entries(finalMap).sort(([a], [b]) => a.localeCompare(b, "de")));
fs.writeFileSync(path.join(projectRoot, "translation-codex-final.json"), JSON.stringify(orderedMap, null, 2) + "\n", "utf8");

const catalogsDir = path.join(projectRoot, "Catalogs");
for (const file of fs.readdirSync(catalogsDir).filter(file => file.endsWith(".json"))) {
  const catalogPath = path.join(catalogsDir, file);
  const catalog = JSON.parse(fs.readFileSync(catalogPath, "utf8"));
  for (const entry of catalog) {
    if (!Object.hasOwn(finalMap, entry.Source))
      throw new Error(`Catalog source is absent from final map: ${file}: ${entry.Source}`);
    if (!String(finalMap[entry.Source]).trim())
      throw new Error(`Catalog source has an empty final translation: ${file}: ${entry.Source}`);
    entry.English = finalMap[entry.Source];
  }
  fs.writeFileSync(catalogPath, JSON.stringify(catalog, null, 2) + "\n", "utf8");
}

fs.writeFileSync(path.join(reviewRoot, "audit-unchanged-likely-german.json"), JSON.stringify(unchangedLikelyGerman, null, 2) + "\n", "utf8");
fs.writeFileSync(path.join(reviewRoot, "audit-translated-german-residue.json"), JSON.stringify(translatedWithGermanResidue, null, 2) + "\n", "utf8");
fs.writeFileSync(path.join(reviewRoot, "audit-location-facing.json"), JSON.stringify(locationFacing, null, 2) + "\n", "utf8");
fs.writeFileSync(path.join(reviewRoot, "audit-unchanged-location-german.json"), JSON.stringify(unchangedLocationLikelyGerman, null, 2) + "\n", "utf8");

console.log(JSON.stringify({
  merged: Object.keys(finalMap).length,
  changed: classified.filter(item => item.source !== item.english).length,
  unchanged: classified.filter(item => item.source === item.english).length,
  unchanged_likely_german: unchangedLikelyGerman.length,
  translated_with_german_residue: translatedWithGermanResidue.length,
  location_facing_strings: locationFacing.length,
  unchanged_location_likely_german: unchangedLocationLikelyGerman.length,
}, null, 2));
