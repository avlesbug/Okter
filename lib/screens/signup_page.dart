import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:okter/screens/home_page.dart';
import 'package:okter/screens/login_page.dart';

import '../reusable_widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordReController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return okterScaffold(
      "",
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 160),
          inputField(nameController, false, "Name"),
          const SizedBox(height: 30),
          inputField(usernameController, false, "Username"),
          const SizedBox(height: 30),
          inputField(emailController, false, "Email"),
          const SizedBox(height: 30),
          inputField(passwordController, true, "Password"),
          const SizedBox(height: 30),
          inputField(passwordReController, true, "Repeat password"),
          const SizedBox(height: 20),
          signInSignUpButton(context, false, (() {
            signUp(
                context,
                nameController.text,
                emailController.text,
                passwordController.text,
                passwordReController.text,
                usernameController.text);
          })),
          signInRow(),
        ],
      ),
    );
  }

  Row signInRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(color: Colors.white),
        ),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Sign In",
              style: TextStyle(color: Colors.white),
            ))
      ],
    );
  }
}

Future<void> signUp(context, String name, String email, String password,
    String passwordRe, String username) async {
  if (password == passwordRe) {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
        writeFirestore(value.user!.uid, email, name, username);
        writeFirebaseDb(value.user!.uid);
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "ERROR_EMAIL_ALREADY_IN_USE":
        case "account-exists-with-different-credential":
        case "email-already-in-use":
          showToastMessage("Email address already in use.");
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
        case "operation-not-allowed":
          showToastMessage("Error occurred. Please try again later.");
          break;
        case "ERROR_INVALID_EMAIL":
        case "invalid-email":
          showToastMessage("Email address is invalid.");
          break;
        default:
          showToastMessage("Something went wrong.");
          break;
      }
    }
  } else {
    showToastMessage("Passwords do not match.");
  }
}

void writeFirebaseDb(String uid) {
  DatabaseReference ref = FirebaseDatabase.instance.ref("UserData").child(uid);
  ref.set(0);
}

DateTime getLastDayOfCurrentYear() {
  var now = DateTime.now();
  return DateTime(now.year, 12, 31);
}

void writeFirestore(String uid, String email, String name, String username) {
  FirebaseFirestore.instance.collection('UserData').doc(uid).set({
    'name': name,
    'username': username,
    'email': email,
    'lastWorkout': DateTime.now(),
    'goal': 0,
    'endDate': getLastDayOfCurrentYear(),
    'workouts': 0,
    'profileImage': "",
  });
}
