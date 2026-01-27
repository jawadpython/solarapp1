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
  final double kwhMonth; // E_month
  final double kwhDay; // E_day
  final double kwhCovered; // E_covered
  final double pvPowerKW; // P_pv
  final int panels; // N
  final double pvKwc; // PV_kwc (installed capacity)
  final double inverterKW; // Selected inverter power
  final double coveragePct; // coverage_pct (30-100%)
  final String voltage; // 220V or 380V
  final bool showVoltageWarning; // Warning if inverter > 5kW and voltage = 220V
  final double savingMonth;
  final double savingYear;
  final double saving10Y;
  final double saving20Y;
  final double billAfter; // New bill after solar
  final int panelWp;

  OnGridResult({
    required super.systemType,
    required super.regionCode,
    required super.sunHours,
    required this.montantDH,
    required this.kwhMonth,
    required this.kwhDay,
    required this.kwhCovered,
    required this.pvPowerKW,
    required this.panels,
    required this.pvKwc,
    required this.inverterKW,
    required this.coveragePct,
    required this.voltage,
    required this.showVoltageWarning,
    required this.savingMonth,
    required this.savingYear,
    required this.saving10Y,
    required this.saving20Y,
    required this.billAfter,
    required this.panelWp,
  });
}

/// Result for HYBRID system
class HybridResult extends CalculatorResult {
  final double montantDH;
  final double kwhMonth; // E_mois
  final double kwhDay; // E_jour
  final double kwhTarget; // E_target
  final String profile; // Profile name (Maison, Commerce, etc.)
  final double dayRatio; // Jour_ratio
  final double nightRatio; // Nuit_ratio
  final double kwhDayPart; // E_day_part
  final double kwhNight; // E_nuit
  final double batteryKwh; // Battery capacity (kWh)
  final double batteryUsable; // Battery_usable
  final double kwhNightCovered; // E_nuit_couvert
  final double kwhGridNight; // E_grid_nuit
  final double nightCoveragePct; // Night coverage percentage
  final double pvPowerKW; // P_PV
  final int panels; // N
  final double pvKwc; // PV_kWc
  final double inverterKW; // Recommended inverter
  final double coveragePct; // Coverage percentage (30-100%)
  final String voltage; // 220V or 380V
  final bool showVoltageWarning; // Warning if inverter > 5kW and voltage = 220V
  final double savingMonth;
  final double savingYear;
  final double saving10Y;
  final double saving20Y;
  final double billAfter; // Facture_apres
  final int panelWp;

  HybridResult({
    required super.systemType,
    required super.regionCode,
    required super.sunHours,
    required this.montantDH,
    required this.kwhMonth,
    required this.kwhDay,
    required this.kwhTarget,
    required this.profile,
    required this.dayRatio,
    required this.nightRatio,
    required this.kwhDayPart,
    required this.kwhNight,
    required this.batteryKwh,
    required this.batteryUsable,
    required this.kwhNightCovered,
    required this.kwhGridNight,
    required this.nightCoveragePct,
    required this.pvPowerKW,
    required this.panels,
    required this.pvKwc,
    required this.inverterKW,
    required this.coveragePct,
    required this.voltage,
    required this.showVoltageWarning,
    required this.savingMonth,
    required this.savingYear,
    required this.saving10Y,
    required this.saving20Y,
    required this.billAfter,
    required this.panelWp,
  });
}

/// Result for OFF-GRID system
class OffGridResult extends CalculatorResult {
  final String profile; // Profile name (Maison petite, etc.)
  final double kwhDay; // E_day (from profile)
  final int autonomyDays; // 1, 2, or 3
  final double pvPowerKW; // P_PV
  final int panels; // N
  final double pvKwc; // PV_kWc
  final double batteryKwh; // Battery_kWh (calculated)
  final double inverterKW; // Recommended inverter
  final String? voltage; // Optional: 220V or 380V
  final bool showVoltageWarning; // Warning if inverter > 5kW and voltage = 220V
  final String? recommendedVoltage; // Recommended voltage if not chosen by user
  final int panelWp;

  OffGridResult({
    required super.systemType,
    required super.regionCode,
    required super.sunHours,
    required this.profile,
    required this.kwhDay,
    required this.autonomyDays,
    required this.pvPowerKW,
    required this.panels,
    required this.pvKwc,
    required this.batteryKwh,
    required this.inverterKW,
    this.voltage,
    required this.showVoltageWarning,
    this.recommendedVoltage,
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
  // VFD/Variateur information (for AC pumps)
  final double? vfdRecommendedKW;
  final String? vfdType;
  final String? recommendedVoltage;
  final bool showVoltageWarning;

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
    this.vfdRecommendedKW,
    this.vfdType,
    this.recommendedVoltage,
    this.showVoltageWarning = false,
  });
}

