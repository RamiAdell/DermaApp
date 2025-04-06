import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../buttons/Elv_button.dart';
import '../helper/custom_textfiled.dart';
import '../helper/show_snack_bar.dart';
import '../helper/text_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _conPasswordController = TextEditingController();

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
                height: 110,
              ),
              Center(
                child: Text(
                  'Signup',
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
                controller: _nameController,
                text: 'Name',
              ),
              SizedBox(
                height: 15,
              ),
              CustomTextfiled(
                  obscureText: false,
                  controller: _emailController,
                  text: 'Email'),
              SizedBox(
                height: 15,
              ),
              CustomTextfiled(
                  obscureText: true,
                  controller: _passwordController,
                  text: 'Password'),
              SizedBox(
                height: 15,
              ),
              CustomTextfiled(
                  obscureText: true,
                  controller: _conPasswordController,
                  text: 'Confirm password'),
              SizedBox(
                height: 15,
              ),
              ElvButtons(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    isLoading = true;
                    setState(() {});

                    try {
                      await register();
                      showSnackBar(context, 'Successfull');
                      Navigator.of(context).pushReplacementNamed('/home');
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        showSnackBar(context, 'weak password');
                      } else if (e.code == 'email-already-in-use') {
                        showSnackBar(context, 'email already exists');
                      }
                    } catch (e) {
                      showSnackBar(context, 'There was an error');
                    }
                    isLoading = false;
                    setState(() {});
                  }
                },
                text: 'Signup',
              ),
              SizedBox(
                height: 5,
              ),
              Text_Button(
                text1: 'Already have an account?',
                text2: ' Login',
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> register() async {
    UserCredential user =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Only proceed with adding user details if user creation was successful
    if (user.user != null) {
      await addUserDetails(
        _nameController.text.trim(),
        _emailController.text.trim(),
        user.user!.uid,
      );
    }
  }

  Future<void> addUserDetails(String name, String email, String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'displayName': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
