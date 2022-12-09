import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:intl/intl.dart';
import 'package:okter/screens/addFriend_page.dart';

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
  var _friendNames = [];

  String _frindname = "Friend Name";

  @override
  void initState() {
    print("Called init state");
    //super.initState();
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    //userId = Provider.of(context).auth.getCurrentUID();
    ref = FirebaseDatabase.instance.ref("UserData");
  }

  Future<void> initFriends() async {
    print("Called initFriends");
    var childRef = ref.child(userId);
    final friendsRef = users.doc(userId).collection('friends');
    final friendsSnapshot = await friendsRef.get();
    DatabaseEvent event = await childRef.once();
    FirebaseFirestore.instance
        .collection('UserData')
        .doc(userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      //if (!mounted) return;
      if (documentSnapshot.exists) {
        //print('Friend list: ${documentSnapshot.get('friends')}');
        setState(() {
          _friends = documentSnapshot.get('friends') as List<dynamic>;
          for (DocumentReference element in _friends) {
            element.get().then((DocumentSnapshot documentSnapshot) {
              if (documentSnapshot.exists) {
                if (!_friendNames.contains(documentSnapshot.get('name'))) {
                  _friendNames.add(documentSnapshot.get('name'));
                  print('Added: ${documentSnapshot.get('name')}');
                }
              }
            });
          }
        });
      }
    });
  }

  Future<void> getUserData() async {
    final docRef =
        FirebaseFirestore.instance.collection("UserData").doc(userId);
    try {
      docRef.get().then((DocumentSnapshot doc) {
        if (!mounted) return;
        setState(() {
          _name = doc["name"];
          _username = doc["username"];
        });
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    initState();
    getUserData();
    initFriends();
    return okterScaffold(
        context,
        //display friends
        Column(
          children: [
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Friends",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                      onPressed: (() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddFriendsPage()));
                      }),
                      icon: const Icon(Icons.add))
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 1000,
              child: ListView.builder(
                itemCount: _friendNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_friendNames[index]),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
