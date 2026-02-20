/// A city record with coordinates for Panchangam calculations.
class CityData {
  final String name;
  final String state;
  final double lat;
  final double lng;

  const CityData({
    required this.name,
    required this.state,
    required this.lat,
    required this.lng,
  });

  factory CityData.fromJson(Map<String, dynamic> json) => CityData(
        name: json['n'] as String,
        state: json['s'] as String,
        lat: (json['lt'] as num).toDouble(),
        lng: (json['lg'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'n': name,
        's': state,
        'lt': lat,
        'lg': lng,
      };

  @override
  String toString() => '$name, $state';

  @override
  bool operator ==(Object other) =>
      other is CityData && other.name == name && other.state == state;

  @override
  int get hashCode => Object.hash(name, state);
}
