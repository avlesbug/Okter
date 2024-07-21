import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';
import 'package:okter/screens/addProgram_page.dart';
import 'package:okter/screens/detailedProgram_page.dart';
import 'package:okter/utils/color_pallet.dart';
import 'package:okter/utils/reusable_widgets.dart';

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  late String userId;

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  void initState() {
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
  }

  @override
  Widget build(BuildContext context) {
    return 
    
    okterAddButtonScaffold(
      "Programmer",
      [
        IconButton(
            onPressed: (() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddProgramPage(
                          editWorkout: const {},
                          workoutIndex: 0,
                          updateProgram: updateProgram,
                          )));
            }),
            icon: const Icon(Icons.add)),
      ],
      context,
      StreamBuilder(
          stream: FirebaseFirestore.instance.collection('UserData').doc(userId).snapshots(),
          builder: (context, snapshot) {
            return 
            snapshot.hasData ?
             Column(
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 1000,
                      child: snapshot.data!['workoutPrograms'].isEmpty
                          ? const Text(
                              "Ingen programmer lagt til enda",
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            )
                          : ListView.builder(
                              itemCount: snapshot.data!['workoutPrograms'].length,
                              itemBuilder: (BuildContext context, index) {
                                return Material(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Dismissible(
                                      onDismissed: (direction) {
                                        deleteProgram(snapshot.data!['workoutPrograms'][index]);
                                      },
                                      background: Container(
                                        color: colorPallet[2],
                                        child: Center(
                                          child: Row(
                                            children: const [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(16.0,8,16,32),
                                                child: Icon(Icons.delete,size: 36,),
                                              ),
                                              Spacer(),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(16.0,8,16,32),
                                                child: Icon(Icons.delete,size: 36,),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      key: Key(snapshot.data!['workoutPrograms'][index]["name"].toString()),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        tileColor: themeColorPallet['grey light'],
                                        leading: 
                                        snapshot.data!['workoutPrograms'][index]["isCardio"]
                                            ? const Icon(
                                                Icons.directions_run,
                                                color: Colors.white,
                                                size: 40,
                                              )
                                            : const Icon(
                                                Icons.fitness_center,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailedProgramPage(
                                                        updateProgram: updateProgram,
                                                        workoutIndex: index,
                                                        workout: snapshot.data!['workoutPrograms'][index],
                                                      )));
                                        },
                                        title: Text(snapshot.data!['workoutPrograms'][index]["name"],
                                            style: const TextStyle(fontSize: 22)),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    )
                  ],
                )
          : loadingComponent();
            }
          ));
  }

    void updateProgram(Map<String,dynamic> newWorkout, int index) async {
      print("Updating program");
      print('New program: ${newWorkout}');
      DocumentSnapshot userDataSnapshot = await _fireStore.collection("UserData").doc(userId).get();
      Map<String, dynamic>? userData = userDataSnapshot.data() as Map<String, dynamic>?;
      if (userData != null) {
        List<dynamic> workoutPrograms = userData['workoutPrograms'];
        workoutPrograms.removeWhere((value) => 
          mapEquals(value, workoutPrograms[index])
        );

        workoutPrograms.add(newWorkout);

        await _fireStore.collection("UserData").doc(userId).update({
          "workoutPrograms": workoutPrograms,
        });
      }
    }

  Future<void> deleteProgram(var tempProgram) async {
    await _fireStore.collection("UserData").doc(userId).update({
      "workoutPrograms": FieldValue.arrayRemove([tempProgram]),
    });
  }
}
