import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:okter/utils/color_utils.dart';
import 'package:okter/utils/reusable_widgets.dart';
import 'package:okter/screens/homePage/home_page.dart';
import 'package:okter/screens/signup_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  var height = 844;
  var width = 390;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height.toInt();
    width = MediaQuery.of(context).size.width.toInt();
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
        : okterSignInScaffold(
            "",
            context,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.16),
                Icon(
                  Icons.sports_martial_arts,
                  color: hexStringtoColor("1d8a99"),
                  size: 100,
                ),
                SizedBox(height: height * 0.05),
                inputField(emailController, false, "Email"),
                SizedBox(height: height * 0.04),
                inputField(passwordController, true, "Password"),
                SizedBox(height: height * 0.05),
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

    Route _createRouteSignUp() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const SignUpPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
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
              Navigator.of(context).push(_createRouteSignUp());
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
