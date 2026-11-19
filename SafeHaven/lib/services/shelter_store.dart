import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/shelter.dart';

enum LocationStatus { idle, loading, ready, failed }

/// Device feature: LOCATION.
/// Wraps the geolocator plugin: checks that GPS is on, asks permission,
/// reads the position and exposes it to the UI. If anything fails, the app
/// falls back to a default point (central Kuala Lumpur) so it still works.
class ShelterStore extends ChangeNotifier {
  ShelterStore._();
  static final ShelterStore instance = ShelterStore._();

  static const double _fallbackLat = 3.1390;
  static const double _fallbackLon = 101.6869;

  final List<Shelter> _shelters = sampleShelters();

  LocationStatus status = LocationStatus.idle;
  String message = 'Location not requested yet.';
  double userLat = _fallbackLat;
  double userLon = _fallbackLon;
  bool get usingGps => status == LocationStatus.ready;

  // ---------- location ----------
  Future<void> refreshLocation() async {
    status = LocationStatus.loading;
    message = 'Finding your location...';
    notifyListeners();

    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        return _fail('Location is switched off. Turn on GPS to see distances.');
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        return _fail('Location permission denied. Showing central KL instead.');
      }
      if (perm == LocationPermission.deniedForever) {
        return _fail(
            'Permission blocked. Enable it in phone Settings > Apps > Permissions.');
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      userLat = pos.latitude;
      userLon = pos.longitude;
      status = LocationStatus.ready;
      message = 'Using your live location.';
      notifyListeners();
    } catch (e) {
      _fail('Could not get a GPS fix. Showing central KL instead.');
    }
  }

  void _fail(String msg) {
    status = LocationStatus.failed;
    message = msg;
    userLat = _fallbackLat;
    userLon = _fallbackLon;
    notifyListeners();
  }

  double distanceKm(Shelter s) =>
      Geolocator.distanceBetween(userLat, userLon, s.lat, s.lon) / 1000;

  // ---------- data ----------
  List<Shelter> get nearestFirst {
    final list = List<Shelter>.from(_shelters);
    list.sort((a, b) => distanceKm(a).compareTo(distanceKm(b)));
    return list;
  }

  Shelter? get nearestOpenWithSpace {
    for (final s in nearestFirst) {
      if (s.isOpen && !s.isFull) return s;
    }
    return null;
  }

  int get totalCount => _shelters.length;
  int get openCount => _shelters.where((s) => s.isOpen).length;
  int get freeBeds =>
      _shelters.where((s) => s.isOpen).fold(0, (sum, s) => sum + s.available);

  void add(Shelter s) {
    _shelters.add(s);
    notifyListeners();
  }

  void update(Shelter s) {
    final i = _shelters.indexWhere((x) => x.id == s.id);
    if (i != -1) _shelters[i] = s;
    notifyListeners();
  }
}
