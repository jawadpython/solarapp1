import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:noor_energy/features/calculator/models/calculator_result.dart';
import 'package:noor_energy/features/calculator/services/region_service.dart';

/// V1 Calculator Service with new formulas and constants
class CalculatorV1Service {
  // Calculation Constants (V1)
  static const double prix_kWh = 1.2;
  static const double PR = 0.75; // Performance Ratio
  static const double DoD = 0.8; // Depth of Discharge
  static const double eff_batt = 0.9; // Battery efficiency
  static const double rendement_pompe = 0.5; // Pump efficiency

  // Sun hours by region
  static const Map<String, double> regionSunHours = {
    'Nord': 4.8,
    'Centre': 5.3,
    'Sud': 5.8,
  };

  // Default sun hours if region not found
  static const double defaultSunHours = 5.3;

  final RegionService _regionService = RegionService.instance;

  /// Get sun hours for a region
  /// Uses actual sun hours from region service to ensure different regions produce different results
  Future<double> _getSunHours(String regionCode) async {
    try {
      // Get actual sun hours from region service
      final sunH = await _regionService.getSunHoursByRegion(regionCode);
      
      // Use the actual value to ensure different regions produce different results
      // This ensures that when parameters change, calculations will reflect those changes
      debugPrint('Sun hours for region $regionCode: $sunH');
      return sunH;
    } catch (e) {
      debugPrint('Error getting sun hours: $e');
      return defaultSunHours;
    }
  }

