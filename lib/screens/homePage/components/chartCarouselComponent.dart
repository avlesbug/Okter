import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../utils/color_pallet.dart';

class ChartCarouselWidget extends StatefulWidget {
  var documentRef;
  final String userId;

  ChartCarouselWidget({required this.documentRef, required this.userId});

  @override
  State<ChartCarouselWidget> createState() => _ChartCarouselWidgetState();
}


class _ChartCarouselWidgetState extends State<ChartCarouselWidget> {
  bool displayYearProg = false;

  var height = 667;
  var width = 375;
  var _maxValueDay;
  var _dayInterval;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height.toInt();
    width = MediaQuery.of(context).size.width.toInt();
    List<dynamic> workouts = widget.documentRef.data!['detailedWorkouts'] as List<dynamic>;
    _maxValueDay = getMaxWorkouts(workouts);
    _dayInterval = (_maxValueDay / 10).toInt().toDouble();
    return SizedBox(
      height: height * 0.33,
      width: width * 0.9,
      child: Center(
        child: CarouselSlider(
            items: [
              GestureDetector(
                onTap: () {
                  setState(() {
                  displayYearProg = !displayYearProg;
                  });
                },
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: 
                  true ?
                  SfCircularChart(
                    annotations: <CircularChartAnnotation>[
                      CircularChartAnnotation(
                        widget: !displayYearProg
                            ? SizedBox(
                                height: height * 0.032,
                                width: width * 0.14,
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(
                                      (("${((widget.documentRef.data!['workouts'] / widget.documentRef.data!['goal']) * 100).toStringAsFixed(0)}%")),
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
                                      "År: ${getPeriodeProgress(widget.documentRef.data!['endDate'])}%",
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
                          fontSize: 22,
                        )),
                    margin: const EdgeInsets.all(28),
                    series: [
                      RadialBarSeries<WorkoutData, String>(
                        dataSource: [
                          WorkoutData(getPeriodeProgress(widget.documentRef.data!['endDate']), "År",
                              const Color.fromARGB(255, 87, 117, 168)),
                          WorkoutData(
                              num.parse(((widget.documentRef.data!['workouts'] / widget.documentRef.data!['goal']) * 100)
                                  .toStringAsFixed(2)),
                              "Meg",
                              const Color.fromARGB(255, 93, 87, 168)),
                        ],
                        xValueMapper: (WorkoutData data, _) =>
                            data.workoutProgram,
                        yValueMapper: (WorkoutData data, _) =>
                            data.workouts,
                        pointColorMapper: (WorkoutData data, _) =>
                            data.color,
                        // Radius of the radial bar
                        radius: '100%',
                        cornerStyle: CornerStyle.bothCurve,
                        trackColor: const Color(0xFF086c6a),
                        trackOpacity: 0.1,
                        maximumValue: 100,
                        gap: '3%',
                      )
                    ],
                  ):
                  const Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 93, 87, 168)),
                    ),
                  ))
                  ,
                ),
              ),

              SfCartesianChart(
                  title: ChartTitle(
                      text: 'Økter etter dag',
                      textStyle: const TextStyle(
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
                      dataSource: createChartData(workouts),
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
                    dataSource: createProgamData(workouts),
                    sortingOrder: SortingOrder.descending,
                    explodeIndex: 0,
                    explode: true,
                    xValueMapper: (WorkoutData data, _) =>
                        data.workoutProgram,
                    yValueMapper: (WorkoutData data, _) => data.workouts,
                    dataLabelMapper: (WorkoutData data, _) =>
                        data.workoutProgram,
                    pointColorMapper: (WorkoutData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        showZeroValue: false,
                        labelPosition: ChartDataLabelPosition.outside,
                        textStyle: TextStyle(
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
    );
  }
}

List<WeekdayData> createChartData(List<dynamic> totalWorkouts) {
    List<WeekdayData> weekdayData = [];
    int index = 0;
    getWorkoutsPerDay(totalWorkouts).forEach((day, workouts) {
      weekdayData.add(WeekdayData((workouts / totalWorkouts.length) * 100, day,
          colorPallet[index % colorPallet.length]));
      index++;
    });
    return weekdayData;
  }
Map<String, dynamic> getWorkoutsByProgram(List<dynamic> workouts) {
  List<String> programsKeys = [];
  Map<String, dynamic> workoutsByProgram = {};
  if (workouts.isNotEmpty) {
    for (var i = 0; i < workouts.length; i++) {
      if (workoutsByProgram.containsKey(workouts[i]["workoutProgram"])) {
        workoutsByProgram[workouts[i]["workoutProgram"]] += 1;
      } else {
        workoutsByProgram[workouts[i]["workoutProgram"]] = 1;
      }
    }
  }
  return workoutsByProgram;
}
List<WorkoutData> createProgamData(List<dynamic> totalWorkouts) {
  List<WorkoutData> workoutData = [];
  int index = 0;
  var sortedByValueMap = Map.fromEntries(getWorkoutsByProgram(totalWorkouts).entries.toList()
    ..sort((e2, e1) => e1.value.compareTo(e2.value)));

  sortedByValueMap.forEach((program, workouts) {
    if (workouts != 0) {
      workoutData.add(WorkoutData((workouts / totalWorkouts.length) * 100,
          program, colorPallet[index % colorPallet.length]));
      index++;
    }
  });
  return workoutData;
}

Map<String, dynamic> getWorkoutsPerDay(List<dynamic> workouts) {
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
  for (var i = 0; i < workouts.length; i++) {
    switch (DateFormat("EEEE").format(workouts[i]["date"].toDate())) {
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

double getMaxWorkouts(List<dynamic> workouts) {
  var maxValue = 0.0;
  var maxKey = "";

  getWorkoutsPerDay(workouts).forEach((key, value) {
    if ((value.toDouble() / workouts.length) * 100 > maxValue) {
      maxValue = (value.toDouble() / workouts.length) * 100;
      maxKey = key;
    }
  });

  return maxValue;
}

num getPeriodeProgress(var endDate){
    Duration totalDays =
        DateTime(DateTime.now().year, 1, 1).difference(endDate.toDate());
    Duration periodeProgresion =
        DateTime(DateTime.now().year, 1, 1).difference(DateTime.now());

    return num.parse(
        ((periodeProgresion.inDays / totalDays.inDays) * 100)
            .toStringAsFixed(1));

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