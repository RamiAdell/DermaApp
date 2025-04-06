import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

// Function to get the local IP address
String getLocalIP() {
  // Replace this with your computer's local IP address
  // You can find it by running 'ipconfig' on Windows or 'ifconfig' on Mac/Linux
  return '192.168.1.100'; // Change this to your actual local IP
}

// Function to get the server URL
String getUploadURL() {
  if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
    // Use 10.0.2.2 for Android emulator to access host machine's localhost
    return 'http://10.0.2.2:5000/predict';
  } else {
    // Use localhost for web and other platforms
    return 'http://127.0.0.1:5000/predict';
  }
}

// Custom gradient for the app background
BoxDecoration boxDecoration() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF4B5945), // Soft earthy green
        Color(0xFF66785F), // Muted olive green
        Color(0xFF91AC8F), // Soft minty green
        Color(0xFFB2C9AD), // Light minty green
      ],
    ),
  );
}

// Text style for headers
TextStyle TextStylehead() {
  return const TextStyle(
    color: Color(0xFF4B5945), // Darker green shade for emphasis
    fontSize: 24,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w800,
  );
}

// Text style for subheaders
TextStyle TextStylesubhead() {
  return const TextStyle(
    color: Color(0xFF66785F), // Mid-tone green for subtler emphasis
    fontSize: 20,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
  );
}
