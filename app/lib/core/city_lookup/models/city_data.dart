/// A city record with coordinates and timezone for Panchangam calculations.
///
/// [utcOffsetMinutes] is the city's standard UTC offset in minutes.
/// e.g. IST = 330, UAE = 240, London = 0, New York = -300.
/// DST is not applied — times may be off by 1 hour during daylight saving.
class CityData {
  final String name;
  final String state;
  final double lat;
  final double lng;

  /// UTC offset in minutes. Defaults to 330 (IST) if not specified.
  final int utcOffsetMinutes;

  const CityData({
    required this.name,
    required this.state,
    required this.lat,
    required this.lng,
    this.utcOffsetMinutes = 330,
  });

  double get utcOffsetHours => utcOffsetMinutes / 60.0;

  /// True if this city uses IST (i.e. is in India).
  bool get isIST => utcOffsetMinutes == 330;

  factory CityData.fromJson(Map<String, dynamic> json) => CityData(
        name: json['n'] as String,
        state: json['s'] as String,
        lat: (json['lt'] as num).toDouble(),
        lng: (json['lg'] as num).toDouble(),
        utcOffsetMinutes: (json['tz'] as num?)?.toInt() ?? 330,
      );

  Map<String, dynamic> toJson() => {
        'n': name,
        's': state,
        'lt': lat,
        'lg': lng,
        'tz': utcOffsetMinutes,
      };

  @override
  String toString() => '$name, $state';

  @override
  bool operator ==(Object other) =>
      other is CityData && other.name == name && other.state == state;

  @override
  int get hashCode => Object.hash(name, state);
}
