#!/usr/bin/env python3
"""
Parse 2026-27 Sringeri Panchangam OCR (compact weekly format).

This PDF uses a different format from 2025-26:
  - Each page covers ~2 weeks with a header showing date range
  - Column 2 = English Gregorian date (day number)
  - Amrita format: అ:<period>.<H>.<MM>-<period>.<H>.<MM>
  - No Di/Ra distinction — inferred from start-time period

Period codes:
  ఉ. = morning     (AM, 06-12 → keep)
  మ. = afternoon   (PM, 12-17 → add 12 if h<12)
  సా. = evening    (PM, 17-20 → add 12 if h<12)
  రా. = night      (PM/AM: h 7-11 → add 12; h 0-6 → keep)
  తె. = pre-dawn   (AM, 04-06 → keep)

Usage:
  python3 bin/parse_amrita_2627.py <ocr_dir> <output_csv>
"""

import sys, re, csv
from pathlib import Path
from datetime import date, timedelta

TEL_DIGITS = str.maketrans("౦౧౨౩౪౫౬౭౮౯", "0123456789")

# Nakshatra Telugu → English (same as other parser)
NK_MAP_RAW = {
    "అశ్వని": "Ashwini", "అశ్విని": "Ashwini", "అశ్వనీ": "Ashwini",
    "భరణి": "Bharani", "భరణీ": "Bharani",
    "కృత్తిక": "Krttika", "కృత్తికా": "Krttika",
    "రోహిణి": "Rohini", "రోహిణీ": "Rohini",
    "మృగశిర": "Mrgasira", "మృగశిరా": "Mrgasira",
    "ఆర్ద్ర": "Ardra", "ఆర్ద్రా": "Ardra",
    "పునర్వసు": "Punarvasu", "పునర్వసూ": "Punarvasu",
    "పుష్యమి": "Pushya", "పుష్యమీ": "Pushya", "పుష్య": "Pushya",
    "ఆశ్లేష": "Ashlesha", "ఆశ్లేషా": "Ashlesha", "ఆశ్రేష": "Ashlesha",
    "మఘ": "Magha", "మఘా": "Magha",
    "పూర్వఫల్గుని": "PvPhalguni", "పూర్వఫల్గుణి": "PvPhalguni",
    "ఉత్తరఫల్గుని": "UtPhalguni", "ఉత్తరఫల్గుణి": "UtPhalguni",
    "హస్త": "Hasta", "హస్తా": "Hasta",
    "చిత్ర": "Chitra", "చిత్తా": "Chitra", "చిత్తా": "Chitra", "చిత్త": "Chitra",
    "స్వాతి": "Swati", "స్వాతీ": "Swati",
    "విశాఖ": "Vishakha", "విశాఖా": "Vishakha",
    "అనూరాధ": "Anuradha", "అనురాధ": "Anuradha",
    "జ్యేష్ఠ": "Jyeshtha", "జ్యేష్టా": "Jyeshtha", "జ్యేష్ట": "Jyeshtha",
    "మూల": "Mula", "మూలా": "Mula",
    "పూర్వాషాఢ": "PvAshadha", "పూర్వాషాఢా": "PvAshadha",
    "ఉత్తరాషాఢ": "UtAshadha", "ఉత్తరాషాఢా": "UtAshadha",
    "శ్రవణ": "Shravana", "శ్రవణం": "Shravana",
    "ధనిష్ఠ": "Dhanishtha", "ధనిష్టా": "Dhanishtha",
    "శతభిష": "Shatabhisha", "శతభిషం": "Shatabhisha",
    "పూర్వాభాద్ర": "PvBhadra", "పూర్వభాద్ర": "PvBhadra",
    "ఉత్తరాభాద్ర": "UtBhadra", "ఉత్తరభాద్ర": "UtBhadra",
    "రేవతి": "Revati", "రేవతీ": "Revati",
}
NK_MAP = sorted(NK_MAP_RAW.items(), key=lambda x: -len(x[0]))

NK_IDX = {
    "Ashwini": 0, "Bharani": 1, "Krttika": 2, "Rohini": 3, "Mrgasira": 4,
    "Ardra": 5, "Punarvasu": 6, "Pushya": 7, "Ashlesha": 8, "Magha": 9,
    "PvPhalguni": 10, "UtPhalguni": 11, "Hasta": 12, "Chitra": 13,
    "Swati": 14, "Vishakha": "Vishakha", "Anuradha": 16, "Jyeshtha": 17,
    "Mula": 18, "PvAshadha": 19, "UtAshadha": 20, "Shravana": 21,
    "Dhanishtha": 22, "Shatabhisha": 23, "PvBhadra": 24,
    "UtBhadra": 25, "Revati": 26,
}
NK_IDX["Vishakha"] = 15  # fix above


def tel2int(s: str) -> int:
    return int(s.translate(TEL_DIGITS))


def strip_tags(s: str) -> str:
    return re.sub(r'<[^>]+>', ' ', s)


def period_to_24h(period: str, h: int, m: int) -> tuple[int, int]:
    """Convert period+time to 24h."""
    if 'మ' in period:       # afternoon 12-17
        if h < 12:
            h += 12
    elif 'సా' in period:    # evening 17-20
        if h < 12:
            h += 12
    elif 'రా' in period:    # night: h=12→midnight(0), h 7-11→PM(+12), h 0-6→AM
        if h == 12: h = 0
        elif 7 <= h <= 11: h += 12
        # 0-6 stays as AM
    # ఉ. and తె. stay as-is (morning/pre-dawn AM)
    return h, m


def amrita_type_from_hour(h: int) -> str:
    """Di = daytime amrita (06-18), Ra = night amrita (18-06)."""
    return 'Di' if 6 <= h < 18 else 'Ra'


