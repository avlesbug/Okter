import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';

import '../color_utils.dart';
import '../reusable_widgets.dart';

class PersonalBestPage extends StatefulWidget {
  const PersonalBestPage({super.key});

  @override
  State<PersonalBestPage> createState() => _PersonalBestPageState();
}

class _PersonalBestPageState extends State<PersonalBestPage> {
  late CollectionReference users;
  late String userId;
  late DatabaseReference ref;

  final TextEditingController _vektController = TextEditingController();
  final TextEditingController _ovelseController = TextEditingController();

  final String _collection = 'collectionName';
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  void initState() {
    //super.initState();
    users = FirebaseFirestore.instance.collection('UserData');
    userId = FirebaseAuth.instance.currentUser!.uid.toString();
    //userId = Provider.of(context).auth.getCurrentUID();
    ref = FirebaseDatabase.instance.ref("UserData");
  }

  @override
  Widget build(BuildContext context) {
    initState();
    return okterAddButtonScaffold(
        "Personlig beste",
        [IconButton(onPressed: dialog, icon: const Icon(Icons.add))],
        context,
        Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 1000,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("UserData")
                    .doc(userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.get("rekorder").length == 0) {
                    return const Text(
                      "No personal bests added yet",
                      style: TextStyle(fontSize: 16),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.get("rekorder").length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onLongPress: (() {
                          updateDialog(
                              snapshot.data!.get("rekorder")[index]["ovelse"],
                              snapshot.data!.get("rekorder")[index]["vekt"]);
                        }),
                        child: ListTile(
                          title: Text(
                              snapshot.data!.get("rekorder")[index]["ovelse"],
                              style: const TextStyle(fontSize: 20)),
                          subtitle: Text(
                              "${snapshot.data!
                                      .get("rekorder")[index]["vekt"]} kg",
                              style: const TextStyle(fontSize: 16)),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ));
  }

  void addRekord(String ovelse, String vekt) {
    Map<String, dynamic> data = {
      "ovelse": ovelse,
      "vekt": int.parse(vekt),
    };

    _fireStore.collection("UserData").doc(userId).update({
      "rekorder": FieldValue.arrayUnion([data])
    });
  }

  void deleteRekord(String ovelse, String vekt) {
    Map<String, dynamic> data = {
      "ovelse": ovelse,
      "vekt": int.parse(vekt),
    };

    _fireStore.collection("UserData").doc(userId).update({
      "rekorder": FieldValue.arrayRemove([data])
    });
  }

  void dialog() {
    showDialog(
        context: context,
        builder: (context) => Padding(
              padding: const EdgeInsets.fromLTRB(48.0, 84.0, 48.0, 280),
              child: Material(
                color: Colors.transparent,
                child: Card(
                  color: hexStringtoColor("030c10"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 0),
                        child: Text(
                          "Legg til ny personlig rekord",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(64, 0, 64, 0),
                        child: inputField(_ovelseController, false, "Øvelse"),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(64, 0, 64, 0),
                        child: numInputField(_vektController, "Vekt"),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextButton(
                          onPressed: () {
                            addRekord(
                                _ovelseController.text, _vektController.text);
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(155, 0, 150, 135)),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                            child: Text(
                              "Legg til",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  void updateDialog(param1, param2) {
    TextEditingController ovelseController = TextEditingController();
    ovelseController.text = param1;
    TextEditingController vektController = TextEditingController();
    vektController.text = param2.toString();
    showDialog(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(48.0, 80.0, 48.0, 280),
        child: Card(
          color: hexStringtoColor("030c10"),
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 0),
                child: Text(
                  "Oppdater personlig rekord",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(64, 0, 64, 0),
                child: inputField(ovelseController, false, "Øvelse"),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(64, 0, 64, 0),
                child: numInputField(vektController, "Vekt"),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    addRekord(ovelseController.text, vektController.text);
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          addRekord(ovelseController.text, vektController.text);
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(155, 0, 150, 135)),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),),
                          ),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                          child: Text("Legg til",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          deleteRekord(param1, param2.toString());
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(155, 0, 150, 135),),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),),
                          ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16,4,16,4),
                          child: const Text("Slett",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
