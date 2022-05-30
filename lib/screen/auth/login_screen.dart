import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:task_app/widgets/navigate.dart';
import 'sign_up_screen.dart';
import 'validaror_auth.dart';

import '../../widgets/CurvedClipper.dart';
import '../../widgets/color.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/toast.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordObscured = true;
  bool confirmPassObscured = true;
  final formKey = GlobalKey<FormState>();

  final loginEmailControl = TextEditingController();
  final loginPasswordControl = TextEditingController();

  Future<FirebaseApp> _initializeApp() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }
 @override
  void dispose() {
    super.dispose();
    loginEmailControl.dispose();
    loginPasswordControl.dispose();
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
                  const SizedBox(
                    height: 5.0,
                  ),
                  Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10, left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5.0),
                          CustomTextFormField(
                            controller: loginEmailControl,
                            backgroundColor: const Color(0xfff2f2f2),
                            roundedRectangleBorder: 10.0,
                            textInputAction: TextInputAction.next,
                            textHint: "Enter your Email",
                            validator: (value) =>
                                ValidarorsAuth.emailValidator(value!),
                            prefix: const Icon(
                              Icons.email,
                              color: mainColor,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          CustomTextFormField(
                            controller: loginPasswordControl,
                            backgroundColor: const Color(0xfff2f2f2),
                            roundedRectangleBorder: 10.0,
                            textInputAction: TextInputAction.next,
                            textHint: "Your password",
                            obscureText: passwordObscured,
                            validator: (value) =>
                                ValidarorsAuth.passwordValidator(value!),
                            prefix: const Icon(
                              Icons.lock,
                              color: mainColor,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  passwordObscured = !passwordObscured;
                                });
                              },
                              icon: Icon(passwordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      var email = loginEmailControl.text.trim();
                      var password = loginPasswordControl.text.trim();
                      if (email.isEmpty && password.isEmpty) {
                        showToast(
                            message: 'Please Enter Email and Password',
                            state: ToastStates.warning);
                      }
                      ProgressDialog progressDialog = ProgressDialog(
                        context,
                        title: const Text('Signing In'),
                        message: const Text('Please wait...'),
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
                          onNavigate(context, page: const HomeScreen());
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
                          color: mainColor,
                          border: Border.all(
                              color: mainColor, // Set border color
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
                          onNavigate(context, page: const SignUpScreen());
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ));
  }
}
