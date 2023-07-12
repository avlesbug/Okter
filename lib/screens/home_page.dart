import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:okter/color_utils.dart';
import 'package:okter/reusable_widgets.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  late CollectionReference users;
  late String userId;
  late DatabaseReference ref;

  num displayOkter = 0;
  num displayGoalOkter = 0;
  num _goal = 0;
  num _workout = 0;
  List<dynamic> _workouts = [];
  List<dynamic> _programs = [];

  bool _isLoaded = false;

  Timestamp _endDate = Timestamp.fromDate(DateTime.utc(2022, 12, 31));
  Timestamp _lastWorkout = Timestamp.now();
  late DateTime date = DateTime.now();

  final TextEditingController _okterController = TextEditingController();
  final TextEditingController _okterGoalController = TextEditingController();

  @override
  void initState() {
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    getUserData();
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

      final userData = docSnapshot.data() as Map<String, dynamic>;
      //final workoutData =
      //    workoutDocRef.docs.first.data() as Map<String, dynamic>;

      setState(() {
        _goal = userData['goal'];
        _endDate = userData['endDate'] ??
            Timestamp.fromDate(DateTime.utc(2023, 12, 31));
        displayOkter = userData['workouts'];
        _isLoaded = true;

        try {
          _workouts = userData['detailedWorkouts'] as List<dynamic>;
          _workouts.sort((a, b) => b['date'].compareTo(a['date']));
        } catch (e) {
          print(e);
        }

        try {
          _programs = userData['workoutPrograms'] as List<dynamic>;
        } catch (e) {
          print(e);
        }
      });
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    initState();
    //initOkter();
    return okterDrawerScaffold(
        context,
        Column(children: [
          const SizedBox(height: 100),
          const Text("Økter i år:",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          //firestoreFutureBuilder("name", TextStyle(fontSize: 20)),
          _isLoaded
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onLongPress: () {
                          openDialog();
                        },
                        child: Text(displayOkter.toString() + " / ",
                            style: const TextStyle(
                                fontSize: 30,
                                color: Color.fromARGB(255, 255, 255, 255)))),
                    GestureDetector(
                        onLongPress: () {
                          openGoalDialog();
                        },
                        child: Text("$_goal",
                            style: const TextStyle(
                                color: Color.fromARGB(255, 93, 87, 168),
                                fontSize: 30,
                                fontWeight: FontWeight.w300))),
                  ],
                )
              : CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 93, 87, 168)),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  decreaseWorkouts();
                  //getLastWorkout();
                },
                icon: const Icon(Icons.remove),
                iconSize: 30,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              const SizedBox(
                width: 20,
              ),
              GestureDetector(
                onLongPress: () {
                  workoutProgramDialog();
                },
                child: IconButton(
                  onPressed: () {
                    increaseWorkouts();
                    //getLastWorkout();
                  },
                  icon: const Icon(Icons.add),
                  iconSize: 30,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Siste økt: ",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255)),
              ),
              GestureDetector(
                  onLongPress: () {
                    //openDatePicker();
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(2000, 1, 1),
                        maxTime: DateTime(2010, 1, 1),
                        theme: DatePickerTheme(
                            headerColor: Color(0xFF020A0B),
                            backgroundColor: Color(0xFF020A0B),
                            itemStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                            doneStyle:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        onChanged: (date) {
                      //print('change $date');
                    }, onConfirm: (date) {
                      setLastWorkout(date);
                    }, currentTime: DateTime.now(), locale: LocaleType.no);
                  },
                  child: _workouts.length > 0
                      ? Text(
                          DateFormat.yMMMEd()
                                  .format(_workouts[0]["date"].toDate())
                                  .toString() +
                              ", " +
                              DateFormat.Hm()
                                  .format(_workouts[0]["date"].toDate())
                                  .toString(),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                              color: Color.fromARGB(255, 93, 87, 168)),
                        )
                      : Text(
                          "N/A" + ", " + "N/A",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                              color: Color.fromARGB(255, 93, 87, 168)),
                        )),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          _buildElevationDoughnutChart(displayOkter, _goal),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onLongPress: () {
              //openEndDatePicker();
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(2000, 1, 1),
                  maxTime: DateTime(DateTime.now().year + 10, 12, 31),
                  theme: DatePickerTheme(
                      headerColor: Color(0xFF020A0B),
                      backgroundColor: Color(0xFF020A0B),
                      itemStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      doneStyle: TextStyle(color: Colors.white, fontSize: 16)),
                  onChanged: (date) {
                print('change $date');
              }, onConfirm: (date) {
                FirebaseFirestore.instance
                    .collection("UserData")
                    .doc(userId)
                    .update({
                  'endDate': date,
                });
              }, currentTime: DateTime.now(), locale: LocaleType.no);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: RichText(
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text: "For å nå ${_goal} økter innen ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: DateFormat.yMMMEd()
                              .format(_endDate.toDate())
                              .toString()),
                      TextSpan(
                          text: " må du trene " +
                              ((_goal - displayOkter) / getWeeksLeft())
                                  .toStringAsFixed(1) +
                              " ganger i uken, eller ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: ((_goal - displayOkter) / getDaysLeft())
                                  .toStringAsFixed(1) +
                              " ganger per dag",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
              ),
            ),
          )
        ]));
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Økter"),
          backgroundColor: hexStringtoColor("041416"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.0)),
          content: numInputField(_okterController, "Skriv antall økter"),
          actions: [
            TextButton(
                onPressed: submit,
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      );

  void submit() async {
    var okterNum = int.parse(_okterController.text);
    FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      'workouts': okterNum,
    });
    final docRef =
        FirebaseFirestore.instance.collection("UserData").doc(userId);
    docRef.get().then(
      (DocumentSnapshot doc) {
        _workout = doc.get("workouts");
      },
    );
    setState(() {
      displayOkter = _workout;
    });
    Navigator.pop(context);
  }

  void submitGoal() async {
    var okterNum = int.parse(_okterGoalController.text);
    FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      'goal': okterNum,
    });
    final docRef =
        FirebaseFirestore.instance.collection("UserData").doc(userId);
    docRef.get().then(
      (DocumentSnapshot doc) {
        _goal = doc.get("goal");
      },
    );
    setState(() {
      displayGoalOkter = _goal;
    });
    Navigator.pop(context);
  }

  void increaseWorkouts() async {
    FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      'workouts': displayOkter + 1,
      'lastWorkout': Timestamp.now(),
      'detailedWorkouts': FieldValue.arrayUnion([
        {'date': Timestamp.now(), 'workoutProgram': "Annen aktivitet"}
      ])
    });
  }

  void increaseDetailedWorkouts(program) async {
    FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      'workouts': displayOkter + 1,
      'lastWorkout': Timestamp.now(),
      'detailedWorkouts': FieldValue.arrayUnion([
        {'date': Timestamp.now(), 'workoutProgram': program}
      ])
    });
  }

  void decreaseWorkouts() async {
    FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      'workouts': displayOkter - 1,
      if (_workouts.length > 0)
        'detailedWorkouts': FieldValue.arrayRemove([
          _workouts[0],
        ])
    });
  }

  void setLastWorkout(DateTime date) async {
    print(date);
    var tempWorkout = _workouts[0];
    _workouts[0]["date"] = Timestamp.fromDate(date);
    FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      'detailedWorkouts': _workouts,
    });
  }

  Future openGoalDialog() => showDialog(
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
                onPressed: submitGoal,
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      );

  num getDaysLeft() {
    var now = DateTime.now();
    var end = _endDate.toDate();
    var difference = end.difference(now).inDays;
    return difference;
  }

  num getWeeksLeft() {
    var now = DateTime.now();
    var end = _endDate.toDate();
    var difference = end.difference(now).inDays;
    return difference / 7;
  }

  Future workoutProgramDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("Treningsprogram"),
            backgroundColor: hexStringtoColor("041416"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26.0)),
            content: Container(
              height: 100,
              width: 300,
              child: ListView.builder(
                itemCount: _programs.length,
                itemBuilder: (context, index) {
                  if (_programs.length > 0) {
                    return TextButton(
                        onPressed: () {
                          increaseDetailedWorkouts(
                              _programs[index]["name"].toString());
                          Navigator.pop(context);
                        },
                        child: Text(
                          _programs[index]["name"].toString(),
                          style: TextStyle(color: Colors.white),
                        ));
                  } else {
                    return Text("Ingen treningsprogrammer tilgjengelig");
                  }
                },
              ),
            ),
          ));
}

