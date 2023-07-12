import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart';
import 'package:okter/basePage.dart';
import 'package:okter/screens/detailedProgram_page.dart';
import 'package:numberpicker/numberpicker.dart';

import '../color_utils.dart';
import '../reusable_widgets.dart';

class AddProgramPage extends StatefulWidget {
  const AddProgramPage({super.key});

  @override
  State<AddProgramPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<AddProgramPage> {
  late CollectionReference users;
  late String userId;
  late DatabaseReference ref;

  int _formCount = 0; //add this
  final List<Map<String, dynamic>> _exercises = []; //add this
  final Map<String, dynamic> _dataArray = {
    'name': 'test',
    'exercises': [
      {
        'name': 'testøvelse 1',
        'sets': 3,
        'reps': 8,
        'weight': 60,
      }
    ],
  }; //add this

  int _currentSetsValue = 3;
  int _currentRepsValue = 8;

  TextEditingController _vektController = TextEditingController();
  TextEditingController _programController = TextEditingController();

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Widget form(int key) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Øvelse ${key + 1}',
                        hintStyle: TextStyle(color: Colors.white)),
                    onChanged: (value) {
                      setState(() {
                        _exercises[key]['name'] = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: NumberPicker(
                      //haptics: true,
                      itemHeight: 30,
                      itemWidth: 20,
                      value: _exercises[key]['sets'],
                      minValue: 1,
                      maxValue: 100,
                      onChanged: (value) {
                        print("New value: $value");
                        setState(() {
                          _exercises[key]['sets'] = value;
                        });
                      }),
                ),
                Expanded(
                  child: Center(child: Text("Sets")),
                ),
                Expanded(
                  child: NumberPicker(
                      //haptics: true,
                      itemHeight: 30,
                      itemWidth: 20,
                      value: _exercises[key]['reps'],
                      minValue: 1,
                      maxValue: 100,
                      onChanged: (value) {
                        setState(() {
                          _exercises[key]['reps'] = value;
                        });
                        print("New value: $value");
                      }),
                ),
                Expanded(
                  child: Center(child: Text("Reps")),
                ),
                Expanded(
                  child: NumberPicker(
                      //haptics: true,
                      itemHeight: 30,
                      itemWidth: 20,
                      value: _exercises[key]['weight'],
                      minValue: 0,
                      maxValue: 400,
                      onChanged: (value) {
                        setState(() {
                          _exercises[key]['weight'] = value;
                        });
                      }),
                ),
                Expanded(
                  child: Center(child: Text("kg")),
                )
              ],
            ),
          ),
        ),
      );

  Widget buttonRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            visible: _formCount > 0,
            child: IconButton(
                onPressed: () {
                  if (_exercises.isNotEmpty) {
                    _exercises.removeAt(_dataArray.length - 1);
                  }
                  setState(() {
                    _formCount--;
                  });
                },
                icon: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(
                    Icons.remove,
                  ),
                )),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _formCount++;
                  _exercises.add({
                    'name': 'Øvelse $_formCount',
                    'sets': 3,
                    'reps': 8,
                    'weight': 100,
                  });
                  print(_formCount);
                });
              },
              icon: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(
                  Icons.add,
                ),
              )),
        ],
      );

  @override
  void initState() {
    //super.initState();
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    //userId = Provider.of(context).auth.getCurrentUID();
    ref = FirebaseDatabase.instance.ref("UserData");
  }

  @override
  Widget build(BuildContext context) {
    initState();
    return okterScaffold(
        "Programmer",
        context,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 19),
              largerInputField(_programController, "Navn på program"),
              const SizedBox(height: 20),
              ...List.generate(_formCount, (index) => form(index)),
              buttonRow(),
              const SizedBox(height: 30),
              TextButton(
                  onPressed: () {
                    print(_exercises.toString());
                    print(_programController.text);
                    _dataArray.addAll({
                      'name': _programController.text,
                      'exercises': _exercises,
                    });

                    addProgram();
                    print("DataArray: " + _dataArray.toString());
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.teal, // Background Color
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Lagre program",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )),
            ],
          ),
        ));
  }

  void addProgram() {
    _fireStore.collection("UserData").doc(userId).update({
      'workoutPrograms': FieldValue.arrayUnion([
        _dataArray,
      ])
    });
  }
}
