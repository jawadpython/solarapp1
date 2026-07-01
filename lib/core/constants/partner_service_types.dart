/// Canonical "type de service" labels for partners (stored as Firestore `speciality`).
class PartnerServiceTypes {
  PartnerServiceTypes._();

  static const List<String> canonicalLabels = [
    'Installation solaire',
    'Maintenance et dépannage',
    'Étude et ingénierie',
    'Pompage solaire',
    'Fourniture matériel',
    'Autre',
  ];

  /// Values for search filters (`Tous` + sorted canonical labels).
  static List<String> defaultFilterOptions() {
    final rest = List<String>.from(canonicalLabels)..sort();
    return ['Tous', ...rest];
  }

  static const List<String> _keys = [
    'speciality',
    'specialty',
    'serviceType',
    'specialite',
    'typeService',
    'typeDeService',
    'type_de_service',
  ];

  /// First non-empty known field from partner/company maps (legacy keys vary).
  static String serviceTypeFromMap(Map<String, dynamic> data) {
    for (final key in _keys) {
      final v = data[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return '';
  }
}
