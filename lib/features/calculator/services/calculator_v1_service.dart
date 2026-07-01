import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:noor_energy/features/calculator/models/calculator_result.dart';
import 'package:noor_energy/features/calculator/services/onee_tariff_service.dart';
import 'package:noor_energy/features/calculator/services/region_service.dart';

enum _SunHoursMode { annualAverage, worstMonth }

/// V1 Calculator Service with new formulas and constants
class CalculatorV1Service {
  // Calculation Constants (V1)
  static const double prix_kWh = 1.2; // DH/kWh (legacy - kept for other systems)
  static const double tariff_avg = 1.30; // Legacy display fallback
  static const double surplusInjectionRate = 0.20; // DH/kWh ANRE buyback (peak approx.)
  static const double maxSurplusRatio = 0.20; // Loi 82-21: max 20% annual injection
  static const double regulatoryPowerLimitKwc = 11.0; // Loi 82-21 declaration threshold
  static const double PR = 0.80; // Performance Ratio (updated from 0.75)
  static const double DoD = 0.8; // Depth of Discharge
  static const double eff_batt = 0.9; // Battery efficiency
  static const double rendement_pompe = 0.5; // Pump efficiency
  static const double co2_factor = 0.6; // kg CO2 / kWh (updated from 0.7)
  static const double kg_per_tree = 22.0; // kg CO2 / tree / year (updated from 20)
  static const double battery_usable_factor = 0.90; // Battery usable capacity factor
  static const double billMin = OneeTariffService.billMin;

  // Self-Consumption (SC) percentages for ON-GRID
  static const Map<String, double> onGridSelfConsumption = {
    'Maison': 0.45, // Residential: 45%
    'Commerce': 0.65, // Commercial: 65%
  };
  static const double defaultSC = 0.45; // Default SC = 45% if no profile selected

  // Consumption Profiles (Day/Night ratios) - for HYBRID
  // Note: Profile names match UI (with space), but also support "MaisonNuit" from text file
  static const Map<String, Map<String, double>> consumptionProfiles = {
    'Maison': {'day': 0.60, 'night': 0.40}, // 60% Day / 40% Night
    'Commerce': {'day': 0.80, 'night': 0.20}, // 80% Day / 20% Night
    'Industrie': {'day': 0.90, 'night': 0.10}, // 90% Day / 10% Night
    'Maison Nuit': {'day': 0.40, 'night': 0.60}, // 40% Day / 60% Night (UI format)
    'MaisonNuit': {'day': 0.40, 'night': 0.60}, // 40% Day / 60% Night (text file format)
  };

  // Usage Profiles (E_day values) - for OFF-GRID
  static const Map<String, double> usageProfiles = {
    'Maison petite (rural)': 5.0, // kWh/day
    'Maison moyenne': 10.0, // kWh/day
    'Maison grande / Villa rurale': 20.0, // kWh/day
    'Atelier / Commerce petit': 30.0, // kWh/day
  };

  static const double fixedSunHours = 5.5; // Fallback when region data is missing

  final RegionService _regionService = RegionService.instance;

  Future<double> _getSunHours(
    String regionCode, {
    _SunHoursMode mode = _SunHoursMode.annualAverage,
  }) async {
    final hours = switch (mode) {
      _SunHoursMode.annualAverage =>
        await _regionService.getAnnualAverageSunHours(regionCode),
      _SunHoursMode.worstMonth =>
        await _regionService.getWorstMonthSunHours(regionCode),
    };
    debugPrint(
      'Sun hours ($mode, region=$regionCode): ${hours.toStringAsFixed(2)} h/day',
    );
    return hours;
  }

  double _kwhFromBill(double montantDH) =>
      OneeTariffService.kwhFromBill(montantDH);

  double _billAfterSolar({
    required double montantDH,
    required double kwhMonth,
    required double kwhCovered,
  }) =>
      OneeTariffService.billAfterSolar(
        originalBillDh: montantDH,
        kwhMonth: kwhMonth,
        kwhCovered: kwhCovered,
      );

