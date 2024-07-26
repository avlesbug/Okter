import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:okter/utils/color_pallet.dart';

import 'package:uuid/uuid.dart';

class IncreaseDecreaseWidget extends StatelessWidget {
  var documentRef;
  final String userId;
  var uuid = Uuid();

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
      },
      {
        'name': 'Håndball',
        'isCardio': false,
      },
      {
        'name': 'Fotball',
        'isCardio': false,
      },
      {
        'name': 'Alpint',
        'isCardio': false,
      },
      {
        'name': 'Snowboard',
        'isCardio': false,
      },
      {
        'name': 'Skitur',
        'isCardio': false,
      },
      {
        'name': 'Topptur',
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
            backgroundColor: themeColorPallet['grey dark'],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26.0)),
            content: SizedBox(
              height: 200,
              width: 300,
              child: ListView.builder(
                itemCount: workoutPrograms.length,
                itemBuilder: (context, index) {
                  if (workoutPrograms.isNotEmpty) {
                    return ListTile(
                      onTap: () {
                        increaseDetailedWorkouts(
                            workoutPrograms[index]["name"].toString());
                        Navigator.pop(context);
                      },
                      title: Text(
                        workoutPrograms[index]["name"].toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
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
        'detailedWorkouts': FieldValue.arrayUnion([
          {'id': uuid.v1(), 'date': Timestamp.now(), 'workoutProgram': program}
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
        'detailedWorkouts': FieldValue.arrayUnion([
          {
            'id': uuid.v1(),
            'date': Timestamp.now(),
            'workoutProgram': "Trening"
          }
        ])
      });
    });
  }

  void decreaseWorkouts() async {
    var updateList;
    List<dynamic> detailedWorkouts = documentRef.data!['detailedWorkouts'];
    if (detailedWorkouts.length > 0) {
      updateList =
          detailedWorkouts.getRange(0, detailedWorkouts.length - 1).toList();
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
        'detailedWorkouts': updateList
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height.toInt();
    width = min(MediaQuery.of(context).size.width.toInt(), 500);
    List<dynamic> workoutPrograms = getWorkoutPrograms(
        documentRef.data!['workoutPrograms'] as List<dynamic>);
    return Row(
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
              color: themeColorPallet['white'],
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
                workoutProgramDialog(context, workoutPrograms);
              },
              child: IconButton(
                onPressed: () {
                  increaseWorkouts();
                },
                icon: const Icon(Icons.add),
                color: themeColorPallet['white'],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
