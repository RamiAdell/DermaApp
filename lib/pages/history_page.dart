import 'package:flutter/material.dart';
import '../models/patient_history.dart';
import '../services/history_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class HistoryPage extends StatelessWidget {
  final HistoryService _historyService = HistoryService();

  HistoryPage({Key? key}) : super(key: key);

  String _formatDiagnosisResult(String rawResult) {
    try {
      final Map<String, dynamic> results = jsonDecode(rawResult);
      final List<dynamic> diseases = results['predicted_classes'];
      final List<dynamic> confidences = results['confidence'];

      List<String> formattedResults = [];
      for (int i = 0; i < diseases.length; i++) {
        String confidence =
            (double.parse(confidences[i].toString()) * 100).toStringAsFixed(1);
        formattedResults.add('${diseases[i]}: ${confidence}%');
      }
      return formattedResults.join('\n');
    } catch (e) {
      // If the result is in the old format, just return it as is
      return rawResult
          .replaceAll(RegExp(r'[\[\]{}"]'), '')
          .replaceAll('predicted_classes:', '')
          .replaceAll('confidence:', '')
          .trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF66785F),
        elevation: 0,
        title: const Text(
          'Medical History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<List<PatientHistory>>(
        stream: _historyService.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF66785F)),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No history available',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4B5945),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              final formattedResult = _formatDiagnosisResult(item.disease);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB2C9AD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: formattedResult.split('\n').map((result) {
                      final parts = result.split(':');
                      if (parts.length == 2) {
                        final confidence = double.tryParse(
                                parts[1].replaceAll('%', '').trim()) ??
                            0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      parts[0].trim(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4B5945),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    parts[1].trim(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF66785F),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Stack(
                                children: [
                                  Container(
                                    height: 4,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0E0E0),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: confidence / 100,
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: confidence >= 80
                                            ? const Color(0xFF66785F)
                                            : confidence >= 50
                                                ? const Color(0xFFB2C9AD)
                                                : const Color(0xFF4B5945),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(item.date)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF66785F).withOpacity(0.8),
                      ),
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB2C9AD),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.medical_services,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Diagnosis Details',
                                style: TextStyle(
                                  color: Color(0xFF4B5945),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...formattedResult.split('\n').map((result) {
                              final parts = result.split(':');
                              if (parts.length == 2) {
                                final confidence = double.tryParse(
                                        parts[1].replaceAll('%', '').trim()) ??
                                    0.0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              parts[0].trim(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF4B5945),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            parts[1].trim(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF66785F),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Stack(
                                        children: [
                                          Container(
                                            height: 6,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0E0E0),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                          FractionallySizedBox(
                                            widthFactor: confidence / 100,
                                            child: Container(
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: confidence >= 80
                                                    ? const Color(0xFF66785F)
                                                    : confidence >= 50
                                                        ? const Color(
                                                            0xFFB2C9AD)
                                                        : const Color(
                                                            0xFF4B5945),
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }).toList(),
                            const Divider(height: 24),
                            Text(
                              'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(item.date)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF66785F).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                color: Color(0xFF4B5945),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                await _historyService
                                    .deleteHistoryEntry(item.id);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Entry deleted successfully'),
                                    backgroundColor: Color(0xFF66785F),
                                  ),
                                );
                              } catch (e) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error deleting entry: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
