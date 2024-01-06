import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:intl/intl.dart';
import 'package:okter/basePage.dart';
import 'package:table_calendar/table_calendar.dart';


class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  late CollectionReference users;
  late String userId;

  List<dynamic> _workouts = [];
  List<dynamic> _programs = [];
  final List<dynamic> _programNames = [];
  final Map<DateTime, dynamic> _workoutMap = {};
  var _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _selectedEvents = [];
  var _selectedDay = DateTime.now();

  @override
  void initState() {
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    getUserData();
    getNames();
    //print(_workoutMap);
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
          _workouts = doc["detailedWorkouts"] as List<dynamic>;
          _programs = doc["workoutPrograms"] as List<dynamic>;
        });
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  List<String> getNames() {
    List<String> programNames = [];
    for (int i = 0; i < _programs.length; i++) {
      programNames.add(_programs[i]['name']);
    }
    programNames.add("Annen aktivitet");
    programNames.add("Styrketrening");
    programNames.add("Kardio");
    programNames.add("Fjelltur");
    programNames.add("Gåtur");
    return programNames;
  }

  @override
  Widget build(BuildContext context) {
    initState();
    //print(_workoutMap);
    return okterAddButtonScaffold(
      "Kalender",
      [
        Builder(builder: (BuildContext context) {
          return IconButton(
              onPressed: () {
                /*
                DatePickerDialog(
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000,1,1),
                          lastDate: DateTime.now(),
                        );
                  */
                DatePicker.showTimePicker(
                  context,
                  showTitleActions: true,
                  currentTime: DateTime.now(),
                  theme: const DatePickerTheme(
                    headerColor: Color(0xFF020A0B),
                    backgroundColor: Color(0xFF020A0B),
                    itemStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    doneStyle: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onConfirm: (time) {
                    showPicker(context, time);
                  },
                );
                  
              },
              icon: const Icon(Icons.add));
        })
      ],
      context,
      Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2000, 1, 1),
            lastDay: DateTime(2100, 1, 1),
            weekNumbersVisible: true,
            pageJumpingEnabled: true,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update `_focusedDay` here as well
                _selectedEvents = _getEventsForDay(selectedDay);
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _getEventsForDay(day);
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: SizedBox(
              height: 600,
              width: 500,
              child: ListView.builder(
                  itemCount: _selectedEvents.length,
                  itemBuilder: ((context, index) {
                    return Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Dismissible(
                          key: UniqueKey(),
                          onDismissed: (direction) {
                            deleteWorkout(_selectedEvents[index]);
                            setState(() {
                              _selectedEvents.removeAt(index);
                            });
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
                          child: ListTile(
                              tileColor: const Color(0xFF031011),
                              leading: getIcon(_selectedEvents[index]
                                      ['workoutProgram']
                                  .toString()),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              title: Text(
                                  '${DateFormat.Hm().format(_selectedEvents[index]['date']).toString()} - ${_selectedEvents[index]['workoutProgram'].toString()}'),
                              onTap: () {
                                workoutProgramDialog(_selectedEvents[index]);
                              }),
                        ),
                      ),
                    );
                  })),
            ),
          )
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    List<Map<String, dynamic>> events = [];
    DateTime calenderDay = DateTime.parse(day.toString().replaceAll('Z', ''));
    DateTime nextDay = calenderDay.add(const Duration(days: 1));

    for (int i = 0; i < _workouts.length; i++) {
      if (_workouts[i]["date"].toDate().isAfter(calenderDay) &&
          _workouts[i]["date"].toDate().isBefore(nextDay)) {
        String formattedTime =
            DateFormat.Hm().format(_workouts[i]["date"].toDate());
        //events.add(formattedTime + " - " + _workouts[i]["workoutProgram"]);
        events.add({
          'date': _workouts[i]["date"].toDate(),
          'workoutProgram': _workouts[i]["workoutProgram"]
        });
      }
    }

    //events.add(_workoutMap[day]!);
    return events;
  }

  List<String> _getEventsForDayAsString(DateTime day) {
    List<String> events = [];
    DateTime calenderDay = DateTime.parse(day.toString().replaceAll('Z', ''));
    DateTime nextDay = calenderDay.add(const Duration(days: 1));

    for (int i = 0; i < _workouts.length; i++) {
      if (_workouts[i]["date"].toDate().isAfter(calenderDay) &&
          _workouts[i]["date"].toDate().isBefore(nextDay)) {
        String formattedTime =
            DateFormat.Hm().format(_workouts[i]["date"].toDate());
        events.add(formattedTime + " - " + _workouts[i]["workoutProgram"]);
      }
    }

    //events.add(_workoutMap[day]!);
    return events;
  }

  void addWorkout(DateTime time, String selectedProgram) {
    DateTime workoutTime = DateTime(_selectedDay.year, _selectedDay.month,
        _selectedDay.day, time.hour, time.minute);
    FirebaseFirestore.instance.collection('UserData').doc(userId).update({
      'detailedWorkouts': FieldValue.arrayUnion([
        {'date': workoutTime, 'workoutProgram': selectedProgram}
      ])
    });
  }

  Future workoutProgramDialog(workout) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Center(child: Text(workout["workoutProgram"])),
            backgroundColor: const Color(0xFF041416),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26.0)),
            content: SizedBox(
                height: 70,
                width: 200,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                      onPressed: () {
                        deleteWorkout(workout);
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 7, 34, 38)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0)))),
                      child: const Text(
                        "Slett økt",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )),
                )),
          ));

  void deleteWorkout(workout) {
    print("Deleting workout: " + workout.toString());
    FirebaseFirestore.instance.collection('UserData').doc(userId).update({
      'detailedWorkouts': FieldValue.arrayRemove([workout])
    });
  }

  showPicker(BuildContext context, DateTime time) async {
    Picker picker = Picker(
        adapter: PickerDataAdapter<String>(pickerData: getNames()),
        changeToFirst: false,
        containerColor: const Color(0xFF020A0B),
        headerColor: const Color(0xFF020A0B),
        backgroundColor: const Color(0xFF020A0B),
        textAlign: TextAlign.left,
        textStyle: const TextStyle(color: Colors.white, fontSize: 20),
        columnPadding: const EdgeInsets.all(8.0),
        confirmText: "Lagre",
        cancelText: "Tilbake",
        confirmTextStyle: const TextStyle(color: Colors.white),
        cancelTextStyle: const TextStyle(color: Colors.white),
        onCancel: () {
          /*
          DatePickerDialog(
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000,1,1),
                          lastDate: DateTime.now(),
                        );
            */
          DatePicker.showTimePicker(
            context,
            showTitleActions: true,
            currentTime: DateTime.now(),
            theme: const DatePickerTheme(
              headerColor: Color(0xFF020A0B),
              backgroundColor: Color(0xFF020A0B),
              itemStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              doneStyle: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onConfirm: (time) {
              showPicker(context, time);
              //addWorkout(time);
            },
          );
        },
        onConfirm: (Picker picker, List value) {
          String selectedProgram = picker.getSelectedValues()[0];
          addWorkout(time, selectedProgram);
          //print(value.toString());
          print(picker.getSelectedValues()[0]);
            
        });
    picker.showBottomSheet(context);
  }

  Icon getIcon(String workoutProgram) {
    if (workoutProgram == "Annen aktivitet") {
      return const Icon(
        Icons.hiking,
        color: Colors.white,
      );
    } else if (workoutProgram == "Kardio") {
      return const Icon(
        Icons.directions_run,
        color: Colors.white,
      );
    } else {
      return const Icon(
        Icons.fitness_center,
        color: Colors.white,
      );
    }
  }
}
