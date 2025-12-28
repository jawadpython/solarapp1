class SolarResult {
  final double kwhMonth;
  final double powerKW;
  final int panels;
  final double savingRate;
  final double savingMonth;
  final double savingYear;
  final double saving10Y;
  final double saving20Y;
  final double usedSunH;
  final String monthName;
  final String regionCode;

  SolarResult({
    required this.kwhMonth,
    required this.powerKW,
    required this.panels,
    required this.savingRate,
    required this.savingMonth,
    required this.savingYear,
    required this.saving10Y,
    required this.saving20Y,
    required this.usedSunH,
    required this.monthName,
    required this.regionCode,
  });

  @override
  String toString() {
    return 'SolarResult('
        'kwhMonth: $kwhMonth, '
        'powerKW: $powerKW, '
        'panels: $panels, '
        'savingRate: $savingRate, '
        'savingMonth: $savingMonth, '
        'savingYear: $savingYear, '
        'saving10Y: $saving10Y, '
        'saving20Y: $saving20Y, '
        'usedSunH: $usedSunH, '
        'monthName: $monthName, '
        'regionCode: $regionCode'
        ')';
  }
}

