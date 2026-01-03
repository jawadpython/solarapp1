/// Product model for marketplace products
/// Represents a solar energy product (inverter, panel, battery, etc.)
class ProductModel {
  final String brand;
  final String category;
  final String model;
  final String type;
  final String phase;
  final double powerKw;
  final double maxPvKw;
  final int mppt;
  final String batteryType;
  final String voltage;
  final String usage;
  final String suitableFor;
  final String descriptionShort;
  final String warranty;
  final String? imageUrl;
  final String status;

  const ProductModel({
    this.brand = '',
    this.category = '',
    this.model = '',
    this.type = '',
    this.phase = '',
    this.powerKw = 0.0,
    this.maxPvKw = 0.0,
    this.mppt = 0,
    this.batteryType = '',
    this.voltage = '',
    this.usage = '',
    this.suitableFor = '',
    this.descriptionShort = '',
    this.warranty = '',
    this.imageUrl,
    this.status = 'Active',
  });

  /// Create ProductModel from Firestore document snapshot
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      brand: json['brand'] as String? ?? '',
      category: json['category'] as String? ?? '',
      model: json['model'] as String? ?? '',
      type: json['type'] as String? ?? '',
      phase: json['phase'] as String? ?? '',
      powerKw: _parseDouble(json['powerKw'], 0.0),
      maxPvKw: _parseDouble(json['maxPvKw'], 0.0),
      mppt: _parseInt(json['mppt'], 0),
      batteryType: json['batteryType'] as String? ?? '',
      voltage: json['voltage'] as String? ?? '',
      usage: json['usage'] as String? ?? '',
      suitableFor: json['suitableFor'] as String? ?? '',
      descriptionShort: json['descriptionShort'] as String? ?? '',
      warranty: json['warranty'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String? ?? 'Active',
    );
  }

  /// Convert ProductModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'category': category,
      'model': model,
      'type': type,
      'phase': phase,
      'powerKw': powerKw,
      'maxPvKw': maxPvKw,
      'mppt': mppt,
      'batteryType': batteryType,
      'voltage': voltage,
      'usage': usage,
      'suitableFor': suitableFor,
      'descriptionShort': descriptionShort,
      'warranty': warranty,
      'imageUrl': imageUrl,
      'status': status,
    };
  }

  /// Create a copy of ProductModel with updated fields
  ProductModel copyWith({
    String? brand,
    String? category,
    String? model,
    String? type,
    String? phase,
    double? powerKw,
    double? maxPvKw,
    int? mppt,
    String? batteryType,
    String? voltage,
    String? usage,
    String? suitableFor,
    String? descriptionShort,
    String? warranty,
    String? imageUrl,
    String? status,
  }) {
    return ProductModel(
      brand: brand ?? this.brand,
      category: category ?? this.category,
      model: model ?? this.model,
      type: type ?? this.type,
      phase: phase ?? this.phase,
      powerKw: powerKw ?? this.powerKw,
      maxPvKw: maxPvKw ?? this.maxPvKw,
      mppt: mppt ?? this.mppt,
      batteryType: batteryType ?? this.batteryType,
      voltage: voltage ?? this.voltage,
      usage: usage ?? this.usage,
      suitableFor: suitableFor ?? this.suitableFor,
      descriptionShort: descriptionShort ?? this.descriptionShort,
      warranty: warranty ?? this.warranty,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
    );
  }

  /// Helper method to safely parse double values
  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Helper method to safely parse int values
  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  @override
  String toString() {
    return 'ProductModel(brand: $brand, category: $category, model: $model, type: $type, powerKw: $powerKw, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductModel &&
        other.brand == brand &&
        other.category == category &&
        other.model == model &&
        other.type == type &&
        other.phase == phase &&
        other.powerKw == powerKw &&
        other.maxPvKw == maxPvKw &&
        other.mppt == mppt &&
        other.batteryType == batteryType &&
        other.voltage == voltage &&
        other.usage == usage &&
        other.suitableFor == suitableFor &&
        other.descriptionShort == descriptionShort &&
        other.warranty == warranty &&
        other.imageUrl == imageUrl &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      brand,
      category,
      model,
      type,
      phase,
      powerKw,
      maxPvKw,
      mppt,
      batteryType,
      voltage,
      usage,
      suitableFor,
      descriptionShort,
      warranty,
      imageUrl,
      status,
    );
  }
}

