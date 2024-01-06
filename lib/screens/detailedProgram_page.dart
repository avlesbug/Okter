import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:okter/screens/addProgram_page.dart';


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
  var _isLoaded = false;

  final TextEditingController _vektController = TextEditingController();
  final TextEditingController _ovelseController = TextEditingController();

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
          _isLoaded = true;
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
    return okterBackAddButtonScaffold(
        _isLoaded ? _programs[widget.workoutNumber]["name"] : "",
        [
          IconButton(
              onPressed: () {
                print({
                  "name": _programs[widget.workoutNumber]["name"],
                  "isCardio": _programs[widget.workoutNumber]["isCardio"],
                  "exercises": _programs[widget.workoutNumber]["exercises"]
                });
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddProgramPage(
                            programs: _programs,
                            workoutNumber: widget.workoutNumber)));
              },
              icon: const Icon(Icons.edit))
        ],
        context,
        Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 1000,
              child: _isLoaded
                  ? ListView.builder(
                      itemCount:
                          _programs[widget.workoutNumber]["exercises"].length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onLongPress: (() {}),
                          child: !_programs[widget.workoutNumber]['isCardio']
                              ? ListTile(
                                  title: Text(
                                      _programs[widget.workoutNumber]
                                          ["exercises"][index]["name"],
                                      style: const TextStyle(fontSize: 22)),
                                  subtitle: Text(
                                      "${_programs[widget.workoutNumber]["exercises"][index]["sets"]} sets x ${_programs[widget.workoutNumber]["exercises"][index]["reps"]} reps - ${_programs[widget.workoutNumber]["exercises"][index]["weight"]} kg",
                                      style: const TextStyle(fontSize: 18)),
                                )
                              : ListTile(
                                  title: const Text("Løping",
                                      style: TextStyle(fontSize: 22)),
                                  subtitle: Text(stringBuilder(index),
                                      style: const TextStyle(fontSize: 18)),
                                ),
                        );
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

  void addRekord(String ovelse, String vekt) {
    Map<String, dynamic> data = {
      "ovelse": ovelse,
      "vekt": int.parse(vekt),
    };

    _fireStore.collection("UserData").doc(userId).update({
      "rekorder": FieldValue.arrayUnion([data])
    });
  }

  String stringBuilder(index) {
    String programString =
        "${_programs[widget.workoutNumber]["exercises"][index]["sets"]} x ";
    if (_programs[widget.workoutNumber]["exercises"][index]["minutes"] != 0) {
      programString +=
          "${_programs[widget.workoutNumber]["exercises"][index]["minutes"]} min - ";
    }
    if (_programs[widget.workoutNumber]["exercises"][index]["seconds"] != 0) {
      programString +=
          "${_programs[widget.workoutNumber]["exercises"][index]["seconds"]} sek - ";
    }
    programString +=
        "${_programs[widget.workoutNumber]["exercises"][index]["speed"]} km/t";

    if (_programs[widget.workoutNumber]["exercises"][index]["pauseM"] != 0) {
      programString +=
          " - ${_programs[widget.workoutNumber]["exercises"][index]["pauseM"]} min pause";
    }
    if (_programs[widget.workoutNumber]["exercises"][index]["pauseS"] != 0) {
      programString +=
          " - ${_programs[widget.workoutNumber]["exercises"][index]["pauseS"]} sek pause";
    }
    return programString;
  }
}
