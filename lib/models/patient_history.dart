import 'package:cloud_firestore/cloud_firestore.dart';

class PatientHistory {
  final String id;
  final String userId;
  final String imageUrl;
  final String disease;
  final DateTime date;
  final String? notes;

  PatientHistory({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.disease,
    required this.date,
    this.notes,
  });

  factory PatientHistory.fromMap(Map<String, dynamic> map, String documentId) {
    return PatientHistory(
      id: documentId,
      userId: map['userId'] as String,
      imageUrl: map['imageUrl'] as String,
      disease: map['disease'] as String,
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'disease': disease,
      'date': date,
      'notes': notes,
    };
  }
}
