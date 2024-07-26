import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:intl/intl.dart';
import 'package:okter/utils/color_pallet.dart';
import 'package:okter/utils/color_utils.dart';
import 'package:okter/screens/addFriend_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  late CollectionReference users;
  late CollectionReference groups;
  late String userId;
  late DatabaseReference ref;
//
  final _friends = [];
  var _groups = [];
  final _groupMembers = [];
  final _groupMap = [];
  final _friendMap = [];

  @override
  void initState() {
    //super.initState();
    groups = FirebaseFirestore.instance.collection('Groups');
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
          _groups = doc["groups"];
          //print(_groups);
        });
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> getGroupMap() async {
    for (var reference in _groups) {
      var snapshot = reference["group"].get();
      snapshot.then((DocumentSnapshot docuSnap) {
        if (docuSnap.exists) {
          Map<String, dynamic> data = docuSnap.data() as Map<String, dynamic>;
          bool added = false;
          for (var group in _groupMap) {
            if (group["id"] == data["id"]) {
              added = true;
            }
          }
          if (!mounted) return;
          setState(() {
            if (!added) {
              _groupMap.add(data);
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
    getGroupMap();
    return okterAddButtonScaffold(
        name: "Grupper",
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
              print("Legg til");
            }
          },
        ),
        context: context,
        leading: Icon(Icons.calendar_month),
        bodyContent: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 1000,
              child: ListView.builder(
                itemCount: _groupMap.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: themeColorPallet['grey dark'],
                    child: ListTile(title: Text(_groupMap[index]["name"])),
                  );
                },
              ),
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
    var goal = 0;
    var progress = 0;
    try {
      docRef.get().then((DocumentSnapshot doc) {
        if (!mounted) return;
        setState(() {
          goal = doc.get("goal");
        });
      });
    } on FirebaseException catch (e) {
      print(e);
    }

    return goal.toString();
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
}
