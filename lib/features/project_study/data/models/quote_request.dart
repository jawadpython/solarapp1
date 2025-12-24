/// QuoteRequest model represents a solar project quote request from a customer.
/// 
/// This model is used to store quote request data before sending to Firebase
/// or displaying in the app.
class QuoteRequest {
  final String? id; // Document ID from Firestore
  final String systemType; // ON-GRID, OFF-GRID, HYBRID, PUMPING
  final int panels;
  final double systemPowerKw;
  final double? batteryCapacity; // Nullable for systems without batteries
  final String userName;
  final String phone;
  final String city;
  final String usageType; // Residential, Commercial, Industrial, etc.
  final String? note; // Optional additional notes
  final DateTime createdAt;
  final String? status; // pending, approved, rejected, completed

  QuoteRequest({
    this.id,
    required this.systemType,
    required this.panels,
    required this.systemPowerKw,
    this.batteryCapacity,
    required this.userName,
    required this.phone,
    required this.city,
    required this.usageType,
    this.note,
    DateTime? createdAt,
    this.status,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Converts QuoteRequest to Map for Firestore storage.
  /// 
  /// Excludes the id field as it's stored as document ID.
  Map<String, dynamic> toMap() {
    return {
      'systemType': systemType,
      'panels': panels,
      'systemPowerKw': systemPowerKw,
      'batteryCapacity': batteryCapacity,
      'userName': userName,
      'phone': phone,
      'city': city,
      'usageType': usageType,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'status': status ?? 'pending',
    };
  }

  /// Creates QuoteRequest from Firestore document Map.
  /// 
  /// [id] - Document ID from Firestore
  /// [map] - Document data map
  factory QuoteRequest.fromMap(String id, Map<String, dynamic> map) {
    return QuoteRequest(
      id: id,
      systemType: map['systemType'] ?? '',
      panels: (map['panels'] ?? 0).toInt(),
      systemPowerKw: (map['systemPowerKw'] ?? 0.0).toDouble(),
      batteryCapacity: map['batteryCapacity'] != null
          ? (map['batteryCapacity'] as num).toDouble()
          : null,
      userName: map['userName'] ?? '',
      phone: map['phone'] ?? '',
      city: map['city'] ?? '',
      usageType: map['usageType'] ?? '',
      note: map['note'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] ?? 'pending',
    );
  }

  /// Creates a copy of QuoteRequest with updated fields.
  QuoteRequest copyWith({
    String? id,
    String? systemType,
    int? panels,
    double? systemPowerKw,
    double? batteryCapacity,
    String? userName,
    String? phone,
    String? city,
    String? usageType,
    String? note,
    DateTime? createdAt,
    String? status,
  }) {
    return QuoteRequest(
      id: id ?? this.id,
      systemType: systemType ?? this.systemType,
      panels: panels ?? this.panels,
      systemPowerKw: systemPowerKw ?? this.systemPowerKw,
      batteryCapacity: batteryCapacity ?? this.batteryCapacity,
      userName: userName ?? this.userName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      usageType: usageType ?? this.usageType,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'QuoteRequest('
        'id: $id, '
        'systemType: $systemType, '
        'panels: $panels, '
        'systemPowerKw: $systemPowerKw, '
        'batteryCapacity: $batteryCapacity, '
        'userName: $userName, '
        'phone: $phone, '
        'city: $city, '
        'usageType: $usageType, '
        'note: $note, '
        'createdAt: $createdAt, '
        'status: $status'
        ')';
  }
}

