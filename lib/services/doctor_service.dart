import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor.dart';
import 'dart:math';

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  // Helper method to generate random phone number
  String _generateRandomPhoneNumber() {
    // Generate random 7 digits for the phone number
    String randomDigits =
        List.generate(7, (index) => _random.nextInt(10)).join();

    // Format: +20 1XX XXX XXXX where X is random
    return '+20 1${_random.nextInt(6)}${_random.nextInt(10)} ${randomDigits.substring(0, 3)} ${randomDigits.substring(3)}';
  }

  // Get all doctors
  Stream<List<Doctor>> getDoctors() {
    return _firestore.collection('doctors').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Doctor.fromMap(doc.data())).toList());
  }

  // Get doctors sorted by distance from user
  Future<List<Doctor>> getNearbyDoctors(double userLat, double userLng) async {
    print('Fetching doctors from Firestore...');
    final doctors = await _firestore.collection('doctors').get();
    print('Found ${doctors.docs.length} doctors');

    List<Doctor> doctorsList = doctors.docs.map((doc) {
      print('Doctor data: ${doc.data()}');
      return Doctor.fromMap(doc.data());
    }).toList();

    // Sort by distance
    doctorsList.sort((a, b) {
      double distA = a.distanceTo(userLat, userLng);
      double distB = b.distanceTo(userLat, userLng);
      return distA.compareTo(distB);
    });

    return doctorsList;
  }

  // Add dummy doctors data
  Future<void> addDummyDoctors() async {
    print('Starting to add dummy doctors...');

    try {
      // First, delete all existing doctors
      print('Deleting existing doctors...');
      final existingDoctors = await _firestore.collection('doctors').get();
      WriteBatch deleteBatch = _firestore.batch();
      for (var doc in existingDoctors.docs) {
        deleteBatch.delete(doc.reference);
      }
      await deleteBatch.commit();
      print(
          'Successfully deleted ${existingDoctors.docs.length} existing doctors');

      List<Map<String, dynamic>> dummyDoctors = [
        {
          'id': '5',
          'name': 'Dr. Heba Kamal',
          'specialty': 'Dermatologist',
          'latitude': 30.020343128583896,
          'longitude': 31.17169920785318,
          'address': 'Kit Kat Medical Center, Imbaba',
          'phone': _generateRandomPhoneNumber(),
        },
        {
          'id': '6',
          'name': 'Dr. Yasser Hamdy',
          'specialty': 'Dermatologist',
          'latitude': 29.99486940914076,
          'longitude': 31.18046060933262,
          'address': 'Giza Medical Complex, Giza Square',
          'phone': _generateRandomPhoneNumber(),
        },
        {
          'id': '7',
          'name': 'Dr. Rana Adel',
          'specialty': 'Dermatologist',
          'latitude': 30.006013435107313,
          'longitude': 31.26665405744868,
          'address': 'Downtown Medical Tower, Cairo',
          'phone': _generateRandomPhoneNumber(),
        },
        {
          'id': '8',
          'name': 'Dr. Khaled Omar',
          'specialty': 'Dermatologist',
          'latitude': 30.0492379750985,
          'longitude': 31.215602985525646,
          'address': 'Heliopolis Dermatology Center',
          'phone': _generateRandomPhoneNumber(),
        },
        {
          'id': '10',
          'name': 'Dr. Tarek Mostafa',
          'specialty': 'Dermatologist',
          'latitude': 29.996154821337026,
          'longitude': 31.18652949226671,
          'address': 'Giza Dermatology Clinic, Giza',
          'phone': _generateRandomPhoneNumber(),
        },
        {
          'id': '11',
          'name': 'Dr. Fatma Hussein',
          'specialty': 'Dermatologist',
          'latitude': 29.976950090432375,
          'longitude': 31.198570301127585,
          'address': 'Haram Dermatology Center',
          'phone': _generateRandomPhoneNumber(),
        },
        {
          'id': '12',
          'name': 'Dr. Omar Saad',
          'specialty': 'Dermatologist',
          'latitude': 29.963169573994097,
          'longitude': 31.18574635019651,
          'address': 'Faisal Medical Complex',
          'phone': _generateRandomPhoneNumber(),
        },
        {
          'id': '13',
          'name': 'Dr. Laila Zaki',
          'specialty': 'Dermatologist',
          'latitude': 29.95576340818815,
          'longitude': 31.128196302901472,
          'address': 'October Medical Center',
          'phone': _generateRandomPhoneNumber(),
        },
        {
          'id': '14',
          'name': 'Dr. Hassan Mahmoud',
          'specialty': 'Dermatologist',
          'latitude': 29.920377107791296,
          'longitude': 31.189782343673635,
          'address': 'Maadi Skin Care Center',
          'phone': _generateRandomPhoneNumber(),
        },
      ];

      // Add new doctors
      WriteBatch addBatch = _firestore.batch();
      for (var doctorData in dummyDoctors) {
        print('Adding doctor: ${doctorData['name']}');
        DocumentReference docRef =
            _firestore.collection('doctors').doc(doctorData['id']);
        addBatch.set(docRef, doctorData, SetOptions(merge: true));
      }

      await addBatch.commit();
      print('Successfully added ${dummyDoctors.length} new doctors');
    } catch (e) {
      print('Error managing doctors data: $e');
      rethrow;
    }
  }
}