  /// Parse number accepting both comma and dot as decimal separator
  static double? parseNumber(String value) {
    if (value.isEmpty) return null;
    // Replace comma with dot
    final normalized = value.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  /// Calculate ON-GRID system
  Future<OnGridResult> calculateOnGrid({
    required double montantDH,
    required String regionCode,
    required String usageType, // Maison or Commerce
    required int panelWp,
  }) async {
    debugPrint('INPUTS: ON-GRID, montantDH=$montantDH, region=$regionCode, usageType=$usageType, panelWp=$panelWp');

    final sunHours = await _getSunHours(regionCode);

    // Formula: kWh_mois = montantDH / prix_kWh
    final kwhMonth = montantDH / prix_kWh;

    // Formula: P_kW = kWh_mois / (30 * sunHours * PR)
    final powerKW = kwhMonth / (30 * sunHours * PR);

    // Formula: Nb_panneaux = ceil((P_kW * 1000) / panelWp)
    final panels = ((powerKW * 1000) / panelWp).ceil();

    // Savings: ON-GRID depends on usageType
    // Maison: 75%, Commerce: 85%, Industrie: 88%
    final savingRate = usageType == 'Maison' 
        ? 0.75 
        : (usageType == 'Commerce' ? 0.85 : 0.88);
    final savingMonth = montantDH * savingRate;
    final savingYear = savingMonth * 12;
    final saving10Y = savingYear * 10;
    final saving20Y = savingYear * 20;

    final result = OnGridResult(
      systemType: 'ON-GRID',
      regionCode: regionCode,
      sunHours: sunHours,
      montantDH: montantDH,
      kwhMonth: kwhMonth,
      powerKW: powerKW,
      panels: panels,
      savingRate: savingRate,
      savingMonth: savingMonth,
      savingYear: savingYear,
      saving10Y: saving10Y,
      saving20Y: saving20Y,
      usageType: usageType,
      panelWp: panelWp,
    );

    debugPrint('OUTPUTS: kWh_mois=${result.kwhMonth.toStringAsFixed(2)}, P_kW=${result.powerKW.toStringAsFixed(2)}, panels=${result.panels}');
    return result;
  }

  /// Calculate HYBRID system
  Future<HybridResult> calculateHybrid({
    required double montantDH,
    required String regionCode,
    required int panelWp,
    int? batteryKwh, // Optional: 5, 10, 15, 20
  }) async {
    debugPrint('INPUTS: HYBRID, montantDH=$montantDH, region=$regionCode, panelWp=$panelWp, batteryKwh=$batteryKwh');

    final sunHours = await _getSunHours(regionCode);

    // Formula: kWh_mois = montantDH / prix_kWh
    final kwhMonth = montantDH / prix_kWh;

    // Formula: P_kW = kWh_mois / (30 * sunHours * PR)
    final powerKW = kwhMonth / (30 * sunHours * PR);

    // Formula: Nb_panneaux = ceil((P_kW * 1000) / panelWp)
    final panels = ((powerKW * 1000) / panelWp).ceil();

    // Savings: HYBRID 70% to 90% - depends on battery capacity
    // Without battery: 70%, Small battery (≤10kWh): 75%, Large battery (>10kWh): 85%
    double savingRate;
    if (batteryKwh == null || batteryKwh == 0) {
      savingRate = 0.70;  // 70% without battery
    } else if (batteryKwh <= 10) {
      savingRate = 0.75;  // 75% with small battery
    } else {
      savingRate = 0.85;  // 85% with large battery
    }
    final savingMonth = montantDH * savingRate;
    final savingYear = savingMonth * 12;
    final saving10Y = savingYear * 10;
    final saving20Y = savingYear * 20;

    // Battery coverage calculation (if battery provided)
    double? hoursCover;
    if (batteryKwh != null && batteryKwh > 0) {
      // Formula: kWh_jour = kWh_mois / 30
      final kwhDay = kwhMonth / 30;

      // Formula: usable_batt = batt_kWh * DoD * eff_batt
      final usableBatt = batteryKwh * DoD * eff_batt;

      // Formula: avg_kW = kWh_jour / 24
      final avgKW = kwhDay / 24;

      // Formula: hours_cover = usable_batt / avg_kW (limit 0..24)
      if (avgKW > 0) {
        hoursCover = math.min(24.0, math.max(0.0, usableBatt / avgKW));
      } else {
        hoursCover = 0.0;
      }
    }

    final result = HybridResult(
      systemType: 'HYBRID',
      regionCode: regionCode,
      sunHours: sunHours,
      montantDH: montantDH,
      kwhMonth: kwhMonth,
      powerKW: powerKW,
      panels: panels,
      savingRate: savingRate,
      savingMonth: savingMonth,
      savingYear: savingYear,
      saving10Y: saving10Y,
      saving20Y: saving20Y,
      batteryKwh: batteryKwh,
      hoursCover: hoursCover,
      panelWp: panelWp,
    );

    debugPrint('OUTPUTS: kWh_mois=${result.kwhMonth.toStringAsFixed(2)}, P_kW=${result.powerKW.toStringAsFixed(2)}, panels=${result.panels}, hours_cover=${result.hoursCover?.toStringAsFixed(2) ?? "N/A"}');
    return result;
  }

  /// Calculate OFF-GRID system
  Future<OffGridResult> calculateOffGrid({
    required double kwhPerDay,
    required String regionCode,
    required int autonomyDays, // 1 or 2
    required double batteryKwh,
    required int panelWp,
  }) async {
    debugPrint('INPUTS: OFF-GRID, kwhPerDay=$kwhPerDay, region=$regionCode, autonomyDays=$autonomyDays, batteryKwh=$batteryKwh, panelWp=$panelWp');

    final sunHours = await _getSunHours(regionCode);

    // Formula: P_kW = kWh_jour / (sunHours * PR)
    final powerKW = kwhPerDay / (sunHours * PR);

    // Formula: Nb_panneaux = ceil((P_kW * 1000) / panelWp)
    final panels = ((powerKW * 1000) / panelWp).ceil();

    // Calculate required battery capacity for verification
    // Formula: batt_required = (kWh_jour × autonomie_jours) / (DoD × eff_batt)
    final batteryRequired = (kwhPerDay * autonomyDays) / (DoD * eff_batt);
    
    // Log warning if provided battery is insufficient
    if (batteryKwh < batteryRequired) {
      debugPrint('WARNING: Battery capacity may be insufficient. Required: ${batteryRequired.toStringAsFixed(2)} kWh, Provided: $batteryKwh kWh');
    }

    final result = OffGridResult(
      systemType: 'OFF-GRID',
      regionCode: regionCode,
      sunHours: sunHours,
      kwhPerDay: kwhPerDay,
      powerKW: powerKW,
      panels: panels,
      batteryKwh: batteryKwh,
      batteryRequired: batteryRequired,
      autonomyDays: autonomyDays,
      panelWp: panelWp,
    );

    debugPrint('OUTPUTS: P_kW=${result.powerKW.toStringAsFixed(2)}, panels=${result.panels}, batteryKwh=${result.batteryKwh.toStringAsFixed(2)}, batteryRequired=${result.batteryRequired.toStringAsFixed(2)}');
    return result;
  }

  /// Calculate POMPAGE system
  Future<PumpingResult> calculatePumping({
    required double flowValue,
    required String flowUnit, // 'm3/h' or 'L/min'
    required double hmtMeters,
    required double hoursPerDay,
    required String regionCode,
    required String pumpType, // 'AC' or 'DC'
    required int panelWp,
  }) async {
    debugPrint('INPUTS: POMPAGE, flowValue=$flowValue, flowUnit=$flowUnit, hmtMeters=$hmtMeters, hoursPerDay=$hoursPerDay, region=$regionCode, pumpType=$pumpType, panelWp=$panelWp');

    final sunHours = await _getSunHours(regionCode);

    // Convert flow to m3/h if needed
    double flowM3h;
    if (flowUnit == 'L/min') {
      flowM3h = flowValue * 0.06; // L/min to m3/h: 1 L/min = 0.06 m3/h
    } else {
      flowM3h = flowValue;
    }

    // Formula: P_pompe(kW) = (2.7 * Q * HMT) / (1000 * rendement_pompe)
    // Where Q is in m3/h, HMT in meters
    final pumpPowerKW = (2.7 * flowM3h * hmtMeters) / (1000 * rendement_pompe);

    // Formula: P_PV(kW) = P_pompe / PR
    final pvPowerKW = pumpPowerKW / PR;

    // Formula: Nb_panneaux = ceil((P_PV * 1000) / panelWp)
    final panels = ((pvPowerKW * 1000) / panelWp).ceil();

    final result = PumpingResult(
      systemType: 'POMPAGE SOLAIRE',
      regionCode: regionCode,
      sunHours: sunHours,
      flowValue: flowValue,
      flowUnit: flowUnit,
      hmtMeters: hmtMeters,
      hoursPerDay: hoursPerDay,
      pumpType: pumpType,
      pumpPowerKW: pumpPowerKW,
      pvPowerKW: pvPowerKW,
      panels: panels,
      panelWp: panelWp,
    );

    debugPrint('OUTPUTS: P_pompe=${result.pumpPowerKW.toStringAsFixed(2)}kW, P_PV=${result.pvPowerKW.toStringAsFixed(2)}kW, panels=${result.panels}');
    return result;
  }
}