def extract_amrita_2627(content: str) -> list[tuple[str, str]]:
    """Extract (type, HH:MM) from compact format: అ:<period>.<H>.<MM>-..."""
    text = strip_tags(content)
    if 'అమృతఘటికాభావ' in text:
        return []
    results = []
    # Pattern: అ:<period>.<digits>.<digits>
    for m in re.finditer(r'అ:([ఉమసారాతె]+)\.(\d+)\.(\d+)', text):
        period = m.group(1)
        h, mn = int(m.group(2)), int(m.group(3))
        h, mn = period_to_24h(period, h, mn)
        atype = amrita_type_from_hour(h)
        results.append((atype, f"{h:02d}:{mn:02d}"))
    return results


def extract_nakshatra(content: str) -> str | None:
    text = strip_tags(content)
    for tel, eng in NK_MAP:
        if tel in text:
            return eng
    return None


def extract_page_date_range(text: str) -> tuple[date, date] | None:
    """
    Extract (start_date, end_date) from the page header.
    Header format: YYYY <tel_month> D1 నుండి <tel_month> D2 వరకు
    Also handles: YYYY <tel_month> D1-D2 ...
    """
    TEL_MONTHS = {
        "జనవరి": 1,
        "ఫిబ్రవరి": 2, "ఫిబ్రవరీ": 2,
        "మార్చి": 3, "మార్చ్": 3,
        "ఏప్రిల్": 4, "ఏప్రల్": 4,
        "మే": 5,
        "జూన్": 6,
        "జూలై": 7, "జులై": 7,
        "ఆగస్టు": 8, "ఆగస్ట": 8, "ఆగష్ట్": 8, "ఆగస్ట్": 8,
        "సెప్టెంబర్": 9, "సెప్టెంబరు": 9,
        "అక్టోబర్": 10, "అక్టోబరు": 10,
        "నవంబర్": 11, "నవంబరు": 11,
        "డిసెంబర్": 12, "డిసెంబరు": 12,
    }
    # Look for year
    year_m = re.search(r'(20\d\d)', text)
    if not year_m:
        return None
    year = int(year_m.group(1))

    # Find Telugu month names with day numbers
    # Pattern: <month> D నుండి <month> D వరకు
    months_found = []
    for tel, mo_num in TEL_MONTHS.items():
        for m in re.finditer(re.escape(tel) + r'\s+(\d+)', text):
            months_found.append((m.start(), mo_num, int(m.group(1))))

    months_found.sort()
    if len(months_found) >= 2:
        _, mo1, d1 = months_found[0]
        _, mo2, d2 = months_found[1]
        y2 = year + 1 if mo2 < mo1 else year
        try:
            return date(year, mo1, d1), date(y2, mo2, d2)
        except ValueError:
            pass
    elif len(months_found) == 1:
        # Single-month range: "మే 2 నుండి 16 వరకు"
        _, mo1, d1 = months_found[0]
        # Find the end day — last standalone number before "వరకు"
        end_m = re.search(r'(\d+)\s+వరకు', text)
        if end_m:
            d2 = int(end_m.group(1))
            try:
                return date(year, mo1, d1), date(year, mo1, d2)
            except ValueError:
                pass
    return None


def parse_2627_page(text: str, page_name: str) -> list[dict]:
    """Parse one 2026-27 format OCR page."""
    date_range = extract_page_date_range(text)
    if not date_range:
        print(f"  {page_name}: could not detect date range, skipping")
        return []

    start_d, end_d = date_range
    page_year = start_d.year
    page_month = start_d.month

    # Extract table rows
    rows = re.findall(r'<tr>(.*?)</tr>', text, re.DOTALL)
    entries = []
    current_day = start_d.day
    prev_eng_day = None
    page_entries = 0

    for row in rows:
        cells = re.findall(r'<td[^>]*>(.*?)</td>', row, re.DOTALL)
        if len(cells) < 4:
            continue

        # Column 2 (index 1) = English date, column 4 (index 3) = content
        eng_day_raw = strip_tags(cells[1]).strip().rstrip('.')
        content = cells[3]  # main content cell

        eng_day = None
        if re.match(r'^\d{1,2}$', eng_day_raw):
            eng_day = int(eng_day_raw)

        if eng_day is not None:
            # Detect month rollover
            if prev_eng_day is not None and eng_day < prev_eng_day - 20:
                if page_month == 12:
                    page_year += 1
                    page_month = 1
                else:
                    page_month += 1
            current_day = eng_day
            prev_eng_day = eng_day

        # Try to build date
        try:
            row_date = date(page_year, page_month, current_day)
        except ValueError:
            continue

        nk = extract_nakshatra(content)
        for atype, atime in extract_amrita_2627(content):
            entries.append({
                'date': row_date.isoformat(),
                'nk_name': nk or 'Unknown',
                'nk_idx': NK_IDX.get(nk, -1) if nk else -1,
                'amrita_type': atype,
                'amrita_start': atime,
            })
            page_entries += 1

    print(f"  {page_name}: {page_entries} amrita entries ({start_d} to {end_d})")
    return entries


def main():
    if len(sys.argv) != 3:
        print("Usage: python3 parse_amrita_2627.py <ocr_dir> <output_csv>")
        sys.exit(1)

    ocr_dir, output_csv = sys.argv[1], sys.argv[2]
    md_files = sorted(Path(ocr_dir).glob("page_*.md"))

    all_entries = []
    for md_file in md_files:
        text = md_file.read_text()
        all_entries.extend(parse_2627_page(text, md_file.name))

    # Deduplicate same date+type
    seen = set()
    unique = []
    for e in all_entries:
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
