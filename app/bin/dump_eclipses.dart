import '../lib/core/calculations/eclipse.dart';

String fmt(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '${dt.day}/${dt.month}/${dt.year} $h:$m IST';
}

void main() {
  for (final year in [2025, 2026]) {
    print('=== $year ===');
    final eclipses = Eclipse.findInYear(year);
    for (final e in eclipses) {
      print('${e.type.nameEn} — detected on ${e.date.day}/${e.date.month}/${e.date.year}');
      print('  Sparsha:         ${fmt(e.sparsha)}');
      print('  Moksha:          ${fmt(e.moksha)}');
      print('  SutakStart:      ${fmt(e.sutakStart)}');
      print('  SutakVulnerable: ${fmt(e.sutakStartVulnerable)}');
      print('  Duration:        ${e.moksha.difference(e.sparsha).inMinutes} min');
      print('');
    }
  }
}
