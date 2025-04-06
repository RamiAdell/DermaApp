import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomTextfiled extends StatelessWidget {
  CustomTextfiled({
    required this.text,
    required this.controller,
    required this.obscureText,
    this.onTap,
  });

  final String text;
  final bool obscureText;
  final controller;
  Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        
        validator: (data) {
          if (data!.isEmpty) {
            return 'Please enter Data';
          }
          return null;
        },
        obscureText: obscureText,
        controller: controller,
        style: TextStyle(color: const Color(0xFF4A3F35) , fontFamily: "Teachers",
            
            fontWeight: FontWeight.bold,),
        decoration: InputDecoration(
         
          enabledBorder:
              OutlineInputBorder(borderRadius : BorderRadius.circular(10),borderSide: BorderSide(color: const Color(0xFF4A3F35) , width: 1) ),
          hintStyle: TextStyle(color: const Color(0xFF4A3F35)),
          hintText: text,
          border: OutlineInputBorder(borderRadius : BorderRadius.circular(10),borderSide: BorderSide(color: const Color(0xFF4A3F35) , width: 3)),
        ),
      ),
    );
  }
}