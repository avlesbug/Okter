import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../utils/color_utils.dart';
import '../../../utils/reusable_widgets.dart';

class WorkoutsGoalWidget extends StatelessWidget{
  var documentRef;
  final String userId;

  WorkoutsGoalWidget({required this.documentRef, required this.userId});

  final TextEditingController _okterController = TextEditingController();
  final TextEditingController _okterGoalController = TextEditingController();

  var height = 667;
  var width = 375;


  void openGoalDialog(var context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Mål"),
      backgroundColor: hexStringtoColor("041416"),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.0)),
      content: numInputField(
          _okterGoalController, "Skriv antall økter du ønsker å nå"),
      actions: [
        TextButton(
            onPressed: (() => (submitGoal(context))),
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            ))
      ],
    ),
  );

  void openDialog(context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Økter"),
      backgroundColor: hexStringtoColor("041416"),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.0)),
      content: numInputField(_okterController, "Skriv antall økter"),
      actions: [
        TextButton(
            onPressed: () {
              submit(context);
            },
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            ))
      ],
    ),
  );

  void submitGoal(BuildContext context) {
    String input = _okterGoalController.text.trim();
    if (input.isEmpty) {
      return;
    }
    var okterNum = int.parse(_okterGoalController.text);
    FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      'goal': okterNum,
    });
    Navigator.pop(context);
}

void submit(BuildContext context) {
    String input = _okterController.text.trim();
    if (input.isEmpty) {
      return;
    }
    var okterNum = int.parse(_okterController.text);
    FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      'workouts': okterNum,
    });
    Navigator.pop(context);
}


  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height.toInt();
    width = MediaQuery.of(context).size.width.toInt();
    return 
    Container(
      width: width * 0.4,
      height: height * 0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: GestureDetector(
                onLongPress: () {
                  openDialog(context);
                },
                child: Text(documentRef.data!['workouts'].toString(),
                    style: const TextStyle(
                      fontSize: 32,
                        color:
                            Color.fromARGB(255, 255, 255, 255)))),
          ),
          Container(
            child: GestureDetector(
                onLongPress: () {
                  openDialog(context);
                },
                child: const Text(" / ",
                    style: TextStyle(
                      fontSize: 32,
                        color:
                            Color.fromARGB(255, 255, 255, 255)))),
          ),
          SizedBox(
            child: GestureDetector(
                onLongPress: () {
                  openGoalDialog(context);
                },
                child: Text(documentRef.data!['goal'].toString(),
                  style: const TextStyle(
                    fontSize: 32,
                      color:
                          Color.fromARGB(255, 255, 255, 255)))),
            ),
        ],
      ),
    );
}
}