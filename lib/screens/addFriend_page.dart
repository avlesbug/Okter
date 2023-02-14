import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:okter/reusable_widgets.dart';

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
  double height = 700;
  double width = 300;

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
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
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
                              leading: snapshot.data!.docs[index]
                                          .get("profileImage") !=
                                      ""
                                  ? CircleAvatar(
                                      radius: 30,
                                      foregroundImage: NetworkImage(
                                          snapshot.data!.docs[index]
                                              .get("profileImage"),
                                          scale: 0.5),
                                    )
                                  : CircleAvatar(
                                      backgroundColor:
                                          Color.fromARGB(255, 29, 138, 153),
                                      radius: 30,
                                      child: Icon(
                                        Icons.person,
                                        size: 30,
                                        color:
                                            Color.fromARGB(255, 11, 201, 205),
                                      )),
                              onTap: () {
                                openAddFriendDialog(
                                    snapshot.data!.docs[index].reference);
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
                                openAddFriendDialog(
                                    snapshot.data!.docs[index].reference);
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

  void openAddFriendDialog(DocumentReference userRef) {
    showDialog(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            width * 0.1, height * 0.23, width * 0.1, height * 0.6),
        child: Container(
            color: hexStringtoColor("041416"),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 38.0, 32.0, 38.0),
              child: TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        hexStringtoColor("061E21"))),
                onPressed: () {
                  sendFriendRequest(userRef);
                  Navigator.pop(context);
                  showToastMessage("Friend Request Sent");
                },
                child: Text("Send Friend Request",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )),
      ),
    );
  }

  void addFriends(DocumentReference userRef) {
    FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      "friendList": FieldValue.arrayUnion([userRef])
    });
  }

  void sendFriendRequest(DocumentReference userRef) {
    userRef.update({
      "friendRequests": FieldValue.arrayUnion(
          [FirebaseFirestore.instance.collection("UserData").doc(userId)])
    });
  }
}
