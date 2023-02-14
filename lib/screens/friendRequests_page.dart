import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:intl/intl.dart';
import 'package:okter/color_utils.dart';
import 'package:okter/screens/addFriend_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../reusable_widgets.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  late CollectionReference users;
  late String userId;
  late DatabaseReference ref;
  double height = 700;
  double width = 300;

  var _name = "Name";
  var _username = "UserName";
  var _friendRequests = [];
  var _requestsMap = [];
  var _counter = 0;

  String _frindname = "Friend Name";

  @override
  void initState() {
    //super.initState();
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    //userId = Provider.of(context).auth.getCurrentUID();
    ref = FirebaseDatabase.instance.ref("UserData");
  }

  Future<void> getUserData() async {
    final docRef =
        FirebaseFirestore.instance.collection("UserData").doc(userId);
    try {
      docRef.get().then((DocumentSnapshot doc) {
        if (!mounted) return;
        setState(() {
          _friendRequests = doc["friendRequests"];
        });
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> getFriendMap() async {
    for (var reference in _friendRequests) {
      var snapshot = reference.get();
      snapshot.then((DocumentSnapshot docuSnap) {
        if (docuSnap.exists) {
          Map<String, dynamic> data = docuSnap.data() as Map<String, dynamic>;
          bool added = false;
          for (var friend in _requestsMap) {
            if (friend["email"] == data["email"]) {
              added = true;
            }
          }
          if (!mounted) return;
          setState(() {
            if (!added) {
              _requestsMap.add(data);
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    print("h: " + height.toString() + " w: " + width.toString());
    initState();
    getUserData();
    getFriendMap();
    return okterAddButtonScaffold(
        "Friend Requests",
        [],
        context,
        Column(
          children: [
            const SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height - 100,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("UserData")
                      .doc(userId)
                      .collection("friendRequests")
                      .snapshots(),
                  builder: (context, snapshot) {
                    return ListView.builder(
                      itemCount: _requestsMap.length,
                      itemBuilder: (context, index) {
                        if (_requestsMap[index]["profileImage"] != "") {
                          return Material(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  title: Text(_requestsMap[index]["name"]),
                                  subtitle: Text(_requestsMap[index]["workouts"]
                                          .toString() +
                                      " / " +
                                      _requestsMap[index]["goal"].toString()),
                                  tileColor: hexStringtoColor("061E21"),
                                  leading: CircleAvatar(
                                    radius: 30,
                                    foregroundImage: NetworkImage(
                                        _requestsMap[index]["profileImage"]),
                                  ),
                                  trailing: trailing(index)),
                            ),
                          );
                        } else {
                          return Material(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  title: Text(_requestsMap[index]["name"]),
                                  subtitle: Text(
                                      _requestsMap[index]["email"].toString()),
                                  tileColor: hexStringtoColor("061E21"),
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
                                  trailing: trailing(index)),
                            ),
                          );
                        }
                      },
                    );
                  }),
            ),
          ],
        ));
  }

  void answerRequest(DocumentReference<Object?> userRef, bool accepted) {
    print(userRef.id);
    if (accepted) {
      users.doc(userId).update({
        "friendList": FieldValue.arrayUnion([userRef])
      });
      users.doc(userRef.id).update({
        "friendList": FieldValue.arrayUnion([users.doc(userId)])
      });
      users.doc(userId).update({
        "friendRequests": FieldValue.arrayRemove([userRef])
      });
    } else {
      users.doc(userId).update({
        "friendRequests": FieldValue.arrayRemove([userRef])
      });
    }
  }

  Widget trailing(index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            answerRequest(_friendRequests[index], true);
            updataPage(context, super.widget);
          },
          icon: Icon(
            Icons.check,
            size: 26,
            color: Color.fromARGB(255, 11, 201, 205),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        IconButton(
          onPressed: () {
            answerRequest(_friendRequests[index], false);
            updataPage(context, super.widget);
          },
          icon: Icon(
            Icons.clear,
            size: 26,
            color: Color.fromARGB(255, 11, 201, 205),
          ),
        ),
      ],
    );
  }
}
