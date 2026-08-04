import 'dart:math' as math;

/// Kaaba coordinates (Mecca).
const double kMeccaLat = 21.4225;
const double kMeccaLon = 39.8262;

/// Default location (e.g. Kurdistan center) when user location is unavailable.
const double kDefaultLat = 36.2;
const double kDefaultLon = 44.5;

/// Known coordinates for Kurdistan cities to fallback or manual selection.
const Map<String, List<double>> kCityCoordinates = {
  'Slemany': [35.5558, 45.4351],
  'Slemani': [35.5558, 45.4351],
  'Hewler': [36.1901, 44.0090],
  'Hawler': [36.1901, 44.0090],
  'Erbil': [36.1901, 44.0090],
  'Duhok': [36.8679, 42.9489],
  'Zakho': [37.1492, 42.6822],
  'Zaxo': [37.1492, 42.6822],
  'Halabja': [35.1778, 45.9861],
  'Kirkuk': [35.4674, 44.3831],
  'Kalar': [34.6293, 45.3117],
  'Ranya': [36.2544, 44.8828],
  'Chamchamal': [35.5342, 44.8322],
  'Darbandixan': [35.1093, 45.6983],
  'Kfri': [34.7208, 44.9654],
  'Amedi': [37.0911, 43.4883],
  'Penjwin': [35.6253, 45.9614],
  'SaidSadiq': [35.3725, 45.8697],
  'Dukan': [35.9494, 44.9547],
};

/// Computes qibla bearing in degrees (0–360) from North clockwise from [latitude] and [longitude].
double qiblaBearingFrom(double latitude, double longitude) {
  final phi1 = latitude * math.pi / 180.0;
  final lambda1 = longitude * math.pi / 180.0;
  final phi2 = 21.422487 * math.pi / 180.0;
  final lambda2 = 39.826206 * math.pi / 180.0;
  
  final deltaLambda = lambda2 - lambda1;

  final y = math.sin(deltaLambda) * math.cos(phi2);
  final x = math.cos(phi1) * math.sin(phi2) -
      math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);
      
  final theta = math.atan2(y, x) * 180.0 / math.pi;
  final bearing = (theta + 360.0) % 360.0;
  
  return bearing;
}
