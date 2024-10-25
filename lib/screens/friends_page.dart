import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:intl/intl.dart';
import 'package:okter/utils/color_utils.dart';
import 'package:okter/utils/reusable_widgets.dart';
import 'package:okter/screens/addFriend_page.dart';
import 'package:okter/screens/friendRequests_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../utils/color_pallet.dart';

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
  double height = 700;
  double width = 300;

  final _name = "Name";
  final _username = "UserName";
  var _friends = [];
  final _friendMap = [];
  var _counter = 0;
  var _isLoaded = false;

  final String _frindname = "Friend Name";

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
          _counter = doc["friendRequests"].length;
          _isLoaded = true;
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
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    initState();
    getUserData();
    getFriendMap();
    return okterAddButtonScaffold(
        name: "Friends",
        bottomNavigation: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.expand_more),
              label: 'Tilbake',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Legg til',
            ),
          ],
          currentIndex: 0,
          backgroundColor: themeColorPallet['grey dark'],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).pop();
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddFriendsPage()));
            }
          },
        ),
        // [
        // Stack(children: [
        //   IconButton(
        //       onPressed: (() {
        //         Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => const FriendRequestsPage()));
        //       }),
        //       icon: const Icon(Icons.notifications)),
        //   _counter != 0
        //       ? Positioned(
        //           right: 5,
        //           top: 5,
        //           child: Container(
        //             padding: const EdgeInsets.all(2),
        //             decoration: BoxDecoration(
        //               color: Colors.red,
        //               borderRadius: BorderRadius.circular(6),
        //             ),
        //             constraints: const BoxConstraints(
        //               minWidth: 14,
        //               minHeight: 14,
        //             ),
        //             child: Text(
        //               '$_counter',
        //               style: const TextStyle(
        //                 color: Colors.white,
        //                 fontSize: 8,
        //               ),
        //               textAlign: TextAlign.center,
        //             ),
        //           ),
        //         )
        //       : Container(),
        // ]),
        //   IconButton(
        //       onPressed: (() {
        //         Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => const AddFriendsPage()));
        //       }),
        //       icon: const Icon(Icons.add)),
        // ],
        context: context,
        leading: Icon(Icons.groups),
        friendRequestIcon: Stack(children: [
          IconButton(
              onPressed: (() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FriendRequestsPage()));
              }),
              icon: const Icon(Icons.notifications)),
          _counter != 0
              ? Positioned(
                  right: 5,
                  top: 5,
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
                      '$_counter',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Container(),
        ]),
        bodyContent: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: _isLoaded
                  ? ListView.builder(
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
                                    "${_friendMap[index]["workouts"]} / ${_friendMap[index]["goal"]}"),
                                tileColor: themeColorPallet['grey light'],
                                leading: CircleAvatar(
                                  radius: 30,
                                  foregroundImage: NetworkImage(
                                      _friendMap[index]["profileImage"]),
                                ),
                                trailing: SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: SfCircularChart(
                                    series: [
                                      RadialBarSeries<WorkoutData, String>(
                                        dataSource: [
                                          (WorkoutData(
                                              _friendMap[index]["workouts"] /
                                                  _friendMap[index]["goal"] *
                                                  100,
                                              "Treninger",
                                              colorPallet[
                                                  index % colorPallet.length]))
                                        ],
                                        xValueMapper: (WorkoutData data, _) =>
                                            data.workoutsLable,
                                        yValueMapper: (WorkoutData data, _) =>
                                            data.workouts,
                                        pointColorMapper:
                                            (WorkoutData data, _) => data.color,
                                        // Radius of the radial bar
                                        radius: '100%',
                                        innerRadius: '68%',
                                        cornerStyle: CornerStyle.bothCurve,
                                        trackColor:
                                            themeColorPallet['grey lightest']!,
                                        trackOpacity: 0.1,
                                        maximumValue: 100,
                                        gap: '3%',
                                      )
                                    ],
                                  ),
                                ),
                                onLongPress: () {
                                  openFriendDialog(_friends[index]);
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
                                    "${_friendMap[index]["workouts"]} / ${_friendMap[index]["goal"]}"),
                                tileColor: themeColorPallet['grey light'],
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
                                  openFriendDialog(_friends[index]);
                                },
                              ),
                            ),
                          );
                        }
                      },
                    )
                  : const Center(
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.teal),
                        ),
                      ),
                    ),
            ),
          ],
        ));
  }

  void openFriendDialog(DocumentReference userRef) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeColorPallet['grey dark'],
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.0)),
        content: SizedBox(
          height: 70,
          width: 200,
          child: TextButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0))),
                backgroundColor: MaterialStateProperty.all<Color>(
                    themeColorPallet['grey dark']!)),
            onPressed: () {
              Navigator.pop(context);
              deleteFriend(userRef);
            },
            child: const Text("Remove friend",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  void deleteFriend(DocumentReference userRef) {
    var currentUserRef =
        FirebaseFirestore.instance.collection("UserData").doc(userId);

    var friendUserRef =
        FirebaseFirestore.instance.collection("UserData").doc(userRef.id);

    currentUserRef.update({
      "friendList": FieldValue.arrayRemove([userRef])
    });

    friendUserRef.update({
      "friendList": FieldValue.arrayRemove([currentUserRef])
    });

    updataPage(context, super.widget);
  }
}

class WorkoutData {
  WorkoutData(this.workouts, this.workoutsLable, this.color);
  final num workouts;
  final String workoutsLable;
  final Color color;
}
