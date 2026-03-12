class ApiData {
  final double? vMod;
  final double? vReal;
  final double? vMax;
  final double? vAverage;
  final double? distance;
  final double? slopePct;
  final double? inclinationDeg;
  final double? temperatureC;
  final double? pressureHpa;
  final double? humidityPct;
  final double? voltage;
  final double? batteryPercent;

  ApiData({
    required this.vMod,
    required this.vReal,
    required this.vMax,
    required this.vAverage,
    required this.distance,
    required this.slopePct,
    required this.inclinationDeg,
    required this.temperatureC,
    required this.pressureHpa,
    required this.humidityPct,
    required this.voltage,
    required this.batteryPercent,
  });

  factory ApiData.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return ApiData(
      vMod: toDouble(json['v_mod']),
      vReal: toDouble(json['v_real']),
      vMax: toDouble(json['v_max']),
      vAverage: toDouble(json['v_average']),
      distance: toDouble(json['distance']),
      slopePct: toDouble(json['slope_pct']),
      inclinationDeg: toDouble(json['inclination_deg']),
      temperatureC: toDouble(json['temperature_C']),
      pressureHpa: toDouble(json['pressure_hPa']),
      humidityPct: toDouble(json['humidity_pct']),
      voltage: toDouble(json['voltage']),
      batteryPercent: toDouble(json['batteryPercent']),
    );
  }
}