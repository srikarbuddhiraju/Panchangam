---
name: read-doc
description: Efficiently read and extract information from large files or documents without burning tokens on irrelevant content.
---

Read and extract from: `$ARGUMENTS`

**Protocol — never read blindly. Always scan → target → extract.**

---

## Step 1 — Identify file type and size

- Use `Glob` or `Bash: wc -l <file>` to check line count before reading.
- For files > 300 lines: do NOT read the whole file. Use steps below.
- For files ≤ 300 lines: read fully, then extract.

---

## Step 2 — Scan structure first

**Markdown / docs:**
- `Grep pattern:"^#" path:<file> output_mode:content` — list all headers
- Then `Read` only the section(s) relevant to the query using `offset` + `limit`.

**Dart / code files:**
- `Grep pattern:"^(class|void|Future|double|int|String|Map|List) " path:<file> output_mode:content` — list all top-level symbols
- Then `Read` only the function/class block needed (use `offset` + `limit`).

**PDF files:**
- NEVER read all pages. Use `Read` with `pages: "N"` (single page) or `pages: "N-M"` (range, max 20).
- Ask the caller which page(s) if unknown. Do not guess by reading sequentially.

**Plain text / data files:**
- `Grep` for the specific keyword or date first.
- Only `Read` the surrounding lines (use `-C 5` context).

---

## Step 3 — Extract and return

- Return only the requested information — not the surrounding boilerplate.
- Quote the exact lines found, with line numbers.
- If the target was NOT found, state that clearly: "Not found in <file>. Searched for: <pattern>."
- Do NOT paraphrase or summarise unless explicitly asked.

---

## Panchangam-specific patterns

| What you need | Grep pattern |
|---|---|
| Eclipse timings | `sparsha\|moksha\|eclipse\|Grahanam` |
| Amruthakalam | `amrutha\|horaOffset\|amruta` |
| Tithi calculation | `tithi\|currentTithi\|tithiIndex` |
| Nakshatra | `nakshatra\|nakshatraIndex` |
| Festival data | `FestivalData\|FestivalCalculator\|festival` |
| Notification scheduling | `scheduleNotification\|zonedSchedule\|flutter_local` |
| Provider/Riverpod | `@riverpod\|Provider\|StateNotifier` |

---

## Hard rules

- Max 2 full-file reads per invocation. If you need a 3rd, stop and use Grep instead.
- Never re-read a file already in context this session.
- For PDFs with Telugu content: always use the `/ocr` skill after reading the page — do not rely on PDF text extraction alone.
- Log what you searched and where you found it, so the result is reproducible.
