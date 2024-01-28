import 'package:flutter/material.dart';
import 'package:okter/screens/login_page.dart';

class Provider extends InheritedWidget {
  final AuthService auth;
  const Provider({super.key, 
    required Widget child,
    required this.auth,
  }) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWiddget) {
    return true;
  }

  static Provider? of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<Provider>());
}
