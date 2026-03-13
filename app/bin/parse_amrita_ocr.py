#!/usr/bin/env python3
"""
Parse raw Sarvam OCR markdown from Sringeri Panchangam daily pages.
Extracts amrita kalam entries (date, nakshatra, time, Di/Ra type).

Usage:
  python3 bin/parse_amrita_ocr.py <ocr_dir> <output_csv> <start_date>

  ocr_dir:    directory with page_NNN.md files
  output_csv: output CSV path
  start_date: YYYY-MM-DD of the FIRST entry in the first page
              2025-26 PDF (pages 69-110): start_date = 2025-03-30
              2026-27 PDF (pages 58-83):  start_date = 2026-03-20 (approx, verify)

The script tracks day-number progression across pages to compute dates.
Month transitions detected when day number resets from >20 to <=5.
"""

import sys, re, csv
from pathlib import Path
from datetime import date

# Telugu digit map
TEL_DIGITS = str.maketrans("౦౧౨౩౪౫౬౭౮౯", "0123456789")

# Nakshatra name normalization (Telugu -> English), sorted longest first
NK_MAP_RAW = {
    "అశ్వని": "Ashwini", "అశ్విని": "Ashwini", "అశ్వనీ": "Ashwini",
    "భరణి": "Bharani", "భరణీ": "Bharani",
    "కృత్తిక": "Krttika", "కృత్తికా": "Krttika",
    "రోహిణి": "Rohini", "రోహిణీ": "Rohini",
    "మృగశిర": "Mrgasira", "మృగశిరా": "Mrgasira", "మృగశీర్ష": "Mrgasira",
    "ఆర్ద్ర": "Ardra", "ఆర్ద్రా": "Ardra",
    "పునర్వసు": "Punarvasu", "పునర్వసూ": "Punarvasu",
    "పుష్యమి": "Pushya", "పుష్యమీ": "Pushya", "పుష్య": "Pushya",
    "ఆశ్లేష": "Ashlesha", "ఆశ్లేషా": "Ashlesha",
    "మఘ": "Magha", "మఘా": "Magha",
    "పూర్వఫల్గుని": "PvPhalguni", "పూర్వఫల్గుణి": "PvPhalguni",
    "ఉత్తరఫల్గుని": "UtPhalguni", "ఉత్తరఫల్గుణి": "UtPhalguni",
    "హస్త": "Hasta", "హస్తా": "Hasta",
    "చిత్ర": "Chitra", "చిత్రా": "Chitra",
    "స్వాతి": "Swati", "స్వాతీ": "Swati",
    "విశాఖ": "Vishakha", "విశాఖా": "Vishakha",
    "అనూరాధ": "Anuradha", "అనురాధ": "Anuradha", "అనూరాధా": "Anuradha",
    "జ్యేష్ఠ": "Jyeshtha", "జ్యేష్టా": "Jyeshtha", "జ్యేష్ట": "Jyeshtha",
    "మూల": "Mula", "మూలా": "Mula",
    "పూర్వాషాఢ": "PvAshadha", "పూర్వాషాఢా": "PvAshadha",
    "ఉత్తరాషాఢ": "UtAshadha", "ఉత్తరాషాఢా": "UtAshadha",
    "శ్రవణ": "Shravana", "శ్రవణం": "Shravana",
    "ధనిష్ఠ": "Dhanishtha", "ధనిష్టా": "Dhanishtha", "ధనిష్ట": "Dhanishtha",
    "శతభిష": "Shatabhisha", "శతభిషా": "Shatabhisha",
    "పూర్వాభాద్ర": "PvBhadra", "పూర్వభాద్ర": "PvBhadra",
    "ఉత్తరాభాద్ర": "UtBhadra", "ఉత్తరభాద్ర": "UtBhadra",
    "రేవతి": "Revati", "రేవతీ": "Revati",
}
NK_MAP = sorted(NK_MAP_RAW.items(), key=lambda x: -len(x[0]))

NK_IDX = {
    "Ashwini": 0, "Bharani": 1, "Krttika": 2, "Rohini": 3, "Mrgasira": 4,
    "Ardra": 5, "Punarvasu": 6, "Pushya": 7, "Ashlesha": 8, "Magha": 9,
    "PvPhalguni": 10, "UtPhalguni": 11, "Hasta": 12, "Chitra": 13,
    "Swati": 14, "Vishakha": 15, "Anuradha": 16, "Jyeshtha": 17,
    "Mula": 18, "PvAshadha": 19, "UtAshadha": 20, "Shravana": 21,
    "Dhanishtha": 22, "Shatabhisha": 23, "PvBhadra": 24,
    "UtBhadra": 25, "Revati": 26,
}


def tel2int(s: str) -> int:
    return int(s.translate(TEL_DIGITS))


def strip_tags(s: str) -> str:
    return re.sub(r'<[^>]+>', ' ', s)


def extract_td_cells(text: str) -> list[tuple[str, str]]:
    """Extract (day_str, content_raw) pairs from HTML table rows."""
    rows = re.findall(r'<tr>(.*?)</tr>', text, re.DOTALL)
    pairs = []
    for row in rows:
        cells = re.findall(r'<td[^>]*>(.*?)</td>', row, re.DOTALL)
        if len(cells) >= 2:
            day_text = strip_tags(cells[0]).strip().rstrip('.')
            # Day cell should be a 1-2 digit number (ASCII or Telugu)
            day_match = re.match(r'^([0-9౦-౯]{1,2})$', day_text)
            if day_match:
                pairs.append((day_match.group(1), cells[1]))
    return pairs


