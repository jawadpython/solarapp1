import 'package:noor_energy/features/pumping/models/pumping_input.dart';

class PumpingDevisRequest {
  final String name;
  final String phone;
  final String city;
  final String? gps;
  final String? note;
  final double q;
  final double h;
  final double pumpKW;
  final double pvPower;
  final int panels;
  final double savingMonth;
  final double savingYear;
  final String regionCode;
  final PumpingMode mode;

  PumpingDevisRequest({
    required this.name,
    required this.phone,
    required this.city,
    this.gps,
    this.note,
    required this.q,
    required this.h,
    required this.pumpKW,
    required this.pvPower,
    required this.panels,
    required this.savingMonth,
    required this.savingYear,
    required this.regionCode,
    required this.mode,
  });
}
