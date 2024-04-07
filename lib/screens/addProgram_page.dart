import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:numberpicker/numberpicker.dart';

import '../utils/reusable_widgets.dart';

class AddProgramPage extends StatefulWidget {
  const AddProgramPage(
      {super.key, required this.editWorkout,
      required this.updateProgram,
      required this.workoutIndex});
  final Map<String,dynamic> editWorkout;
  final Function updateProgram;
  final int workoutIndex;

  @override
  State<AddProgramPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<AddProgramPage> {
  late String userId;
  var _isCardio = false;
  var _editing = false;
  Map<String, dynamic> _oldProgram = {};
  String _title = "Nytt program";

  int _formCount = 0; //add this
  List<dynamic> _exercises = []; //add this
  Map<String, dynamic> _dataArray = {}; //add this

  final TextEditingController _programController = TextEditingController();

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return okterScaffold(
        _title,
        context,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _isCardio
                  ? const Icon(Icons.directions_run,
                      size: 40, color: Colors.white)
                  : const Icon(Icons.fitness_center,
                      size: 40, color: Colors.white),
              const SizedBox(height: 19),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 200,
                      height: 50,
                      child: largerInputField(
                          _programController, "Navn på program")),
                  CupertinoSwitch(
                      thumbColor: Colors.white,
                      trackColor: const Color.fromARGB(155, 0, 150, 135),
                      activeColor: const Color.fromARGB(145, 0, 150, 135),
                      value: _isCardio,
                      onChanged: (value) {
                        setState(() {
                          _isCardio = value;
                        });
                      }),
                ],
              ),
              const SizedBox(height: 20),
              ...List.generate(_formCount, (index) => form(index)),
              buttonRow(),
              const SizedBox(height: 30),
              TextButton(
                  onPressed: () {
                    _dataArray.addAll({
                      'name': _programController.text,
                      'isCardio': _isCardio,
                      'exercises': _exercises,
                    });
                    if (_editing) {
                      widget.updateProgram(_dataArray,widget.workoutIndex);
                    } else {
                      addProgram();
                    }
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        155, 0, 150, 135), // Background Color
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      "Lagre program",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )),
            ],
          ),
        ));
  }

  Widget form(int key) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: _isCardio
                  ? [
                      Row(children: [
                        Expanded(
                          child: NumberPicker(
                              haptics: true,
                              itemHeight: 30,
                              itemWidth: 20,
                              value: _exercises[key]['sets'],
                              minValue: 1,
                              maxValue: 100,
                              onChanged: (value) {
                                setState(() {
                                  _exercises[key]['sets'] = value;
                                });
                              }),
                        ),
                        const Expanded(
                          child: Center(child: Text("x")),
                        ),
                        Expanded(
                            child: NumberPicker(
                                haptics: true,
                                itemHeight: 30,
                                itemWidth: 20,
                                value: _exercises[key]['minutes'],
                                minValue: 0,
                                maxValue: 100,
                                onChanged: (value) {
                                  setState(() {
                                    _exercises[key]['minutes'] = value;
                                  });
                                })),
                        const Expanded(child: Center(child: Text("min"))),
                        Expanded(
                            child: NumberPicker(
                                haptics: true,
                                itemHeight: 30,
                                itemWidth: 20,
                                value: _exercises[key]['seconds'],
                                minValue: 0,
                                maxValue: 60,
                                onChanged: (value) {
                                  setState(() {
                                    _exercises[key]['seconds'] = value;
                                  });
                                })),
                        const Expanded(child: Center(child: Text("sek"))),
                        Expanded(
                          child: NumberPicker(
                              haptics: true,
                              itemHeight: 30,
                              itemWidth: 20,
                              value: _exercises[key]['speed'],
                              minValue: 0,
                              maxValue: 40,
                              onChanged: (value) {
                                setState(() {
                                  _exercises[key]['speed'] = value;
                                });
                              }),
                        ),
                        const Expanded(
                          child: Center(child: Text("km/t")),
                        )
                      ]),
                      const Divider(
                        color: Color(0xFF086c6a),
                        thickness: 1,
                      ),
                      Row(
                        children: [
                          const Expanded(child: Text("Pause:")),
                          Expanded(
                            child: NumberPicker(
                                haptics: true,
                                itemHeight: 30,
                                itemWidth: 20,
                                value: _exercises[key]['pauseM'],
                                minValue: 0,
                                maxValue: 60,
                                onChanged: (value) {
                                  setState(() {
                                    _exercises[key]['pauseM'] = value;
                                  });
                                }),
                          ),
                          const Expanded(child: Center(child: Text("min"))),
                          Expanded(
                            child: NumberPicker(
                                haptics: true,
                                itemHeight: 30,
                                itemWidth: 20,
                                value: _exercises[key]['pauseS'],
                                minValue: 0,
                                maxValue: 59,
                                onChanged: (value) {
                                  setState(() {
                                    _exercises[key]['pauseS'] = value;
                                  });
                                }),
                          ),
                          const Expanded(child: Center(child: Text("sek"))),
                        ],
                      )
                    ]
                  : [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  hintText: _exercises[key]['name'],
                                  hintStyle:
                                      const TextStyle(color: Colors.white)),
                              onChanged: (value) {
                                setState(() {
                                  _exercises[key]['name'] = value;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: NumberPicker(
                                haptics: true,
                                itemHeight: 30,
                                itemWidth: 20,
                                value: _exercises[key]['sets'],
                                minValue: 1,
                                maxValue: 100,
                                onChanged: (value) {
                                  setState(() {
                                    _exercises[key]['sets'] = value;
                                  });
                                }),
                          ),
                          const Expanded(
                            child: Center(child: Text("Sets")),
                          ),
                          Expanded(
                            child: NumberPicker(
                                haptics: true,
                                itemHeight: 30,
                                itemWidth: 20,
                                value: _exercises[key]['reps'],
                                minValue: 1,
                                maxValue: 100,
                                onChanged: (value) {
                                  setState(() {
                                    _exercises[key]['reps'] = value;
                                  });
                                }),
                          ),
                          const Expanded(
                            child: Center(child: Text("Reps")),
                          ),
                          Expanded(
                            child: NumberPicker(
                                haptics: true,
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
                          const Expanded(
                            child: Center(child: Text("kg")),
                          )
                        ],
                      )
                    ],
            ),
          ),
        ),
      );

  Widget buttonRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _isCardio
            ? [
                Visibility(
                  visible: _formCount > 0,
                  child: IconButton(
                      onPressed: () {
                        if (_exercises.isNotEmpty) {
                          _exercises.removeAt(_exercises.length - 1);
                        }
                        setState(() {
                          _formCount--;
                        });
                      },
                      icon: const CircleAvatar(
                        backgroundColor: Color.fromARGB(155, 0, 150, 135),
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
                          'name': 'Løping',
                          'sets' : 1,
                          'seconds': 0,
                          'minutes': 1,
                          'speed': 10,
                          'pauseM': 1,
                          'pauseS': 0,
                        });
                      });
                    },
                    icon: const CircleAvatar(
                      backgroundColor: Color.fromARGB(155, 0, 150, 135),
                      child: Icon(
                        Icons.add,
                      ),
                    ))
              ]
            : [
                Visibility(
                  visible: _formCount > 0,
                  child: IconButton(
                      onPressed: () {
                        if (_exercises.isNotEmpty) {
                          _exercises.removeAt(_exercises.length - 1);
                        }
                        setState(() {
                          _formCount--;
                        });
                      },
                      icon: const CircleAvatar(
                        backgroundColor: Color.fromARGB(155, 0, 150, 135),
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
                          'weight': 60,
                        });
                      });
                    },
                    icon: const CircleAvatar(
                      backgroundColor: Color.fromARGB(155, 0, 150, 135),
                      child: Icon(
                        Icons.add,
                      ),
                    ))
              ],
      );
  void addProgram() {
    _fireStore.collection("UserData").doc(userId).update({
      'workoutPrograms': FieldValue.arrayUnion([
        _dataArray,
      ])
    });
  }


  void getData() {
    if (widget.editWorkout.isNotEmpty) {
      _dataArray = widget.editWorkout;
      _exercises = widget.editWorkout['exercises'];
      _formCount = _exercises.length;
      _programController.text = _dataArray['name'];
      _isCardio = _dataArray['isCardio'];
      _title = "Rediger program";
      _editing = true;
    }
  }
}