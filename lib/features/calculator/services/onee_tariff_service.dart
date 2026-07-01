/// ONEE domestic electricity tariff (Usage domestique et Éclairage Privé).
///
/// Implements progressive billing for consumption ≤ 150 kWh/month and
/// tarification sélective (single rate on total consumption) above 150 kWh.
class OneeTariffService {
  OneeTariffService._();

  static const double billMin = 50.0;

  /// Progressive tranches for consumption ≤ 150 kWh/month (DH/kWh TTC).
  static const List<({double upToKwh, double rate})> progressiveTranches = [
    (upToKwh: 100, rate: 0.9010),
    (upToKwh: 150, rate: 1.0732),
  ];

  /// Selective tranches for consumption > 150 kWh/month (upper bound, rate).
  static const List<({double upToKwh, double rate})> selectiveTranches = [
    (upToKwh: 200, rate: 1.0732),
    (upToKwh: 300, rate: 1.1676),
    (upToKwh: 500, rate: 1.3817),
    (upToKwh: double.infinity, rate: 1.5958),
  ];

  /// Bill amount (DH TTC) for a given monthly consumption.
  static double billFromKwh(double kwh) {
    if (kwh <= 0) return 0;

    if (kwh <= 150) {
      double bill = 0;
      double remaining = kwh;
      double prevLimit = 0;

      for (final tranche in progressiveTranches) {
        final band = tranche.upToKwh - prevLimit;
        final inBand = remaining.clamp(0, band);
        bill += inBand * tranche.rate;
        remaining -= inBand;
        prevLimit = tranche.upToKwh;
        if (remaining <= 0) break;
      }
      return bill;
    }

    for (final tranche in selectiveTranches) {
      if (kwh <= tranche.upToKwh) {
        return kwh * tranche.rate;
      }
    }

    return kwh * 1.5958;
  }

  /// Estimate monthly consumption (kWh) from a bill amount (DH TTC).
  static double kwhFromBill(double billDh) {
    if (billDh <= 0) return 0;

    // Progressive range (≤ 150 kWh).
    double low = 0;
    double high = 150;
    for (var i = 0; i < 50; i++) {
      final mid = (low + high) / 2;
      if (billFromKwh(mid) < billDh) {
        low = mid;
      } else {
        high = mid;
      }
    }
    if ((billFromKwh(high) - billDh).abs() < 0.5) {
      return high;
    }

    // Selective range (> 150 kWh).
    for (final tranche in selectiveTranches) {
      final kwh = billDh / tranche.rate;
      if (kwh > 150 && kwh <= tranche.upToKwh) {
        return kwh;
      }
    }

    return billDh / 1.5958;
  }

  /// Bill after solar offset, respecting ONEE tranches and minimum bill floor.
  static double billAfterSolar({
    required double originalBillDh,
    required double kwhMonth,
    required double kwhCovered,
  }) {
    final remainingKwh = (kwhMonth - kwhCovered).clamp(0.0, kwhMonth);
    final newBill = billFromKwh(remainingKwh);
    return newBill < billMin ? billMin : newBill;
  }

  /// Monthly savings from covered energy.
  static double savingsMonth({
    required double originalBillDh,
    required double kwhMonth,
    required double kwhCovered,
  }) {
    final billAfter = billAfterSolar(
      originalBillDh: originalBillDh,
      kwhMonth: kwhMonth,
      kwhCovered: kwhCovered,
    );
    return (originalBillDh - billAfter).clamp(0.0, originalBillDh);
  }

  /// Effective average tariff (DH/kWh) for a bill — useful for display.
  static double effectiveTariff(double billDh, double kwhMonth) {
    if (kwhMonth <= 0) return 0;
    return billDh / kwhMonth;
  }
}
