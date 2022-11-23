import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:okter/basePage.dart';

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

  TextEditingController _vektController = TextEditingController();
  TextEditingController _ovelseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return okterScaffold(
        context,
        Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Rekorder",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  48.0, 200.0, 48.0, 200.0),
                              child: Card(
                                elevation: 20,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          32.0, 32.0, 32.0, 0),
                                      child: Text(
                                        "Legg til ny personlig rekord",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          64, 0, 64, 0),
                                      child: inputField(
                                          _ovelseController, false, "Øvelse"),
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          64, 0, 64, 0),
                                      child: numInputField(
                                          _vektController, "Vekt"),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            )),
                    icon: const Icon(Icons.add))
              ],
            ),
          ],
        ));
  }
}
