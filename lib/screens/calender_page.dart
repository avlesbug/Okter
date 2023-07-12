import 'dart:collection';
import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  var _selectedDay;
  var _focusedDay = DateTime.now();

  Map<DateTime, List<Event>> workoutMap = {};

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
        try {
          _workouts = userData['detailedWorkouts'] as List<dynamic>;
          _workouts.sort((a, b) => b['date'].compareTo(a['date']));
        } catch (e) {
          print(e);
        }
      });
    } catch (error) {
      print('Error fetching user data: $error');
    }

    for (int i = 0; i < _workouts.length; i++) {
      var time = (_workouts[i]['date'] as Timestamp).toDate();
      var title = Event(_workouts[i]['name']);
      workoutMap[time] = [title];
    }
    print("WorkoutMap: " + workoutMap.toString());
  }

  @override
  Widget build(BuildContext context) {
    initState();
    return okterScaffold(
      "Kalender",
      context,
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
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        eventLoader: (day) {
          return _getEventsForDay(day);
        },
      ),
    );
  }

  List _getEventsForDay(DateTime day) {
    final events = LinkedHashMap(equals: isSameDay)..addAll(workoutMap);
    return events[day] ?? [];
  }
}
