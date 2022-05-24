import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:task_app/screen/auth/sign_up_screen.dart';

import '../../widgets/CurvedClipper.dart';
import '../../widgets/toast.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordObscured = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<FirebaseApp> _initializeApp() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  ClipPath(
                    clipper: CurvedClipper(),
                    child: Image(
                      image: const AssetImage('assets/images/books.jpeg'),
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Note App',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(
                          Icons.account_box,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: passwordObscured,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              passwordObscured = !passwordObscured;
                            });
                          },
                          icon: Icon(
                            passwordObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15.0),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      var email = emailController.text;
                      var password = passwordController.text;
                      var formValid = true;
                      if (email.isEmpty) {
                        showToast(
                            message: 'Please provide email',
                            state: ToastStates.warning);
                        formValid = false;
                      }

                      if (password.isEmpty) {
                        showToast(
                            message: 'Please provide email',
                            state: ToastStates.warning);
                        formValid = false;
                      }

                      if (formValid == false) {
                        return;
                      }

                      ProgressDialog progressDialog = ProgressDialog(
                        context,
                        title: const Text('Signing In'),
                        message: const Text('Please wait'),
                      );

                      progressDialog.show();

                      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                      try {
                        UserCredential userCredential =
                            await firebaseAuth.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        progressDialog.dismiss();
                        User? user = userCredential.user;

                        if (user != null) {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const HomeScreen();
                          }));
                        }
                      } on FirebaseAuthException catch (e) {
                        progressDialog.dismiss();
                        if (e.code == 'user-not-found') {
                          showToast(
                              message: 'User not found',
                              state: ToastStates.error);
                        } else if (e.code == 'wrong-password') {
                          showToast(
                              message: 'Wrong password',
                              state: ToastStates.error);
                        }
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      margin: const EdgeInsets.symmetric(horizontal: 50.0),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                              color: Colors.blue, // Set border color
                              width: 3.0), // Set border width
                          borderRadius: const BorderRadius.all(Radius.circular(
                              10.0)), // Set rounded corner radius
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black,
                              offset: Offset(1, 3),
                            )
                          ] // Make rounded corner of border
                          ),
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const SignUpScreen();
                          }));
                        },
                        child: Container(
                          height: 100,
                          alignment: Alignment.center,
                          color: Theme.of(context).primaryColor,
                          child: const Text(
                            'Don\'t have account, Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ));
  }
}
