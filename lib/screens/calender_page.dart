import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:intl/intl.dart';
import 'package:okter/basePage.dart';
import 'package:okter/utils/reusable_widgets.dart';
import 'package:table_calendar/table_calendar.dart';


class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  late CollectionReference users;
  late String userId;

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //List<dynamic> _programs = [];
  var _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _selectedEvents = [];
  var _selectedDay = DateTime.now();

  @override
  void initState() {
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
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

  @override
  Widget build(BuildContext context) {
    initState();
    return okterAddButtonScaffold(
      "Kalender",
      [
       StreamBuilder(
          stream: FirebaseFirestore.instance.collection('UserData').doc(userId).snapshots(),
          builder: (context, snapshot) {
            return Builder(builder: (BuildContext context) {
              return IconButton(
                  onPressed: () {
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
                        showPicker(context, time, snapshot);
                      },
                    );
                      
                  },
                  icon: const Icon(Icons.add));
            });
          }
        )
      ],
      context,
     StreamBuilder(
          stream: FirebaseFirestore.instance.collection('UserData').doc(userId).snapshots(),
          builder: (context, snapshot) {
            return 
            snapshot.hasData ?
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
                    _selectedEvents = _getEventsForDay(selectedDay, snapshot.data!['detailedWorkouts']);
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) {
                  return _getEventsForDay(day,snapshot.data!['detailedWorkouts']);
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
                                onLongPress: () {
                                  workoutProgramDialog(_selectedEvents[index]);
                                }),
                          ),
                        );
                      })),
                ),
              )
            ],
          ):
          loadingComponent();
        }
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day, List<dynamic> detailedWorkouts) {
    List<Map<String, dynamic>> events = [];
    DateTime calenderDay = DateTime.parse(day.toString().replaceAll('Z', ''));
    DateTime nextDay = calenderDay.add(const Duration(days: 1));

    for (int i = 0; i < detailedWorkouts.length; i++) {
      if (detailedWorkouts[i]["date"].toDate().isAfter(calenderDay) &&
          detailedWorkouts[i]["date"].toDate().isBefore(nextDay)) {
        events.add({
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

  showPicker(BuildContext context, DateTime time, var snapshot) async {
    Picker picker = Picker(
        adapter: PickerDataAdapter<String>(pickerData: getNames(snapshot.data!['workoutPrograms'])),
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
              //showPicker(context, time);
              //addWorkout(time);
            },
          );
        },
        onConfirm: (Picker picker, List value) {
          String selectedProgram = picker.getSelectedValues()[0];
          addWorkout(time, selectedProgram);

            
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
