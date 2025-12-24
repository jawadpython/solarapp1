class ProjectRequest {
  final String? id;
  final String userId;
  final String projectType; // ON-GRID, OFF-GRID, PUMPING, HYBRID
  final double consumption;
  final bool isKwh;
  final int panelPower;
  final double estimatedPower;
  final String status; // pending, approved, rejected
  final DateTime createdAt;

  ProjectRequest({
    this.id,
    required this.userId,
    required this.projectType,
    required this.consumption,
    required this.isKwh,
    required this.panelPower,
    required this.estimatedPower,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'projectType': projectType,
      'consumption': consumption,
      'isKwh': isKwh,
      'panelPower': panelPower,
      'estimatedPower': estimatedPower,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProjectRequest.fromMap(String id, Map<String, dynamic> map) {
    return ProjectRequest(
      id: id,
      userId: map['userId'] ?? '',
      projectType: map['projectType'] ?? '',
      consumption: (map['consumption'] ?? 0).toDouble(),
      isKwh: map['isKwh'] ?? true,
      panelPower: map['panelPower'] ?? 550,
      estimatedPower: (map['estimatedPower'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

