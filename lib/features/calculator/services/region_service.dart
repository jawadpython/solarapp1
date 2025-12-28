import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class RegionModel {
  final String regionCode;
  final String regionNameFr;

  RegionModel({
    required this.regionCode,
    required this.regionNameFr,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      regionCode: json['regionCode'] as String,
      regionNameFr: json['regionNameFr'] as String,
    );
  }
}

class RegionService {
  static RegionService? _instance;
  static RegionService get instance {
    _instance ??= RegionService._();
    return _instance!;
  }

  RegionService._();

  List<RegionModel>? _regions;
  Map<String, List<double>>? _sunHours;

  /// Load regions from JSON file
  Future<List<RegionModel>> loadRegions() async {
    if (_regions != null) {
      return _regions!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/regions.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      _regions = jsonList
          .map((json) => RegionModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return _regions!;
    } catch (e) {
      debugPrint('Error loading regions: $e');
      return [];
    }
  }

  /// Load sun hours from JSON file
  Future<Map<String, List<double>>> loadSunHours() async {
    if (_sunHours != null) {
      return _sunHours!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/regionSunHours.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString) as Map<String, dynamic>;

      _sunHours = jsonMap.map((key, value) {
        final List<dynamic> hoursList = value as List<dynamic>;
        return MapEntry(
          key,
          hoursList.map((hour) => (hour as num).toDouble()).toList(),
        );
      });

      return _sunHours!;
    } catch (e) {
      debugPrint('Error loading sun hours: $e');
      return {};
    }
  }

  /// Get sun hours for a specific region based on current month
  /// Returns 5.5 as fallback if region code is not found or error occurs
  Future<double> getSunHoursByRegion(String regionCode) async {
    try {
      final sunHoursMap = await loadSunHours();

      if (!sunHoursMap.containsKey(regionCode)) {
        debugPrint('Region code not found: $regionCode');
        return 5.5;
      }

      final monthHours = sunHoursMap[regionCode];
      if (monthHours == null || monthHours.isEmpty) {
        debugPrint('Sun hours data is empty for region: $regionCode');
        return 5.5;
      }

      final monthIndex = DateTime.now().month - 1; // 0-11 for Jan-Dec
      if (monthIndex >= 0 && monthIndex < monthHours.length) {
        return monthHours[monthIndex];
      }

      debugPrint('Invalid month index: $monthIndex');
      return 5.5;
    } catch (e) {
      debugPrint('Error getting sun hours for region $regionCode: $e');
      return 5.5;
    }
  }

  /// Get region name by code
  Future<String?> getRegionNameByCode(String regionCode) async {
    try {
      final regions = await loadRegions();
      final region = regions.firstWhere(
        (r) => r.regionCode == regionCode,
        orElse: () => RegionModel(regionCode: '', regionNameFr: ''),
      );
      return region.regionCode.isEmpty ? null : region.regionNameFr;
    } catch (e) {
      debugPrint('Error getting region name for code $regionCode: $e');
      return null;
    }
  }
}

