/// Verification Test for Calculator - Based on Real Examples
/// 
/// This test verifies that the calculator produces results matching
/// the expected examples provided by the client.
/// 
/// Expected accuracy: ±5% tolerance

import 'package:flutter_test/flutter_test.dart';
import 'package:noor_energy/features/calculator/services/calculator_v1_service.dart';

void main() {
  group('Calculator Verification Tests', () {
    final calculator = CalculatorV1Service();

    test('1️⃣ ON-GRID Example - Maison (1000 DH/month)', () async {
      // Inputs
      const factureDH = 1000.0;
      const panelWp = 550;
      const profile = 'Maison';
      const voltage = '220V';
      const regionCode = 'Centre'; // Any region (uses fixed 5.5h)

      // Expected results (from example)
      const expectedPanels = 11;
      const expectedPvKwc = 6.05; // 11 × 0.55
      const expectedSavingsMonth = 417.0; // ±5% = 396-438
      const expectedCoveragePct = 47.0; // ±5% = 44.65-49.35
      const expectedInverterKW = 6.0; // Palier for 6.05 kWc

      // Calculate
      final result = await calculator.calculateOnGrid(
        montantDH: factureDH,
        regionCode: regionCode,
        panelWp: panelWp,
        profile: profile,
        voltage: voltage,
      );

      // Verify
      print('\n📊 ON-GRID Results:');
      print('  Panels: ${result.panels} (expected: $expectedPanels)');
      print('  PV kWc: ${result.pvKwc.toStringAsFixed(2)} (expected: $expectedPvKwc)');
      print('  Savings: ${result.savingMonth.toStringAsFixed(2)} DH (expected: $expectedSavingsMonth)');
      print('  Coverage: ${result.coveragePct.toStringAsFixed(1)}% (expected: $expectedCoveragePct%)');
      print('  Inverter: ${result.inverterKW} kW (expected: $expectedInverterKW)');
      print('  Voltage Warning: ${result.showVoltageWarning} (expected: true)');

      expect(result.panels, equals(expectedPanels), reason: 'Panel count should match');
      expect(result.pvKwc, closeTo(expectedPvKwc, 0.1), reason: 'PV kWc should be close');
      expect(result.savingMonth, closeTo(expectedSavingsMonth, expectedSavingsMonth * 0.05), 
          reason: 'Savings should be within 5%');
      expect(result.coveragePct, closeTo(expectedCoveragePct, expectedCoveragePct * 0.05), 
          reason: 'Coverage should be within 5%');
      expect(result.inverterKW, equals(expectedInverterKW), reason: 'Inverter should match');
      expect(result.showVoltageWarning, isTrue, reason: 'Should show voltage warning for >5kW with 220V');
    });

    test('2️⃣ HYBRID Example - Maison Nuit (1000 DH, 70% coverage)', () async {
      // Inputs
      const factureDH = 1000.0;
      const panelWp = 550;
      const coveragePct = 70.0;
      const batteryKwh = 10.0;
      const profile = 'Maison Nuit'; // 40% day / 60% night
      const voltage = '220V';
      const regionCode = 'Centre';

      // Expected results (from example)
      const expectedPanels = 8;
      const expectedPvKwc = 4.4; // 8 × 0.55
      const expectedSavingsMonth = 650.0; // ±5% = 617.5-682.5
      const expectedInverterKW = 5.0; // Palier for 4.4 × 1.10 = 4.84
      const expectedNightCoveragePct = 84.0; // ±5% = 79.8-88.2

      // Calculate
      final result = await calculator.calculateHybrid(
        montantDH: factureDH,
        regionCode: regionCode,
        panelWp: panelWp,
        coveragePct: coveragePct,
        batteryKwh: batteryKwh,
        profile: profile,
        voltage: voltage,
      );

      // Verify
      print('\n📊 HYBRID Results:');
      print('  Panels: ${result.panels} (expected: $expectedPanels)');
      print('  PV kWc: ${result.pvKwc.toStringAsFixed(2)} (expected: $expectedPvKwc)');
      print('  Savings: ${result.savingMonth.toStringAsFixed(2)} DH (expected: $expectedSavingsMonth)');
      print('  Coverage: ${result.coveragePct.toStringAsFixed(1)}% (expected: ~70%)');
      print('  Night Coverage: ${result.nightCoveragePct.toStringAsFixed(1)}% (expected: $expectedNightCoveragePct%)');
      print('  Inverter: ${result.inverterKW} kW (expected: $expectedInverterKW)');
      print('  Voltage Warning: ${result.showVoltageWarning} (expected: false)');

      expect(result.panels, equals(expectedPanels), reason: 'Panel count should match');
      expect(result.pvKwc, closeTo(expectedPvKwc, 0.1), reason: 'PV kWc should be close');
      expect(result.savingMonth, closeTo(expectedSavingsMonth, expectedSavingsMonth * 0.05), 
          reason: 'Savings should be within 5%');
      expect(result.nightCoveragePct, closeTo(expectedNightCoveragePct, expectedNightCoveragePct * 0.05), 
          reason: 'Night coverage should be within 5%');
      expect(result.inverterKW, equals(expectedInverterKW), reason: 'Inverter should match');
      expect(result.showVoltageWarning, isFalse, reason: 'No warning for 5kW with 220V');
    });

    test('3️⃣ OFF-GRID Example - Maison moyenne (10 kWh/day, 2 days autonomy)', () async {
      // Inputs
      const profile = 'Maison moyenne'; // 10 kWh/day
      const autonomyDays = 2;
      const panelWp = 550;
      const regionCode = 'Centre';

      // Expected results (from example)
      const expectedPanels = 5;
      const expectedPvKwc = 2.75; // 5 × 0.55
      const expectedBatteryKwh = 27.8; // ±5% = 26.41-29.19
      const expectedInverterKW = 5.0; // Palier for 2.75 × 1.20 = 3.3

      // Calculate
      final result = await calculator.calculateOffGrid(
        profile: profile,
        regionCode: regionCode,
        autonomyDays: autonomyDays,
        panelWp: panelWp,
      );

      // Verify
      print('\n📊 OFF-GRID Results:');
      print('  Panels: ${result.panels} (expected: $expectedPanels)');
      print('  PV kWc: ${result.pvKwc.toStringAsFixed(2)} (expected: $expectedPvKwc)');
      print('  Battery: ${result.batteryKwh.toStringAsFixed(2)} kWh (expected: $expectedBatteryKwh)');
      print('  Inverter: ${result.inverterKW} kW (expected: $expectedInverterKW)');
      print('  Recommended Voltage: ${result.recommendedVoltage} (expected: 220V)');

      expect(result.panels, equals(expectedPanels), reason: 'Panel count should match');
      expect(result.pvKwc, closeTo(expectedPvKwc, 0.1), reason: 'PV kWc should be close');
      expect(result.batteryKwh, closeTo(expectedBatteryKwh, expectedBatteryKwh * 0.05), 
          reason: 'Battery should be within 5%');
      expect(result.inverterKW, equals(expectedInverterKW), reason: 'Inverter should match');
      expect(result.recommendedVoltage, equals('220V'), reason: 'Should recommend 220V for ≤5kW');
    });

    test('4️⃣ POMPAGE Example - AC Pump (10 m³/h, 40m HMT)', () async {
      // Inputs
      const flowValue = 10.0;
      const flowUnit = 'm3/h';
      const hmtMeters = 40.0;
      const hoursPerDay = 8.0; // Not in example, but needed
      const pumpType = 'AC';
      const panelWp = 550;
      const regionCode = 'Centre';
      const voltage = '220V';

      // Expected results (from example)
      const expectedPanels = 5;
      const expectedPvKwc = 2.75; // 5 × 0.55
      const expectedPumpPowerKW = 2.18; // ±5% = 2.07-2.29
      const expectedPvPowerKW = 2.73; // ±5% = 2.59-2.87
      const expectedVfdKW = 3.0; // Palier for 2.18 × 1.20 = 2.6

      // Calculate
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

      // Verify
      print('\n📊 POMPAGE Results:');
      print('  Panels: ${result.panels} (expected: $expectedPanels)');
      print('  PV kWc: ${(result.panels * panelWp / 1000).toStringAsFixed(2)} (expected: $expectedPvKwc)');
      print('  Pump Power: ${result.pumpPowerKW.toStringAsFixed(2)} kW (expected: $expectedPumpPowerKW)');
      print('  PV Power: ${result.pvPowerKW.toStringAsFixed(2)} kW (expected: $expectedPvPowerKW)');
      print('  VFD Recommended: ${result.vfdRecommendedKW} kW (expected: $expectedVfdKW)');
      print('  Voltage Warning: ${result.showVoltageWarning}');

      expect(result.panels, equals(expectedPanels), reason: 'Panel count should match');
      expect(result.pumpPowerKW, closeTo(expectedPumpPowerKW, expectedPumpPowerKW * 0.05), 
          reason: 'Pump power should be within 5%');
      expect(result.pvPowerKW, closeTo(expectedPvPowerKW, expectedPvPowerKW * 0.05), 
          reason: 'PV power should be within 5%');
      expect(result.vfdRecommendedKW, equals(expectedVfdKW), reason: 'VFD should match');
    });
  });
}
