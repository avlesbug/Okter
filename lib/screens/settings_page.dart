import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:okter/basePage.dart';
import 'package:intl/intl.dart';
import 'package:okter/utils/color_pallet.dart';
import 'package:okter/screens/login_page.dart';

import '../utils/reusable_widgets.dart';

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
    var userId = FirebaseAuth.instance.currentUser!.uid.toString();
    var docRef = FirebaseFirestore.instance.collection("UserData").doc(userId);
    initState();
    getUserData();
    return okterScaffold(
        name: "Settings",
        context: context,
        bodycontent: StreamBuilder(
            stream: docRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  color: Color(0xFF030c10),
                  child: CircularProgressIndicator(),
                );
              }
              return Column(
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onLongPress: (() async {
                      ImagePicker imagePicker = ImagePicker();
                      XFile? image = await imagePicker.pickImage(
                          source: ImageSource.gallery);

                      Reference storageReference = FirebaseStorage.instance
                          .ref()
                          .child('profileImages/$userId');

                      try {
                        storageReference.putFile(File(image!.path));
                        var url = await storageReference.getDownloadURL();
                        docRef.update({"profileImage": url});
                        print(url);
                      } catch (e) {
                        print(e);
                      }
                    }),
                    child: snapshot.data!.get("profileImage") != ""
                        ? CircleAvatar(
                            radius: 60,
                            foregroundImage: NetworkImage(
                                snapshot.data!.get("profileImage")),
                          )
                        : CircleAvatar(
                            backgroundColor: themeColorPallet['green'],
                            radius: 60,
                            child: Icon(
                              Icons.person,
                              size: 70,
                              color: themeColorPallet['yellow'],
                            ),
                          ),
                  ),
                  const SizedBox(height: 80),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Name:",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onLongPress: () {
                            openDialog();
                          },
                          child: Text(
                            _name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ]),
                  const SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Username:",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onLongPress: () {
                            openDialog();
                          },
                          child: Text(
                            _username,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ]),
                  const SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Email:",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onLongPress: () {
                            openDialog();
                          },
                          child: Text(
                            _email,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ]),
                  const SizedBox(height: 80),
                  defaultButton(context, "Tilbakestil passord", () {
                    FirebaseAuth.instance
                        .sendPasswordResetEmail(email: _email)
                        .then(
                          (value) =>
                              showToastMessage("Password reset email sent"),
                        );
                  }),
                  const SizedBox(height: 40),
                  defaultButton(context, "Logg ut", () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInPage()));
                  }),
                ],
              );
            }));
  }

  void openDialog() {
    showToastMessage("Long pressed");
  }
}
