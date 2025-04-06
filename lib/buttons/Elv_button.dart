import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ElvButtons extends StatelessWidget {
  final String text;
   Function() onPressed; // Added onPressed parameter

  ElvButtons({
    required this.text,
    
   required this.onPressed, // Added this line
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color(0xFF6E8B3D)),
        ),
        onPressed: onPressed, // Call onPressed when button is pressed
        child: Text(
          text,
          style: TextStyle(color: Colors.white , fontFamily: "Teachers" , fontSize: 18),
        ),
      ),
    );
  }
}
