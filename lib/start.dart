import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'public/public_constant.dart';
import 'widgets/defoult_button.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        decoration: boxDecoration(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Add the Lottie animation here
              Lottie.asset(
                'assets/animations/Animation.json',
                height: 400, // Adjust the height as needed
              ),
              const SizedBox(height:
              0),
              const Text(
                'Welcome to DermaApp',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
              const SizedBox(height: 50),
                                    DefaultButton(
                        buttonWidget: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [

                            SizedBox(width: 5),
                            Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        function: () {
                          Navigator.of(context).pushReplacementNamed('/start');
                        },
                        width: MediaQuery.of(context).size.width / 3,
                        radius: 15.0,
                        backgroundColor: const Color(0xFF66785F),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
