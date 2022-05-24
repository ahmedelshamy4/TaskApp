import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';

import '../../widgets/CurvedClipper.dart';
import '../../widgets/toast.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool passwordObscured = true;
  bool confirmPassObscured = true;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final retypePasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                ),
                child: TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    hintText: 'FullName',
                    prefixIcon: Icon(
                      Icons.account_box_outlined,
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
                  vertical: 20,
                ),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(
                      Icons.email,
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
                      icon: Icon(
                        passwordObscured
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordObscured = !passwordObscured;
                        });
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: TextField(
                  controller: retypePasswordController,
                  obscureText: confirmPassObscured,
                  decoration: InputDecoration(
                    hintText: 'Retype Password',
                    prefixIcon: const Icon(
                      Icons.lock,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          confirmPassObscured = !confirmPassObscured;
                        });
                      },
                      icon: Icon(confirmPassObscured
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
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
                  var formValid = true;

                  var fullName = fullNameController.text;
                  var email = emailController.text;
                  var password = passwordController.text;
                  var retypePassword = retypePasswordController.text;

                  if (fullName.isEmpty) {
                    showToast(
                        message: 'Please provide FullName',
                        state: ToastStates.warning);

                    formValid = false;
                  }

                  if (email.isEmpty) {
                    showToast(
                        message: 'Please provide email',
                        state: ToastStates.warning);
                    formValid = false;
                  }

                  if (password.isEmpty) {
                    showToast(
                        message: 'Please provide Password',
                        state: ToastStates.warning);
                    formValid = false;
                  }

                  if (retypePassword.isEmpty) {
                    showToast(
                        message: 'Please provide Retype Password',
                        state: ToastStates.warning);
                    formValid = false;
                  }

                  if (password.length < 6) {
                    showToast(
                        message: 'Please provide at least 6 digits',
                        state: ToastStates.warning);
                    formValid = false;
                  }

                  if (password != retypePassword) {
                    showToast(
                        message: 'Passwords do not match',
                        state: ToastStates.warning);

                    formValid = false;
                  }

                  if (formValid == false) {
                    return;
                  }

                  ProgressDialog progressDialog = ProgressDialog(
                    context,
                    message: const Text("Signing Up"),
                    title: const Text("Please wait..."),
                  );

                  progressDialog.show();

                  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

                  try {
                    UserCredential userCredential =
                        await firebaseAuth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    User? user = userCredential.user;

                    if (user != null) {
                      // save record in realtime database
                      final databaseReference =
                          FirebaseDatabase.instance.reference();

                      await databaseReference
                          .child('users')
                          .child(user.uid)
                          .set({
                        'uid': user.uid,
                        'name': fullName,
                        'email': email,
                        'dt': DateTime.now().millisecondsSinceEpoch,
                        'profileImage': '',
                      });
                      showToast(
                          message: 'Sign Up Successful',
                          state: ToastStates.success);

                      progressDialog.dismiss();
                    }
                  } on FirebaseAuthException catch (e) {
                    progressDialog.dismiss();
                    if (e.code == 'weak-password') {
                      showToast(
                          message: 'Weak Password', state: ToastStates.error);
                    } else if (e.code == 'email-already-in-use') {
                      showToast(
                          message: 'Email Already in Use',
                          state: ToastStates.error);
                    }
                  } catch (e) {
                    showToast(
                        message: 'Something went wrong',
                        state: ToastStates.error);

                    progressDialog.dismiss();
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
                      borderRadius: const BorderRadius.all(
                          Radius.circular(10.0)), // Set rounded corner radius
                      boxShadow: const [
                        BoxShadow(
                            blurRadius: 10,
                            color: Colors.black,
                            offset: Offset(1, 3))
                      ] // Make rounded corner of border
                      ),
                  child: const Text(
                    'SIGN UP',
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
                        return const LoginScreen();
                      }));
                    },
                    child: Container(
                      height: 100,
                      alignment: Alignment.center,
                      color: Theme.of(context).primaryColor,
                      child: const Text(
                        'Already have an account? Login Here',
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
      ),
    );
  }
}
