import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okter/color_utils.dart';
import 'package:okter/screens/login_page.dart';

Widget okterScaffold(context, name, username, bodycontent) {
  return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: homePageDrawer(context, name, username),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringtoColor("0F464D"),
            hexStringtoColor("0A3237")
            //hexStringtoColor("1d8a99") //hexStringtoColor("7c77b9")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(child: bodycontent)),
        );
      }));
}

Widget okterSignInUpScaffold(context, bodycontent) {
  return Scaffold(body: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
    return Container(
      height: constraints.maxHeight,
      width: constraints.maxWidth,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        hexStringtoColor("0F464D"),
        hexStringtoColor("0A3237")
        //hexStringtoColor("1d8a99") //hexStringtoColor("7c77b9")
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(child: bodycontent)),
    );
  }));
}

Widget homePageDrawer(context, name, username) {
  return Drawer(
    child: SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringtoColor("0A3237"),
          hexStringtoColor("0A3237"),
          hexStringtoColor("0F464D")
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
                    const CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 29, 138, 153),
                      radius: 30,
                      child: Icon(
                        Icons.person,
                        size: 54,
                        color: Color.fromARGB(255, 11, 201, 205),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text("@" + username,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w300)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.normal)),
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
            Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                    alignment: Alignment.bottomLeft,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.settings)),
                const Spacer(),
                IconButton(
                    alignment: Alignment.bottomRight,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInPage()));
                    },
                    icon: const Icon(Icons.exit_to_app_outlined)),
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
