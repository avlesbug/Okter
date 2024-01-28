import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class SisteOktWidget extends StatelessWidget {
  var documentRef;
  final String userId;

  SisteOktWidget({required this.documentRef, required this.userId});

  var height = 667;
  var width = 375;


  void setLastWorkout(DateTime date, List<dynamic> sortedWorkouts) async {
    sortedWorkouts[0]["date"] = Timestamp.fromDate(date);
    FirebaseFirestore.instance.collection("UserData").doc(userId).update({
      'detailedWorkouts': sortedWorkouts,
    });
  }

  List<dynamic> getSortedWorkouts(var documentRef){
    var sortedWorkouts = documentRef.data!['detailedWorkouts'] as List<dynamic>;
    sortedWorkouts.sort((a, b) => b['date'].compareTo(a['date']));
    return sortedWorkouts;
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> sortedWorkouts = getSortedWorkouts(documentRef);
    height = MediaQuery.of(context).size.height.toInt();
    width = MediaQuery.of(context).size.width.toInt();
    return Row(
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
                  }, 
                  onConfirm: (date) {
                    setLastWorkout(date, sortedWorkouts);
                  }, currentTime: DateTime.now(), locale: LocaleType.no);
                  
                },
                child: sortedWorkouts.isNotEmpty
                    ? Text(
                        "${DateFormat.yMMMEd().format(sortedWorkouts[0]["date"].toDate())}, ${DateFormat.Hm().format(sortedWorkouts[0]["date"].toDate())}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Color.fromARGB(255, 93, 87, 168)),
                      )
                    : Text(
                        " ${DateTime(2000,0,0).toString()}, ${DateTime(2000,0,0).hour.toString()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Color.fromARGB(255, 93, 87, 168)),
                      )),
          ),
        ),
      ],
    );
  }
}