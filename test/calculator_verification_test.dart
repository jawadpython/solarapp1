/// Morocco-aligned calculator verification tests.
///
/// Uses real region codes and ONEE tariff; tolerances allow ±5%.

import 'package:flutter_test/flutter_test.dart';
import 'package:noor_energy/features/calculator/services/calculator_v1_service.dart';
import 'package:noor_energy/features/calculator/services/onee_tariff_service.dart';
import 'package:noor_energy/features/calculator/services/region_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Calculator Verification Tests (Morocco)', () {
    final calculator = CalculatorV1Service();
    const regionCode = 'R04_RSK'; // Rabat-Salé-Kénitra

    test('ONEE kWh for 1000 DH bill', () {
      final kwh = OneeTariffService.kwhFromBill(1000);
      expect(kwh, closeTo(626.6, 2.0));
    });

    test('1️⃣ ON-GRID - Maison (1000 DH/month)', () async {
      const factureDH = 1000.0;
      const panelWp = 550;
      const profile = 'Maison';
      const voltage = '220V';

      final result = await calculator.calculateOnGrid(
        montantDH: factureDH,
        regionCode: regionCode,
        panelWp: panelWp,
        profile: profile,
        voltage: voltage,
      );

      final kwhExpected = OneeTariffService.kwhFromBill(factureDH);
      final sunHours =
          await RegionService.instance.getAnnualAverageSunHours(regionCode);

      print('\n📊 ON-GRID Results:');
      print('  kWh/month: ${result.kwhMonth.toStringAsFixed(1)} (ONEE: ${kwhExpected.toStringAsFixed(1)})');
      print('  Sun hours: ${result.sunHours.toStringAsFixed(2)} (region avg: ${sunHours.toStringAsFixed(2)})');
      print('  Panels: ${result.panels}');
      print('  PV kWc: ${result.pvKwc.toStringAsFixed(2)}');
      print('  Savings: ${result.savingMonth.toStringAsFixed(2)} DH');
      print('  Coverage: ${result.coveragePct.toStringAsFixed(1)}%');

      expect(result.kwhMonth, closeTo(kwhExpected, 2.0));
      expect(result.sunHours, closeTo(sunHours, 0.1));
      expect(result.panels, greaterThan(0));
      expect(result.pvKwc, greaterThan(0));
      expect(result.savingMonth, greaterThan(0));
      expect(result.savingMonth, lessThan(factureDH));
      expect(result.coveragePct, greaterThan(30));
      expect(result.coveragePct, lessThan(55));
      expect(result.inverterKW, equals(5.0));
      expect(result.showVoltageWarning, isFalse);
    });

    test('2️⃣ HYBRID - Maison Nuit (1000 DH, 70% coverage)', () async {
      const factureDH = 1000.0;
      const panelWp = 550;
      const coveragePct = 70.0;
      const batteryKwh = 10.0;
      const profile = 'Maison Nuit';
      const voltage = '220V';

      final result = await calculator.calculateHybrid(
        montantDH: factureDH,
        regionCode: regionCode,
        panelWp: panelWp,
        coveragePct: coveragePct,
        batteryKwh: batteryKwh,
        profile: profile,
        voltage: voltage,
      );

      print('\n📊 HYBRID Results:');
      print('  Panels: ${result.panels}');
      print('  Savings: ${result.savingMonth.toStringAsFixed(2)} DH');
      print('  Coverage: ${result.coveragePct.toStringAsFixed(1)}%');
      print('  Night Coverage: ${result.nightCoveragePct.toStringAsFixed(1)}%');

      expect(result.panels, greaterThan(0));
      expect(result.savingMonth, greaterThan(0));
      expect(result.coveragePct, closeTo(70.0, 5.0));
      expect(result.nightCoveragePct, greaterThan(70));
      expect(result.kwhNightCovered, greaterThan(0));
    });

    test('3️⃣ OFF-GRID - Maison moyenne (2 days autonomy)', () async {
      const profile = 'Maison moyenne';
      const autonomyDays = 2;
      const panelWp = 550;

      final worstSun =
          await RegionService.instance.getWorstMonthSunHours(regionCode);

      final result = await calculator.calculateOffGrid(
        profile: profile,
        regionCode: regionCode,
        autonomyDays: autonomyDays,
        panelWp: panelWp,
      );

      print('\n📊 OFF-GRID Results:');
      print('  Sun hours (worst month): ${result.sunHours.toStringAsFixed(2)}');
      print('  Panels: ${result.panels}');
      print('  Battery: ${result.batteryKwh.toStringAsFixed(2)} kWh');

      expect(result.sunHours, closeTo(worstSun, 0.1));
      expect(result.kwhDay, equals(10.0));
      expect(result.panels, greaterThanOrEqualTo(5));
      expect(result.batteryKwh, closeTo(27.78, 1.0));
      expect(result.recommendedVoltage, equals('220V'));
    });

    test('4️⃣ POMPAGE - AC Pump (10 m³/h, 40m HMT, 8h/day)', () async {
      const flowValue = 10.0;
      const flowUnit = 'm3/h';
      const hmtMeters = 40.0;
      const hoursPerDay = 8.0;
      const pumpType = 'AC';
      const panelWp = 550;
      const voltage = '220V';

      final sunHours =
          await RegionService.instance.getAnnualAverageSunHours(regionCode);

      final result = await calculator.calculatePumping(
        flowValue: flowValue,
        flowUnit: flowUnit,
        hmtMeters: hmtMeters,
        hoursPerDay: hoursPerDay,
        regionCode: regionCode,
        pumpType: pumpType,
        panelWp: panelWp,
        voltage: voltage,
      );

      const expectedPumpPowerKW = 2.18;
      final expectedPvPowerKW =
          expectedPumpPowerKW * hoursPerDay / (sunHours * 0.8);

      print('\n📊 POMPAGE Results:');
      print('  Pump Power: ${result.pumpPowerKW.toStringAsFixed(2)} kW');
      print('  PV Power: ${result.pvPowerKW.toStringAsFixed(2)} kW (expected ~${expectedPvPowerKW.toStringAsFixed(2)})');
      print('  Panels: ${result.panels}');

      expect(result.pumpPowerKW, closeTo(expectedPumpPowerKW, 0.05));
      expect(result.pvPowerKW, closeTo(expectedPvPowerKW, expectedPvPowerKW * 0.05));
      expect(result.panels, greaterThan(5));
      expect(result.vfdRecommendedKW, equals(3.0));
    });
  });
}
