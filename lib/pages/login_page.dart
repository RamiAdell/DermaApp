import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../buttons/Elv_button.dart';
import '../helper/custom_textfiled.dart';
import '../helper/text_button.dart';
import 'package:lottie/lottie.dart';
import '../home.dart';
import '../splashScreen.dart';
import '../start.dart';
import '../helper/show_snack_bar.dart';

class loginPage extends StatefulWidget {
  loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  bool isLoading = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 179, 192, 177),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              SizedBox(
                height: 30,
              ),
              Lottie.asset(
                'assets/animations/Animation.json',
                height: 250, // Adjust the height as needed
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: "Teachers",
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    color: Color(0xFF4A3F35),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              CustomTextfiled(
                  obscureText: false,
                  controller: emailController,
                  text: 'Email'),
              SizedBox(
                height: 15,
              ),
              CustomTextfiled(
                  obscureText: true,
                  controller: passwordController,
                  text: 'Password'),
              SizedBox(
                height: 15,
              ),
              ElvButtons(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    isLoading = true;
                    setState(
                      () {},
                    );

                    try {
                      await login();
                      showSnackBar(context, 'Successful');
                      Navigator.pushReplacementNamed(context, '/home');
                      emailController.clear();
                      passwordController.clear();
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        showSnackBar(context, 'user not found');
                      } else if (e.code == 'wrong-password') {
                        showSnackBar(context, 'wrong password');
                      } else {
                        showSnackBar(context, 'Error: ${e.message}');
                      }
                    } catch (e) {
                      showSnackBar(context, 'Error: $e');
                    }
                    isLoading = false;
                    setState(
                      () {},
                    );
                  }
                },
                text: 'Login',
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Color(0xFF66785F),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        throw FirebaseAuthException(
          code: 'empty-fields',
          message: 'Please enter both email and password',
        );
      }

      print('Attempting to login with email: ${emailController.text}');
      final auth = FirebaseAuth.instance;
      print('Firebase Auth instance created');

      UserCredential user = await auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());

      print('Login successful for user: ${user.user?.email}');
      print('User ID: ${user.user?.uid}');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('General Error during login: $e');
      rethrow;
    }
  }
}
