import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
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
  num displayGoalOkter = 99;
  num _goal = 99;

  var _name = "Name";
  var _username = "UserName";

  Timestamp _endDate = Timestamp.fromDate(DateTime.utc(2022, 12, 31));
  Timestamp _lastWorkout = Timestamp.now();
  late DateTime date = DateTime.now();

  final TextEditingController _okterController = TextEditingController();
  final TextEditingController _okterGoalController = TextEditingController();

  @override
  void initState() {
    //super.initState();
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    print("User ID: $userId");
    //userId = Provider.of(context).auth.getCurrentUID();
    ref = FirebaseDatabase.instance.ref("UserData");
  }

  Future<void> initOkter() async {
    var childRef = ref.child(userId);
    DatabaseEvent event = await childRef.once();
    if (!mounted) return;
    setState(() {
      displayOkter = event.snapshot.value as num;
    });
  }

  Future<void> increaseOkter() async {
    final ref = FirebaseDatabase.instance.ref("UserData").child(userId);
    try {
      if (!mounted) return;
      final docRef =
          FirebaseFirestore.instance.collection("UserData").doc(userId);
      await docRef.update({
        'lastWorkout': Timestamp.now(),
      });
      ref.set(displayOkter + 1);
      DatabaseEvent event = await ref.once();
      setState(() {
        displayOkter = event.snapshot.value as num;
      });
    } on FirebaseException catch (e) {
      print(e);
    }
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
        });
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> decreaseOkter() async {
    final ref = FirebaseDatabase.instance.ref("UserData").child(userId);
    ref.set(displayOkter - 1);
    DatabaseEvent event = await ref.once();
    if (!mounted) return;
    setState(() {
      displayOkter = event.snapshot.value as num;
    });
  }

  @override
  Widget build(BuildContext context) {
    initState();
    getUserData();
    initOkter();
    return okterDrawerScaffold(
        context,
        _name,
        _username,
        Column(children: [
          const SizedBox(height: 120),
          const Text("Økter i år:",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          //firestoreFutureBuilder("name", TextStyle(fontSize: 20)),
          Row(
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  decreaseOkter();
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
                  increaseOkter();
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
          content: numInputField(_okterController, "Skriv antall økter"),
          actions: [TextButton(onPressed: submit, child: const Text("Submit"))],
        ),
      );

  void submit() async {
    final ref = FirebaseDatabase.instance.ref("UserData").child(userId);
    var okterNum = int.parse(_okterController.text);
    ref.set(okterNum);
    DatabaseEvent event = await ref.once();
    if (!mounted) return;
    setState(() {
      displayOkter = event.snapshot.value as num;
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

  Future openGoalDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Mål"),
          content: numInputField(
              _okterGoalController, "Skriv antall økter du ønsker å nå"),
          actions: [
            TextButton(onPressed: submitGoal, child: const Text("Submit"))
          ],
        ),
      );

  void openDatePicker() {
    showDatePicker(
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
