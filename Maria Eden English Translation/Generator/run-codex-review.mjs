import fs from "node:fs";
import path from "node:path";
import { spawn } from "node:child_process";

const projectRoot = path.resolve(import.meta.dirname, "..");
const reviewRoot = path.join(projectRoot, "Codex Review");
const inputDir = path.join(reviewRoot, "input");
const outputDir = path.join(reviewRoot, "output");
const schemaPath = path.join(import.meta.dirname, "codex-output-schema.json");
const manifest = JSON.parse(fs.readFileSync(path.join(reviewRoot, "manifest.json"), "utf8"));
const codexScript = "C:\\Users\\antho\\AppData\\Roaming\\npm\\node_modules\\@openai\\codex\\bin\\codex.js";
const concurrency = 8;

const pending = manifest.batches.filter(batch => !validExistingOutput(batch));
const requestedLimit = Number(process.env.CODEX_MAX_BATCHES ?? pending.length);
const queue = pending.slice(0, requestedLimit);
console.log(`Codex review: total=${manifest.batch_count}; already valid=${manifest.batch_count - pending.length}; queued=${queue.length}`);
let cursor = 0;
let completed = manifest.batch_count - pending.length;
await Promise.all(Array.from({ length: Math.min(concurrency, queue.length) }, (_, worker) => runWorker(worker)));
console.log(`Codex review complete: ${completed}/${manifest.batch_count} batches.`);

async function runWorker(worker) {
  while (cursor < queue.length) {
    const batch = queue[cursor++];
    let error;
    for (let attempt = 1; attempt <= 3; attempt++) {
      try {
        await runBatch(batch, worker);
        validateOutput(batch);
        completed++;
        console.log(`Completed ${batch.file} (${completed}/${manifest.batch_count})`);
        error = null;
        break;
      } catch (caught) {
        error = caught;
        console.warn(`${batch.file} attempt ${attempt} failed: ${caught.message}`);
      }
    }
    if (error) throw error;
  }
}

function runBatch(batch, worker) {
  const inputPath = path.join(inputDir, batch.file);
  const outputPath = path.join(outputDir, batch.file);
  const input = fs.readFileSync(inputPath, "utf8");
  const prompt = buildPrompt(input);
  const args = [
    codexScript,
    "exec", "--ephemeral", "--ignore-rules", "--skip-git-repo-check",
    "-s", "read-only", "-C", projectRoot,
    "-c", "model_reasoning_effort=\"low\"",
    "--output-schema", schemaPath,
    "-o", outputPath,
    "-",
  ];
  return new Promise((resolve, reject) => {
    const environment = { ...process.env };
    delete environment.CODEX_THREAD_ID;
    const child = spawn(process.execPath, args, { cwd: projectRoot, env: environment, windowsHide: true });
    let stdout = "";
    let stderr = "";
    child.stdout.on("data", data => { stdout += data; });
    child.stderr.on("data", data => { stderr += data; });
    child.on("error", reject);
    child.on("exit", code => {
      if (code === 0) resolve();
      else reject(new Error(`Codex exit ${code}; worker=${worker}; ${stderr.slice(-1500) || stdout.slice(-1500)}`));
    });
    child.stdin.end(prompt, "utf8");
  });
}

function validExistingOutput(batch) {
  try { validateOutput(batch); return true; }
  catch { return false; }
}

function validateOutput(batch) {
  const input = JSON.parse(fs.readFileSync(path.join(inputDir, batch.file), "utf8"));
  const output = JSON.parse(fs.readFileSync(path.join(outputDir, batch.file), "utf8"));
  if (output.batch_id !== input.batch_id) throw new Error("Batch ID mismatch");
  if (!Array.isArray(output.translations) || output.translations.length !== input.items.length)
    throw new Error(`Expected ${input.items.length} translations, got ${output.translations?.length}`);
  const sourceById = new Map(input.items.map(item => [item.id, item.source]));
  const seen = new Set();
  for (const translation of output.translations) {
    if (!sourceById.has(translation.id) || seen.has(translation.id)) throw new Error(`Invalid or duplicate ID ${translation.id}`);
    seen.add(translation.id);
    if (!translation.english?.trim()) throw new Error(`Empty English text for ${translation.id}`);
    if (translation.classification === "technical_or_name" && translation.english !== sourceById.get(translation.id))
      throw new Error(`Technical/name entry was altered: ${translation.id}`);
    assertTokensPreserved(sourceById.get(translation.id), translation.english, translation.id);
  }
}

function assertTokensPreserved(source, english, id) {
  const tokenPattern = /<[^>]+>|\{[^}]+\}|%[^%\s]+%|\\[nrt]|\$[A-Za-z0-9_]+/g;
  const before = (source.match(tokenPattern) ?? []).sort();
  const after = (english.match(tokenPattern) ?? []).sort();
  if (JSON.stringify(before) !== JSON.stringify(after)) throw new Error(`Protected token mismatch: ${id}`);
}

function buildPrompt(input) {
  return `Act as the final English localization editor for the Skyrim mod Maria Eden. Review EVERY item in the supplied JSON batch independently.

For each item:
- If source is German, mixed German/English, or mojibake-encoded German, produce fluent natural English and classify "translated".
- If source is already good English, return source byte-for-byte and classify "already_english".
- If source is a proper name, filename/path, script/editor identifier, animation/event token, or other non-user-facing technical value, return source byte-for-byte and classify "technical_or_name".
- existing_draft is only a fallible suggestion. Correct its meaning, pronouns, subject/object, negation, tense, Skyrim terminology, and tone against source.
- Translate short user-facing names too. Contexts identify record types and fields: Cell, Location, Worldspace, Door, Activator, Message, Quest, Objective, Book, Topic, and dialogue text must be localized when German. This explicitly includes zone/cell/location names displayed on doors.
- Preserve all placeholders, HTML/font markup, escape sequences, numbers, proper character names, and tokens such as <Alias=...>, {...}, %...%, $..., and \\n exactly.
- Do not censor or soften sexual, coercive, insulting, or violent dialogue. Correct obvious German spelling mistakes without changing intent.
- Use canonical Skyrim names: Himmelsrand=Skyrim, Weißlauf=Whiterun, Einsamkeit=Solitude, Windhelm=Windhelm, Rifton=Riften, Markarth=Markarth, Drachenfeste=Dragonsreach.
- Role glossary: Sklavin/Sklave=female slave/slave; Herrin=Mistress; Meister/Herr=Master when addressing an owner; Hure=whore in insulting/role dialogue and prostitute in neutral UI; Freier=client; Zuhälter/Zuhälterin=pimp/female pimp; Sklavenhändler=slave trader; Fesseln=restraints; Keuschheitsgürtel=chastity belt.
- Explicit glossary: Schwanz=cock; Muschi/Möse=pussy; Titten=tits; Arsch=ass; kommen in sexual context=climax/orgasm; Einreiten=breaking in/training when describing a slave or pony, not "riding me"; Mösengeld=sexual earnings/pussy money according to tone.
- Preserve Maria Eden, SexLab, ZAZ, Devious Devices, MCM, MEP, and character names.

Return exactly one object matching the required schema. batch_id must equal the supplied batch_id. Include each supplied id exactly once and do not add commentary.

INPUT JSON:
${input}`;
}
