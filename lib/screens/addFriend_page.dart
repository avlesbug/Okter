import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';

import '../color_utils.dart';

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({super.key});

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  late CollectionReference users;
  late String userId;
  late DatabaseReference ref;
  String search = "";

  @override
  void initState() {
    //super.initState();
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    //userId = Provider.of(context).auth.getCurrentUID();
    ref = FirebaseDatabase.instance.ref("UserData");
  }

  @override
  Widget build(BuildContext context) {
    initState();
    return okterScaffold(
        "Add Friends",
        context,
        Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                hintText: "search...",
              ),
              cursorColor: Colors.white,
            ),
            const SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height - 100,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("UserData")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;

                      if (search.isEmpty) {
                        return Material(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              tileColor: hexStringtoColor("061E21"),
                              title:
                                  Text(snapshot.data!.docs[index].get("name")),
                              subtitle: Text(
                                  snapshot.data!.docs[index].get("username")),
                              leading: CircleAvatar(
                                backgroundColor:
                                    Color.fromARGB(255, 29, 138, 153),
                                radius: 30,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Color.fromARGB(255, 11, 201, 205),
                                ),
                              ),
                              onTap: () {
                                openAddFriendDialog();
                              },
                            ),
                          ),
                        );
                      }

                      if (data["name"]
                          .toString()
                          .toLowerCase()
                          .startsWith(search.toLowerCase())) {
                        return Material(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              tileColor: hexStringtoColor("061E21"),
                              title:
                                  Text(snapshot.data!.docs[index].get("name")),
                              subtitle: Text(
                                  snapshot.data!.docs[index].get("username")),
                              leading: CircleAvatar(
                                backgroundColor:
                                    Color.fromARGB(255, 29, 138, 153),
                                radius: 30,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Color.fromARGB(255, 11, 201, 205),
                                ),
                              ),
                              onTap: () {
                                openAddFriendDialog();
                              },
                            ),
                          ),
                        );
                      }
                      return Container();
                    },
                  );
                },
              ),
            )
          ],
        ));
  }

  void openAddFriendDialog() {
    showDialog(
        context: context,
        builder: (context) => Padding(
              padding: const EdgeInsets.fromLTRB(48.0, 60.0, 48.0, 450),
              child: Card(
                  color: hexStringtoColor("041416"),
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text("Test")),
            ));
  }

  void addFriends(String ovelse, String vekt) {
    FirebaseFirestore.instance
        .collection("UserData")
        .doc(userId)
        .update({"friendList": FieldValue.arrayUnion([])});
  }
}
