import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditHabitBox extends StatefulWidget {
  const EditHabitBox({
    Key? key,
    required this.onSave,
    required this.docId,
    required this.nameController,
    required this.durationController,
    required this.noteController,
    required this.onCancel,
  }) : super(key: key);

  final VoidCallback onSave;
  final String docId;
  final TextEditingController nameController;
  final TextEditingController durationController;
  final TextEditingController noteController;
  final VoidCallback onCancel;

  @override
  _EditHabitBoxState createState() => _EditHabitBoxState();
}

class _EditHabitBoxState extends State<EditHabitBox> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data; // Use Map<String, dynamic>?

          if (data != null) {
            print(data); // Access the 'habitCompleted' key
            String stringValue = data['string']; // Access the 'stringValue' key

            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              content: Container(
                height: 200,
                child: Column(
                  children: [
                    TextField(
                      controller: widget.nameController,
                      style:
                          const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      decoration: InputDecoration(
                        hintText: data['habit'][0],
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 0, 0, 0))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 0, 0, 0))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: widget.durationController,
                      style:
                          const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      decoration: InputDecoration(
                        hintText: data['duration'].toString(),
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 0, 0, 0))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 0, 0, 0))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: widget.noteController,
                      style:
                          const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      decoration: InputDecoration(
                        hintText: data['note'].toString(),
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 0, 0, 0))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 0, 0, 0))),
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: widget.onCancel,
                  child: Text('Cancel',
                      style:
                          TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
                  color: Color.fromARGB(255, 219, 116, 116),
                ),
                MaterialButton(
                  onPressed: widget.onSave,
                  child: Text('Save',
                      style:
                          TextStyle(color: Color.fromARGB(255, 252, 252, 252))),
                  color: Color.fromARGB(255, 115, 239, 181),
                ),
              ],
            );
          } else {
            return Text('Document does not exist');
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  String convertDateTimeToString(DateTime dateTime) {
    String year = dateTime.year.toString().padLeft(4, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String day = dateTime.day.toString().padLeft(2, '0');

    return '$year$month$day';
  }

  Future<Map<String, dynamic>> getData() async {
    String userId = getUserId();
    String currentDateStr = convertDateTimeToString(DateTime.now());
    DocumentReference userDoc = firestore.collection("users").doc(userId);
    print(userDoc.collection("habits").doc(currentDateStr).toString());
    DocumentReference habitDoc = userDoc
        .collection("habits")
        .doc(currentDateStr)
        .collection("habits")
        .doc(widget.docId);

    DocumentSnapshot<Object?> habitSnapshot = await habitDoc.get();
    print(12);
    if (habitSnapshot.exists) {
      print(34);
      Map<String, dynamic>? habitData =
          habitSnapshot.data() as Map<String, dynamic>?;
      if (habitData != null) {
        print(56);
        // Access the "habit" field, which is an array
        List<dynamic> habitArray = habitData['habit'];
        String habitName = habitArray[0]; // "xx"
        bool habitValue = habitArray[1]; // true

        // Access the "string" field, which is a string
        String stringValue = habitData['string']; // "0"

        print('Habit Name: $habitName');
        print('Habit Value: $habitValue');
        print('String Value: $stringValue');

        return habitData;
      }
    }

    return {}; // Return an empty map if the document doesn't exist
  }

  String getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return '';
  }
}
