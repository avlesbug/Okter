import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:numberpicker/numberpicker.dart';

import '../utils/reusable_widgets.dart';

class AddProgramPage extends StatefulWidget {
  const AddProgramPage(
      {super.key, required this.programs, required this.workoutNumber});
  final List<dynamic> programs;
  final int workoutNumber;

  @override
  State<AddProgramPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<AddProgramPage> {
  late CollectionReference users;
  late String userId;
  late DatabaseReference ref;
  final _switchValue = true;
  var _isCardio = false;
  var _editing = false;
  Map<String, dynamic> _oldProgram = {};
  String _title = "Nytt program";

  int _formCount = 0; //add this
  List<dynamic> _exercises = []; //add this
  Map<String, dynamic> _dataArray = {}; //add this

  final TextEditingController _programController = TextEditingController();

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

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
                                print("New value: $value");
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
                                  print("New value: $value");
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
                                  print("New value: $value");
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
                                  print("New value: $value");
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
                          'sets': 3,
                          'reps': 8,
                          'weight': 60,
                          'seconds': 0,
                          'minutes': 1,
                          'speed': 10,
                          'pauseM': 1,
                          'pauseS': 0,
                        });
                        print(_formCount);
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
                          'seconds': 0,
                          'minutes': 1,
                          'speed': 10,
                          'pauseM': 1,
                          'pauseS': 0,
                        });
                        print(_formCount);
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

  @override
  void initState() {
    super.initState();
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    //userId = Provider.of(context).auth.getCurrentUID();
    ref = FirebaseDatabase.instance.ref("UserData");
    //print(widget.dataArray);
    getData();
    //_isCardio = _dataArray['isCardio'];
    //print("test");
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
                    print(_editing);
                    if (_editing) {
                      updatePrograms();
                      print("updated");
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

  void addProgram() {
    _fireStore.collection("UserData").doc(userId).update({
      'workoutPrograms': FieldValue.arrayUnion([
        _dataArray,
      ])
    });
  }

  void updatePrograms() {
    print("Updated");
    print("Old program: $_oldProgram");
    _fireStore.collection("UserData").doc(userId).update({
      'workoutPrograms': FieldValue.arrayRemove([
        _oldProgram,
      ])
    }).then((_) {
      print("Tried to remove old program");
      _fireStore.collection("UserData").doc(userId).update({
        'workoutPrograms': FieldValue.arrayUnion([
          _dataArray,
        ]),
      });
    });
  }

  void getData() {
    if (widget.programs.isNotEmpty) {
      print("Loading data");
      if (_oldProgram.isEmpty) {
        print("Loading old program");
        _oldProgram = widget.programs[widget.workoutNumber];
        print("Loading... $_oldProgram");
      }
      _dataArray = widget.programs[widget.workoutNumber];
      _exercises = widget.programs[widget.workoutNumber]['exercises'];
      _formCount = _exercises.length;
      _programController.text = _dataArray['name'];
      _isCardio = _dataArray['isCardio'];
      _title = "Rediger program";
      _editing = true;
    }
  }
}
