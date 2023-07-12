import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:okter/color_utils.dart';

TextField inputField(
    TextEditingController inputController, bool isPassword, String labelText) {
  return TextField(
      cursorColor: Colors.white,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      obscureText: isPassword,
      controller: inputController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: hexStringtoColor("08282D")),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: hexStringtoColor("092E33")),
        ),
      ));
}

TextField largerInputField(
    TextEditingController inputController, String labelText) {
  return TextField(
      cursorColor: Colors.white,
      autofocus: true,
      style: const TextStyle(color: Colors.white, fontSize: 20),
      controller: inputController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: hexStringtoColor("08282D")),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: hexStringtoColor("092E33")),
        ),
      ));
}

TextField numInputField(
    TextEditingController inputController, String labelText) {
  return TextField(
      cursorColor: Colors.white,
      keyboardType: TextInputType.number,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      controller: inputController,
      textInputAction: TextInputAction.next,
      inputFormatters: <TextInputFormatter>[
        // for below version 2 use this
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
// for version 2 and greater youcan also use this
        FilteringTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: hexStringtoColor("08282D")),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: hexStringtoColor("092E33")),
        ),
      ));
}

Container signInSignUpButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    child: ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return hexStringtoColor("1d8a99");
          }
          return hexStringtoColor("1d8a99");
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
      ),
      onPressed: (() {
        onTap();
      }),
      child: Text(
        isLogin ? "Sign In" : "Sign Up",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    ),
  );
}

Container defaultButton(BuildContext context, String text, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width / 2,
    height: 50,
    child: ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return hexStringtoColor("0A2E33");
          }
          return hexStringtoColor("0A2E33");
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
      ),
      onPressed: (() {
        onTap();
      }),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    ),
  );
}

void showToastMessage(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

void updataPage(context, page) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return page;
        },
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return Align(
            child: SizeTransition(
              sizeFactor: animation,
              child: child,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 00),
        reverseTransitionDuration: Duration(milliseconds: 00)),
  );
}
