import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MoroccanCity {
  final String id;
  final String nameFr;
  final String nameAr;
  final String nameEn;
  final List<String> aliases;

  const MoroccanCity({
    required this.id,
    required this.nameFr,
    required this.nameAr,
    required this.nameEn,
    required this.aliases,
  });

  factory MoroccanCity.fromJson(Map<String, dynamic> json) {
    return MoroccanCity(
      id: json['id'] as String,
      nameFr: json['name_fr'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      aliases: (json['aliases'] as List<dynamic>? ?? const [])
          .map((alias) => alias.toString())
          .toList(),
    );
  }

  String displayName(String locale) {
    switch (locale) {
      case 'ar':
        return nameAr;
      case 'en':
        return nameEn;
      default:
        return nameFr;
    }
  }
}

class CityFilterOption {
  final String id;
  final String label;

  const CityFilterOption({required this.id, required this.label});
}

class CityService {
  static const String otherCityId = 'other';
  static const String allFilterId = 'Tous';

  static CityService? _instance;
  static CityService get instance {
    _instance ??= CityService._();
    return _instance!;
  }

  CityService._();

  List<MoroccanCity>? _cities;
  Map<String, MoroccanCity>? _citiesById;
  Map<String, String>? _aliasToId;

  Future<void> ensureLoaded() async {
    if (_cities != null) return;
    await loadCities();
  }

  Future<List<MoroccanCity>> loadCities() async {
    if (_cities != null) return _cities!;

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/moroccan_cities.json');
      final jsonList = json.decode(jsonString) as List<dynamic>;
      _cities = jsonList
          .map((item) => MoroccanCity.fromJson(item as Map<String, dynamic>))
          .toList();

      _citiesById = {
        for (final city in _cities!) city.id: city,
      };

      _aliasToId = {};
      for (final city in _cities!) {
        _registerAlias(city.id, city.id);
        _registerAlias(city.id, city.nameFr);
        _registerAlias(city.id, city.nameAr);
        _registerAlias(city.id, city.nameEn);
        for (final alias in city.aliases) {
          _registerAlias(city.id, alias);
        }
      }
    } catch (e) {
      debugPrint('Error loading Moroccan cities: $e');
      _cities = [];
      _citiesById = {};
      _aliasToId = {};
    }

    return _cities!;
  }

  void _registerAlias(String cityId, String alias) {
    final normalized = normalize(alias);
    if (normalized.isEmpty) return;
    _aliasToId![normalized] = cityId;
  }

  MoroccanCity? getCityById(String cityId) {
    return _citiesById?[cityId];
  }

  List<MoroccanCity> getCitiesSorted(String locale) {
    final cities = List<MoroccanCity>.from(_cities ?? const []);
    cities.sort(
      (a, b) => a.displayName(locale).compareTo(b.displayName(locale)),
    );
    return cities;
  }

  String getDisplayName(String cityId, String locale) {
    final city = getCityById(cityId);
    if (city != null) return city.displayName(locale);
    return cityId;
  }

  String normalize(String input) {
    var value = input.trim().toLowerCase();
    if (value.isEmpty) return '';

    const replacements = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ä': 'a',
      'ã': 'a',
      'å': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'ö': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
      'œ': 'oe',
      'æ': 'ae',
      '’': '',
      "'": '',
      '-': ' ',
      '_': ' ',
    };

    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(replacements[char] ?? char);
    }

    value = buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    return value;
  }

  String? resolveCityId(String input) {
    if (_aliasToId == null) return null;

    final normalized = normalize(input);
    if (normalized.isEmpty) return null;
    return _aliasToId![normalized];
  }

  String cityTextFromRecord(Map<String, dynamic> record) {
    final city = record['city']?.toString().trim();
    if (city != null && city.isNotEmpty) return city;
    final ville = record['ville']?.toString().trim();
    if (ville != null && ville.isNotEmpty) return ville;
    return '';
  }

  String getCityIdForRecord(Map<String, dynamic> record) {
    final storedId = record['cityId']?.toString().trim();
    if (storedId != null && storedId.isNotEmpty && storedId != otherCityId) {
      if (storedId.startsWith('legacy:')) return storedId;
      if (getCityById(storedId) != null) return storedId;
    }

    final cityText = cityTextFromRecord(record);
    if (cityText.isEmpty) return '';

    final resolved = resolveCityId(cityText);
    if (resolved != null) return resolved;

    return 'legacy:${normalize(cityText)}';
  }

  String getDisplayLabelForRecord(Map<String, dynamic> record, String locale) {
    final cityId = getCityIdForRecord(record);
    if (cityId.isEmpty) return '';

    if (cityId.startsWith('legacy:')) {
      return cityTextFromRecord(record);
    }

    final city = getCityById(cityId);
    if (city != null) return city.displayName(locale);

    return cityTextFromRecord(record);
  }

  List<CityFilterOption> buildFilterOptions(
    List<Map<String, dynamic>> records,
    String locale,
  ) {
    final labelsById = <String, String>{};

    for (final record in records) {
      final cityId = getCityIdForRecord(record);
      if (cityId.isEmpty) continue;
      labelsById.putIfAbsent(
        cityId,
        () => getDisplayLabelForRecord(record, locale),
      );
    }

    final options = labelsById.entries
        .map((entry) => CityFilterOption(id: entry.key, label: entry.value))
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    return options;
  }

  String resolveFilterId(String filterValue) {
    final trimmed = filterValue.trim();
    if (trimmed.isEmpty) return '';

    if (trimmed.startsWith('legacy:')) return trimmed;
    if (getCityById(trimmed) != null) return trimmed;

    final resolved = resolveCityId(trimmed);
    if (resolved != null) return resolved;

    return 'legacy:${normalize(trimmed)}';
  }

  bool matchesCityFilter(
    Map<String, dynamic> record,
    String? selectedCityId,
  ) {
    if (selectedCityId == null ||
        selectedCityId.isEmpty ||
        selectedCityId == allFilterId) {
      return true;
    }
    return getCityIdForRecord(record) == resolveFilterId(selectedCityId);
  }

  Map<String, String?> resolveCityFields({
    required String ville,
    String? cityId,
  }) {
    final trimmedVille = ville.trim();
    final resolvedId = (cityId != null && cityId.isNotEmpty && cityId != otherCityId)
        ? cityId
        : resolveCityId(trimmedVille);

    return {
      'ville': trimmedVille,
      'city': trimmedVille,
      'cityId': resolvedId,
    };
  }
}
