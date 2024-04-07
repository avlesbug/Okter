import 'dart:core';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart'hide DatePickerTheme;
import 'package:okter/basePage.dart';
import 'package:okter/screens/homePage/components/chartCarouselComponent.dart';
import 'package:okter/screens/homePage/components/endGoalComponent.dart';
import 'package:intl/intl.dart';
import 'package:okter/screens/homePage/components/increaseDecreaseComponent.dart';
import 'package:okter/screens/homePage/components/sisteOktComponent.dart';
import 'package:okter/screens/homePage/components/workoutsGoalComponent.dart';
import 'package:okter/utils/reusable_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  late CollectionReference users;
  late String userId;
  late DatabaseReference ref;

  var height = 667;
  var width = 375;

  @override
  void initState() {
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height.toInt();
    width = MediaQuery.of(context).size.width.toInt();
    return okterDrawerScaffold(
        context,
        StreamBuilder(
          stream: FirebaseFirestore.instance.collection('UserData').doc(userId).snapshots(),
          builder: (context, snapshot) {
            return 
            snapshot.hasData ?
                Column(children: [
                SizedBox(height: height * 0.1),
                SizedBox(
                  height: height * 0.04,
                  width: min(width, 500) * 0.36,
                  child: const FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text("Økter i år:",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                WorkoutsGoalWidget(documentRef: snapshot, userId: userId),
                IncreaseDecreaseWidget(documentRef: snapshot, userId: userId),
                SizedBox(
                  height: height * 0.02,
                ),
                SisteOktWidget(documentRef: snapshot, userId: userId),
                ChartCarouselWidget(documentRef: snapshot, userId: userId),
                EndGoalComponent(documentRef: snapshot, userId: userId)
              ]) : loadingComponent();
          }
        ));
  }
}