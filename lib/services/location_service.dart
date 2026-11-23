import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../data/models/models.dart';

class LocationUnavailableException implements Exception {
  const LocationUnavailableException(this.message, {this.canOpenSettings = false});

  final String message;
  final bool canOpenSettings;

  @override
  String toString() => message;
}

class LocationService {
  Future<LivePoint> currentPoint() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationUnavailableException(
        'Location permission is off. Turn it on in Settings so your person can find you.',
        canOpenSettings: true,
      );
    }
    if (permission == LocationPermission.denied) {
      throw const LocationUnavailableException(
        'Location permission is needed for live distance.',
      );
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationUnavailableException(
        'Location services are off. Turn them on to share where you are.',
        canOpenSettings: true,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 18),
        ),
      );
      return _pointFrom(position);
    } on TimeoutException {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return _pointFrom(lastKnown);
      throw const LocationUnavailableException(
        'We could not get a location fix. Try again in a moment.',
      );
    } on LocationServiceDisabledException {
      throw const LocationUnavailableException(
        'Location services are off. Turn them on to share where you are.',
        canOpenSettings: true,
      );
    }
  }

  Stream<LivePoint> watch() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 15,
      ),
    ).map(_pointFrom);
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  LivePoint _pointFrom(Position position) {
    return LivePoint(
      latitude: position.latitude,
      longitude: position.longitude,
      updatedAt: DateTime.now(),
      accuracy: position.accuracy,
    );
  }
}
