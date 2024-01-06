import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:okter/screens/addProgram_page.dart';
import 'package:okter/screens/detailedProgram_page.dart';

import '../color_utils.dart';

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
  final Map<String, dynamic> _userData = {};
  bool _isLoaded = false;
  final Map<String, dynamic> _dataArray = {};

  final TextEditingController _vektController = TextEditingController();
  final TextEditingController _programController = TextEditingController();

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
                      builder: (context) => const AddProgramPage(
                          programs: [], workoutNumber: 0)));
            }),
            icon: const Icon(Icons.add)),
      ],
      context,
      _isLoaded
          ? Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: 1000,
                  child: _programs.isEmpty
                      ? const Text(
                          "Ingen programmer lagt til enda",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )
                      : ListView.builder(
                          itemCount: _programs.length,
                          itemBuilder: (BuildContext context, index) {
                            return Material(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Dismissible(
                                  onDismissed: (direction) {
                                    var tempProgram = _programs[index];
                                    deleteProgram(tempProgram);
                                  },
                                  background: Container(
                                    color: Colors.red,
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Icon(Icons.delete,size: 30,),
                                          ),
                                          Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Icon(Icons.delete, size: 30,),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  key: Key(_programs[index]["name"].toString()),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    tileColor: const Color(0xFF031011),
                                    leading: _programs[index]["name"] == "Håndball" ?
                                    const Icon(
                                      Icons.sports_handball,
                                      color: Colors.white,
                                      size: 40,
                                    ) :
                                    _programs[index]["isCardio"]
                                        ? const Icon(
                                            Icons.directions_run,
                                            color: Colors.white,
                                            size: 40,
                                          )
                                        : const Icon(
                                            Icons.fitness_center,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailedProgramPage(
                                                    workoutNumber: index,
                                                  )));
                                    },
                                    title: Text(_programs[index]["name"],
                                        style: const TextStyle(fontSize: 22)),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                )
              ],
            )
          : const Center(
              child: SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              ),
            ),
    );
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
          _isLoaded = true;
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

  Future workoutProgramDialog(int index) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Center(child: Text(_programs[index]["name"])),
            backgroundColor: hexStringtoColor("041416"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26.0)),
            content: SizedBox(
                height: 70,
                width: 200,
                child: TextButton(
                    onPressed: () {
                      //deleteProgram(index);
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
                    child: const Text(
                      "Slett program",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ))),
          ));

  Future<void> deleteProgram(var tempProgram) async {
    //print(_programs[index]);

    await _fireStore.collection("UserData").doc(userId).update({
      "workoutPrograms": FieldValue.arrayRemove([tempProgram]),
    });
  }
}
