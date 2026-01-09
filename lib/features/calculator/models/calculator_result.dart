/// Base result class for all calculator types
abstract class CalculatorResult {
  final String systemType;
  final String regionCode;
  final double sunHours;

  CalculatorResult({
    required this.systemType,
    required this.regionCode,
    required this.sunHours,
  });
}

/// Result for ON-GRID system
class OnGridResult extends CalculatorResult {
  final double montantDH;
  final double kwhMonth;
  final double powerKW;
  final int panels;
  final double savingRate; // 0.70 (70%)
  final double savingMonth;
  final double savingYear;
  final double saving10Y;
  final double saving20Y;
  final String usageType;
  final int panelWp;

  OnGridResult({
    required super.systemType,
    required super.regionCode,
    required super.sunHours,
    required this.montantDH,
    required this.kwhMonth,
    required this.powerKW,
    required this.panels,
    required this.savingRate,
    required this.savingMonth,
    required this.savingYear,
    required this.saving10Y,
    required this.saving20Y,
    required this.usageType,
    required this.panelWp,
  });
}

/// Result for HYBRID system
class HybridResult extends CalculatorResult {
  final double montantDH;
  final double kwhMonth;
  final double powerKW;
  final int panels;
  final double savingRate; // 0.70 to 0.90
  final double savingMonth;
  final double savingYear;
  final double saving10Y;
  final double saving20Y;
  final int? batteryKwh;
  final double? hoursCover; // Battery coverage in hours (0-24)
  final int panelWp;

  HybridResult({
    required super.systemType,
    required super.regionCode,
    required super.sunHours,
    required this.montantDH,
    required this.kwhMonth,
    required this.powerKW,
    required this.panels,
    required this.savingRate,
    required this.savingMonth,
    required this.savingYear,
    required this.saving10Y,
    required this.saving20Y,
    this.batteryKwh,
    this.hoursCover,
    required this.panelWp,
  });
}

/// Result for OFF-GRID system
class OffGridResult extends CalculatorResult {
  final double kwhPerDay;
  final double powerKW;
  final int panels;
  final double batteryKwh; // Provided by user
  final double batteryRequired; // Calculated required capacity
  final int autonomyDays;
  final int panelWp;

  OffGridResult({
    required super.systemType,
    required super.regionCode,
    required super.sunHours,
    required this.kwhPerDay,
    required this.powerKW,
    required this.panels,
    required this.batteryKwh,
    required this.batteryRequired,
    required this.autonomyDays,
    required this.panelWp,
  });
}

/// Result for POMPAGE system
class PumpingResult extends CalculatorResult {
  final double flowValue; // m3/h or L/min
  final String flowUnit;
  final double hmtMeters;
  final double hoursPerDay;
  final String pumpType; // AC or DC
  final double pumpPowerKW;
  final double pvPowerKW;
  final int panels;
  final int panelWp;

  PumpingResult({
    required super.systemType,
    required super.regionCode,
    required super.sunHours,
    required this.flowValue,
    required this.flowUnit,
    required this.hmtMeters,
    required this.hoursPerDay,
    required this.pumpType,
    required this.pumpPowerKW,
    required this.pvPowerKW,
    required this.panels,
    required this.panelWp,
  });
}

