import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';
import 'splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DermaApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF66785F),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StreamBuilder<User?>(
              stream: _authService.authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF66785F)),
                      ),
                    ),
                  );
                }

                if (snapshot.hasData) {
                  return const HomeScreen();
                }

                return loginPage();
              },
            ),
        '/login': (context) => loginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => const HomeScreen(),
        '/splash': (context) => SplashScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => loginPage(),
        );
      },
    );
  }
}
