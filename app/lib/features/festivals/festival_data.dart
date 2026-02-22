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

  /// If true, this festival is observed at night (e.g. Shivaratri, Janmashtami).
  /// The calculator will check the tithi at 11:30 PM instead of sunrise.
  final bool observedAtNight;

  /// Short description explaining significance (Purana / Itihasa / astronomical).
  final String descriptionEn;

  const Festival({
    required this.nameTe,
    required this.nameEn,
    required this.type,
    this.paksha,
    this.tithi,
    this.teluguMonth,
    this.gregorianMonth,
    this.gregorianDay,
    this.observedAtNight = false,
    this.descriptionEn = '',
  });
}

enum FestivalType { tithi, solar }

/// The complete list of major Telugu + pan-India festivals.
class FestivalData {
  FestivalData._();

  static const List<Festival> all = [
    // ── Solar festivals ────────────────────────────────────────────────────
    Festival(
      nameTe: 'భోగి',
      nameEn: 'Bhogi',
      type: FestivalType.solar,
      gregorianMonth: 1,
      gregorianDay: 13,
      descriptionEn:
          'The day before Sankranti. Old and worn-out items are burned in a bonfire '
          '(Bhogi fire) at dawn, symbolising the release of the old and welcome of '
          'the new. Children are blessed with Bhogi Pallu (seasonal fruits, flowers).',
    ),
    Festival(
      nameTe: 'మకర సంక్రాంతి',
      nameEn: 'Makara Sankranti',
      type: FestivalType.solar,
      gregorianMonth: 1,
      gregorianDay: 14,
      descriptionEn:
          'The Sun enters Makara Rashi (Capricorn), ending Dakshinayana and beginning '
          'Uttarayana — the six-month northward journey considered auspicious for '
          'spiritual practices. The harvest festival of Andhra Pradesh, celebrated '
          'with sesame (til) and jaggery offerings, kite flying, and cattle worship.',
    ),
    Festival(
      nameTe: 'కనుమ',
      nameEn: 'Kanuma',
      type: FestivalType.solar,
      gregorianMonth: 1,
      gregorianDay: 15,
      descriptionEn:
          'The third day of Sankranti; cattle who assist in farming are bathed, '
          'decorated, and worshipped. Cockfights and bullock races are held in '
          'villages of Andhra Pradesh as thanksgiving to working animals.',
    ),
    Festival(
      nameTe: 'ముక్కనుమ',
      nameEn: 'Mukkanuma',
      type: FestivalType.solar,
      gregorianMonth: 1,
      gregorianDay: 16,
      descriptionEn:
          'The fourth and final day of the Sankranti celebrations. Families gather '
          'for meals together; non-vegetarian dishes are traditionally prepared.',
    ),

    // ── Chaitra (Telugu Month 1) ────────────────────────────────────────────
    Festival(
      nameTe: 'ఉగాది',
      nameEn: 'Ugadi',
      type: FestivalType.tithi,
      teluguMonth: 1,
      paksha: 1,
      tithi: 1,
      descriptionEn:
          'Telugu New Year — the first day of Chaitra month (Shukla Pratipada). '
          'Per the Brahma Purana, Lord Brahma began the creation of the universe '
          'on this day. The famous Ugadi Pachadi — a chutney of six tastes '
          '(sweet, sour, bitter, pungent, salty, astringent) — symbolises the '
          'varied experiences of life in the coming year.',
    ),
    Festival(
      nameTe: 'శ్రీ రామ నవమి',
      nameEn: 'Sri Rama Navami',
      type: FestivalType.tithi,
      teluguMonth: 1,
      paksha: 1,
      tithi: 9,
      descriptionEn:
          'Birth anniversary of Lord Rama, the 7th avatar of Vishnu. Per Valmiki '
          'Ramayana, Rama was born at midday (Abhijit Muhurtha) in Ayodhya on '
          'Chaitra Shukla Navami, when the Sun was in Mesha Rashi and Punarvasu '
          'nakshatra was prominent. The midday solar alignment makes this the most '
          'auspicious moment of the day.',
    ),
    Festival(
      nameTe: 'హనుమాన్ జయంతి',
      nameEn: 'Hanuman Jayanti',
      type: FestivalType.tithi,
      teluguMonth: 1,
      paksha: 1,
      tithi: 15,
      descriptionEn:
          'Birth anniversary of Lord Hanuman, the devoted disciple of Rama. '
          'Born on Chaitra Shukla Purnima, Hanuman is considered the son of '
          'Vayu (wind god) and possesses immense strength, speed, and wisdom. '
          'His story in the Ramayana exemplifies selfless devotion (Bhakti).',
    ),

    // ── Vaisakha (Month 2) ────────────────────────────────────────────────
    Festival(
      nameTe: 'అక్షయ తృతీయ',
      nameEn: 'Akshaya Tritiya',
      type: FestivalType.tithi,
      teluguMonth: 2,
      paksha: 1,
      tithi: 3,
      descriptionEn:
          'Considered one of the most auspicious days of the year — any good deed '
          'begun on Akshaya (indestructible) Tritiya never diminishes. This is also '
          'the birthday of Parashurama (6th avatar of Vishnu) and the day Sudama '
          'visited Krishna in Dwarka. Both the Sun and Moon are exalted, making '
          'this astronomically unique.',
    ),
    Festival(
      nameTe: 'నరసింహ జయంతి',
      nameEn: 'Narasimha Jayanti',
      type: FestivalType.tithi,
      teluguMonth: 2,
      paksha: 1,
      tithi: 14,
      descriptionEn:
          'Appearance of Lord Narasimha (half-lion avatar of Vishnu), who destroyed '
          'the demon Hiranyakashipu at twilight (neither day nor night) to protect '
          'his devotee Prahlada. The Chaturdashi tithi at Pradosha (dusk) time holds '
          'special significance — the Lord emerged from a pillar at sunset. '
          'Observed with fasting until dusk.',
    ),

    // ── Ashadha (Month 4) ─────────────────────────────────────────────────
    Festival(
      nameTe: 'గురు పౌర్ణమి',
      nameEn: 'Guru Purnima',
      type: FestivalType.tithi,
      teluguMonth: 4,
      paksha: 1,
      tithi: 15,
      descriptionEn:
          'Full moon of Ashadha month, dedicated to honouring the Guru (teacher). '
          'Also called Vyasa Purnima — the birthday of Veda Vyasa, who compiled '
          'the four Vedas, 18 Puranas, and authored the Mahabharata. The Purnima '
          'also marks the beginning of Chaturmasya (four-month Vedic study period).',
    ),

    // ── Shravana (Month 5) ────────────────────────────────────────────────
    Festival(
      nameTe: 'నాగ పంచమి',
      nameEn: 'Naga Panchami',
      type: FestivalType.tithi,
      teluguMonth: 5,
      paksha: 1,
      tithi: 5,
      descriptionEn:
          'Worship of serpent gods (Nagas) on Shravana Shukla Panchami. In Hindu '
          'cosmology, serpents guard the earth, water bodies, and the underworld. '
          'The fifth tithi is associated with the Naga clan. Per Mahabharata, the '
          'serpent king Takshaka resides near the River Ganga, and appeasing Nagas '
          'protects against snake bites and bestows blessings.',
    ),
    Festival(
      nameTe: 'రక్షాబంధన్',
      nameEn: 'Raksha Bandhan',
      type: FestivalType.tithi,
      teluguMonth: 5,
      paksha: 1,
      tithi: 15,
      descriptionEn:
          'Sisters tie a sacred thread (Rakhi) on their brothers\' wrists as a '
          'symbol of protection and love. Per the Bhavishya Purana, Indra\'s wife '
          'Shachi tied a protective thread on Indra before his battle with Vritra, '
          'ensuring victory. The full moon of Shravana is also the day for '
          'Brahmins to renew the sacred thread (Yajnopavita).',
    ),
    Festival(
      nameTe: 'శ్రీ కృష్ణ జన్మాష్టమి',
      nameEn: 'Krishna Janmashtami',
      type: FestivalType.tithi,
      teluguMonth: 5,
      paksha: 2,
      tithi: 8,
      observedAtNight: true,
      descriptionEn:
          'Birth of Lord Krishna at midnight (Nishita Kala) in Mathura\'s prison, '
          'during Krishna Paksha Ashtami when Rohini nakshatra was prominent. '
          'Per Bhagavata Purana, the prison doors opened miraculously and Vasudeva '
          'carried the newborn across the Yamuna. Observed with midnight puja, '
          'fasting throughout the day, and breaking fast only after midnight.',
    ),

    // ── Bhadrapada (Month 6) ──────────────────────────────────────────────
    Festival(
      nameTe: 'వినాయక చవితి',
      nameEn: 'Vinayaka Chaturthi',
      type: FestivalType.tithi,
      teluguMonth: 6,
      paksha: 1,
      tithi: 4,
      descriptionEn:
          'Birthday of Lord Ganesha, remover of obstacles. Per Shiva Purana, '
          'Parvati created Ganesha from clay to guard her chamber. Shiva severed '
          'his head and replaced it with an elephant\'s. The Moon is forbidden '
          'to be viewed on this night — per Bhagavata Purana, the Moon laughed '
          'at Ganesha and was cursed: anyone who sees the Moon on Chaturthi '
          'will face false accusations.',
    ),
    Festival(
      nameTe: 'అనంత చతుర్దశి',
      nameEn: 'Anant Chaturdashi',
      type: FestivalType.tithi,
      teluguMonth: 6,
      paksha: 1,
      tithi: 14,
      descriptionEn:
          'The 14th day of Bhadrapada Shukla Paksha; concludes the 10-day Ganesh '
          'festival with idol immersion. Lord Ananta (the infinite form of Vishnu '
          'on Adishesha) is worshipped. Per Mahabharata, Yudhishthira observed '
          'this vrata for 14 years to recover the Pandavas\' lost kingdom.',
    ),

    // ── Ashvayuja (Month 7) ───────────────────────────────────────────────
    Festival(
      nameTe: 'మహాలయ అమావాస్య',
      nameEn: 'Mahalaya Amavasya',
      type: FestivalType.tithi,
      teluguMonth: 7,
      paksha: 2,
      tithi: 15,
      descriptionEn:
          'The final day of Pitru Paksha (fortnight of ancestors); the most '
          'important day for Shraddha (ancestral rites). Per Garuda Purana, '
          'the veil between the living and ancestral realms is thinnest on this '
          'Amavasya, allowing offerings to reach ancestors most effectively. '
          'Families perform Tarpana (water offerings) at rivers.',
    ),
    Festival(
      nameTe: 'దసరా / విజయదశమి',
      nameEn: 'Dasara / Vijayadasami',
      type: FestivalType.tithi,
      teluguMonth: 7,
      paksha: 1,
      tithi: 10,
      descriptionEn:
          'Victory of good over evil. On this Dashami, Rama slew Ravana after '
          'nine nights of worship (Ramayana). Simultaneously, Goddess Durga '
          'defeated Mahishasura on the tenth day after nine nights of battle '
          '(Devi Mahatmyam). The crossing of boundaries (Seemollanghana) '
          'and Shastra Puja (worship of tools/weapons) mark this day.',
    ),
    Festival(
      nameTe: 'అట్ల తద్ది',
      nameEn: 'Atla Taddi',
      type: FestivalType.tithi,
      teluguMonth: 7,
      paksha: 2,
      tithi: 8,
      descriptionEn:
          'An exclusive Telugu festival where unmarried girls and women fast and '
          'worship decorated pots (Atla) for the well-being of their brothers '
          'and future husbands. Associated with the story of Usha and Aniruddha '
          'from the Bhagavata Purana. Celebrated on Krishna Ashtami of Ashvayuja.',
    ),

    // ── Kartika (Month 8) ─────────────────────────────────────────────────
    Festival(
      nameTe: 'ధన్ తేరస్',
      nameEn: 'Dhanteras',
      type: FestivalType.tithi,
      teluguMonth: 8,
      paksha: 2,
      tithi: 13,
      descriptionEn:
          'First day of Diwali celebrations. Lord Dhanvantari (god of Ayurveda '
          'and medicine) emerged from the cosmic ocean on this Trayodashi during '
          'Samudra Manthan, carrying the pot of immortality (Amrita). New '
          'utensils and gold are bought as symbols of prosperity.',
    ),
    Festival(
      nameTe: 'నరక చతుర్దశి',
      nameEn: 'Naraka Chaturdashi',
      type: FestivalType.tithi,
      teluguMonth: 8,
      paksha: 2,
      tithi: 14,
      descriptionEn:
          'Krishna (with Satyabhama) slew the demon Narakasura on this '
          'Chaturdashi, liberating 16,000 captive women. Celebrated before '
          'sunrise with oil baths (Abhyanga Snanam) and bursting crackers '
          'to symbolise destruction of evil. This is the second night of '
          'Diwali and often called Chhoti Diwali.',
    ),
    Festival(
      nameTe: 'దీపావళి',
      nameEn: 'Deepavali',
      type: FestivalType.tithi,
      teluguMonth: 8,
      paksha: 2,
      tithi: 15,
      descriptionEn:
          'The festival of lights. Per Ramayana, Lord Rama returned to Ayodhya '
          'after 14 years of exile on this Amavasya — citizens lit thousands of '
          'oil lamps to guide his path home. Also marks Goddess Lakshmi\'s '
          'emergence from Samudra Manthan and is the darkest night of the year, '
          'made brilliant by lamps symbolising the triumph of light over darkness.',
    ),
    Festival(
      nameTe: 'నాగుల చవితి',
      nameEn: 'Nagula Chaviti',
      type: FestivalType.tithi,
      teluguMonth: 8,
      paksha: 1,
      tithi: 4,
      descriptionEn:
          'A Telugu festival on Kartika Shukla Chaturthi where women worship '
          'snake gods (Nagas) near anthills for the health and longevity of '
          'their children. Milk is poured into snake burrows as an offering.',
    ),
    Festival(
      nameTe: 'కార్తీక పౌర్ణమి',
      nameEn: 'Karthika Purnima',
      type: FestivalType.tithi,
      teluguMonth: 8,
      paksha: 1,
      tithi: 15,
      descriptionEn:
          'The full moon of Kartika — among the most sacred days of the Hindu '
          'calendar. Lord Shiva destroyed the demon Tripurasura on this night '
          '(Tripurotsava). It is also the birth of Kartikeya (Subrahmanya) and '
          'the day the Buddha gave his first sermon at Sarnath. Lighting '
          'Karthika deepams in temples is the central observance.',
    ),

    // ── Margashira (Month 9) ──────────────────────────────────────────────
    Festival(
      nameTe: 'వైకుంఠ ఏకాదశి',
      nameEn: 'Vaikunta Ekadashi',
      type: FestivalType.tithi,
      teluguMonth: 9,
      paksha: 1,
      tithi: 11,
      descriptionEn:
          'The Vaikunta Dwara (gate of Vaikuntha — Vishnu\'s abode) is believed '
          'to open on this Ekadashi of Margashira, per the Padma Purana. '
          'Devotees who pass through the Vaikunta Dwaram at Tirupati or other '
          'Vishnu temples on this day attain liberation. A complete fast and '
          'all-night vigil (Jagaranam) are observed.',
    ),

    // ── Magha (Month 11) ──────────────────────────────────────────────────
    Festival(
      nameTe: 'సరస్వతి పూజ',
      nameEn: 'Saraswati Puja / Vasant Panchami',
      type: FestivalType.tithi,
      teluguMonth: 11,
      paksha: 1,
      tithi: 5,
      descriptionEn:
          'Goddess Saraswati (of knowledge, music, arts, and wisdom) is worshipped '
          'on Magha Shukla Panchami. This is the first day of spring (Vasant Ritu) '
          'astronomically — the fifth day after the Full Moon when winter recedes. '
          'Students worship their books and instruments (Vidyarambham for children '
          'beginning education). Yellow colour is worn to signify the blooming '
          'mustard fields of spring.',
    ),
    Festival(
      nameTe: 'రథ సప్తమి',
      nameEn: 'Ratha Saptami',
      type: FestivalType.tithi,
      teluguMonth: 11,
      paksha: 1,
      tithi: 7,
      descriptionEn:
          'The Sun God (Surya) turns his golden chariot — pulled by 7 horses '
          'representing the 7 colours of light and 7 days of the week — fully '
          'northward on this Saptami of Magha Shukla. This marks the peak of '
          'Uttarayana. Per Skanda Purana, Surya\'s energy reaches maximum '
          'daytime strength from this day. Surya Namaskar and sunrise '
          'worship are central observances.',
    ),

    // ── Magha (Month 11) continued ────────────────────────────────────────
    Festival(
      nameTe: 'మహా శివరాత్రి',
      nameEn: 'Maha Shivaratri',
      type: FestivalType.tithi,
      // Magha (11) in Amavasyant (Telugu) system — the month ending at the
      // Magha Amavasya. North Indian Purnimanta calendars call this "Phalguna"
      // because the same tithi falls before the Phalguna Purnima, but in
      // the Amavasyant month is named by the NEXT Amavasya (Kumbha rashi → Magha).
      teluguMonth: 11,
      paksha: 2,
      tithi: 14,
      observedAtNight: true,
      descriptionEn:
          'The great night of Shiva — observed on Krishna Chaturdashi of Phalguna. '
          'Per Shiva Purana, Shiva performed his cosmic dance (Tandava) at midnight. '
          'A hunter sheltering in a bilva tree accidentally dropped leaves onto a '
          'Shivalinga below while staying awake all night — Shiva liberated him for '
          'this unintentional act of devotion. Four praharas (night-watches) of '
          'puja are performed, with complete fasting and night vigil.',
    ),
    // ── Phalguna (Month 12) ───────────────────────────────────────────────
    Festival(
      nameTe: 'హోలీ',
      nameEn: 'Holi',
      type: FestivalType.tithi,
      teluguMonth: 12,
      paksha: 1,
      tithi: 15,
      descriptionEn:
          'The festival of colours on Phalguna Purnima. The demoness Holika '
          '(immune to fire) sat in a bonfire holding devotee Prahlada — but '
          'Prahlada\'s devotion to Vishnu saved him and Holika burned instead '
          '(Bhagavata Purana). The bonfire (Holika Dahan) is lit the night '
          'before; colours are played the following day to celebrate the '
          'arrival of spring and Krishna\'s playful tradition with Radha.',
    ),
  ];
}
