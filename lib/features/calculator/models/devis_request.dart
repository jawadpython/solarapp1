class DevisRequest {
  final String id;
  final DateTime date;
  final String fullName;
  final String phone;
  final String city;
  final String? gps;
  final String? note;
  final String? factureImagePath;

  // Technical data from SolarResult
  final String systemType;
  final String regionCode;
  final double kwhMonth;
  final double powerKW;
  final int panels;
  final double savingsMonth;
  final double savingsYear;

  DevisRequest({
    required this.id,
    required this.date,
    required this.fullName,
    required this.phone,
    required this.city,
    this.gps,
    this.note,
    this.factureImagePath,
    required this.systemType,
    required this.regionCode,
    required this.kwhMonth,
    required this.powerKW,
    required this.panels,
    required this.savingsMonth,
    required this.savingsYear,
  });

  @override
  String toString() {
    return 'DevisRequest('
        'id: $id, '
        'date: $date, '
        'fullName: $fullName, '
        'phone: $phone, '
        'city: $city, '
        'systemType: $systemType, '
        'regionCode: $regionCode'
        ')';
  }
}

