import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:okter/color_utils.dart';
import 'package:okter/screens/calender_page.dart';
import 'package:okter/screens/friends_page.dart';
import 'package:okter/screens/home_page.dart';
import 'package:okter/screens/login_page.dart';
import 'package:okter/screens/personalBest_page.dart';
import 'package:okter/screens/settings_page.dart';
import 'package:okter/screens/programs_page.dart';

Widget okterDrawerScaffold(context, bodycontent) {
  return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: homePageDrawer(context),
      body: LayoutBuilder(
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
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(child: bodycontent)),
        );
      }));
}

Widget okterScaffold(name, context, bodycontent) {
  final currentWidth = MediaQuery.of(context).size.width;
  double paddingWidth = 6.0;
  if (currentWidth > 540) {
    paddingWidth = currentWidth / 5;
  }
  if (currentWidth > 700) {
    paddingWidth = currentWidth / 4;
  }
  return Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringtoColor("041416"),
        elevation: 0,
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          padding: EdgeInsets.only(left: paddingWidth, right: paddingWidth),
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringtoColor("041416"),
            hexStringtoColor("041416"),
            hexStringtoColor("020A0B")
            //hexStringtoColor("1d8a99") //hexStringtoColor("7c77b9")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(child: bodycontent)),
        );
      }));
}

Widget okterAddButtonScaffold(
    name, List<Widget> actions, context, bodycontent) {
  final currentWidth = MediaQuery.of(context).size.width;
  double paddingWidth = 6.0;
  if (currentWidth > 540) {
    paddingWidth = currentWidth / 5;
  }
  if (currentWidth > 700) {
    paddingWidth = currentWidth / 4;
  }
  return Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringtoColor("041416"),
        elevation: 0,
        actions: actions,
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          padding: EdgeInsets.only(left: paddingWidth, right: paddingWidth),
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringtoColor("041416"),
            hexStringtoColor("041416"),
            hexStringtoColor("020A0B")
            //hexStringtoColor("1d8a99") //hexStringtoColor("7c77b9")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(child: bodycontent)),
        );
      }));
}

Widget homePageDrawer(context) {
  var userId = FirebaseAuth.instance.currentUser!.uid.toString();
  var docRef = FirebaseFirestore.instance.collection("UserData").doc(userId);

  return Drawer(
    child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("UserData")
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
              colors: [
                hexStringtoColor("041416"),
                hexStringtoColor("041416"),
                hexStringtoColor("020A0B")
              ],
            )));
          }
          return SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                hexStringtoColor("041416"),
                hexStringtoColor("041416"),
                hexStringtoColor("020A0B")
                //hexStringtoColor("1d8a99") //hexStringtoColor("7c77b9")
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onLongPress: (() async {
                              ImagePicker imagePicker = ImagePicker();
                              XFile? image = await imagePicker.pickImage(
                                  source: ImageSource.gallery);

                              Reference storageReference = FirebaseStorage
                                  .instance
                                  .ref()
                                  .child('profileImages/$userId');

                              try {
                                storageReference.putFile(File(image!.path));
                                var url =
                                    await storageReference.getDownloadURL();
                                docRef.update({"profileImage": url});
                                print(url);
                              } catch (e) {
                                print(e);
                              }
                            }),
                            child: snapshot.data!.get("profileImage") != ""
                                ? CircleAvatar(
                                    radius: 40,
                                    foregroundImage: NetworkImage(
                                        snapshot.data!.get("profileImage")),
                                  )
                                : const CircleAvatar(
                                    backgroundColor:
                                        Color.fromARGB(255, 29, 138, 153),
                                    radius: 40,
                                    child: Icon(
                                      Icons.person,
                                      size: 70,
                                      color: Color.fromARGB(255, 11, 201, 205),
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: TextButton(
                              child: Text("@" + snapshot.data!["username"],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white)),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomePage()));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextButton(
                              child: Text(snapshot.data!["name"],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white)),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomePage()));
                              },
                            ),
                          ),
                        ]),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 14.0, right: 14.0, top: 16),
                    child: Divider(
                      color: Color(0xFF086c6a),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 14.0, right: 14.0, top: 16),
                      child: Stack(children: [
                        TextButton(
                          child: const Text("Venner",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const FriendsPage()));
                          },
                        ),
                        snapshot.data!.get("friendRequests").length != 0
                            ? Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 14,
                                    minHeight: 14,
                                  ),
                                  child: Text(
                                    snapshot.data!
                                        .get("friendRequests")
                                        .length
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : Container()
                      ])),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 14.0, right: 14.0, top: 16),
                      child: TextButton(
                        child: const Text("Rekorder",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.white)),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PersonalBestPage()));
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 14.0, right: 14.0, top: 16),
                      child: TextButton(
                        child: const Text("Kalender",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.white)),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CalenderPage()));
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 14.0, right: 14.0, top: 16),
                      child: TextButton(
                        child: const Text("Programmer",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.white)),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProgramsPage()));
                        },
                      )),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                            alignment: Alignment.bottomLeft,
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsPage()));
                            },
                            icon: const Icon(Icons.settings,
                                color: Colors.white)),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                            alignment: Alignment.bottomRight,
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SignInPage()));
                            },
                            icon: const Icon(Icons.exit_to_app_outlined,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
  );
}
