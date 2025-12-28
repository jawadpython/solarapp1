import 'package:noor_energy/features/calculator/models/solar_result.dart';
import 'package:noor_energy/features/calculator/services/region_service.dart';

class SolarCalculatorService {
  static const double loss = 0.15;
  static const double safety = 0.10;

  static const Map<String, Map<String, double>> savingRate = {
    "ON-GRID": {
      "Maison": 0.75,
      "Commerce": 0.85,
      "Industrie": 0.88,
    },
    "HYBRID": {
      "Maison": 0.88,
      "Commerce": 0.92,
      "Industrie": 0.93,
    },
    "OFF-GRID": {
      "Maison": 0.95,
      "Commerce": 0.96,
      "Industrie": 0.97,
    },
  };

  static const List<String> monthNamesFr = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  final RegionService _regionService = RegionService.instance;

  /// Calculate price per kWh based on factureDH
  static double getPricePerKwh(double factureDH) {
    if (factureDH < 300) {
      return 1.10;
    } else if (factureDH <= 1000) {
      return 1.20;
    } else {
      return 1.30;
    }
  }

  /// Calculate solar system based on input parameters
  Future<SolarResult> calculate({
    required double factureDH,
    required String systemType,
    required String regionCode,
    String usageType = 'Maison',
    int panelWp = 550,
  }) async {
    // Step 1: Get month index (0-11)
    final monthIndex = DateTime.now().month - 1;
    final monthName = monthNamesFr[monthIndex];

    // Step 2: Get sun hours for region
    final sunH = await _regionService.getSunHoursByRegion(regionCode);

    // Step 3: Convert DH to kWh
    final pricePerKwh = getPricePerKwh(factureDH);
    final kwhMonth = factureDH / pricePerKwh;

    // Step 4: System Sizing
    // powerKW = kwhMonth / (30 * sunH * (1 - loss))
    var powerKW = kwhMonth / (30 * sunH * (1 - loss));
    // Apply safety margin
    powerKW = powerKW * (1 + safety);

    // Step 5: Calculate number of panels
    final panels = ((powerKW * 1000) / panelWp).ceil();

    // Step 6: Calculate savings
    final rateMap = savingRate[systemType];
    if (rateMap == null) {
      throw Exception('Invalid system type: $systemType');
    }
    final savingRateValue = rateMap[usageType] ?? rateMap['Maison'] ?? 0.75;

    final savingMonthDH = factureDH * savingRateValue;
    final savingYearDH = savingMonthDH * 12;
    final saving10Y = savingYearDH * 10;
    final saving20Y = savingYearDH * 20;

    return SolarResult(
      kwhMonth: kwhMonth,
      powerKW: powerKW,
      panels: panels,
      savingRate: savingRateValue,
      savingMonth: savingMonthDH,
      savingYear: savingYearDH,
      saving10Y: saving10Y,
      saving20Y: saving20Y,
      usedSunH: sunH,
      monthName: monthName,
      regionCode: regionCode,
    );
  }
}

