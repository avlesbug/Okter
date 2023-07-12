import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart';
import 'package:okter/basePage.dart';
import 'package:okter/screens/addProgram_page.dart';
import 'package:okter/screens/detailedProgram_page.dart';

import '../color_utils.dart';
import '../reusable_widgets.dart';

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  late CollectionReference users;
  late String userId;
  late DatabaseReference ref;
  List<dynamic> _programs = [];
  Map<String, dynamic> _userData = {};

  int _formCount = 2; //add this
  final List<Map<String, dynamic>> _dataArray = []; //add this
  String? _data = '';

  TextEditingController _vektController = TextEditingController();
  TextEditingController _programController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    initState();
    return okterAddButtonScaffold(
        "Programmer",
        [
          IconButton(
              onPressed: (() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddProgramPage()));
              }),
              icon: const Icon(Icons.add)),
        ],
        context,
        Column(
          children: [
            const SizedBox(height: 20),
            Container(
              height: 1000,
              child: ListView.builder(
                itemCount: _programs.length,
                itemBuilder: (BuildContext context, index) {
                  return GestureDetector(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailedProgramPage(
                                      workoutNumber: index,
                                    )));
                      },
                      onLongPress: (() {
                        workoutProgramDialog(index);
                      }),
                      title: Text(_programs[index]["name"],
                          style: const TextStyle(fontSize: 22)),
                    ),
                  );
                },
              ),
            )
          ],
        ));
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
          _userData = userData;
        } catch (e) {
          print(e);
        }
      });
    } catch (error) {
      print('Error fetching user data: $error');
    }

    final docRef =
        FirebaseFirestore.instance.collection("UserData").doc(userId);
    try {
      docRef.get().then((DocumentSnapshot doc) {
        if (!mounted) return;
        setState(() {
          _programs = doc["workoutPrograms"];
        });
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  void updateProgram(name, id) {
    Map<String, dynamic> data = {
      "name": name,
    };

    _fireStore
        .collection("UserData")
        .doc(userId)
        .collection("workoutPrograms")
        .doc(id)
        .set(data);
  }

  void deleteRekord(String programId) {
    _fireStore
        .collection("UserData")
        .doc(userId)
        .collection("workoutPrograms")
        .doc(programId)
        .delete();
  }

  Future workoutProgramDialog(int index) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Center(child: Text(_programs[index]["name"])),
            backgroundColor: hexStringtoColor("041416"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26.0)),
            content: Container(
                height: 70,
                width: 200,
                child: TextButton(
                    onPressed: () {
                      deleteProgram(index);
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.teal),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(18.0)))),
                    child: Text(
                      "Slett program",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ))),
          ));

  void deleteProgram(int index) {
    Map<String, dynamic> data = {
      "name": _userData['workoutPrograms'][index]['name'],
      "exercises": _userData['workoutPrograms'][index]['exercises'],
    };

    _fireStore.collection("UserData").doc(userId).update({
      "workoutPrograms": FieldValue.arrayRemove([data])
    });
  }
}
