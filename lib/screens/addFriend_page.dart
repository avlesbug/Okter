import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({super.key});

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  late CollectionReference users;
  late String userId;
  late DatabaseReference ref;

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
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  "Legg til venner",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 1000,
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
                      return GestureDetector(
                        onLongPress: (() {
                          print("long press");
                        }),
                        child: ListTile(
                          title: Text(snapshot.data!.docs[index].get("name")),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ));
  }
}
