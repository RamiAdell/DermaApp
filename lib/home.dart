import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'public/public_constant.dart';
import 'widgets/defoult_button.dart';

import 'package:http/http.dart' as http;
import 'services/history_service.dart';
import 'pages/history_page.dart';
import 'pages/doctors_map_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HistoryService _historyService = HistoryService();
  final AuthService _authService = AuthService();
  bool isImageSelected = false;
  bool showImageContainer = false;
  File? selectedImageFile;
  String? imagePath;
  String? diagnosisResult;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    if (_auth.currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.get('displayName') as String?;
          });
        }
      } catch (e) {
        print('Error loading user name: $e');
      }
    }
  }

  void closeResultDialog() {
    setState(() {
      showDialog = false;
    });
  }

  bool showDialog = false;
  bool isProcessing = false;

  void pickImage(BuildContext context, ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      setState(() {
        selectedImageFile = File(image.path);
        imagePath = image.path;
        isImageSelected = true;
        showImageContainer = true;
      });
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFF66785F),
      textColor: Colors.white,
      fontSize: 16.0,
      webShowClose: true,
      webBgColor: "#66785F",
      webPosition: "center",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF66785F),
        elevation: 0,
        title: const Text(
          'DermaApp',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF66785F),
              ),
              margin: EdgeInsets.zero,
              currentAccountPicture: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFB2C9AD),
                  child: Text(
                    _userName?.isNotEmpty == true
                        ? _userName![0].toUpperCase()
                        : _auth.currentUser?.email?.isNotEmpty == true
                            ? _auth.currentUser!.email![0].toUpperCase()
                            : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              accountName: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _userName ?? 'User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              accountEmail: Text(
                _auth.currentUser?.email ?? '',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.history,
                color: Color(0xFF66785F),
              ),
              title: const Text(
                'Medical History',
                style: TextStyle(
                  color: Color(0xFF4B5945),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.local_hospital,
                color: Color(0xFF66785F),
              ),
              title: const Text(
                'Find Doctors',
                style: TextStyle(
                  color: Color(0xFF4B5945),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorsMapPage()),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Color(0xFF66785F),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFF4B5945),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                try {
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: boxDecoration(),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: isImageSelected
                      ? Image.file(
                          selectedImageFile!,
                          fit: BoxFit.contain,
                        )
                      : Center(
                          child: Text(
                            'Choose an Image',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Maximum image size: 5 MB',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DefaultButton(
                      buttonWidget: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.photo, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      function: () {
                        pickImage(context, ImageSource.gallery);
                      },
                      width: MediaQuery.of(context).size.width / 3,
                      radius: 15.0,
                      backgroundColor: const Color(0xFF4B5945),
                    ),
                    const SizedBox(height: 20),
                    DefaultButton(
                      buttonWidget: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            'Camera',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      function: () {
                        pickImage(context, ImageSource.camera);
                      },
                      width: MediaQuery.of(context).size.width / 3,
                      radius: 15.0,
                      backgroundColor: const Color(0xFF4B5945),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DefaultButton(
                  buttonWidget: const Text(
                    'Diagnose',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  function: () async {
                    await performDiagnosis();
                  },
                  width: MediaQuery.of(context).size.width / 2,
                  radius: 20.0,
                  backgroundColor: const Color(0xFF66785F),
                ),
              ],
            ),
          ),
          resultDialog(
            showDialog,
            const Text(
              'Results',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            diagnosisResult ?? '',
            closeResultDialog,
          ),
        ],
      ),
    );
  }

  Visibility resultDialog(
    bool showDialog,
    Widget title,
    String text,
    Function closeDialog,
  ) {
    return Visibility(
      visible: showDialog,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF66785F),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Results',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isProcessing) ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF66785F)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Processing your image...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4B5945),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFB2C9AD),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.medical_services,
                            color: Color(0xFF66785F),
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Diagnosis Results',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF4B5945),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (text.isNotEmpty) ...[
                        ..._parseDiagnosisResults(text).map((result) => Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result['disease'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF4B5945),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Stack(
                                    children: [
                                      Container(
                                        height: 8,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0E0E0),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: result['confidence'],
                                        child: Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _getConfidenceColor(
                                                result['confidence']),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${(result['confidence'] * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _getConfidenceColor(
                                            result['confidence']),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ] else ...[
                        const Text(
                          'No diagnosis results available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4B5945),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => closeDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB2C9AD),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        closeDialog();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorsMapPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66785F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Show Doctors',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> performDiagnosis() async {
    if (imagePath == null) {
      showToast('Please Choose photo');
      return;
    }

    setState(() {
      showDialog = true;
      isProcessing = true;
    });

    try {
      print('Starting diagnosis...'); // Debug print
      final String baseUrl = '10.0.2.2';
      final Uri uri = Uri.parse('http://$baseUrl:5000/predict');

      final file = File(imagePath!);
      final bytes = await file.readAsBytes();
      final encodedImage = base64Encode(bytes);

      final response = await http
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'image': encodedImage,
          'filename': imagePath!.split('/').last,
        }),
      )
          .timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Raw response: $jsonResponse');

        // Store the entire response as a JSON string
        diagnosisResult = jsonEncode({
          'predicted_classes': jsonResponse['predicted_classes'],
          'confidence': jsonResponse['confidence']
        });

        print('Processed diagnosis result: $diagnosisResult');

        await _historyService.addHistory(
          disease: diagnosisResult!,
        );
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Error during diagnosis: $e');
      showToast('Error: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  List<Map<String, dynamic>> _parseDiagnosisResults(String text) {
    try {
      final Map<String, dynamic> results = jsonDecode(text);
      final List<dynamic> diseases = results['predicted_classes'];
      final List<dynamic> confidences = results['confidence'];

      List<Map<String, dynamic>> parsedResults = [];
      for (int i = 0; i < diseases.length; i++) {
        parsedResults.add({
          'disease': diseases[i].toString(),
          'confidence': double.parse(confidences[i].toString()),
        });
      }
      return parsedResults;
    } catch (e) {
      print('Error parsing diagnosis results: $e');
      return [];
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return const Color(0xFF66785F); // High confidence
    } else if (confidence >= 0.5) {
      return const Color(0xFFB2C9AD); // Medium confidence
    } else {
      return const Color(0xFF4B5945); // Low confidence
    }
  }
}
