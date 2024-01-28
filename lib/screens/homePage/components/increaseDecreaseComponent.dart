import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../utils/color_utils.dart';
import '../../../utils/reusable_widgets.dart';

class IncreaseDecreaseWidget extends StatelessWidget{
  var documentRef;
  final String userId;

  IncreaseDecreaseWidget({required this.documentRef, required this.userId});

  final TextEditingController _okterController = TextEditingController();
  final TextEditingController _okterGoalController = TextEditingController();


  List<dynamic> getWorkoutPrograms(List<dynamic> userPrograms) {
    final List<dynamic> _programs = [
      {
        'name': 'Styrketrening',
        'isCardio': false,
      },
      {
        'name': 'Løping',
        'isCardio': true,
      },
      {
        'name': 'Fjelltur',
        'isCardio': false,
      },
      {
        'name': 'Gåtur',
        'isCardio': false,
      }
    ];
    return [...userPrograms, ..._programs];
  }


  var height = 667;
  var width = 375;

  workoutProgramDialog(context, workoutPrograms) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
          title: const Text("Treningsprogram"),
          backgroundColor: hexStringtoColor("041416"),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.0)),
          content: SizedBox(
            height: 200,
            width: 300,
            child: ListView.builder(
              itemCount: workoutPrograms.length,
              itemBuilder: (context, index) {
                if (workoutPrograms.isNotEmpty) {
                  return TextButton(
                      onPressed: () {
                        increaseDetailedWorkouts(
                            workoutPrograms[index]["name"].toString());
                        Navigator.pop(context);
                      },
                      child: Text(
                        workoutPrograms[index]["name"].toString(),
                        style: const TextStyle(color: Colors.white),
                      ));
                } else {
                  return const Text("Ingen treningsprogrammer tilgjengelig");
                }
              },
            ),
          ),
        ));

  void increaseDetailedWorkouts(program) async {
      await FirebaseFirestore.instance
          .collection("UserData")
          .doc(userId)
          .get()
          .then((value) {
            FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      'workouts': documentRef.data!['workouts'] + 1,
      'lastWorkout': Timestamp.now(),
      'detailedWorkouts': FieldValue.arrayUnion([
        {'date': Timestamp.now(), 'workoutProgram': program}
      ])
    });
  });
  }

  void increaseWorkouts() async {
    await FirebaseFirestore.instance
          .collection("UserData")
          .doc(userId)
          .get()
          .then((value) {
            FirebaseFirestore.instance.collection("UserData").doc(userId).update({
              'workouts': value['workouts'] + 1,
              'lastWorkout': Timestamp.now(),
              'detailedWorkouts': FieldValue.arrayUnion([
                {'date': Timestamp.now(), 'workoutProgram': "Trening"}
              ])
            });
          });
  }

  void decreaseWorkouts() async {
    var updateList;
    List<dynamic> detailedWorkouts = documentRef.data!['detailedWorkouts'];
    if(detailedWorkouts.length > 0){
      updateList = detailedWorkouts.getRange(0, detailedWorkouts.length-1).toList();
    } else {
      updateList = [];
    }
    await FirebaseFirestore.instance
          .collection("UserData")
          .doc(userId)
          .get()
          .then((value) {
            FirebaseFirestore.instance.collection("UserData").doc(userId).update({
              'workouts': value['workouts'] - 1,
              'lastWorkout': Timestamp.now(),
              'detailedWorkouts':
               updateList
            });
          });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height.toInt();
    width = MediaQuery.of(context).size.width.toInt();
    List<dynamic> workoutPrograms = getWorkoutPrograms(documentRef.data!['workoutPrograms'] as List<dynamic>);
    return 
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: width * 0.15,
          height: height * 0.02,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: IconButton(
              onPressed: () {
                decreaseWorkouts();
              },
              icon: const Icon(Icons.remove),
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
        SizedBox(
          width: width * 0.05,
        ),
        SizedBox(
          width: width * 0.15,
          height: height * 0.02,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: GestureDetector(
              onLongPress: () {
                workoutProgramDialog(context,workoutPrograms);
              },
              child: IconButton(
                onPressed: () {
                  increaseWorkouts();
                },
                icon: const Icon(Icons.add),
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
        ),
      ],
    );
  }
}