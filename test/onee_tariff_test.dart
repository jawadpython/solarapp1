import 'package:flutter_test/flutter_test.dart';
import 'package:noor_energy/features/calculator/services/onee_tariff_service.dart';

void main() {
  group('OneeTariffService', () {
    test('progressive billing for low consumption', () {
      expect(OneeTariffService.billFromKwh(50), closeTo(50 * 0.9010, 0.01));
      expect(OneeTariffService.billFromKwh(100), closeTo(90.10, 0.01));
      expect(
        OneeTariffService.billFromKwh(150),
        closeTo(100 * 0.9010 + 50 * 1.0732, 0.01),
      );
    });

    test('selective billing above 150 kWh', () {
      expect(OneeTariffService.billFromKwh(627), closeTo(1000, 1.0));
      expect(OneeTariffService.billFromKwh(200), closeTo(200 * 1.0732, 0.5));
    });

    test('bill to kWh round-trip for 1000 DH', () {
      const bill = 1000.0;
      final kwh = OneeTariffService.kwhFromBill(bill);
      expect(kwh, closeTo(626.6, 1.0));
      expect(OneeTariffService.billFromKwh(kwh), closeTo(bill, 1.0));
    });

    test('savings reduce bill through tranches', () {
      const bill = 1000.0;
      final kwh = OneeTariffService.kwhFromBill(bill);
      final savings = OneeTariffService.savingsMonth(
        originalBillDh: bill,
        kwhMonth: kwh,
        kwhCovered: kwh * 0.45,
      );
      expect(savings, greaterThan(0));
      expect(savings, lessThan(bill));
    });
  });
}
