import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:okter/color_utils.dart';
import 'package:okter/screens/friends_page.dart';
import 'package:okter/screens/groups_page.dart';
import 'package:okter/screens/home_page.dart';
import 'package:okter/screens/login_page.dart';
import 'package:okter/screens/personalBest_page.dart';
import 'package:okter/screens/settings_page.dart';

Widget okterDrawerScaffold(context, name, username, profileUrl, bodycontent) {
  return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: homePageDrawer(context, name, username, profileUrl),
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
          style: TextStyle(
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
    name, IconButton iconButton, context, bodycontent) {
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
        actions: [iconButton],
        title: Text(
          name,
          style: TextStyle(
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

Widget homePageDrawer(context, name, username, profileUrl) {
  var userId = FirebaseAuth.instance.currentUser!.uid.toString();
  var docRef = FirebaseFirestore.instance.collection("UserData").doc(userId);

  return Drawer(
    child: SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringtoColor("041416"),
          hexStringtoColor("041416"),
          hexStringtoColor("020A0B")
          //hexStringtoColor("1d8a99") //hexStringtoColor("7c77b9")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        padding: const EdgeInsets.only(top: 40),
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

                        Reference storageReference = FirebaseStorage.instance
                            .ref()
                            .child('profileImages/' + userId);

                        try {
                          storageReference.putFile(File(image!.path));
                          var url = await storageReference.getDownloadURL();
                          docRef.update({"profileImage": url});
                          print(url);
                        } catch (e) {
                          print(e);
                        }
                      }),
                      child: CircleAvatar(
                        foregroundImage: NetworkImage(profileUrl),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextButton(
                        child: Text("@" + username,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                                color: Colors.white)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton(
                        child: Text(name,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.white)),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()));
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
                padding: EdgeInsets.only(left: 14.0, right: 14.0, top: 16),
                child: TextButton(
                  child: Text("Venner",
                      style: const TextStyle(
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
                )),
            Padding(
                padding: EdgeInsets.only(left: 14.0, right: 14.0, top: 16),
                child: TextButton(
                  child: Text("Rekorder",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PersonalBestPage()));
                  },
                )),
            Padding(
                padding: EdgeInsets.only(left: 14.0, right: 14.0, top: 16),
                child: TextButton(
                  child: Text("Grupper",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GroupsPage()));
                  },
                )),
            Spacer(),
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
                                builder: (context) => const SettingsPage()));
                      },
                      icon: const Icon(Icons.settings, color: Colors.white)),
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
                                builder: (context) => const SignInPage()));
                      },
                      icon: const Icon(Icons.exit_to_app_outlined,
                          color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget firestoreFutureBuilder(param, style) {
  final users = FirebaseFirestore.instance.collection('UserData');
  final userId = FirebaseAuth.instance.currentUser!.uid.toString();
  return FutureBuilder<DocumentSnapshot>(
    future: users.doc(userId).get(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.hasError) {
        return Text("Something went wrong", style: style);
      }

      if (snapshot.hasData && !snapshot.data!.exists) {
        return Text("Document does not exist", style: style);
      }

      if (snapshot.connectionState == ConnectionState.done) {
        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
        return Text("${data[param]}", style: style);
      }

      return const Text("loading");
    },
  );
}

Future<String> getParamString(String param, TextStyle textStyle) async {
  String userId = FirebaseAuth.instance.currentUser!.uid.toString();
  var ref = FirebaseFirestore.instance.collection("UserData").doc(userId);
  return ref.get().then((value) => value.data()![param]);
}

class UserData {
  String name;
  String username;
  String email;
  UserData({required this.name, required this.username, required this.email});

  String getName() {
    return name;
  }

  String getUsername() {
    return username;
  }

  String getEmail() {
    return email;
  }

  void setName(String name) {
    this.name = name;
  }

  void setEmail(String email) {
    this.email = email;
  }

  void setUsername(String username) {
    this.username = username;
  }
}
