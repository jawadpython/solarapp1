import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';

/// Result model for location detection
class LocationResult {
  final double? lat;
  final double? lng;
  final String? city;
  final String? errorMessage;
  final bool needsPermission;
  final bool needsLocationService;
  final bool needsAppSettings;

  LocationResult({
    this.lat,
    this.lng,
    this.city,
    this.errorMessage,
    this.needsPermission = false,
    this.needsLocationService = false,
    this.needsAppSettings = false,
  });

  bool get isSuccess => lat != null && lng != null;
  
  String get coordinatesString {
    if (lat != null && lng != null) {
      return '${lat!.toStringAsFixed(6)}, ${lng!.toStringAsFixed(6)}';
    }
    return '';
  }
}

/// Service for handling GPS location and geocoding
/// Provides safe permission handling and location retrieval
class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('Error checking location service: $e');
      return false;
    }
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('Error opening location settings: $e');
      return false;
    }
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }

  /// Get address from coordinates (reverse geocoding)
  /// Returns city name or full address if available
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('Geocoding timeout');
          return <Placemark>[];
        },
      );

      if (placemarks.isEmpty) {
        return null;
      }

      final place = placemarks.first;
      
      // Try to get city name first
      if (place.locality != null && place.locality!.isNotEmpty) {
        return place.locality;
      }
      
      // Fallback to subAdministrativeArea or administrativeArea
      if (place.subAdministrativeArea != null && 
          place.subAdministrativeArea!.isNotEmpty) {
        return place.subAdministrativeArea;
      }
      
      if (place.administrativeArea != null && 
          place.administrativeArea!.isNotEmpty) {
        return place.administrativeArea;
      }

      // Return formatted address as last resort
      return _formatAddress(place);
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Format placemark to readable address string
  String? _formatAddress(Placemark place) {
    List<String> parts = [];
    
    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    if (place.postalCode != null && place.postalCode!.isNotEmpty) {
      parts.add(place.postalCode!);
    }
    
    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  /// Main method to get location with full permission and GPS handling
  /// Returns LocationResult with coordinates and city, or error information
  Future<LocationResult> getLocation() async {
    try {
      // Step 1: Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          errorMessage: 'Veuillez activer votre localisation pour détecter votre position',
          needsLocationService: true,
        );
      }

      // Step 2: Check permission status
      LocationPermission permission = await checkPermission();
      
      // Step 3: Handle permission states
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            errorMessage: 'Veuillez autoriser la localisation pour continuer',
            needsPermission: true,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          errorMessage: 'Autorisation localisation bloquée. Veuillez l\'activer dans les paramètres',
          needsAppSettings: true,
        );
      }

      // Step 4: Get position with timeout
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('Location timeout');
            return throw TimeoutException('Location timeout', const Duration(seconds: 10));
          },
        );
      } catch (e) {
        if (e is TimeoutException) {
          return LocationResult(
            errorMessage: 'Délai d\'attente dépassé. Veuillez réessayer',
          );
        }
        rethrow;
      }

      if (position == null) {
        return LocationResult(
          errorMessage: 'Impossible de détecter votre position',
        );
      }

      // Step 5: Reverse geocode to get city
      String? city;
      try {
        city = await getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } catch (e) {
        debugPrint('Geocoding failed but continuing with coordinates: $e');
        // Continue without city if geocoding fails
      }

      // Step 6: Return success result
      return LocationResult(
        lat: position.latitude,
        lng: position.longitude,
        city: city,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return LocationResult(
        errorMessage: 'Erreur lors de la détection de la position: ${e.toString()}',
      );
    }
  }

  /// Get current position with permission handling
  /// Returns null if permission denied or location unavailable
  /// @deprecated Use getLocation() instead
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Check permission status
      LocationPermission permission = await checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied forever');
        return null;
      }

      // Get position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  /// Get location string (coordinates and/or city)
  /// Returns formatted string for GPS field
  /// @deprecated Use getLocation() instead
  Future<String?> getLocationString() async {
    try {
      final result = await getLocation();
      if (!result.isSuccess) {
        return null;
      }

      // Format: "latitude, longitude" or "City (latitude, longitude)"
      if (result.city != null && result.city!.isNotEmpty) {
        return '${result.city} (${result.coordinatesString})';
      }

      // Fallback to coordinates only
      return result.coordinatesString;
    } catch (e) {
      debugPrint('Error getting location string: $e');
      return null;
    }
  }

  /// Get coordinates only string
  /// @deprecated Use getLocation() instead
  Future<String?> getCoordinatesString() async {
    try {
      final result = await getLocation();
      if (!result.isSuccess) {
        return null;
      }
      return result.coordinatesString;
    } catch (e) {
      debugPrint('Error getting coordinates string: $e');
      return null;
    }
  }
}
