enum PumpingMode {
  flow,
  area,
  tank,
}

enum FlowUnit {
  m3h,
  lmin,
}

enum AreaUnit {
  m2,
  ha,
}

enum CurrentSource {
  electricity,
  diesel,
  unknown,
}

class PumpingInput {
  final PumpingMode mode;
  
  // FLOW MODE fields
  final double? flowValue;
  final FlowUnit? flowUnit;
  final double? headMeters;
  
  // AREA MODE fields
  final double? areaValue;
  final AreaUnit? areaUnit;
  final String? cropType;
  final String? irrigationType;
  
  // TANK MODE fields
  final double? tankVolumeM3;
  final double? fillHours;
  final double? wellDepthM;
  final double? tankHeightM;
  
  // Shared fields
  final double? hoursPerDay;
  final String regionCode;
  final CurrentSource currentSource;

  PumpingInput({
    required this.mode,
    this.flowValue,
    this.flowUnit,
    this.headMeters,
    this.areaValue,
    this.areaUnit,
    this.cropType,
    this.irrigationType,
    this.tankVolumeM3,
    this.fillHours,
    this.wellDepthM,
    this.tankHeightM,
    this.hoursPerDay,
    required this.regionCode,
    required this.currentSource,
  });

  // Factory constructors for each mode
  factory PumpingInput.flow({
    required double flowValue,
    required FlowUnit flowUnit,
    required double headMeters,
    required double hoursPerDay,
    required String regionCode,
    required CurrentSource currentSource,
  }) {
    return PumpingInput(
      mode: PumpingMode.flow,
      flowValue: flowValue,
      flowUnit: flowUnit,
      headMeters: headMeters,
      hoursPerDay: hoursPerDay,
      regionCode: regionCode,
      currentSource: currentSource,
    );
  }

  factory PumpingInput.area({
    required double areaValue,
    required AreaUnit areaUnit,
    required String cropType,
    required String irrigationType,
    required double hoursPerDay,
    required double headMeters,
    required String regionCode,
    required CurrentSource currentSource,
  }) {
    return PumpingInput(
      mode: PumpingMode.area,
      areaValue: areaValue,
      areaUnit: areaUnit,
      cropType: cropType,
      irrigationType: irrigationType,
      hoursPerDay: hoursPerDay,
      headMeters: headMeters,
      regionCode: regionCode,
      currentSource: currentSource,
    );
  }

  factory PumpingInput.tank({
    required double tankVolumeM3,
    required double fillHours,
    required double wellDepthM,
    required double tankHeightM,
    required String regionCode,
    required CurrentSource currentSource,
  }) {
    return PumpingInput(
      mode: PumpingMode.tank,
      tankVolumeM3: tankVolumeM3,
      fillHours: fillHours,
      wellDepthM: wellDepthM,
      tankHeightM: tankHeightM,
      regionCode: regionCode,
      currentSource: currentSource,
    );
  }
}

