import 'package:noor_energy/features/calculator/services/region_service.dart';
import 'package:noor_energy/features/pumping/models/pumping_input.dart';
import 'package:noor_energy/features/pumping/models/pumping_result.dart';

class PumpingService {
  static const double eta = 0.45; // Pump efficiency
  static const double derating = 0.75; // PV derating factor
  static const double panelWp = 550.0; // Panel wattage
  static const double pipeLossPercent = 0.10; // 10% pipe loss

  // Water need per hectare per day (m3/ha/day) by crop type
  static const Map<String, double> waterNeedTable = {
    'Blé': 4.0,
    'Orge': 3.5,
    'Maïs': 6.0,
    'Tomate': 5.5,
    'Pomme de terre': 4.5,
    'Luzerne': 7.0,
    'Agrumes': 5.0,
    'Olivier': 3.0,
    'Autre': 4.5, // Default
  };

  // Irrigation efficiency factor
  static const Map<String, double> irrigationFactor = {
    'Goutte à goutte': 0.90,
    'Aspersion': 0.75,
    'Gravitaire': 0.60,
    'Autre': 0.70, // Default
  };

  // Electricity price (DH/kWh)
  static const double electricityPrice = 1.2;

  // Diesel price (DH/liter)
  static const double dieselPrice = 11.0;

  // Diesel consumption (liters per kWh)
  static const double dieselConsumption = 0.4;

  final RegionService _regionService = RegionService.instance;

  /// Calculate pumping system based on input
  Future<PumpingResult> calculate(PumpingInput input) async {
    double q; // Flow rate in m3/h
    double h; // Head in meters

    // Step 1: Calculate Q and H based on mode
    switch (input.mode) {
      case PumpingMode.flow:
        q = _calculateFlowQ(input);
        h = input.headMeters ?? 0;
        break;

      case PumpingMode.area:
        q = _calculateAreaQ(input);
        h = input.headMeters ?? 0;
        break;

      case PumpingMode.tank:
        q = _calculateTankQ(input);
        h = _calculateTankH(input);
        break;
    }

    if (q <= 0 || h <= 0) {
      throw Exception('Débit ou hauteur invalide');
    }

    // Step 2: Get sun hours for region
    final sunH = await _regionService.getSunHoursByRegion(input.regionCode);

    // Step 3: Calculate hydraulic power
    // P_hyd(W) = 2.725 × Q × H
    final pHydW = 2.725 * q * h;

    // Step 4: Calculate required power
    // P_required = P_hyd / eta
    final pRequiredW = pHydW / eta;

    // Step 5: Calculate hours per day (use from input or default)
    final hoursPerDay = input.hoursPerDay ?? 8.0;

    // Step 6: Calculate PV power needed
    // PV_Wp = (P_required × hoursPerDay) / (sunH × derating)
    final pvWp = (pRequiredW * hoursPerDay) / (sunH * derating);

    // Step 7: Calculate number of panels
    final panels = (pvWp / panelWp).ceil();

    // Step 8: Calculate pump power in kW
    final pumpKW = pRequiredW / 1000.0;

    // Step 9: Calculate savings
    final savings = _calculateSavings(
      pumpKW: pumpKW,
      hoursPerDay: hoursPerDay,
      currentSource: input.currentSource,
    );

    return PumpingResult(
      q: q,
      h: h,
      pumpKW: pumpKW,
      pvWp: pvWp,
      panels: panels,
      savingMonth: savings['monthly'] ?? 0,
      savingYear: savings['yearly'] ?? 0,
      sunHoursUsed: sunH,
      regionCode: input.regionCode,
    );
  }

  /// Calculate Q for FLOW mode
  double _calculateFlowQ(PumpingInput input) {
    if (input.flowValue == null || input.flowUnit == null) {
      throw Exception('Valeurs de débit manquantes');
    }

    double qM3h;
    if (input.flowUnit == FlowUnit.lmin) {
      // Convert L/min to m3/h: Q(m3/h) = (L/min * 60) / 1000
      qM3h = (input.flowValue! * 60) / 1000;
    } else {
      // Already in m3/h
      qM3h = input.flowValue!;
    }

    return qM3h;
  }

  /// Calculate Q for AREA mode
  double _calculateAreaQ(PumpingInput input) {
    if (input.areaValue == null ||
        input.areaUnit == null ||
        input.cropType == null ||
        input.irrigationType == null ||
        input.hoursPerDay == null) {
      throw Exception('Valeurs de surface manquantes');
    }

    // Convert area to hectares
    double areaHa;
    if (input.areaUnit == AreaUnit.m2) {
      areaHa = input.areaValue! / 10000.0; // 1 ha = 10000 m²
    } else {
      areaHa = input.areaValue!;
    }

    // Get water need for crop (m3/ha/day)
    final waterNeed = waterNeedTable[input.cropType] ?? waterNeedTable['Autre']!;

    // Get irrigation efficiency factor
    final factor = irrigationFactor[input.irrigationType] ??
        irrigationFactor['Autre']!;

    // Calculate daily water need: waterDay = areaHa * waterNeed * factor
    final waterDay = areaHa * waterNeed * factor;

    // Calculate flow rate: Q = waterDay / hoursPerDay
    final q = waterDay / input.hoursPerDay!;

    return q;
  }

  /// Calculate Q for TANK mode
  double _calculateTankQ(PumpingInput input) {
    if (input.tankVolumeM3 == null || input.fillHours == null) {
      throw Exception('Valeurs de réservoir manquantes');
    }

    // Q = tankVolumeM3 / fillHours
    return input.tankVolumeM3! / input.fillHours!;
  }

  /// Calculate H for TANK mode
  double _calculateTankH(PumpingInput input) {
    if (input.wellDepthM == null || input.tankHeightM == null) {
      throw Exception('Valeurs de profondeur manquantes');
    }

    // H = wellDepth + tankHeight + pipeLoss
    final pipeLoss = (input.wellDepthM! + input.tankHeightM!) * pipeLossPercent;
    return input.wellDepthM! + input.tankHeightM! + pipeLoss;
  }

  /// Calculate savings based on current source
  Map<String, double> _calculateSavings({
    required double pumpKW,
    required double hoursPerDay,
    required CurrentSource currentSource,
  }) {
    double monthlyCost = 0;

    switch (currentSource) {
      case CurrentSource.electricity:
        // monthlyCost = pumpKW × hoursPerDay × 30 × price
        monthlyCost = pumpKW * hoursPerDay * 30 * electricityPrice;
        break;

      case CurrentSource.diesel:
        // dieselConsumption = 0.4 l/kWh
        // litersMonth = pumpKW × hoursPerDay × 30 × dieselConsumption
        final litersMonth = pumpKW * hoursPerDay * 30 * dieselConsumption;
        // monthlyCost = litersMonth × dieselPrice
        monthlyCost = litersMonth * dieselPrice;
        break;

      case CurrentSource.unknown:
        // Use average of electricity and diesel
        final elecCost = pumpKW * hoursPerDay * 30 * electricityPrice;
        final dieselLiters = pumpKW * hoursPerDay * 30 * dieselConsumption;
        final dieselCost = dieselLiters * dieselPrice;
        monthlyCost = (elecCost + dieselCost) / 2;
        break;
    }

    final yearlyCost = monthlyCost * 12;

    return {
      'monthly': monthlyCost,
      'yearly': yearlyCost,
    };
  }

  /// Get available crop types
  static List<String> getCropTypes() {
    return waterNeedTable.keys.toList();
  }

  /// Get available irrigation types
  static List<String> getIrrigationTypes() {
    return irrigationFactor.keys.toList();
  }
}

