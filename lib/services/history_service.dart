import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/patient_history.dart';
import 'package:intl/intl.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add history entry without image storage
  Future<void> addHistory({
    required String disease,
    String? notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final docRef = _firestore.collection('patient_history').doc();

    final history = PatientHistory(
      id: docRef.id,
      userId: user.uid,
      imageUrl: '', // Empty since we're not storing images
      disease: disease,
      date: DateTime.now(),
      notes: notes,
    );

    await docRef.set(history.toMap());
  }

  // Get history for current user
  Stream<List<PatientHistory>> getHistory() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    return _firestore
        .collection('patient_history')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PatientHistory.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> clearHistory() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('patient_history')
            .where('userId', isEqualTo: user.uid)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print('Error clearing history: $e');
      rethrow;
    }
  }

  Future<void> deleteHistoryEntry(String documentId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('patient_history').doc(documentId).delete();
      }
    } catch (e) {
      print('Error deleting history entry: $e');
      rethrow;
    }
  }
}
