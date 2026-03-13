---
name: ocr
description: Extract text from an image or screenshot efficiently. Optimized for Panchangam PDFs and Telugu calendar data. Uses Sarvam AI as primary engine for all Indic scripts.
---

Extract text from: `$ARGUMENTS`

**Protocol — scan first, read once, extract precisely:**

---

## Primary method — Sarvam AI OCR (best for Indic scripts)

Use Sarvam AI for ALL Telugu/Indic PDF pages. It handles Indic scripts far better than direct PDF text extraction.

**API key:** Check `.env` file at project root for `SARVAM_API_KEY`. Ask user if missing.
**Header:** `api-subscription-key: <key>` (NOT `Authorization: Bearer`)
**Base URL:** `https://api.sarvam.ai/doc-digitization/job/v1`

### Workflow (run via Bash)

```bash
# 1. Extract target PDF page(s) to a temp file (pypdf, 0-indexed)
pip3 install pypdf --break-system-packages
python3 - <<'EOF'
import pypdf, sys
reader = pypdf.PdfReader("/path/to/file.pdf")
writer = pypdf.PdfWriter()
# pypdf_index = printed_page_number - page_offset (verify with user)
writer.add_page(reader.pages[113])  # example: doc page 114 = index 113
with open("/tmp/page_extract.pdf", "wb") as f:
    writer.write(f)
EOF

# 2. Create job
JOB=$(curl -s -X POST https://api.sarvam.ai/doc-digitization/job/v1 \
  -H "Authorization: Bearer $SARVAM_API_KEY" -H "Content-Type: application/json" \
  -d '{}' | python3 -c "import sys,json; print(json.load(sys.stdin)['jobId'])")

# 3. Get presigned upload URL
UPLOAD=$(curl -s -X POST https://api.sarvam.ai/doc-digitization/job/v1/upload-files \
  -H "Authorization: Bearer $SARVAM_API_KEY" -H "Content-Type: application/json" \
  -d "{\"jobId\":\"$JOB\",\"files\":[{\"fileName\":\"page.pdf\",\"fileType\":\"application/pdf\"}]}")
UPLOAD_URL=$(echo $UPLOAD | python3 -c "import sys,json; print(json.load(sys.stdin)['uploadDetails'][0]['uploadUrl'])")

# 4. Upload to Azure presigned URL
curl -s -X PUT "$UPLOAD_URL" -H "x-ms-blob-type: BlockBlob" \
  -H "Content-Type: application/pdf" --data-binary @/tmp/page_extract.pdf

# 5. Start job (use te-IN for Telugu, hi-IN for Hindi, kn-IN for Kannada, etc.)
curl -s -X POST https://api.sarvam.ai/doc-digitization/job/v1/$JOB/start \
  -H "Authorization: Bearer $SARVAM_API_KEY" -H "Content-Type: application/json" \
  -d '{"languageCode":"te-IN","outputFormat":"md"}'

# 6. Poll status (repeat until state == "Completed")
curl -s https://api.sarvam.ai/doc-digitization/job/v1/$JOB/status \
  -H "Authorization: Bearer $SARVAM_API_KEY"

# 7. Get download URL and fetch result
DOWNLOAD=$(curl -s -X POST https://api.sarvam.ai/doc-digitization/job/v1/$JOB/download-files \
  -H "Authorization: Bearer $SARVAM_API_KEY" -H "Content-Type: application/json" -d '{}')
DL_URL=$(echo $DOWNLOAD | python3 -c "import sys,json; print(json.load(sys.stdin)['files'][0]['downloadUrl'])")
mkdir -p /tmp/ocr_result && cd /tmp/ocr_result && curl -s "$DL_URL" -o result.zip && unzip -o result.zip
# Result: /tmp/ocr_result/document.md
```

### Language codes for Indic scripts
| Language | Code |
|----------|------|
| Telugu | te-IN |
| Hindi | hi-IN |
| Kannada | kn-IN |
| Tamil | ta-IN |
| Malayalam | ml-IN |
| Bengali | bn-IN |
| Gujarati | gu-IN |
| Marathi | mr-IN |

### PDF page offset (Sringeri Panchangam)
Printed page = doc/PDF page − 2 (2-page unnumbered preamble).
pypdf index (0-based) = doc page − 1. Sarvam page limit: upload one page at a time.

---

## Fallback — direct image/screenshot

If the file is a PNG/JPG/screenshot (not PDF), use the Read tool directly — it renders images visually.

1. **View the image** using Read at the given path.
2. **Identify the target before extracting** — do NOT transcribe everything.

---

## Telugu Panchangam — known scan targets

- Amruthakalam: look for `ది.అమృత` / `రా.అమృత` / `శే.అమృత` / `తే.అమృత`
- No amrita: `అమృతఘటికాభావః`
- Eclipse: `స్పర్శ` (Sparsha), `మోక్షం` (Moksha)
- Sutak: `సూతక`
- Tithi end times: `||` or `|` separators after tithi name
- Times are in IST, format `HH:MM` or `H.MM` — convert `.` to `:` if needed

## Output format

Return extracted values as a clean key→value list:
- Preserve Telugu text exactly as printed
- Flag ambiguous values with `[unclear]`
- If a time straddles midnight, note `(next day)` explicitly

**Reference: Telugu digit map**
౦=0, ౧=1, ౨=2, ౩=3, ౪=4, ౫=5, ౬=6, ౭=7, ౮=8, ౯=9
