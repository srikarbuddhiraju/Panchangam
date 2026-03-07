import 'package:panchangam/core/calculations/sunrise_sunset.dart';

const double lat = 17.3850, lng = 78.4867;

void main() {
  final entries = [
    [DateTime.utc(2026,1,29), 'Jan29 Thu Mrigashira', 5, 'Ra', 20, 3, false],
    [DateTime.utc(2026,1,30), 'Jan30 Fri Ardra',      6, 'Di', 17, 23, false],
    [DateTime.utc(2026,1,31), 'Jan31 Sat Punarvasu',  7, 'Ra', 23, 12, false],
    [DateTime.utc(2026,2,1),  'Feb01 Sun Pushyami',   8, 'Ra', 18, 20, false],
    [DateTime.utc(2026,2,2),  'Feb02 Mon Ashlesha',   9, 'Ra', 22, 16, false],
    [DateTime.utc(2026,2,3),  'Feb03 Tue Magha',     10, 'Ra', 21, 12, false],
    [DateTime.utc(2026,2,4),  'Feb04 Wed PvPhalguni',11, 'Di', 17, 21, false],
    [DateTime.utc(2026,2,5),  'Feb05 Thu UtPhalguni',12, 'Di', 17,  5, false],
    [DateTime.utc(2026,2,6),  'Feb06 Fri Hasta',     13, 'Ra', 19, 25, false],
    [DateTime.utc(2026,2,7),  'Feb07 Sat Chitra',    14, 'Ra', 20, 33, false],
    [DateTime.utc(2026,2,8),  'Feb08 Sun Swati',     15, 'Ra', 19, 56, false],
    [DateTime.utc(2026,2,9),  'Feb09 Mon Vishaka',   16, 'Ra', 22, 14, false],
    [DateTime.utc(2026,2,10), 'Feb10 Tue Vishaka',   16, 'Ra', 23,  1, false],
    [DateTime.utc(2026,2,11), 'Feb11 Wed Anuradha',  17, 'Ra',  3, 23, true],
    [DateTime.utc(2026,2,13), 'Feb13 Fri Mula',      19, 'Di',  8, 30, false],
    [DateTime.utc(2026,2,14), 'Feb14 Sat PvAshadha', 20, 'Di', 12, 28, false],
    [DateTime.utc(2026,2,15), 'Feb15 Sun UtAshadha', 21, 'Di', 12, 35, false],
    [DateTime.utc(2026,2,16), 'Feb16 Mon Shravana',  22, 'Di',  9, 46, false],
    [DateTime.utc(2026,2,17), 'Feb17 Tue Dhanishtha',23, 'Di', 10, 49, false],
  ];

  String p(int n) => n.toString().padLeft(2,'0');

  for (final e in entries) {
    final date = e[0] as DateTime;
    final lbl  = e[1] as String;
    final nk   = e[2] as int;
    final type = e[3] as String;
    final h    = e[4] as int;
    final m    = e[5] as int;
    final next = e[6] as bool;

    final times = SunriseSunset.computeNOAA(date, lat, lng);
    final sunrise = times[0]; final sunset = times[1];

    var amrita = DateTime.utc(date.year, date.month, date.day, h, m);
    if (next) amrita = amrita.add(const Duration(days: 1));

    final int off = type == 'Di'
        ? amrita.difference(sunrise).inMinutes
        : -amrita.difference(sunset).inMinutes;

    final sr = '${p(sunrise.hour)}:${p(sunrise.minute)}';
    final ss = '${p(sunset.hour)}:${p(sunset.minute)}';
    final vara = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][date.weekday % 7];
    print("E('$lbl', DateTime(${date.year},${date.month.toString().padLeft(2,' ')},${date.day.toString().padLeft(2,' ')}), $nk, ?, $off),  // $type SR=$sr SS=$ss");
  }
}
