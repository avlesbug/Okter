import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart';
import 'package:okter/basePage.dart';

import '../color_utils.dart';
import '../reusable_widgets.dart';

class DetailedProgramPage extends StatefulWidget {
  const DetailedProgramPage({super.key, required this.workoutNumber});

  final int workoutNumber;

  @override
  State<DetailedProgramPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<DetailedProgramPage> {
  late CollectionReference users;
  late String userId;
  late DatabaseReference ref;

  List<dynamic> _programs = [];

  TextEditingController _vektController = TextEditingController();
  TextEditingController _ovelseController = TextEditingController();

  final String _collection = 'collectionName';
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  void initState() {
    //super.initState();
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    //userId = Provider.of(context).auth.getCurrentUID();
    ref = FirebaseDatabase.instance.ref("UserData");
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        // Document does not exist
        return;
      }

      final userData = docSnapshot.data() as Map<String, dynamic>;
      //final workoutData =
      //    workoutDocRef.docs.first.data() as Map<String, dynamic>;

      setState(() {
        try {
          _programs = userData['workoutPrograms'] as List<dynamic>;
        } catch (e) {
          print(e);
        }
      });
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    initState();
    return okterScaffold(
        "Treningsprogram",
        context,
        Column(
          children: [
            const SizedBox(height: 20),
            Container(
              height: 1000,
              child: ListView.builder(
                itemCount: _programs[widget.workoutNumber]["exercises"].length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: (() {}),
                    child: ListTile(
                      title: Text(
                          _programs[widget.workoutNumber]["exercises"][index]
                              ["name"],
                          style: const TextStyle(fontSize: 22)),
                      subtitle: Text(
                          "${_programs[widget.workoutNumber]["exercises"][index]["weight"]} kg - ${_programs[widget.workoutNumber]["exercises"][index]["sets"]} sets x ${_programs[widget.workoutNumber]["exercises"][index]["reps"]} reps",
                          style: const TextStyle(fontSize: 18)),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }

  void addRekord(String ovelse, String vekt) {
    Map<String, dynamic> data = {
      "ovelse": ovelse,
      "vekt": int.parse(vekt),
    };

    _fireStore.collection("UserData").doc(userId).update({
      "rekorder": FieldValue.arrayUnion([data])
    });
  }
}
