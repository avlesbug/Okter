import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:okter/auth_provider.dart';
import 'package:okter/color_utils.dart';
import 'package:okter/screens/home_page.dart';
import 'package:okter/screens/login_page.dart';
import 'package:okter/theme_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: AuthService(),
      child: MaterialApp(
        title: 'Økter',
        themeMode: ThemeMode.dark,
        theme: MyTheme.lightTheme,
        darkTheme: MyTheme.darkTheme,
        home: const HomeController(),
      ),
    );
  }
}

class HomeController extends StatelessWidget {
  const HomeController({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context)!.auth;

    return StreamBuilder<User?>(
      stream: auth.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool signedIn = snapshot.hasData;
          return signedIn ? const HomePage() : const SignInPage();
        }
        return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              hexStringtoColor("041416"),
              hexStringtoColor("041416"),
              hexStringtoColor("020A0B")
              //hexStringtoColor("1d8a99") //hexStringtoColor("7c77b9")
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Icon(
                    Icons.sports_martial_arts,
                    color: Color.fromARGB(255, 29, 138, 153),
                    size: 100,
                  ),
                ),
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(hexStringtoColor("1d8a99")),
                )
              ],
            ),
          );
        });
      },
    );
  }
}
