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

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  late CollectionReference users;
  late String userId;
  late DatabaseReference ref;

  var _name = "Name";
  var _username = "UserName";
  var _friends = [];
  var _friendMap = [];

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
          _friends = doc["friendList"];
        });
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> getFriendMap() async {
    for (var reference in _friends) {
      var snapshot = reference.get();
      snapshot.then((DocumentSnapshot docuSnap) {
        if (docuSnap.exists) {
          Map<String, dynamic> data = docuSnap.data() as Map<String, dynamic>;
          bool added = false;
          for (var friend in _friendMap) {
            if (friend["email"] == data["email"]) {
              added = true;
            }
          }
          if (!mounted) return;
          setState(() {
            if (!added) {
              _friendMap.add(data);
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initState();
    getUserData();
    getFriendMap();
    return okterAddButtonScaffold(
        "Friends",
        IconButton(
            onPressed: (() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddFriendsPage()));
            }),
            icon: const Icon(Icons.add)),
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
                      .collection("friendList")
                      .snapshots(),
                  builder: (context, snapshot) {
                    return ListView.builder(
                      itemCount: _friendMap.length,
                      itemBuilder: (context, index) {
                        if (_friendMap[index]["profileImage"] != "") {
                          return Material(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                title: Text(_friendMap[index]["name"]),
                                subtitle: Text(
                                    _friendMap[index]["workouts"].toString() +
                                        " / " +
                                        _friendMap[index]["goal"].toString()),
                                tileColor: hexStringtoColor("061E21"),
                                leading: CircleAvatar(
                                  foregroundImage: NetworkImage(
                                      _friendMap[index]["profileImage"]),
                                ),
                                onTap: () {
                                  openFriendDialog();
                                },
                              ),
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
                                title: Text(_friendMap[index]["name"]),
                                subtitle: Text(
                                    _friendMap[index]["workouts"].toString() +
                                        " / " +
                                        _friendMap[index]["goal"].toString()),
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
                                onTap: () {
                                  openFriendDialog();
                                },
                              ),
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

  /*
  snapshot.data!
  .get("friends")[index]["name"]
  */

  SfCircularChart _buildElevationDoughnutChart(okter, goal) {
    return SfCircularChart(
      /// It used to set the annotation on circular chart.
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
            height: '100%',
            width: '100%',
            widget: PhysicalModel(
              shape: BoxShape.circle,
              elevation: 10,
              color: const Color.fromRGBO(225, 225, 225, 1),
              child: Container(),
            )),
        CircularChartAnnotation(
            widget: Text(((okter / goal) * 100).toStringAsFixed(1) + "%",
                style: const TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.5), fontSize: 25))),
      ],
    );
  }

  void friendDialog(param0, param1) {}

  getProgressFromDocRef(DocumentReference docRef) async {
    var _goal = 0;
    var progress = 0;
    try {
      docRef.get().then((DocumentSnapshot doc) {
        if (!mounted) return;
        setState(() {
          _goal = doc.get("goal");
        });
      });
    } on FirebaseException catch (e) {
      print(e);
    }

    return _goal.toString();
  }

  Future<List> getData(myArray) async {
    var myData = [];
    for (var reference in myArray) {
      var snapshot = await reference.get();
      myData.add(snapshot.data);
    }
    return myData;
    // Use myData to build your UI
  }

  void openFriendDialog() {
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

  void deleteFriend(index) {
    FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      "friendList": FieldValue.arrayRemove([_friends[index]])
    });
  }
}
