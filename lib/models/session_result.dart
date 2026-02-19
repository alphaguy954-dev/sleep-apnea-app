class SessionResult {
  final List<int> minutePredictions;
  final List<double> apneaProbabilities;
  final int totalMinutes;
  final int apneaWindows;
  final double ahiEstimate;
  final String riskLevel;
  final double meanSpo2;
  final double minSpo2;
  final int minutesBelow90;
  final double meanHr;
  final double meanRmssd;
  final double meanSdnn;
  final int maxConsecutiveApnea;
  final List<double> hrValues;
  final List<double> spo2Values;

  SessionResult({
    required this.minutePredictions,
    required this.apneaProbabilities,
    required this.totalMinutes,
    required this.apneaWindows,
    required this.ahiEstimate,
    required this.riskLevel,
    required this.meanSpo2,
    required this.minSpo2,
    required this.minutesBelow90,
    required this.meanHr,
    required this.meanRmssd,
    required this.meanSdnn,
    required this.maxConsecutiveApnea,
    required this.hrValues,
    required this.spo2Values,
  });

  factory SessionResult.fromJson(Map<String, dynamic> json) {
    return SessionResult(
      minutePredictions:    List<int>.from(json['minute_predictions']),
      apneaProbabilities:   List<double>.from(json['apnea_probabilities'].map((e) => e.toDouble())),
      totalMinutes:         json['total_minutes'],
      apneaWindows:         json['apnea_windows'],
      ahiEstimate:          json['ahi_estimate'].toDouble(),
      riskLevel:            json['risk_level'],
      meanSpo2:             json['mean_spo2'].toDouble(),
      minSpo2:              json['min_spo2'].toDouble(),
      minutesBelow90:       json['minutes_below_90'],
      meanHr:               json['mean_hr'].toDouble(),
      meanRmssd:            json['mean_rmssd'].toDouble(),
      meanSdnn:             json['mean_sdnn'].toDouble(),
      maxConsecutiveApnea:  json['max_consecutive_apnea'],
      hrValues:             List<double>.from(json['hr_values'].map((e) => e.toDouble())),
      spo2Values:           List<double>.from(json['spo2_values'].map((e) => e.toDouble())),
    );
  }

  Map<String, dynamic> toJson() => {
    'minute_predictions':    minutePredictions,
    'apnea_probabilities':   apneaProbabilities,
    'total_minutes':         totalMinutes,
    'apnea_windows':         apneaWindows,
    'ahi_estimate':          ahiEstimate,
    'risk_level':            riskLevel,
    'mean_spo2':             meanSpo2,
    'min_spo2':              minSpo2,
    'minutes_below_90':      minutesBelow90,
    'mean_hr':               meanHr,
    'mean_rmssd':            meanRmssd,
    'mean_sdnn':             meanSdnn,
    'max_consecutive_apnea': maxConsecutiveApnea,
    'hr_values':             hrValues,
    'spo2_values':           spo2Values,
  };

  // Helpers for UI
  String get totalDuration {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h}h ${m}m';
  }

  String get ahiCategory {
    if (ahiEstimate < 5)  return 'Normal';
    if (ahiEstimate < 15) return 'Mild';
    if (ahiEstimate < 30) return 'Moderate';
    return 'Severe';
  }
}
