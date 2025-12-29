import 'package:noor_energy/features/pumping/models/pumping_input.dart';

class PumpingResult {
  final double q; // m3/h
  final double h; // meters
  final double pumpKW;
  final double pvWp;
  final int panels;
  final double savingMonth;
  final double savingYear;
  final double sunHoursUsed;
  final String regionCode;
  final PumpingMode mode;

  PumpingResult({
    required this.q,
    required this.h,
    required this.pumpKW,
    required this.pvWp,
    required this.panels,
    required this.savingMonth,
    required this.savingYear,
    required this.sunHoursUsed,
    required this.regionCode,
    required this.mode,
  });

  @override
  String toString() {
    return 'PumpingResult('
        'Q: ${q.toStringAsFixed(2)} m3/h, '
        'H: ${h.toStringAsFixed(2)} m, '
        'pumpKW: ${pumpKW.toStringAsFixed(2)} kW, '
        'panels: $panels'
        ')';
  }
}

