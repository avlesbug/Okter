import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:okter/utils/color_pallet.dart';
import 'package:okter/utils/reusable_widgets.dart';

import '../utils/color_utils.dart';

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
        name: "Add Friends",
        context: context,
        bodycontent: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              decoration: const InputDecoration(
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
            SizedBox(
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
                      var data = snapshot.data!.docs[index].data();

                      if (search.isEmpty) {
                        return Material(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              tileColor: themeColorPallet['grey light'],
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
                                          themeColorPallet['green'],
                                      radius: 30,
                                      child: Icon(
                                        Icons.person,
                                        size: 30,
                                        color: themeColorPallet['yellow'],
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
                              tileColor: themeColorPallet['grey light'],
                              title:
                                  Text(snapshot.data!.docs[index].get("name")),
                              subtitle: Text(
                                  snapshot.data!.docs[index].get("username")),
                              leading: CircleAvatar(
                                backgroundColor: themeColorPallet['green'],
                                radius: 30,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: themeColorPallet['yellow'],
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
            width * 0.2, height * 0.30, width * 0.2, height * 0.50),
        child: Container(
            color: themeColorPallet['grey dark'],
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 50.0, 32.0, 50.0),
              child: TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        themeColorPallet['green']!)),
                onPressed: () {
                  sendFriendRequest(userRef);
                  Navigator.pop(context);
                  showToastMessage("Friend Request Sent");
                },
                child: const Text("Send Friend Request",
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
