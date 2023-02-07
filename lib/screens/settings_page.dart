import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:intl/intl.dart';
import 'package:okter/color_utils.dart';
import 'package:okter/screens/addFriend_page.dart';
import 'package:okter/screens/password_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../reusable_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  late CollectionReference users;
  late String userId;
  late DatabaseReference ref;

  var _name = "Name";
  var _username = "UserName";
  var _email = "Email";

  @override
  void initState() {
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    ref = FirebaseDatabase.instance.ref("UserData");
  }

  Future<void> getUserData() async {
    final docRef =
        FirebaseFirestore.instance.collection("UserData").doc(userId);
    try {
      docRef.get().then((DocumentSnapshot doc) {
        if (!mounted) return;
        setState(() {
          _name = doc.get("name");
          _username = doc.get("username");
          _email = doc.get("email");
        });
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    initState();
    getUserData();
    return okterScaffold(
        "Settings",
        context,
        Column(
          children: [
            const SizedBox(height: 20),
            Row(
                children: [
                  Text(
                    "Name:",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onLongPress: () {
                      openDialog();
                    },
                    child: Text(
                      _name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center),
            const SizedBox(height: 20),
            Row(
                children: [
                  Text(
                    "Username:",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onLongPress: () {
                      openDialog();
                    },
                    child: Text(
                      _username,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center),
            const SizedBox(height: 20),
            Row(
                children: [
                  Text(
                    "Email:",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onLongPress: () {
                      openDialog();
                    },
                    child: Text(
                      _email,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center),
            const SizedBox(height: 20),
            defaultButton(context, "Reset password", () {
              FirebaseAuth.instance.sendPasswordResetEmail(email: _email).then(
                    (value) => showToastMessage("Password reset email sent"),
                  );
            }),
          ],
        ));
  }

  void openDialog() {
    showToastMessage("Long pressed");
  }
}