  /// Optional surplus injection credit (Loi 82-21, capped at 20% of production).
  double _surplusInjectionCredit(double pvKwhMonth, double selfUsedKwh) {
    final surplus = math.max(0.0, pvKwhMonth - selfUsedKwh);
    final injectable = math.min(surplus, pvKwhMonth * maxSurplusRatio);
    return injectable * surplusInjectionRate;
  }

  /// Parse number accepting both comma and dot as decimal separator
  static double? parseNumber(String value) {
    if (value.isEmpty) return null;
    // Replace comma with dot
    final normalized = value.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  /// Select inverter based on PV kWc
  /// Returns recommended inverter power in kW
  static double selectInverter(double pvKwc) {
    if (pvKwc <= 3) return 3;
    if (pvKwc <= 5) return 5;
    if (pvKwc <= 7) return 6;
    if (pvKwc <= 9) return 8;
    if (pvKwc <= 11) return 10;
    if (pvKwc <= 13) return 12;
    if (pvKwc <= 16) return 15;
    if (pvKwc <= 18) return 17; // or 15
    if (pvKwc <= 22) return 20;
    if (pvKwc <= 27) return 25;
    if (pvKwc <= 33) return 30;
    if (pvKwc <= 40) return 40;
    if (pvKwc <= 50) return 50;
    if (pvKwc <= 60) return 60;
    if (pvKwc <= 80) return 80;
    if (pvKwc <= 100) return 100;
    // For systems > 100 kW, scale to nearest 10 kW instead of capping.
    return (pvKwc / 10).ceil() * 10.0;
  }

  /// Calculate ON-GRID system with new formulas
  /// Uses fixed Self-Consumption (SC) based on profile: Maison=45%, Commerce=65%
  /// Formulas:
  ///   kWh_month = bill / tariff_avg
  ///   PV_kWh_month = PV_kWp × PSH × PR × 30
  ///   Self_used = PV_kWh_month × SC
  ///   Covered_kWh = min(Self_used, kWh_month)
  ///   Bill_calc = FixedCharges + (kWh_month - Covered_kWh) × tariff_avg
  ///   Bill_after = max(50 DH, Bill_calc)
  Future<OnGridResult> calculateOnGrid({
    required double montantDH,
    required String regionCode,
    required int panelWp,
    required String? profile, // 'Maison' or 'Commerce' (optional, defaults to 45% SC)
    required String voltage, // '220V' or '380V'
  }) async {
    // Get Self-Consumption (SC) based on profile, default to 45%
    final sc = profile != null && onGridSelfConsumption.containsKey(profile)
        ? onGridSelfConsumption[profile]!
        : defaultSC;

    debugPrint('INPUTS: ON-GRID, montantDH=$montantDH, region=$regionCode, panelWp=$panelWp, profile=$profile (SC=${sc * 100}%), voltage=$voltage');

    final sunHours = await _getSunHours(regionCode);

    // Step 1: Monthly consumption from ONEE bill (reverse tariff)
    final kwhMonth = _kwhFromBill(montantDH);

    // Step 2: Daily Consumption (kWh/day)
    final kwhDay = kwhMonth / 30;

    // Step 3: Panel Power (kW)
    final panelPowerKW = panelWp / 1000;

    // Step 4: PV sizing — production matches daily need; SC applied in savings
    double pvPowerKW = kwhDay / (sunHours * PR);

    // Step 5: Calculate number of panels needed
    int panels = (pvPowerKW / panelPowerKW).ceil();

    // Step 6: Installed PV Capacity (kWc)
    double pvKwc = panels * panelPowerKW;

    // Step 7: Monthly PV Production (kWh/month)
    final pvKwhMonth = pvKwc * sunHours * PR * 30;

    // Step 8: Self-Consumed Energy (kWh/month)
    final selfUsed = pvKwhMonth * sc;

    // Step 9: Covered Energy (kWh/month)
    final kwhCovered = math.min(selfUsed, kwhMonth);

    // Step 10: New bill via ONEE tranches + optional surplus injection credit
    var billAfter = _billAfterSolar(
      montantDH: montantDH,
      kwhMonth: kwhMonth,
      kwhCovered: kwhCovered,
    );
    final injectionCredit = _surplusInjectionCredit(pvKwhMonth, selfUsed);
    billAfter = math.max(billMin, billAfter - injectionCredit).toDouble();

    // Step 11: Monthly Savings (DH)
    final actualSavingMonth =
        math.max(0.0, math.min(montantDH - billAfter, montantDH - billMin))
            .toDouble();

    // Step 13: Coverage percentage (for display)
    final coveragePct = kwhMonth > 0 ? (kwhCovered / kwhMonth * 100) : 0.0;

    // Step 14: Inverter Selection
    final inverterKW = selectInverter(pvKwc);

    final showVoltageWarning = inverterKW > 5 && voltage == '220V';
    final showRegulatoryWarning = pvKwc > regulatoryPowerLimitKwc;

    final savingYear = actualSavingMonth * 12.0;
    final saving10Y = savingYear * 10.0;
    final saving20Y = savingYear * 20.0;

    final result = OnGridResult(
      systemType: 'ON-GRID',
      regionCode: regionCode,
      sunHours: sunHours,
      montantDH: montantDH,
      kwhMonth: kwhMonth,
      kwhDay: kwhDay,
      kwhCovered: kwhCovered,
      pvPowerKW: pvPowerKW,
      panels: panels,
      pvKwc: pvKwc,
      inverterKW: inverterKW,
      coveragePct: coveragePct,
      voltage: voltage,
      showVoltageWarning: showVoltageWarning,
      showRegulatoryWarning: showRegulatoryWarning,
      savingMonth: actualSavingMonth,
      savingYear: savingYear,
      saving10Y: saving10Y,
      saving20Y: saving20Y,
      billAfter: billAfter,
      panelWp: panelWp,
    );

    debugPrint('OUTPUTS: kWh_month=${kwhMonth.toStringAsFixed(2)} kWh, kWh_day=${kwhDay.toStringAsFixed(2)} kWh');
    debugPrint('OUTPUTS: PV_kWc=${pvKwc.toStringAsFixed(2)} kWc, PV_kWh_month=${pvKwhMonth.toStringAsFixed(2)} kWh/month');
    debugPrint('OUTPUTS: Self_used=${selfUsed.toStringAsFixed(2)} kWh/month, Covered=${kwhCovered.toStringAsFixed(2)} kWh/month (${coveragePct.toStringAsFixed(1)}%)');
    debugPrint('OUTPUTS: Bill_after=${billAfter.toStringAsFixed(2)} DH, Saving=${actualSavingMonth.toStringAsFixed(2)} DH/month');
    debugPrint('OUTPUTS: P_pv=${pvPowerKW.toStringAsFixed(2)} kW, panels=${panels}, inverter=${inverterKW} kW');
    return result;
  }

  /// Calculate HYBRID system with new formulas
  /// Uses slider for SelfConsumptionRatio (30-90%)
  /// Formulas:
  ///   kWh_month = Bill / tariff_avg
  ///   PV_kWh_month = PV_kWp × PSH × PR × 30
  ///   SelfConsumptionRatio = slider% (0.3 to 0.9)
  ///   Self_used = PV_kWh_month × SelfConsumptionRatio
  ///   Covered_kWh = min(Self_used, kWh_month)
  ///   Bill_calc = FixedCharges + (kWh_month - Covered_kWh) × tariff_avg
  ///   Bill_after = max(50 DH, Bill_calc)
  ///   Savings = min(Savings, Bill × 0.90) [cap at 90%]
  Future<HybridResult> calculateHybrid({
    required double montantDH,
    required String regionCode,
    required int panelWp,
    required double coveragePct, // 30-90% (slider value - SelfConsumptionRatio)
    required double batteryKwh, // Required battery capacity
    required String profile, // Consumption profile (Maison, Commerce, etc.)
    required String voltage, // '220V' or '380V'
  }) async {
    debugPrint('INPUTS: HYBRID, montantDH=$montantDH, region=$regionCode, panelWp=$panelWp, slider=$coveragePct% (SelfConsumptionRatio), battery=$batteryKwh kWh, profile=$profile, voltage=$voltage');

    final sunHours = await _getSunHours(regionCode);

    final kwhMonth = _kwhFromBill(montantDH);
    final kwhDay = kwhMonth / 30;

    // Step 3: Clamp coverage percentage (30-90%)
    final covPct = math.max(30.0, math.min(90.0, coveragePct));
    final selfConsumptionRatio = covPct / 100; // Convert percentage to ratio

    // Step 4: Profile Division (Day/Night) - for battery calculations
    // Get profile ratios (support both "Maison Nuit" and "MaisonNuit")
    final profileData = consumptionProfiles[profile] ?? consumptionProfiles['Maison']!;
    final dayRatio = profileData['day']!;
    final nightRatio = profileData['night']!;

    // Step 5: Target energy (CORRECTED: based on coverage ratio)
    // Formula: E_target_day = E_day × ratio
    final kwhTargetDay = kwhDay * selfConsumptionRatio;

    // Formula: E_day_part = E_target × Jour_ratio
    final kwhDayPart = kwhTargetDay * dayRatio;

    // Formula: E_nuit = E_target × Nuit_ratio
    final kwhNight = kwhTargetDay * nightRatio;

    // Step 6: Panel Power (kW)
    // Formula: P_panel = panel_w / 1000
    final panelPowerKW = panelWp / 1000;

    // Step 7: PV sizing (CORRECTED: based on E_target_day, not E_day)
    // Formula: P_PV = E_target_day / (H × PR)
    // Where H = 5.5 h/day (fixed), PR = 0.80
    double pvPowerKW = kwhTargetDay / (sunHours * PR);
    
    // Step 8: Calculate number of panels needed
    int panels = (pvPowerKW / panelPowerKW).ceil();
    
    // Step 9: Installed PV Capacity (kWc)
    // Formula: PV_kwc = N × P_panel
    double pvKwc = panels * panelPowerKW;

    // Step 10: Monthly PV Production (kWh/month)
    // Formula: PV_kWh_month = PV_kWc × H × PR × 30
    final pvKwhMonth = pvKwc * sunHours * PR * 30;

    final targetKwhMonth = kwhMonth * selfConsumptionRatio;

    // Battery: usable energy per day for night loads
    final batteryUsable = batteryKwh * battery_usable_factor;
    final kwhNightCovered = math.min(kwhNight, batteryUsable);
    final kwhGridNight = math.max(0.0, kwhNight - kwhNightCovered);
    final nightCoveragePct =
        kwhNight > 0 ? (kwhNightCovered / kwhNight * 100) : 0.0;

    // Covered = PV day offset + battery night offset (monthly)
    final pvDayCoverMonthly = math.min(pvKwhMonth, kwhDayPart * 30);
    final batteryNightCoverMonthly = kwhNightCovered * 30;
    final kwhCovered = math.min(
      kwhMonth,
      math.min(
        targetKwhMonth,
        pvDayCoverMonthly + batteryNightCoverMonthly,
      ),
    );

    var billAfter = _billAfterSolar(
      montantDH: montantDH,
      kwhMonth: kwhMonth,
      kwhCovered: kwhCovered,
    );
    final selfUsed = pvDayCoverMonthly + batteryNightCoverMonthly;
    final injectionCredit = _surplusInjectionCredit(pvKwhMonth, selfUsed);
    billAfter = math.max(billMin, billAfter - injectionCredit).toDouble();

    final savingMonth =
        math.max(0.0, math.min(montantDH - billAfter, montantDH - billMin))
            .toDouble();

    // Step 17: Inverter Selection (HYBRID: PV_kWc * 1.10 margin)
    final inverterKW = selectInverter(pvKwc * 1.10);

    final showVoltageWarning = inverterKW > 5 && voltage == '220V';
    final showRegulatoryWarning = pvKwc > regulatoryPowerLimitKwc;

    final savingYear = savingMonth * 12.0;
    final saving10Y = savingYear * 10.0;
    final saving20Y = savingYear * 20.0;

    // Coverage percentage (for display)
    final coveragePctDisplay = kwhMonth > 0 ? (kwhCovered / kwhMonth * 100) : 0.0;

    final result = HybridResult(
      systemType: 'HYBRID',
      regionCode: regionCode,
      sunHours: sunHours,
      montantDH: montantDH,
      kwhMonth: kwhMonth,
      kwhDay: kwhDay,
      kwhTarget: kwhTargetDay,
      profile: profile,
      dayRatio: dayRatio,
      nightRatio: nightRatio,
      kwhDayPart: kwhDayPart,
      kwhNight: kwhNight,
      batteryKwh: batteryKwh,
      batteryUsable: batteryUsable,
      kwhNightCovered: kwhNightCovered,
      kwhGridNight: kwhGridNight,
      nightCoveragePct: nightCoveragePct,
      pvPowerKW: pvPowerKW,
      panels: panels,
      pvKwc: pvKwc,
      inverterKW: inverterKW,
      coveragePct: coveragePctDisplay, // Display coverage based on actual covered energy
      voltage: voltage,
      showVoltageWarning: showVoltageWarning,
      showRegulatoryWarning: showRegulatoryWarning,
      savingMonth: savingMonth,
      savingYear: savingYear,
      saving10Y: saving10Y,
      saving20Y: saving20Y,
      billAfter: billAfter,
      panelWp: panelWp,
    );

    debugPrint('OUTPUTS: kWh_month=${kwhMonth.toStringAsFixed(2)} kWh, kWh_day=${kwhDay.toStringAsFixed(2)} kWh, E_target_day=${kwhTargetDay.toStringAsFixed(2)} kWh');
    debugPrint('OUTPUTS: PV_kWc=${pvKwc.toStringAsFixed(2)} kWc, PV_kWh_month=${pvKwhMonth.toStringAsFixed(2)} kWh/month');
    debugPrint('OUTPUTS: Covered=${kwhCovered.toStringAsFixed(2)} kWh/month (${coveragePctDisplay.toStringAsFixed(1)}%)');
    debugPrint('OUTPUTS: E_day_part=${result.kwhDayPart.toStringAsFixed(2)} kWh, E_nuit=${result.kwhNight.toStringAsFixed(2)} kWh');
    debugPrint('OUTPUTS: Battery_usable=${result.batteryUsable.toStringAsFixed(2)} kWh, E_nuit_couvert=${result.kwhNightCovered.toStringAsFixed(2)} kWh, E_grid_nuit=${result.kwhGridNight.toStringAsFixed(2)} kWh');
    debugPrint('OUTPUTS: Bill_after=${billAfter.toStringAsFixed(2)} DH, Saving=${savingMonth.toStringAsFixed(2)} DH/month');
    debugPrint('OUTPUTS: P_PV=${pvPowerKW.toStringAsFixed(2)} kW, panels=${panels}, inverter=${inverterKW} kW');
    return result;
  }

  /// Calculate OFF-GRID system with profile-based approach
  Future<OffGridResult> calculateOffGrid({
    required String profile, // Usage profile (Maison petite, etc.)
    required String regionCode,
    required int autonomyDays, // 1, 2, or 3
    required int panelWp,
    String? voltage, // Optional: 220V or 380V
  }) async {
    debugPrint('INPUTS: OFF-GRID, profile=$profile, region=$regionCode, autonomyDays=$autonomyDays, panelWp=$panelWp, voltage=$voltage');

    final sunHours =
        await _getSunHours(regionCode, mode: _SunHoursMode.worstMonth);

    // Step 1: Daily Energy from profile
    // Formula: E_day = profile_kwh_day
    final kwhDay = usageProfiles[profile] ?? 10.0; // Default to 10 if profile not found

    // Step 2: PV required (kW)
    // Formula: P_PV = E_day / (HSP × PR)
    final pvPowerKW = kwhDay / (sunHours * PR);

    // Step 3: Panel power (kW)
    // Formula: P_panel = panel_w / 1000
    final panelPowerKW = panelWp / 1000;

    // Step 4: Number of panels
    // Formula: N = ⌈P_PV / P_panel⌉
    final panels = (pvPowerKW / panelPowerKW).ceil();

    // Step 5: Installed PV capacity (kWc)
    // Formula: PV_kWc = N × P_panel
    final pvKwc = panels * panelPowerKW;

    // Step 6: Battery sizing (Lithium) - CORRECTED FORMULA
    // Formula: Battery_kWh = (E_day × J) / (DoD × EtaBat)
    // Where DoD = 0.80, EtaBat = 0.90
    final batteryKwh = (kwhDay * autonomyDays) / (DoD * eff_batt);

    // Step 7: Inverter sizing (OFF-GRID: PV_kWc * 1.20 margin)
    final inverterKW = selectInverter(pvKwc * 1.20);

    // Step 8: Voltage rule (Warning / Recommendation)
    bool showVoltageWarning = false;
    String? recommendedVoltage;
    
    if (voltage != null) {
      // User chose voltage - show warning if inverter > 5kW and voltage = 220V
      showVoltageWarning = inverterKW > 5 && voltage == '220V';
    } else {
      // User did not choose voltage - recommend based on inverter power
      recommendedVoltage = inverterKW <= 10 ? '220V' : '380V';
    }

    final showRegulatoryWarning = pvKwc > regulatoryPowerLimitKwc;

    final result = OffGridResult(
      systemType: 'OFF-GRID',
      regionCode: regionCode,
      sunHours: sunHours,
      profile: profile,
      kwhDay: kwhDay,
      autonomyDays: autonomyDays,
      pvPowerKW: pvPowerKW,
      panels: panels,
      pvKwc: pvKwc,
      batteryKwh: batteryKwh,
      inverterKW: inverterKW,
      voltage: voltage,
      showVoltageWarning: showVoltageWarning,
      showRegulatoryWarning: showRegulatoryWarning,
      recommendedVoltage: recommendedVoltage,
      panelWp: panelWp,
    );

    debugPrint('OUTPUTS: E_day=${result.kwhDay.toStringAsFixed(1)} kWh, P_PV=${result.pvPowerKW.toStringAsFixed(2)} kW, PV_kwc=${result.pvKwc.toStringAsFixed(2)} kWc');
    debugPrint('OUTPUTS: panels=${result.panels}, Battery_kWh=${result.batteryKwh.toStringAsFixed(2)} kWh, inverter=${result.inverterKW} kW');
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
    String? voltage, // Optional: '220V' or '380V'
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

    // Step 1: Hydraulic power (CORRECTED FORMULA)
    // Formula: P_hyd(kW) = (Q × HMT) / 367
    // Where Q is in m3/h, HMT in meters
    final hydraulicPowerKW = (flowM3h * hmtMeters) / 367;

    // Step 2: Pump electrical power (kW)
    // Formula: P_pump = P_hyd / rendement_pompe
    final pumpPowerKW = hydraulicPowerKW / rendement_pompe;

    // Step 3: Daily pump energy → PV sizing for available sun hours
    final pumpEnergyKwhPerDay = pumpPowerKW * hoursPerDay;
    final pvPowerKW = pumpEnergyKwhPerDay / (sunHours * PR);

    // Step 4: Number of panels
    // Formula: N = ceil((P_PV * 1000) / panelWp)
    final panels = ((pvPowerKW * 1000) / panelWp).ceil();

    // Step 5: VFD/Variateur selection (for AC pumps)
    double? vfdRecommendedKW;
    String? vfdType;
    String? recommendedVoltage;
    bool showVoltageWarning = false;

    if (pumpType == 'AC') {
      // Variateur solaire (VFD) recommandé >= P_pump * 1.20
      final vfdNeeded = pumpPowerKW * 1.20;
      vfdRecommendedKW = selectInverter(vfdNeeded);
      
      // Voltage recommendation
      recommendedVoltage = vfdRecommendedKW <= 10 ? '220V' : '380V';
      showVoltageWarning = vfdRecommendedKW > 5 && (voltage == null || voltage == '220V');
    } else {
      // DC pump: contrôleur/driver DC (not VFD)
      vfdType = 'Contrôleur / Driver DC (pompe DC)';
    }

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
      vfdRecommendedKW: vfdRecommendedKW,
      vfdType: vfdType,
      recommendedVoltage: recommendedVoltage,
      showVoltageWarning: showVoltageWarning,
    );

    debugPrint('OUTPUTS: P_pompe=${result.pumpPowerKW.toStringAsFixed(2)}kW, P_PV=${result.pvPowerKW.toStringAsFixed(2)}kW, panels=${result.panels}');
    return result;
  }
}

