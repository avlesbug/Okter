import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:okter/utils/color_pallet.dart';
import 'package:okter/utils/color_utils.dart';

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
          borderSide: BorderSide(color: themeColorPallet['green']!),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: themeColorPallet['green']!),
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
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: themeColorPallet['green']!),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: themeColorPallet['green']!),
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
          borderSide: BorderSide(color: themeColorPallet['green']!),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: themeColorPallet['green']!),
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
            return themeColorPallet['green'];
          }
          return themeColorPallet['green'];
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

Widget loadingComponent() {
  return Center(
              child: SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colorPallet[5]),
                ),
              ),
            );
}

ElevatedButton defaultButton(BuildContext context, String text, Function onTap) {
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return themeColorPallet['green'];
        }
        return themeColorPallet['green'];
      }),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    ),
    onPressed: (() {
      onTap();
    }),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16,16,16,16),
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
        transitionDuration: const Duration(milliseconds: 00),
        reverseTransitionDuration: const Duration(milliseconds: 00)),
  );
}

