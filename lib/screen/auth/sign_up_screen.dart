import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
import 'validaror_auth.dart';

import '../../widgets/CurvedClipper.dart';
import '../../widgets/color.dart';
import '../../widgets/custom_text_form_field.dart';
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
  final formKey = GlobalKey<FormState>();
  final registerNameControl = TextEditingController();
  final registerEmailControl = TextEditingController();
  final registerPasswordControl = TextEditingController();
  final registerConfirmPasswordControl = TextEditingController();
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
                        controller: registerNameControl,
                        textInputAction: TextInputAction.next,
                        textHint: 'Enter your Name',
                        roundedRectangleBorder: 10.0,
                        backgroundColor: const Color(0xfff2f2f2),
                        prefix: const Icon(
                          Icons.account_circle_outlined,
                          color: mainColor,
                        ),
                        validator: (value) =>
                            (value!.isEmpty) ? 'Please Enter Your Name' : null,
                      ),
                      const SizedBox(height: 5.0),
                      CustomTextFormField(
                        controller: registerEmailControl,
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
                        controller: registerPasswordControl,
                        backgroundColor: const Color(0xfff2f2f2),
                        roundedRectangleBorder: 10.0,
                        textInputAction: TextInputAction.next,
                        textHint: "Enter Your password",
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
                      CustomTextFormField(
                        controller: registerConfirmPasswordControl,
                        backgroundColor: const Color(0xfff2f2f2),
                        roundedRectangleBorder: 10.0,
                        textHint: ' Rewrite password',
                        obscureText: confirmPassObscured,
                        prefix: const Icon(
                          Icons.lock,
                          color: mainColor,
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
                        validator: (value) => value!.isEmpty
                            ? 'please confirm password'
                            : (value != registerPasswordControl.text)
                                ? 'Password does not match'
                                : null,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  var fullName = registerNameControl.text.trim();
                  var email = registerEmailControl.text.trim();
                  var password = registerPasswordControl.text.trim();
                  if (email.isEmpty && password.isEmpty || fullName.isEmpty) {
                    showToast(
                        message: 'Please Fill All Requriements',
                        state: ToastStates.warning);
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
                        'd': DateTime.now().millisecondsSinceEpoch,
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
                      color: mainColor,
                      border: Border.all(
                          color: mainColor, // Set border color
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
