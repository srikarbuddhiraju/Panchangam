#!/usr/bin/env python3
"""
Batch Sarvam OCR for Sringeri Panchangam PDF pages.
Extracts amrita kalam entries from Telugu daily Panchangam pages.

Usage:
  python3 bin/ocr_batch.py <pdf_path> <start_page> <end_page> <output_dir>

Pages are 1-indexed printed page numbers.
Saves raw OCR markdown to output_dir/<page_NNN>.md
"""

import os, sys, json, time, zipfile, pathlib, urllib.request, urllib.error, pypdf

SARVAM_API_KEY = os.environ.get("SARVAM_API_KEY", "")
BASE_URL = "https://api.sarvam.ai/doc-digitization/job/v1"
INTER_PAGE_DELAY = 10  # seconds between pages to stay under rate limit




def extract_page(pdf_path: str, page_num: int, tmp_pdf: str):
    """Extract a single page (1-indexed) to a temporary PDF."""
    reader = pypdf.PdfReader(pdf_path)
    writer = pypdf.PdfWriter()
    idx = page_num - 1  # pypdf 0-indexed
    if idx < 0 or idx >= len(reader.pages):
        raise ValueError(f"Page {page_num} out of range (PDF has {len(reader.pages)} pages)")
    writer.add_page(reader.pages[idx])
    with open(tmp_pdf, "wb") as f:
        writer.write(f)


def sarvam_ocr(tmp_pdf: str, lang: str = "te-IN") -> str:
    """Submit a single-page PDF to Sarvam OCR and return markdown text."""
    if not SARVAM_API_KEY:
        raise RuntimeError("SARVAM_API_KEY not set in environment")

    hdrs = {"api-subscription-key": SARVAM_API_KEY, "Content-Type": "application/json"}
    hdrs_put = {"x-ms-blob-type": "BlockBlob", "Content-Type": "application/pdf"}

    # 1. Create job (API v2: requires job_parameters, returns job_id not jobId)
    create_body = json.dumps({"job_parameters": {"language": lang, "output_format": "md"}}).encode()
    req = urllib.request.Request(BASE_URL, data=create_body, headers=hdrs, method='POST')
    with urllib.request.urlopen(req) as r:
        resp = json.loads(r.read())
    job_id = resp.get('job_id') or resp.get('jobId')
    print(f"    job={job_id}", flush=True)

    # 2. Get presigned upload URL (files = list of strings)
    body = json.dumps({"job_id": job_id, "files": ["page.pdf"]}).encode()
    req = urllib.request.Request(f"{BASE_URL}/upload-files", data=body, headers=hdrs, method='POST')
    with urllib.request.urlopen(req) as r:
        upload_resp = json.loads(r.read())

    # Response: {"upload_urls": {"page.pdf": {"file_url": "..."}}}
    upload_url = upload_resp['upload_urls']['page.pdf']['file_url']

    # 3. Upload PDF
    with open(tmp_pdf, 'rb') as f:
        data = f.read()
    req = urllib.request.Request(upload_url, data=data, headers=hdrs_put, method='PUT')
    with urllib.request.urlopen(req):
        pass

    # 4. Start job
    start_body = json.dumps({"job_id": job_id}).encode()
    req = urllib.request.Request(f"{BASE_URL}/{job_id}/start", data=start_body, headers=hdrs, method='POST')
    with urllib.request.urlopen(req):
        pass

    # 5. Poll until completed (max 5 min)
    for attempt in range(60):
        time.sleep(5)
        req = urllib.request.Request(f"{BASE_URL}/{job_id}/status", headers=hdrs)
        with urllib.request.urlopen(req) as r:
            status = json.loads(r.read())
        state = status.get('job_state') or status.get('state', '')
        if state == 'Completed':
            break
        if state in ('Failed', 'Error'):
            raise RuntimeError(f"Sarvam job failed: {status}")
        if attempt % 6 == 5:
            print(f"    waiting... ({attempt*5}s, state={state})", flush=True)
    else:
        raise TimeoutError(f"Job {job_id} did not complete in time")

    # 6. Download result zip (response: {"download_urls": {"file": {"file_url": "..."}}})
    req = urllib.request.Request(f"{BASE_URL}/{job_id}/download-files",
                                  data=b'{}', headers=hdrs, method='POST')
    with urllib.request.urlopen(req) as r:
        dl_resp = json.loads(r.read())
    dl_url = list(dl_resp['download_urls'].values())[0]['file_url']

    tmp_dir = f"/tmp/ocr_{job_id}"
    os.makedirs(tmp_dir, exist_ok=True)
    zip_path = f"{tmp_dir}/result.zip"
    urllib.request.urlretrieve(dl_url, zip_path)
    with zipfile.ZipFile(zip_path) as z:
        z.extractall(tmp_dir)

    # Find markdown file
    for fname in sorted(os.listdir(tmp_dir)):
        if fname.endswith('.md'):
            with open(f"{tmp_dir}/{fname}") as f:
                return f.read()
    return ""


def main():
    if len(sys.argv) != 5:
        print("Usage: python3 ocr_batch.py <pdf_path> <start_page> <end_page> <output_dir>")
        sys.exit(1)

    pdf_path, start, end, out_dir = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
    pathlib.Path(out_dir).mkdir(parents=True, exist_ok=True)

    for page in range(start, end + 1):
        out_file = f"{out_dir}/page_{page:03d}.md"
        if os.path.exists(out_file) and os.path.getsize(out_file) > 100:
            print(f"  page {page}: already done, skipping")
            continue

        print(f"  page {page}: OCR-ing...", flush=True)
        tmp_pdf = f"/tmp/ocr_page_{page}.pdf"
        for attempt in range(5):
            try:
                extract_page(pdf_path, page, tmp_pdf)
                text = sarvam_ocr(tmp_pdf)
                with open(out_file, 'w') as f:
                    f.write(text)
                print(f"  page {page}: saved ({len(text)} chars)")
                time.sleep(INTER_PAGE_DELAY)
                break
            except urllib.error.HTTPError as e:
                if e.code == 429 and attempt < 4:
                    wait = 60 * (2 ** attempt)
                    print(f"  page {page}: rate limited (attempt {attempt+1}), waiting {wait}s...", flush=True)
                    time.sleep(wait)
                else:
                    print(f"  page {page}: ERROR — {e}")
                    with open(f"{out_dir}/page_{page:03d}.error", 'w') as f:
                        f.write(str(e))
                    break
            except Exception as e:
                print(f"  page {page}: ERROR — {e}")
                with open(f"{out_dir}/page_{page:03d}.error", 'w') as f:
                    f.write(str(e))
                break


if __name__ == "__main__":
    main()
