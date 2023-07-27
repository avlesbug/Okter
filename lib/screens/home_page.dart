import 'dart:core';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Map<String, dynamic> _workoutsByDay = {};
  Map<String, dynamic> _workoutsByProgram = {};
  var _yearProgress;
  var _maxValueDay;
  var _dayInterval;
  var height = 667;
  var width = 375;

  List<Color> colorPallet = [
    Color.fromRGBO(75, 135, 185, 1),
    Color.fromRGBO(192, 108, 132, 1),
    Color.fromRGBO(246, 114, 128, 1),
    Color.fromRGBO(248, 177, 149, 1),
    Color.fromRGBO(116, 180, 155, 1),
    Color.fromRGBO(0, 168, 181, 1),
    Color.fromRGBO(73, 76, 162, 1),
    Color.fromRGBO(255, 205, 96, 1),
    Color.fromRGBO(255, 240, 219, 1),
    Color.fromRGBO(238, 238, 238, 1)
  ];

  bool _isLoaded = false;

  List<WorkoutData> workoutData = [];

  Timestamp _endDate = Timestamp.fromDate(DateTime.utc(2022, 12, 31));
  final Timestamp _lastWorkout = Timestamp.now();
  late DateTime date = DateTime.now();
  bool displayYearProg = false;

  final TextEditingController _okterController = TextEditingController();
  final TextEditingController _okterGoalController = TextEditingController();

  @override
  void initState() {
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    getUserData();
    _maxValueDay = getMaxWorkouts(_workoutsByDay);
    _dayInterval = (_maxValueDay / 10).toInt().toDouble();
  }

  void updateChartData() {
    setState(() {
      if (workoutData.length == 2) {
        workoutData[1] = WorkoutData(
            num.parse(((displayOkter / _goal) * 100).toStringAsFixed(2)),
            "Meg",
            Color.fromARGB(255, 93, 87, 168));
      }
    });
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

        Duration totalDays =
            DateTime(DateTime.now().year, 1, 1).difference(_endDate.toDate());
        Duration periodeProgresion =
            DateTime(DateTime.now().year, 1, 1).difference(DateTime.now());

        _yearProgress = num.parse(
            ((periodeProgresion.inDays / totalDays.inDays) * 100)
                .toStringAsFixed(1));
        if (workoutData.length < 2) {
          workoutData.add(WorkoutData(
              _yearProgress, "År", Color.fromARGB(255, 87, 117, 168)));

          workoutData.add(WorkoutData(
              num.parse(((displayOkter / _goal) * 100).toStringAsFixed(2)),
              "Meg",
              Color.fromARGB(255, 93, 87, 168)));
        }

        try {
          _workouts = userData['detailedWorkouts'] as List<dynamic>;
          _workouts.sort((a, b) => b['date'].compareTo(a['date']));
          _workoutsByDay = workoutsPerDay();
          _workoutsByProgram = workoutsByProgram();
        } catch (e) {
          print(e);
        }

        try {
          _programs = userData['workoutPrograms'] as List<dynamic>;
          _programs.add({
            'name': 'Styrketrening',
            'isCardio': false,
          });
          _programs.add({
            'name': 'Løping',
            'isCardio': true,
          });
          _programs.add({
            'name': 'Fjelltur',
            'isCardio': false,
          });
          _programs.add({
            'name': 'Gåtur',
            'isCardio': false,
          });
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
    height = MediaQuery.of(context).size.height.toInt();
    width = MediaQuery.of(context).size.width.toInt();
    //initOkter();
    return okterDrawerScaffold(
        context,
        Column(children: [
          SizedBox(height: height * 0.1),
          SizedBox(
            height: height * 0.03,
            width: width * 0.36,
            child: const FittedBox(
              fit: BoxFit.fitWidth,
              child: Text("Økter i år:",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          //firestoreFutureBuilder("name", TextStyle(fontSize: 20)),
          _isLoaded
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width * 0.2,
                      height: height * 0.1,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: GestureDetector(
                            onLongPress: () {
                              openDialog();
                            },
                            child: Text("$displayOkter / ",
                                style: TextStyle(
                                    color:
                                        Color.fromARGB(255, 255, 255, 255)))),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.14,
                      height: height * 0.1,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: GestureDetector(
                            onLongPress: () {
                              openGoalDialog();
                            },
                            child: Text("$_goal",
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 93, 87, 168),
                                    fontWeight: FontWeight.w300))),
                      ),
                    ),
                  ],
                )
              : const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 93, 87, 168)),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.15,
                height: height * 0.04,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: IconButton(
                    onPressed: () {
                      decreaseWorkouts();
                      updateChartData();
                      //getLastWorkout();
                    },
                    icon: const Icon(Icons.remove),
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.05,
              ),
              SizedBox(
                width: width * 0.15,
                height: height * 0.04,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: GestureDetector(
                    onLongPress: () {
                      workoutProgramDialog();
                    },
                    child: IconButton(
                      onPressed: () {
                        increaseWorkouts();
                        updateChartData();
                        //getLastWorkout();
                      },
                      icon: const Icon(Icons.add),
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.3,
                height: height * 0.1,
                child: const FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    "Siste økt: ",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.6,
                height: height * 0.1,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: GestureDetector(
                      onLongPress: () {
                        //openDatePicker();
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            minTime: DateTime(2000, 1, 1),
                            maxTime: DateTime(2010, 1, 1),
                            theme: const DatePickerTheme(
                                headerColor: Color(0xFF020A0B),
                                backgroundColor: Color(0xFF020A0B),
                                itemStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                                doneStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16)), onChanged: (date) {
                          //print('change $date');
                        }, onConfirm: (date) {
                          setLastWorkout(date);
                        }, currentTime: DateTime.now(), locale: LocaleType.no);
                      },
                      child: _workouts.isNotEmpty
                          ? Text(
                              "${DateFormat.yMMMEd().format(_workouts[0]["date"].toDate())}, ${DateFormat.Hm().format(_workouts[0]["date"].toDate())}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromARGB(255, 93, 87, 168)),
                            )
                          : const Text(
                              "N/A, N/A",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromARGB(255, 93, 87, 168)),
                            )),
                ),
              ),
            ],
          ),
          SizedBox(
            height: height * 0.36,
            width: width * 0.9,
            child: Center(
              child: CarouselSlider(
                  items: [
                    GestureDetector(
                      onTap: () {
                        displayYearProg = !displayYearProg;
                      },
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: SfCircularChart(
                          annotations: <CircularChartAnnotation>[
                            CircularChartAnnotation(
                              widget: !displayYearProg
                                  ? SizedBox(
                                      height: height * 0.032,
                                      width: width * 0.14,
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                            (("${((displayOkter / _goal) * 100).toStringAsFixed(0)}%")),
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ),
                                    )
                                  : SizedBox(
                                      height: height * 0.030,
                                      width: width * 0.17,
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                            "År: ${_yearProgress.toStringAsFixed(0)}%",
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ),
                                    ),
                            )
                          ],
                          title: ChartTitle(
                              text: 'Fremgang',
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              )),
                          margin: const EdgeInsets.all(28),
                          series: [
                            RadialBarSeries<WorkoutData, String>(
                              dataSource: workoutData,
                              xValueMapper: (WorkoutData data, _) =>
                                  data.workoutProgram,
                              yValueMapper: (WorkoutData data, _) =>
                                  data.workouts,
                              pointColorMapper: (WorkoutData data, _) =>
                                  data.color,
                              // Radius of the radial bar
                              radius: '100%',
                              cornerStyle: CornerStyle.bothCurve,
                              trackColor: Color(0xFF086c6a),
                              trackOpacity: 0.1,
                              maximumValue: 100,
                              gap: '3%',
                            )
                          ],
                        ),
                      ),
                    ),
                    SfCartesianChart(
                        title: ChartTitle(
                            text: 'Økter etter dag',
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            )),
                        margin: const EdgeInsets.all(44),
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum:
                              (_maxValueDay + 2 > 0) ? _maxValueDay + 2 : 50,
                          interval: (_dayInterval) > 0 ? _dayInterval : 10,
                        ),
                        series: <ChartSeries<WeekdayData, String>>[
                          ColumnSeries<WeekdayData, String>(
                            dataSource: createChartData(),
                            xValueMapper: (WeekdayData data, _) => data.weekday,
                            yValueMapper: (WeekdayData data, _) =>
                                data.workoutsOnDay,
                            borderRadius: BorderRadius.circular(15),
                            pointColorMapper: (WeekdayData data, _) =>
                                data.color,
                          )
                        ]),
                    SfCircularChart(
                      title: ChartTitle(
                          text: "Økter per kategori",
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          )),
                      margin: const EdgeInsets.all(30),
                      series: <CircularSeries>[
                        PieSeries<WorkoutData, String>(
                          dataSource: createProgamData(),
                          sortingOrder: SortingOrder.descending,
                          explodeIndex: 0,
                          explode: true,
                          xValueMapper: (WorkoutData data, _) =>
                              data.workoutProgram,
                          yValueMapper: (WorkoutData data, _) => data.workouts,
                          dataLabelMapper: (WorkoutData data, _) =>
                              data.workoutProgram,
                          pointColorMapper: (WorkoutData data, _) => data.color,
                          dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              showZeroValue: false,
                              labelPosition: ChartDataLabelPosition.outside,
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    )
                  ],
                  options: CarouselOptions(
                    height: 300,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.2,
                  )),
            ),
          ),
          SizedBox(
            height: height * 0.21,
            width: width * 0.8,
            child: Center(
              child: GestureDetector(
                onLongPress: () {
                  //openEndDatePicker();
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(2000, 1, 1),
                      maxTime: DateTime(DateTime.now().year + 10, 12, 31),
                      theme: const DatePickerTheme(
                          headerColor: Color(0xFF020A0B),
                          backgroundColor: Color(0xFF020A0B),
                          itemStyle: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          doneStyle:
                              TextStyle(color: Colors.white, fontSize: 16)),
                      onChanged: (date) {}, onConfirm: (date) {
                    FirebaseFirestore.instance
                        .collection("UserData")
                        .doc(userId)
                        .update({
                      'endDate': date,
                    });
                  }, currentTime: DateTime.now(), locale: LocaleType.no);
                },
                child: RichText(
                  text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: "For å nå $_goal økter innen ",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: DateFormat.yMMMEd()
                                .format(_endDate.toDate())
                                .toString()),
                        TextSpan(
                            text:
                                " må du trene ${((_goal - displayOkter) / getWeeksLeft()).toStringAsFixed(1)} ganger i uken, eller ",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text:
                                "${((_goal - displayOkter) / getDaysLeft()).toStringAsFixed(1)} ganger per dag",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                ),
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
        {'date': Timestamp.now(), 'workoutProgram': "Trening"}
      ])
    });

    setState(() {
      FirebaseFirestore.instance
          .collection("UserData")
          .doc(userId)
          .get()
          .then((value) {
        displayOkter = value['workouts'];
      });
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
      if (_workouts.isNotEmpty)
        'detailedWorkouts': FieldValue.arrayRemove([
          _workouts[0],
        ])
    });

    FirebaseFirestore.instance
        .collection("UserData")
        .doc(userId)
        .get()
        .then((value) {
      print(value['workouts']);
    });
  }

  void setLastWorkout(DateTime date) async {
    var tempWorkout = _workouts[0];
    _workouts[0]["date"] = Timestamp.fromDate(date);
    FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      'detailedWorkouts': _workouts,
    });
  }

  void loadWorkouts() async {
    final docRef =
        FirebaseFirestore.instance.collection("UserData").doc(userId);
    docRef.get().then(
      (DocumentSnapshot doc) {
        _workout = doc.get("workouts");
        _goal = doc.get("goal");
      },
    );
    setState(() {
      displayOkter = _workout;
      displayGoalOkter = _goal;
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
            content: SizedBox(
              height: 200,
              width: 300,
              child: ListView.builder(
                itemCount: _programs.length,
                itemBuilder: (context, index) {
                  if (_programs.isNotEmpty) {
                    return TextButton(
                        onPressed: () {
                          increaseDetailedWorkouts(
                              _programs[index]["name"].toString());
                          updateChartData();
                          Navigator.pop(context);
                        },
                        child: Text(
                          _programs[index]["name"].toString(),
                          style: const TextStyle(color: Colors.white),
                        ));
                  } else {
                    return const Text("Ingen treningsprogrammer tilgjengelig");
                  }
                },
              ),
            ),
          ));

  List<WeekdayData> createChartData() {
    List<WeekdayData> weekdayData = [];
    int index = 0;
    _workoutsByDay.forEach((day, workouts) {
      weekdayData.add(WeekdayData((workouts / _workouts.length) * 100, day,
          colorPallet[index % colorPallet.length]));
      //Colors.blue));
      index++;
    });
    return weekdayData;
  }

  List<WorkoutData> createProgamData() {
    List<WorkoutData> workoutData = [];
    int index = 0;
    var sortedByValueMap = Map.fromEntries(_workoutsByProgram.entries.toList()
      ..sort((e2, e1) => e1.value.compareTo(e2.value)));

    sortedByValueMap.forEach((program, workouts) {
      if (workouts != 0) {
        workoutData.add(WorkoutData((workouts / _workouts.length) * 100,
            program, colorPallet[index % colorPallet.length]));
        index++;
      }
    });
    return workoutData;
  }

  Map<String, dynamic> workoutsByProgram() {
    List<String> programsKeys = [];
    Map<String, dynamic> workoutsByProgram = {};
    if (_workouts.length > 0) {
      for (var i = 0; i < _workouts.length; i++) {
        //print(_programs[_workouts[i]["workoutProgram"]]);
        /*
        if (_programs[_workouts[i]["workoutProgram"]]['isCardio']) {
          if (workoutsByProgram.containsKey('Kardio')) {
            workoutsByProgram['Kardio'] += 1;
          } else {
            workoutsByProgram['Kardio'] = 1;
          }
        } else */
        if (workoutsByProgram.containsKey(_workouts[i]["workoutProgram"])) {
          workoutsByProgram[_workouts[i]["workoutProgram"]] += 1;
        } else {
          workoutsByProgram[_workouts[i]["workoutProgram"]] = 1;
        }
      }
    }
    return workoutsByProgram;
  }

  Map<String, dynamic> workoutsPerDay() {
    Map<String, dynamic> workoutsPerDay = {
      'Mandag': 0,
      'Tirsdag': 0,
      'Onsdag': 0,
      'Torsdag': 0,
      'Fredag': 0,
      'Lørdag': 0,
      'Søndag': 0,
    };
    List<WeekdayData> weekdayData = [];
    for (var i = 0; i < _workouts.length; i++) {
      switch (DateFormat("EEEE").format(_workouts[i]["date"].toDate())) {
        case 'Monday':
          workoutsPerDay["Mandag"] += 1;
          break;
        case 'Tuesday':
          workoutsPerDay["Tirsdag"] += 1;
          break;
        case 'Wednesday':
          workoutsPerDay["Onsdag"] += 1;
          break;
        case 'Thursday':
          workoutsPerDay["Torsdag"] += 1;
          break;
        case 'Friday':
          workoutsPerDay["Fredag"] += 1;
          break;
        case 'Saturday':
          workoutsPerDay["Lørdag"] += 1;
          break;
        case 'Sunday':
          workoutsPerDay["Søndag"] += 1;
          break;
      }
    }
    return workoutsPerDay;
  }

  double getMaxWorkouts(Map<String, dynamic> workoutsByCategory) {
    var maxValue = 0.0;
    var maxKey = "";

    workoutsByCategory.forEach((key, value) {
      if ((value.toDouble() / _workouts.length) * 100 > maxValue) {
        maxValue = (value.toDouble() / _workouts.length) * 100;
        maxKey = key;
      }
    });

    return maxValue;
  }
}

class WorkoutData {
  WorkoutData(this.workouts, this.workoutProgram, this.color);
  final num workouts;
  final String workoutProgram;
  final Color color;
}

class ChartData {
  ChartData(this.workouts, this.workoutsLable, this.color);
  final num workouts;
  final String workoutsLable;
  final Color color;
}

class WeekdayData {
  WeekdayData(this.workoutsOnDay, this.weekday, this.color);
  final num workoutsOnDay;
  final String weekday;
  final Color color;
}