def extract_nakshatra(content: str) -> str | None:
    text = strip_tags(content)
    for tel, eng in NK_MAP:
        if tel in text:
            return eng
    return None


def period_to_24h(period: str, h: int, m: int) -> tuple[int, int]:
    """Convert period abbreviation + 12h time to 24h.
    ఉ॥ = morning (5-12 AM)       → keep
    ప॥ = pagalu/daytime (6-18)  → keep if h>=7, add 12 if h<7 (afternoon 1-6PM)
    సా॥ = evening (16-20)        → add 12 if h<12
    రా॥ = night (20-24 or 0-6)  → add 12 if 7<=h<=11; keep if 0-6
    తె॥ = pre-dawn (4-6 AM)     → keep
    """
    if 'సా' in period:    # saayam = evening 17-20
        if h < 12: h += 12
    elif 'ప' in period:   # pagalu = daytime; hours 1-6 = PM (13-18), 7-11 = AM
        if 1 <= h <= 6: h += 12
    elif 'రా' in period:  # rAtri = night; h=12→midnight(0), h 7-11→PM(+12), h 0-6→AM
        if h == 12: h = 0
        elif 7 <= h <= 11: h += 12
    # ఉ (udayam morning) and తె (dawn) stay as-is
    return h, m


def extract_amrita(content: str) -> list[tuple[str, str]]:
    """
    Extract (amrita_type, HH:MM 24h) from table cell content.
    Format: ది.అమృత <fraction> <period>॥<HH.MM>మొ॥ <end>వ॥
    Captures period before ॥ and converts to 24h.
    """
    text = strip_tags(content)
    if 'అమృతఘటికాభావ' in text:
        return []

    results = []
    for m in re.finditer(r'ది\.అమృత[^॥]*?([^\s॥]{1,4})॥(\d+)[.:](\d+)మొ', text):
        period = m.group(1)
        h, mn = int(m.group(2)), int(m.group(3))
        h, mn = period_to_24h(period, h, mn)
        results.append(('Di', f"{h:02d}:{mn:02d}"))
    for m in re.finditer(r'రా\.అమృత[^॥]*?([^\s॥]{1,4})॥(\d+)[.:](\d+)మొ', text):
        period = m.group(1)
        h, mn = int(m.group(2)), int(m.group(3))
        h, mn = period_to_24h(period, h, mn)
        results.append(('Ra', f"{h:02d}:{mn:02d}"))

    return results


def advance_month(d: date) -> date:
    y, mo = d.year, d.month
    if mo == 12:
        return date(y + 1, 1, 1)
    return date(y, mo + 1, 1)


def parse_dir(ocr_dir: str, start_date_str: str) -> list[dict]:
    start_date = date.fromisoformat(start_date_str)
    md_files = sorted(Path(ocr_dir).glob("page_*.md"))

    all_entries = []
    current_month_year = (start_date.year, start_date.month)
    prev_day_num = start_date.day - 1

    for md_file in md_files:
        text = md_file.read_text()
        pairs = extract_td_cells(text)

        if not pairs:
            print(f"  {md_file.name}: no table rows found")
            continue

        page_entries = 0
        for day_str, content in pairs:
            day_num = tel2int(day_str)

            # Detect month rollover: day went backward past threshold
            if day_num < prev_day_num - 20:
                y, mo = current_month_year
                if mo == 12:
                    current_month_year = (y + 1, 1)
                else:
                    current_month_year = (y, mo + 1)

            prev_day_num = day_num
            y, mo = current_month_year
            try:
                current_date = date(y, mo, day_num)
            except ValueError:
                print(f"  {md_file.name}: invalid date {y}-{mo}-{day_num}, skipping")
                continue

            nk = extract_nakshatra(content)
            for atype, atime in extract_amrita(content):
                all_entries.append({
                    'date': current_date.isoformat(),
                    'nk_name': nk or 'Unknown',
                    'nk_idx': NK_IDX.get(nk, -1) if nk else -1,
                    'amrita_type': atype,
                    'amrita_start': atime,
                })
                page_entries += 1

        first_day = tel2int(pairs[0][0]) if pairs else '?'
        last_day = tel2int(pairs[-1][0]) if pairs else '?'
        print(f"  {md_file.name}: {page_entries} amrita entries (days {first_day}–{last_day})")

    return all_entries


def main():
    if len(sys.argv) != 4:
        print("Usage: python3 parse_amrita_ocr.py <ocr_dir> <output_csv> <start_date>")
        print("  2025-26 pages 69-110: start_date = 2025-03-30")
        print("  2026-27 pages 58-83:  start_date = 2026-03-20")
        sys.exit(1)

    ocr_dir, output_csv, start_date = sys.argv[1], sys.argv[2], sys.argv[3]
    entries = parse_dir(ocr_dir, start_date)

    # Deduplicate same date+type (keep first occurrence)
    seen = set()
    unique = []
    for e in entries:
        key = (e['date'], e['amrita_type'])
        if key not in seen:
            seen.add(key)
            unique.append(e)

    unique.sort(key=lambda x: x['date'])

    Path(output_csv).parent.mkdir(parents=True, exist_ok=True)
    with open(output_csv, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['date', 'nk_name', 'nk_idx', 'amrita_type', 'amrita_start'])
        writer.writeheader()
        writer.writerows(unique)

    print(f"\nTotal: {len(unique)} entries -> {output_csv}")


if __name__ == "__main__":
    main()
