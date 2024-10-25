import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dt_picker;
import 'package:intl/intl.dart';

class EndGoalComponent extends StatelessWidget {
  var documentRef;
  final String userId;

  EndGoalComponent({required this.documentRef, required this.userId});

  var height = 667;
  var width = 375;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height.toInt();
    width = MediaQuery.of(context).size.width.toInt();
    return SizedBox(
      height: height * 0.15,
      width: width * 0.8,
      child: Center(
        child: GestureDetector(
          onLongPress: () {
            DatePickerDialog(
              initialDate: DateTime.now(),
              firstDate: DateTime(2000, 1, 1),
              lastDate: DateTime.now(),
            );

            dt_picker.DatePicker.showDatePicker(context,
                showTitleActions: true,
                minTime: DateTime(2000, 1, 1),
                maxTime: DateTime(DateTime.now().year + 10, 12, 31),
                theme: const dt_picker.DatePickerTheme(
                    headerColor: Color(0xFF020A0B),
                    backgroundColor: Color(0xFF020A0B),
                    itemStyle: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    doneStyle: TextStyle(color: Colors.white, fontSize: 16)),
                onChanged: (date) {}, onConfirm: (date) {
              FirebaseFirestore.instance
                  .collection("UserData")
                  .doc(userId)
                  .update({
                'endDate': date,
              });
            }, currentTime: DateTime.now(), locale: dt_picker.LocaleType.no);
          },
          child: RichText(
            text: TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text:
                          "For å nå ${documentRef.data!['goal']} økter innen ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: DateFormat.yMMMEd()
                          .format(documentRef.data!['endDate'].toDate())
                          .toString()),
                  TextSpan(
                      text:
                          " må du trene ${((documentRef.data!['goal'] - documentRef.data!['workouts']) / getWeeksLeft()).toStringAsFixed(1)} ganger i uken, eller ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          "${((documentRef.data!['goal'] - documentRef.data!['workouts']) / getDaysLeft()).toStringAsFixed(1)} ganger per dag",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
          ),
        ),
      ),
    );
  }

  num getDaysLeft() {
    var now = DateTime.now();
    var end = documentRef.data!['endDate'].toDate();
    var difference = end.difference(now).inDays;
    return difference;
  }

  num getWeeksLeft() {
    var now = DateTime.now();
    var end = documentRef.data!['endDate'].toDate();
    var difference = end.difference(now).inDays;
    return difference / 7;
  }
}
