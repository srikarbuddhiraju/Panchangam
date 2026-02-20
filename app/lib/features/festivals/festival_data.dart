/// Festival definition — either Tithi-based (lunar) or Solar (fixed date).
class Festival {
  final String nameTe;
  final String nameEn;
  final FestivalType type;

  // For Tithi-based festivals
  final int? paksha; // 1 = Shukla, 2 = Krishna
  final int? tithi; // 1–15
  final int? teluguMonth; // 1–12

  // For solar festivals
  final int? gregorianMonth;
  final int? gregorianDay;

  const Festival({
    required this.nameTe,
    required this.nameEn,
    required this.type,
    this.paksha,
    this.tithi,
    this.teluguMonth,
    this.gregorianMonth,
    this.gregorianDay,
  });
}

enum FestivalType { tithi, solar }

/// The complete list of major Telugu + pan-India festivals.
/// Source: panchangam-concepts.md
class FestivalData {
  FestivalData._();

  static const List<Festival> all = [
    // ── Solar festivals ────────────────────────────────────────────────────
    Festival(
      nameTe: 'మకర సంక్రాంతి',
      nameEn: 'Makara Sankranti',
      type: FestivalType.solar,
      gregorianMonth: 1,
      gregorianDay: 14,
    ),
    Festival(
      nameTe: 'భోగి',
      nameEn: 'Bhogi',
      type: FestivalType.solar,
      gregorianMonth: 1,
      gregorianDay: 13,
    ),
    Festival(
      nameTe: 'కనుమ',
      nameEn: 'Kanuma',
      type: FestivalType.solar,
      gregorianMonth: 1,
      gregorianDay: 15,
    ),
    Festival(
      nameTe: 'ముక్కనుమ',
      nameEn: 'Mukkanuma',
      type: FestivalType.solar,
      gregorianMonth: 1,
      gregorianDay: 16,
    ),

    // ── Chaitra (Telugu Month 1) ────────────────────────────────────────────
    Festival(
      nameTe: 'ఉగాది',
      nameEn: 'Ugadi',
      type: FestivalType.tithi,
      teluguMonth: 1,
      paksha: 1,
      tithi: 1,
    ),
    Festival(
      nameTe: 'శ్రీ రామ నవమి',
      nameEn: 'Sri Rama Navami',
      type: FestivalType.tithi,
      teluguMonth: 1,
      paksha: 1,
      tithi: 9,
    ),
    Festival(
      nameTe: 'హనుమాన్ జయంతి',
      nameEn: 'Hanuman Jayanti',
      type: FestivalType.tithi,
      teluguMonth: 1,
      paksha: 1,
      tithi: 15,
    ),

    // ── Vaisakha (Month 2) ────────────────────────────────────────────────
    Festival(
      nameTe: 'అక్షయ తృతీయ',
      nameEn: 'Akshaya Tritiya',
      type: FestivalType.tithi,
      teluguMonth: 2,
      paksha: 1,
      tithi: 3,
    ),
    Festival(
      nameTe: 'నరసింహ జయంతి',
      nameEn: 'Narasimha Jayanti',
      type: FestivalType.tithi,
      teluguMonth: 2,
      paksha: 1,
      tithi: 14,
    ),

    // ── Ashadha (Month 4) ─────────────────────────────────────────────────
    Festival(
      nameTe: 'గురు పౌర్ణమి',
      nameEn: 'Guru Purnima',
      type: FestivalType.tithi,
      teluguMonth: 4,
      paksha: 1,
      tithi: 15,
    ),

    // ── Shravana (Month 5) ────────────────────────────────────────────────
    Festival(
      nameTe: 'నాగ పంచమి',
      nameEn: 'Naga Panchami',
      type: FestivalType.tithi,
      teluguMonth: 5,
      paksha: 1,
      tithi: 5,
    ),
    Festival(
      nameTe: 'రక్షాబంధన్',
      nameEn: 'Raksha Bandhan',
      type: FestivalType.tithi,
      teluguMonth: 5,
      paksha: 1,
      tithi: 15,
    ),
    Festival(
      nameTe: 'శ్రీ కృష్ణ జన్మాష్టమి',
      nameEn: 'Krishna Janmashtami',
      type: FestivalType.tithi,
      teluguMonth: 5,
      paksha: 2,
      tithi: 8,
    ),

    // ── Bhadrapada (Month 6) ──────────────────────────────────────────────
    Festival(
      nameTe: 'వినాయక చవితి',
      nameEn: 'Vinayaka Chaturthi',
      type: FestivalType.tithi,
      teluguMonth: 6,
      paksha: 1,
      tithi: 4,
    ),
    Festival(
      nameTe: 'అనంత చతుర్దశి',
      nameEn: 'Anant Chaturdashi',
      type: FestivalType.tithi,
      teluguMonth: 6,
      paksha: 1,
      tithi: 14,
    ),

    // ── Ashvayuja (Month 7) ───────────────────────────────────────────────
    Festival(
      nameTe: 'మహాలయ అమావాస్య',
      nameEn: 'Mahalaya Amavasya',
      type: FestivalType.tithi,
      teluguMonth: 7,
      paksha: 2,
      tithi: 15, // Amavasya = 15 in Krishna Paksha
    ),
    Festival(
      nameTe: 'దసరా / విజయదశమి',
      nameEn: 'Dasara / Vijayadasami',
      type: FestivalType.tithi,
      teluguMonth: 7,
      paksha: 1,
      tithi: 10,
    ),
    Festival(
      nameTe: 'అట్ల తద్ది',
      nameEn: 'Atla Taddi',
      type: FestivalType.tithi,
      teluguMonth: 7,
      paksha: 2,
      tithi: 8,
    ),

    // ── Kartika (Month 8) ─────────────────────────────────────────────────
    Festival(
      nameTe: 'ధన్ తేరస్',
      nameEn: 'Dhanteras',
      type: FestivalType.tithi,
      teluguMonth: 8,
      paksha: 2,
      tithi: 13,
    ),
    Festival(
      nameTe: 'నరక చతుర్దశి',
      nameEn: 'Naraka Chaturdashi',
      type: FestivalType.tithi,
      teluguMonth: 8,
      paksha: 2,
      tithi: 14,
    ),
    Festival(
      nameTe: 'దీపావళి',
      nameEn: 'Deepavali',
      type: FestivalType.tithi,
      teluguMonth: 8,
      paksha: 2,
      tithi: 15, // Amavasya
    ),
    Festival(
      nameTe: 'నాగుల చవితి',
      nameEn: 'Nagula Chaviti',
      type: FestivalType.tithi,
      teluguMonth: 8,
      paksha: 1,
      tithi: 4,
    ),
    Festival(
      nameTe: 'కార్తీక పౌర్ణమి',
      nameEn: 'Karthika Purnima',
      type: FestivalType.tithi,
      teluguMonth: 8,
      paksha: 1,
      tithi: 15,
    ),

    // ── Margashira (Month 9) ──────────────────────────────────────────────
    Festival(
      nameTe: 'వైకుంఠ ఏకాదశి',
      nameEn: 'Vaikunta Ekadashi',
      type: FestivalType.tithi,
      teluguMonth: 9,
      paksha: 1,
      tithi: 11,
    ),

    // ── Magha (Month 11) ──────────────────────────────────────────────────
    Festival(
      nameTe: 'సరస్వతి పూజ',
      nameEn: 'Saraswati Puja / Vasant Panchami',
      type: FestivalType.tithi,
      teluguMonth: 11,
      paksha: 1,
      tithi: 5,
    ),
    Festival(
      nameTe: 'రథ సప్తమి',
      nameEn: 'Ratha Saptami',
      type: FestivalType.tithi,
      teluguMonth: 11,
      paksha: 1,
      tithi: 7,
    ),

    // ── Phalguna (Month 12) ───────────────────────────────────────────────
    Festival(
      nameTe: 'మహా శివరాత్రి',
      nameEn: 'Maha Shivaratri',
      type: FestivalType.tithi,
      teluguMonth: 12,
      paksha: 2,
      tithi: 14,
    ),
    Festival(
      nameTe: 'హోలీ',
      nameEn: 'Holi',
      type: FestivalType.tithi,
      teluguMonth: 12,
      paksha: 1,
      tithi: 15,
    ),
  ];
}
