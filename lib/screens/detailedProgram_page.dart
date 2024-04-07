import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:okter/screens/addProgram_page.dart';



class DetailedProgramPage extends StatefulWidget {
  const DetailedProgramPage({super.key, required this.workout, required this.updateProgram, required this.workoutIndex});


  final Map<String,dynamic> workout;
  final Function updateProgram;
  final int workoutIndex;

  @override
  State<DetailedProgramPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<DetailedProgramPage> {
  late CollectionReference users;
  late String userId;
  late DatabaseReference ref;

  final TextEditingController _vektController = TextEditingController();
  final TextEditingController _ovelseController = TextEditingController();

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  void initState() {
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    ref = FirebaseDatabase.instance.ref("UserData");
  }


  @override
  Widget build(BuildContext context) {
    initState();
        return okterBackAddButtonScaffold(
            widget.workout["name"],
            [
              IconButton(
                  onPressed: () {
                    print({
                      "name": widget.workout["name"],
                      "isCardio": widget.workout["isCardio"],
                      "exercises": widget.workout["exercises"]
                    });
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddProgramPage(
                                editWorkout: widget.workout,
                                workoutIndex: widget.workoutIndex,
                                updateProgram: widget.updateProgram)));
                  },
                  icon: const Icon(Icons.edit))
            ],
            context,
            Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: 1000,
                  child: ListView.builder(
                          itemCount:
                              widget.workout["exercises"].length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: (() {}),
                              child: !widget.workout['isCardio']
                                  ? ListTile(
                                      title: Text(
                                          widget.workout
                                              ["exercises"][index]["name"],
                                          style: const TextStyle(fontSize: 22)),
                                      subtitle: Text(
                                          "${widget.workout["exercises"][index]["sets"]} sets x ${widget.workout["exercises"][index]["reps"]} reps - ${widget.workout["exercises"][index]["weight"]} kg",
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
                ),
              ],
            ));

  }

  String stringBuilder(index) {
    String programString =
        "${widget.workout["exercises"][index]["sets"]} x ";
    if (widget.workout["exercises"][index]["minutes"] != 0) {
      programString +=
          "${widget.workout["exercises"][index]["minutes"]} min - ";
    }
    if (widget.workout["exercises"][index]["seconds"] != 0) {
      programString +=
          "${widget.workout["exercises"][index]["seconds"]} sek - ";
    }
    programString +=
        "${widget.workout["exercises"][index]["speed"]} km/t";

    if (widget.workout["exercises"][index]["pauseM"] != 0) {
      programString +=
          " - ${widget.workout["exercises"][index]["pauseM"]} min pause";
    }
    if (widget.workout["exercises"][index]["pauseS"] != 0) {
      programString +=
          " - ${widget.workout["exercises"][index]["pauseS"]} sek pause";
    }
    return programString;
  }
}
