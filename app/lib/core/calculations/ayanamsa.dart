import 'julian_day.dart';

/// Lahiri Ayanamsa — the official Government of India sidereal correction.
///
/// Tropical longitude − Ayanamsa = Sidereal longitude
///
/// Formula: based on precession from epoch J1900.0
/// Epoch J1900.0: JD = 2415020.0, ayanamsa = 22°27'38" = 22.46055556°
/// Annual rate: 50.2388475 arc-seconds/year
class Ayanamsa {
  Ayanamsa._();

  static const double _epochJD = 2415020.0; // J1900.0
  static const double _epochAyanamsa = 22.46055556; // degrees at J1900.0
  static const double _annualRate = 50.2388475; // arc-seconds per year

  /// Returns the Lahiri Ayanamsa in degrees for a given Julian Day (UT).
  static double lahiri(double jd) {
    final double yearsSince1900 = (jd - _epochJD) / 365.25;
    final double ayanamsa =
        _epochAyanamsa + (_annualRate * yearsSince1900 / 3600.0);
    return ayanamsa;
  }

  /// Convert a tropical longitude to sidereal longitude using Lahiri Ayanamsa.
  static double toSidereal(double tropicalLon, double jd) {
    return JulianDay.normalize360(tropicalLon - lahiri(jd));
  }
}
