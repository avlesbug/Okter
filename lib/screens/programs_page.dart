import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:okter/screens/addProgram_page.dart';
import 'package:okter/screens/detailedProgram_page.dart';
import 'package:okter/utils/color_pallet.dart';

import '../utils/color_utils.dart';

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  late String userId;

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  void initState() {
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
  }

  @override
  Widget build(BuildContext context) {
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
      StreamBuilder(
          stream: FirebaseFirestore.instance.collection('UserData').doc(userId).snapshots(),
          builder: (context, snapshot) {
            return 
            snapshot.hasData ?
             Column(
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 1000,
                      child: snapshot.data!['workoutPrograms'].isEmpty
                          ? const Text(
                              "Ingen programmer lagt til enda",
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            )
                          : ListView.builder(
                              itemCount: snapshot.data!['workoutPrograms'].length,
                              itemBuilder: (BuildContext context, index) {
                                return Material(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Dismissible(
                                      onDismissed: (direction) {
                                        deleteProgram(snapshot.data!['workoutPrograms'][index]);
                                      },
                                      background: Container(
                                        color: colorPallet[2],
                                        child: Center(
                                          child: Row(
                                            children: const [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(16.0,8,16,32),
                                                child: Icon(Icons.delete,size: 36,),
                                              ),
                                              Spacer(),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(16.0,8,16,32),
                                                child: Icon(Icons.delete,size: 36,),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      key: Key(snapshot.data!['workoutPrograms'][index]["name"].toString()),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        tileColor: const Color(0xFF031011),
                                        leading: snapshot.data!['workoutPrograms'][index]["name"] == "Håndball" ?
                                        const Icon(
                                          Icons.sports_handball,
                                          color: Colors.white,
                                          size: 40,
                                        ) :
                                        snapshot.data!['workoutPrograms'][index]["isCardio"]
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
                                        title: Text(snapshot.data!['workoutPrograms'][index]["name"],
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
            );
            }
          ));
  }

  Future<void> deleteProgram(var tempProgram) async {
    await _fireStore.collection("UserData").doc(userId).update({
      "workoutPrograms": FieldValue.arrayRemove([tempProgram]),
    });
  }
}