SfCircularChart _buildElevationDoughnutChart(okter, goal) {
  return SfCircularChart(
    /// It used to set the annotation on circular chart.
    annotations: <CircularChartAnnotation>[
      CircularChartAnnotation(
          height: '100%',
          width: '100%',
          widget: PhysicalModel(
            shape: BoxShape.circle,
            elevation: 10,
            color: const Color.fromRGBO(225, 225, 225, 1),
            child: Container(),
          )),
      CircularChartAnnotation(
          widget: Text(((okter / goal) * 100).toStringAsFixed(1) + "%",
              style: const TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 0.5), fontSize: 25))),
    ],
    title: ChartTitle(
        text: false ? '' : 'Fremgang',
        textStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
        )),
    series: _getElevationDoughnutSeries(okter, goal),
  );
}

List<DoughnutSeries<ChartSampleData, String>> _getElevationDoughnutSeries(
    num okter, num goal) {
  //print(goal);
  return <DoughnutSeries<ChartSampleData, String>>[
    DoughnutSeries<ChartSampleData, String>(
        dataSource: <ChartSampleData>[
          ChartSampleData(
              x: 'A',
              y: (okter / goal) * 100,
              pointColor: const Color.fromARGB(255, 32, 30, 58)),
          ChartSampleData(
              x: 'B',
              y: 100 - ((okter / goal) * 100),
              pointColor: const Color.fromARGB(255, 98, 141, 144))
        ],
        animationDuration: 0,
        xValueMapper: (ChartSampleData data, _) => data.x as String,
        yValueMapper: (ChartSampleData data, _) => data.y,
        pointColorMapper: (ChartSampleData data, _) => data.pointColor)
  ];
}

class ChartSampleData {
  ChartSampleData({this.x, this.y, this.pointColor});
  final String? x;
  final double? y;
  final Color? pointColor;
}
