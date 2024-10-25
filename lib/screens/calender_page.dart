import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dt_picker;
import 'package:flutter_picker/flutter_picker.dart';
import 'package:intl/intl.dart';
import 'package:okter/basePage.dart';
import 'package:okter/utils/reusable_widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

import '../utils/color_pallet.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  late CollectionReference users;
  late String userId;
  late var snapshot;
  var uuid = Uuid();

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  var _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _selectedEvents = [];
  var _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    snapshot = FirebaseFirestore.instance
        .collection('UserData')
        .doc(userId)
        .snapshots();
  }

  List<String> getNames(var workoutPrograms) {
    List<String> programNames = [];
    for (int i = 0; i < workoutPrograms.length; i++) {
      programNames.add(workoutPrograms[i]['name']);
    }
    programNames.add("Annen aktivitet");
    programNames.add("Styrketrening");
    programNames.add("Kardio");
    programNames.add("Fjelltur");
    programNames.add("Gåtur");
    return programNames;
  }

  List<String> programNames = [
    "Annen aktivitet",
    "Styrketrening",
    "Kardio",
    "Fjelltur"
  ];

  CalendarStyle customCalendarStyle = CalendarStyle(
    outsideDaysVisible: false,
    selectedTextStyle: TextStyle(color: themeColorPallet['grey dark']),
    todayTextStyle: TextStyle(color: themeColorPallet['grey dark']),
    markerDecoration: BoxDecoration(
      shape: BoxShape.circle,
      color: themeColorPallet['green'],
    ),
    todayDecoration: BoxDecoration(
      shape: BoxShape.circle,
      color: themeColorPallet['yellow light'],
    ),
    selectedDecoration: BoxDecoration(
      shape: BoxShape.circle,
      color: themeColorPallet['yellow'],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return okterAddButtonScaffold(
      name: "Kalender",
      bottomNavigation: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.expand_more),
            label: 'Tilbake',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Legg til',
          ),
        ],
        currentIndex: 0,
        backgroundColor: themeColorPallet['grey dark'],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pop();
          } else {
            showPicker();
          }
        },
      ),
      context: context,
      leading: Icon(Icons.calendar_month),
      bodyContent: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('UserData')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              programNames = getNames(snapshot.data!['workoutPrograms']);
            }
            return snapshot.hasData
                ? Column(
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
                            _focusedDay = focusedDay;
                            _selectedEvents = _getEventsForDay(selectedDay,
                                snapshot.data!['detailedWorkouts']);
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        eventLoader: (day) {
                          return _getEventsForDay(
                              day, snapshot.data!['detailedWorkouts']);
                        },
                        calendarStyle: customCalendarStyle,
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
                                    child: ListTile(
                                        tileColor:
                                            themeColorPallet['grey light'],
                                        leading: getIcon(_selectedEvents[index]
                                                ['workoutProgram']
                                            .toString()),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        title: Text(
                                            '${DateFormat.Hm().format(_selectedEvents[index]['date']).toString()} - ${_selectedEvents[index]['workoutProgram'].toString()}'),
                                        onLongPress: () {
                                          workoutProgramDialog(
                                              _selectedEvents[index]);
                                        }),
                                  ),
                                );
                              })),
                        ),
                      )
                    ],
                  )
                : loadingComponent();
          }),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(
      DateTime day, List<dynamic> detailedWorkouts) {
    List<Map<String, dynamic>> events = [];
    DateTime calenderDay = DateTime.parse(day.toString().replaceAll('Z', ''));
    DateTime nextDay = calenderDay.add(const Duration(days: 1));

    for (int i = 0; i < detailedWorkouts.length; i++) {
      if (detailedWorkouts[i]["date"].toDate().isAfter(calenderDay) &&
          detailedWorkouts[i]["date"].toDate().isBefore(nextDay)) {
        events.add({
          'id': detailedWorkouts[i]["id"] ?? "",
          'date': detailedWorkouts[i]["date"].toDate(),
          'workoutProgram': detailedWorkouts[i]["workoutProgram"]
        });
      }
    }
    return events;
  }

  void addWorkout(DateTime time, String selectedProgram) {
    DateTime workoutTime = DateTime(_selectedDay.year, _selectedDay.month,
        _selectedDay.day, time.hour, time.minute);

    FirebaseFirestore.instance
        .collection("UserData")
        .doc(userId)
        .get()
        .then((value) {
      FirebaseFirestore.instance.collection("UserData").doc(userId).update({
        'workouts': value['workouts'] + 1,
        'detailedWorkouts': FieldValue.arrayUnion([
          {
            'id': uuid.v1(),
            'date': workoutTime,
            'workoutProgram': selectedProgram
          }
        ])
      });
    });
  }

  Future workoutProgramDialog(workout) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Center(child: Text(workout["workoutProgram"])),
            backgroundColor: themeColorPallet['grey dark'],
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
                              themeColorPallet['green']!),
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
    FirebaseFirestore.instance
        .collection("UserData")
        .doc(userId)
        .get()
        .then((value) {
      FirebaseFirestore.instance.collection("UserData").doc(userId).update({
        'workouts': value['workouts'] - 1,
        'detailedWorkouts': FieldValue.arrayRemove([workout])
      });
    });
  }

  void showPicker() {
    print("showPicker called");
    dt_picker.DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      currentTime: DateTime.now(),
      theme: dt_picker.DatePickerTheme(
          headerColor: themeColorPallet['grey dark'],
          backgroundColor: themeColorPallet['grey dark'] ?? Color(0xFF141213),
          itemStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          doneStyle: TextStyle(color: Colors.white, fontSize: 16),
          cancelStyle: TextStyle(color: Colors.white, fontSize: 16)),
      onConfirm: (time) {
        print("Time selected: $time");
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Builder(
              builder: (BuildContext context) {
                return Picker(
                  adapter: PickerDataAdapter<String>(pickerData: programNames),
                  changeToFirst: false,
                  containerColor: themeColorPallet['grey dark'],
                  headerColor: themeColorPallet['grey dark'],
                  backgroundColor: themeColorPallet['grey dark'],
                  textAlign: TextAlign.left,
                  textStyle: const TextStyle(color: Colors.white, fontSize: 20),
                  columnPadding: const EdgeInsets.all(8.0),
                  confirmText: "Lagre",
                  cancelText: "Tilbake",
                  confirmTextStyle: const TextStyle(color: Colors.white),
                  cancelTextStyle: const TextStyle(color: Colors.white),
                  onCancel: () {
                    showPicker();
                  },
                  onConfirm: (Picker picker, List value) {
                    print("Picker confirmed");
                    String selectedProgram = picker.getSelectedValues()[0];
                    addWorkout(time, selectedProgram);
                  },
                ).makePicker();
              },
            );
          },
        );
      },
    );
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
