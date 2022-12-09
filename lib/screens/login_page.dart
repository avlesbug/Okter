import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:okter/color_utils.dart';
import 'package:okter/reusable_widgets.dart';
import 'package:okter/screens/home_page.dart';
import 'package:okter/screens/signup_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool signedIn = false;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        signedIn = true;
        print('User is signed in!');
      }
    });
    return signedIn
        ? const HomePage()
        : okterScaffold(
            context,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 200),
                Icon(
                  Icons.sports_martial_arts,
                  color: hexStringtoColor("1d8a99"),
                  size: 100,
                ),
                const SizedBox(height: 40),
                inputField(emailController, false, "Email"),
                const SizedBox(height: 40),
                inputField(passwordController, true, "Password"),
                const SizedBox(height: 20),
                signInSignUpButton(context, true, (() async {
                  try {
                    await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text)
                        .then(
                          (value) => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage())),
                        );
                  } on FirebaseAuthException catch (e) {
                    switch (e.code) {
                      case "ERROR_WRONG_PASSWORD":
                      case "wrong-password":
                        showToastMessage("Wrong password");
                        break;
                      case "ERROR_USER_NOT_FOUND":
                      case "user-not-found":
                        showToastMessage("No user found with this email.");
                        break;
                      case "ERROR_USER_DISABLED":
                      case "user-disabled":
                        showToastMessage("User disabled.");
                        break;
                      case "ERROR_TOO_MANY_REQUESTS":
                        showToastMessage("Too many requests. Try again later.");
                        break;
                      case "ERROR_OPERATION_NOT_ALLOWED":
                      case "operation-not-allowed":
                        showToastMessage(
                            "Server error, please try again later.");
                        break;
                      case "ERROR_INVALID_EMAIL":
                      case "invalid-email":
                        showToastMessage("Invalid email address.");
                        break;
                      default:
                        showToastMessage("Login failed. Please try again.");
                        break;
                    }
                  }
                })),
                signUpRow(),
              ],
            ),
          );
  }

  Row signUpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.white),
        ),
        TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()));
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(color: Colors.white),
            ))
      ],
    );
  }
}

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get onAuthStateChanged => _firebaseAuth.authStateChanges();

  // GET UID
  Future<String> getCurrentUID() async {
    return _firebaseAuth.currentUser!.uid;
  }
}
