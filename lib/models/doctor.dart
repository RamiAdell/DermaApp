import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final double latitude;
  final double longitude;
  final String address;
  final String phone;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phone': phone,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    print('Creating Doctor from map: $map');
    try {
      return Doctor(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        specialty: map['specialty'] ?? '',
        latitude: (map['latitude'] ?? 0.0).toDouble(),
        longitude: (map['longitude'] ?? 0.0).toDouble(),
        address: map['address'] ?? '',
        phone: map['phone'] ?? '',
      );
    } catch (e) {
      print('Error creating Doctor from map: $e');
      rethrow;
    }
  }

  double distanceTo(double userLat, double userLng) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert latitude and longitude from degrees to radians
    final double lat1 = userLat * pi / 180;
    final double lon1 = userLng * pi / 180;
    final double lat2 = latitude * pi / 180;
    final double lon2 = longitude * pi / 180;

    // Haversine formula
    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance; // Returns distance in kilometers
  }
}
