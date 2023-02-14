import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:okter/color_utils.dart';
import 'package:okter/reusable_widgets.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  var _name = "Name";
  var _username = "UserName";
  var profileUrl = "";
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
  }

  Future<void> getUserData() async {
    final docRef =
        FirebaseFirestore.instance.collection("UserData").doc(userId);
    try {
      docRef.get().then((DocumentSnapshot doc) {
        if (!mounted) return;
        setState(() {
          _name = doc.get("name");
          _username = doc.get("username");
          _lastWorkout = doc.get("lastWorkout");
          _goal = doc.get("goal");
          _endDate = doc.get("endDate");
          displayOkter = doc.get("workouts");
          profileUrl = doc.get("profileImage");
          _isLoaded = true;
        });
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    initState();
    getUserData();
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
                },
                icon: const Icon(Icons.remove),
                iconSize: 30,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                onPressed: () {
                  increaseWorkouts();
                },
                icon: const Icon(Icons.add),
                iconSize: 30,
                color: Color.fromARGB(255, 255, 255, 255),
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
                  openDatePicker();
                },
                child: Text(
                  DateFormat.yMMMEd().format(_lastWorkout.toDate()).toString(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: Color.fromARGB(255, 93, 87, 168)),
                ),
              ),
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
              openEndDatePicker();
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
    });
  }

  void decreaseWorkouts() async {
    FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      'workouts': displayOkter - 1,
    });
  }

  Future openGoalDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Mål"),
          backgroundColor: hexStringtoColor("041416"),
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

  void openDatePicker() {
    showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: hexStringtoColor("041416"), // <-- SEE HERE
              onPrimary: Colors.white, // <-- SEE HERE
              onSurface: Colors.white, // <-- SEE HERE
            ),
            dialogBackgroundColor: Colors.black,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.white, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((value) {
      _lastWorkout = Timestamp.fromDate(value!);
      FirebaseFirestore.instance.collection("UserData").doc(userId).update({
        'lastWorkout': _lastWorkout,
      });
    });
  }

  void openEndDatePicker() {
    showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: hexStringtoColor("041416"), // <-- SEE HERE
              onPrimary: Colors.white, // <-- SEE HERE
              onSurface: Colors.white, // <-- SEE HERE
            ),
            dialogBackgroundColor: Colors.black,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.white, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    ).then((value) {
      _endDate = Timestamp.fromDate(value!);
      FirebaseFirestore.instance.collection("UserData").doc(userId).update({
        'endDate': _endDate,
      });
    });
  }

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
