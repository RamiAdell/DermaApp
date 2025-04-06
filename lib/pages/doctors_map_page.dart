import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../models/doctor.dart';
import '../services/doctor_service.dart';

class DoctorsMapPage extends StatefulWidget {
  const DoctorsMapPage({super.key});

  @override
  State<DoctorsMapPage> createState() => _DoctorsMapPageState();
}

class _DoctorsMapPageState extends State<DoctorsMapPage> {
  final DoctorService _doctorService = DoctorService();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  List<Doctor> _nearbyDoctors = [];
  bool _isLoading = true;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      print('Getting current location...');
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('Requesting location permission');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions denied');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions permanently denied');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
        return;
      }

      print('Getting current position...');
      Position position = await Geolocator.getCurrentPosition();
      print(
          'Current position obtained: ${position.latitude}, ${position.longitude}');

      setState(() {
        _currentPosition = position;
      });

      // Initialize dummy data if needed
      print('Initializing dummy data...');
      try {
        await _doctorService.addDummyDoctors();
        print('Dummy data initialized successfully');
      } catch (e) {
        print('Error initializing dummy data: $e');
      }

      _loadNearbyDoctors();
    } catch (e) {
      print('Error in getCurrentLocation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _loadNearbyDoctors() async {
    if (_currentPosition == null) {
      print('Current position is null, cannot load doctors');
      return;
    }

    try {
      print('Loading nearby doctors...');
      final doctors = await _doctorService.getNearbyDoctors(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      print('Loaded ${doctors.length} doctors');
      setState(() {
        _nearbyDoctors = doctors;
        _isLoading = false;
      });

      print('Updating markers...');
      _updateMarkers();
      print('Markers updated');

      // Show route to nearest doctor if available
      if (_nearbyDoctors.isNotEmpty) {
        print('Showing route to nearest doctor: ${_nearbyDoctors[0].name}');
        await _showDirections(_nearbyDoctors[0]);
      }
    } catch (e) {
      print('Error loading doctors: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading doctors: $e')),
      );
    }
  }

  void _updateMarkers() {
    print('Starting to update markers...');
    Set<Marker> markers = {};

    // Add current location marker
    if (_currentPosition != null) {
      print('Adding current location marker');
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Add doctor markers
    print('Adding ${_nearbyDoctors.length} doctor markers');
    for (var doctor in _nearbyDoctors) {
      print(
          'Adding marker for doctor: ${doctor.name} at ${doctor.latitude}, ${doctor.longitude}');
      markers.add(
        Marker(
          markerId: MarkerId(doctor.id),
          position: LatLng(doctor.latitude, doctor.longitude),
          infoWindow: InfoWindow(
            title: doctor.name,
            snippet: '${doctor.specialty}\n${doctor.address}',
          ),
          onTap: () => _showDoctorInfo(doctor),
        ),
      );
    }

    setState(() {
      _markers = markers;
      print('Set ${_markers.length} markers on the map');
    });
  }

  Future<void> _showDirections(Doctor doctor) async {
    if (_currentPosition == null) return;

    try {
      print('Showing directions to ${doctor.name}...');

      // Clear existing polylines
      setState(() {
        _polylines.clear();
      });

      // Create route points
      List<LatLng> routePoints = await _getRoutePoints(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        LatLng(doctor.latitude, doctor.longitude),
      );

      print('Got ${routePoints.length} route points');

      // Add new polyline with route points
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 6,
        points: routePoints,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        geodesic: true,
      );

      setState(() {
        _polylines.add(polyline);
      });

      // Zoom to show the entire route with padding
      if (_mapController != null) {
        LatLngBounds bounds = _getBoundsForPoints(routePoints);
        final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100.0);
        await _mapController!.animateCamera(cameraUpdate);
      }
    } catch (e) {
      print('Error showing directions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error showing directions: $e')),
      );
    }
  }

  Future<List<LatLng>> _getRoutePoints(
      LatLng origin, LatLng destination) async {
    final String googleApiKey = 'AIzaSyDsbABEhgA20vIbMHm6DEXlAaYtld9Wrl0';
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=$googleApiKey';

    try {
      print('Fetching route from Google Maps API...');
      final response = await http.get(Uri.parse(url));
      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'OK') {
          List<LatLng> points = [];
          List<dynamic> routes = data['routes'];

          if (routes.isNotEmpty) {
            // Get the first route
            var route = routes[0];

            // Decode the overview polyline
            String encodedPolyline = route['overview_polyline']['points'];
            points = _decodePolyline(encodedPolyline);

            print('Successfully decoded ${points.length} route points');
            return points;
          }
        } else {
          print('API returned status: ${data['status']}');
        }
      }

      // If the API call fails, fall back to a simple straight line
      print(
          'Failed to get route from Google Maps API, falling back to direct line');
      return [origin, destination];
    } catch (e) {
      print('Error getting route: $e');
      return [origin, destination];
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  LatLngBounds _getBoundsForPoints(List<LatLng> points) {
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Remove all characters except digits and +
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    try {
      // For Android, we'll use the Intent approach
      final phoneUri = Uri.parse('tel:$cleanNumber');

      if (!context.mounted) return;

      // First try launching with LaunchMode.platformDefault
      bool launched = await launchUrl(
        phoneUri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched) {
        // If that fails, try with external application mode
        launched = await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
      }

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Could not launch dialer. Number: $cleanNumber',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error launching phone dialer: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error: Unable to make phone call. Please try again.',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _showDoctorInfo(Doctor doctor) {
    double distance = doctor.distanceTo(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF66785F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  doctor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(Icons.medical_services, doctor.specialty),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.location_on, doctor.address),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.phone, doctor.phone),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.directions_walk,
                '${distance.toStringAsFixed(2)} km away'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showDirections(doctor),
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text('Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB2C9AD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(doctor.phone),
                  icon: const Icon(Icons.phone, color: Colors.white),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66785F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFB2C9AD),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF66785F),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF4B5945),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDoctorsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF66785F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Nearby Doctors',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _nearbyDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = _nearbyDoctors[index];
                  final distance = doctor.distanceTo(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFB2C9AD),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        doctor.name,
                        style: const TextStyle(
                          color: Color(0xFF4B5945),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.address,
                            style: const TextStyle(
                              color: Color(0xFF4B5945),
                            ),
                          ),
                          Text(
                            '${distance.toStringAsFixed(2)} km away',
                            style: const TextStyle(
                              color: Color(0xFF66785F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.directions,
                                color: Color(0xFFB2C9AD)),
                            onPressed: () async {
                              final url = Uri.parse(
                                  'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}'
                                  '&destination=${doctor.latitude},${doctor.longitude}&travelmode=driving');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.phone,
                                color: Color(0xFF66785F)),
                            onPressed: () => _makePhoneCall(doctor.phone),
                          ),
                        ],
                      ),
                      onTap: () {
                        if (_mapController != null) {
                          _mapController!.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(doctor.latitude, doctor.longitude),
                              15,
                            ),
                          );
                          Navigator.pop(context);
                          _showDirections(doctor);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF66785F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Nearby Doctors',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition?.latitude ?? 30.0444,
            _currentPosition?.longitude ?? 31.2357,
          ),
          zoom: 13,
        ),
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
          });
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: _showDoctorsBottomSheet,
          label: const Text(
            'Show Nearby Doctors',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          icon: const Icon(Icons.list, color: Colors.white),
          backgroundColor: const Color(0xFF66785F),
          elevation: 0,
        ),
      ),
    );
  }
}
