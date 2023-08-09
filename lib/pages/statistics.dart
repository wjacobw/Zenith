import 'package:flutter/material.dart';
import 'package:zenith/components/habit_tile.dart';
import 'package:zenith/components/my_fab.dart';
import 'package:zenith/components/new_habit_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zenith/components/edit_habit_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zenith/datetime/date_time.dart';
import 'package:zenith/monthly_summary.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:zenith/models/actions.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  int length = 0;
  int countCompleted = 0;
  Map<DateTime, int> heatMapDataSet = {};
  DateTime? firstLoginDate;
  double overallCompletionPercentage = 0.0;
  final Category _selectedCategory = Category.study;
  final Difficulty _selectedDifficulty = Difficulty.easy;

  @override
  void initState() {
    super.initState();
    retrieveFirstLoginDate();
    calculateHeatMapData();
    calculateHabitPercentage();
  }

  Future<void> retrieveFirstLoginDate() async {
    DateTime? loginDate = await getFirstLoginDate();
    setState(() {
      firstLoginDate = loginDate;
    });
    calculateHeatMapData();
  }

  Future<DateTime?> getFirstLoginDate() async {
    String userID = getUserId();
    DocumentReference userDoc = firestore.collection("users").doc(userID);
    DocumentSnapshot<Object?> userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      if (userData.containsKey('firstLoginDate')) {
        Timestamp timestamp = userData['firstLoginDate'] as Timestamp;
        return timestamp.toDate();
      }
    }

    return null;
  }

  Future<void> calculateHeatMapData() async {
    if (firstLoginDate == null) {
      return;
    }

    int daysInBetween = DateTime.now().difference(firstLoginDate!).inDays;
    DateTime startDate =
        createDateTimeObject(convertDateTimeToString(firstLoginDate!));

    for (int i = 0; i < daysInBetween + 2; i++) {
      double parsedPercentage = 0.0;
      int year = startDate.add(Duration(days: i)).year;
      int month = startDate.add(Duration(days: i)).month;
      int day = startDate.add(Duration(days: i)).day;

      String currentDateStr = convertDateTimeToString(firstLoginDate!);
      int modifiedDate = int.parse(currentDateStr) + i;
      DateTime modifiedDateTime = createDateTimeObject(modifiedDate.toString());

      Future<void> fetchPercentageValue() async {
        DocumentReference userDoc =
            firestore.collection("users").doc(getUserId());
        DocumentReference percentageCollection = userDoc
            .collection("percentage_summary")
            .doc(convertDateTimeToString(modifiedDateTime));

        DocumentSnapshot percentageSnapshot = await percentageCollection.get();

        Map<String, dynamic>? data =
            percentageSnapshot.data() as Map<String, dynamic>?;
        String? percentage = data?['percentage'];

        parsedPercentage =
            double.tryParse(percentage == null ? '0.0' : percentage)!; //correct
        final percentForEachDay = <DateTime, int>{
          DateTime(year, month, day): (parsedPercentage * 10).toInt(),
        };

        heatMapDataSet.addEntries(percentForEachDay.entries); //here

        // Use the parsedPercentage variable as needed
      }

      fetchPercentageValue();
    }
    return Future.value();
  }

  void checkBoxTapped(bool? value, String habitId) async {
    String userID = getUserId();
    // Get the current date in "yyyy-mm-dd" format
    String currentDateStr = convertDateTimeToString(DateTime.now());

    DocumentReference userDoc = firestore.collection("users").doc(userID);
    DocumentReference habit = userDoc
        .collection("habits")
        .doc(currentDateStr)
        .collection("habits")
        .doc(habitId);

    DocumentSnapshot<Object?> snapshot = await habit.get();
    if (snapshot.exists) {
      Map<String, dynamic> habitData = snapshot.data() as Map<String, dynamic>;
      String habitName = habitData['habit'][0];

      await habit.update({
        'habit': [habitName, value],
      });

      await calculateHeatMapData(); // Wait for the completion of calculateHeatMapData()

      setState(() {}); // Trigger a rebuild of the widget
    }
    calculateHabitPercentage();
  }

  void editHabit(
    String id,
    TextEditingController nameController,
    TextEditingController durationController,
    TextEditingController noteController,
  ) async {
    String userID = getUserId();
    String currentDateStr = convertDateTimeToString(DateTime.now());

    DocumentReference userDoc = firestore.collection("users").doc(userID);
    DocumentReference habit = userDoc
        .collection("habits")
        .doc(currentDateStr)
        .collection("habits")
        .doc(id);

    await habit.update({
      'habit': [nameController.text, false],
      'duration': durationController.text,
      'note': noteController.text
    });
    nameController.clear();
    durationController.clear();
    noteController.clear();
    await calculateHeatMapData();

    setState(() {});

    // pop dialog box
    Navigator.of(context).pop();
  }

  void openHabitSettings(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return EditHabitBox(
          onSave: () => {
            if (_newHabitNameController.toString() == '')
              {
                _showAlertDialog(context),
              }
            else
              {
                editHabit(id, _newHabitNameController, _durationController,
                    _noteController),
              }
          },
          docId: id,
          nameController: _newHabitNameController,
          durationController: _durationController,
          noteController: _noteController,
          onCancel: cancelDialogBox,
        );
      },
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert Dialog Title'),
          content: Text('This is the content of the alert dialog.'),
          actions: <Widget>[
            // Add buttons to the dialog
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                // Do something when OK is pressed
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void deleteHabit(String docId) async {
    String userID = getUserId();
    // Get the current date in "yyyy-mm-dd" format
    String currentDateStr = convertDateTimeToString(DateTime.now());

    DocumentReference userDoc = firestore.collection("users").doc(userID);
    CollectionReference habitsCollection =
        userDoc.collection("habits").doc(currentDateStr).collection("habits");
    DocumentReference docRef = habitsCollection.doc(docId);

    await docRef.delete();
    await calculateHeatMapData();
    calculateHabitPercentage();

    setState(() {});
  }

  void cancelDialogBox() {
    // clear textfield
    _newHabitNameController.clear();

    // pop dialog box
    Navigator.of(context).pop();
  }

  final _newHabitNameController = TextEditingController();
  final _durationController = TextEditingController();
  final _noteController = TextEditingController();

  void saveNewHabit2(BuildContext context, Difficulty dif, Category cat) async {
    String userID = getUserId();
    DocumentReference userDoc = firestore.collection("users").doc(userID);
    CollectionReference habitsCollection = userDoc.collection("habits");

    // Get the current date in "yyyy-mm-dd" format
    String currentDateStr = convertDateTimeToString(DateTime.now());

    // Create a new habit with the name and completion status
    Map<String, dynamic> newHabitData = {
      'habit': [_newHabitNameController.text, false],
      'duration': _durationController.text,
      'note': _noteController.text,
      'difficulty': dif.toString(),
      'category': cat.toString(),

      'string': '0', // Add the 'string' field with the value '0'
    };

    // Check if the habit subcollection for the current date exists
    habitsCollection.doc(currentDateStr).set({'x': 0});
    // If the subcollection for the current date exists, add a new habit document to it
    await habitsCollection
        .doc(currentDateStr)
        .collection('habits')
        .add(newHabitData);

    _newHabitNameController.clear();
    _durationController.clear();
    _noteController.clear();
    calculateHabitPercentage();

    // Pop dialog box
    Navigator.of(context).pop();

    await calculateHeatMapData();
    setState(() {});
  }

  void cancelNewHabit() {
    // clear textfield
    _newHabitNameController.clear();
    _durationController.clear();

    // pop dialog box
    Navigator.of(context).pop();
  }

  void createNewHabit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return EnterNewHabitBox(
          nameController: _newHabitNameController,
          durationController: _durationController,
          noteController: _noteController,
          onSave: (a, b) => saveNewHabit2(context, a, b), // Pass the context
          onCancel: cancelNewHabit,
          selectedCategory: _selectedCategory,
          selectedDifficulty: _selectedDifficulty,
        );
      },
    );
  }

  String getUserId() {
    // new change
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    // If the user is not authenticated or null, handle the case accordingly
    // For example, you can return a default or empty string
    return '';
  }

  Future<DocumentSnapshot<Object?>> getData(String docID) async {
    DocumentReference userDoc = firestore.collection("users").doc(getUserId());
    DocumentReference habits = userDoc.collection("habits").doc(docID);
    return habits.get();
  }

  Future<DocumentSnapshot<Object?>> getPercentageSummary(String date) async {
    //here
    String userID = getUserId();
    DocumentReference userDoc = firestore.collection("users").doc(userID);
    DocumentReference percentageSummary =
        userDoc.collection("percentage_summary").doc(date);
    return percentageSummary.get();
  }

  Future<void> calculateHabitPercentage() async {
    int countCompleted = 0;
    String userID = getUserId();
    // Get the current date in "yyyy-mm-dd" format
    String currentDateStr = convertDateTimeToString(DateTime.now());

    DocumentReference userDoc = firestore.collection("users").doc(userID);
    CollectionReference habitsCollection =
        userDoc.collection("habits").doc(currentDateStr).collection("habits");

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await habitsCollection.get() as QuerySnapshot<Map<String, dynamic>>;

    for (QueryDocumentSnapshot<Map<String, dynamic>> habitSnapshot
        in snapshot.docs) {
      Map<String, dynamic> habitData = habitSnapshot.data();
      List<dynamic> habitList = habitData["habit"] as List<dynamic>;

      if (habitList.length >= 2) {
        bool habitCompleted = habitList[1];
        // Perform your desired operations with habitCompleted value
        if (habitCompleted) {
          countCompleted++;
        }
      }
    }

    double completionPercentage =
        snapshot.size == 0 ? 0.0 : (countCompleted / snapshot.size);
    double overallCompletionPercentage = double.parse(
      completionPercentage.toStringAsFixed(1),
    );

    String yyyymmdd = convertDateTimeToString(DateTime.now());
    DocumentReference percentageSummaryDoc =
        userDoc.collection("percentage_summary").doc(yyyymmdd);
    await percentageSummaryDoc.set({
      "percentage": overallCompletionPercentage.toString(),
    });

    setState(() {
      this.overallCompletionPercentage = overallCompletionPercentage;
    });
  }

  String parseDifficultyString(String input) {
    final parsedValue =
        input.split('.')[1]; // Split the input and get the second part
    return parsedValue;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamData() {
    String userID = getUserId();
    // Get the current date in "yyyy-mm-dd" format
    String currentDateStr = convertDateTimeToString(DateTime.now());

    CollectionReference habits =
        firestore.collection("users").doc(userID).collection("habits");

    // Listen to the "habits" subcollection for the current date only
    return habits.doc(currentDateStr).collection("habits").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: StreamBuilder<QuerySnapshot<Object?>>(
        stream: streamData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('No data available');
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          var listAllhabits = snapshot.data!.docs;
          length = listAllhabits.length;

          return FutureBuilder<DateTime?>(
            future: getFirstLoginDate(),
            builder: (context, dateSnapshot) {
              if (!dateSnapshot.hasData) {
                return Text('No first login date available');
              }
              firstLoginDate = dateSnapshot.data;

              return SafeArea(
                child: Stack(
                  children: [
                    ListView(
                      children: [
                        MonthlySummary(
                          datasets: heatMapDataSet,
                          startDate: convertDateTimeToString(
                              firstLoginDate!.subtract(Duration(days: 100))),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: LinearPercentIndicator(
                            linearStrokeCap: LinearStrokeCap
                                .round, // Use round stroke caps for a thicker line

                            barRadius: Radius.circular(5),
                            lineHeight: 20,
                            width: MediaQuery.of(context).size.width,
                            percent: overallCompletionPercentage,
                            progressColor: Color.fromARGB(255, 109, 203, 167),
                            backgroundColor: Color.fromARGB(255, 251, 251, 251),
                            center: Text(
                              (overallCompletionPercentage * 100).toString(),
                              style: new TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: listAllhabits.length,
                          itemBuilder: (context, index) {
                            return HabitTile(
                              habitName:
                                  "${(listAllhabits[index].data() as Map<String, dynamic>)["habit"][0]}"
                                      .toString(),
                              habitCompleted: (listAllhabits[index].data()
                                  as Map<String, dynamic>)["habit"][1],
                              onChanged: (value) => checkBoxTapped(
                                  value, listAllhabits[index].id),
                              settingsTapped: (context) =>
                                  openHabitSettings(listAllhabits[index].id),
                              deleteTapped: (context) =>
                                  deleteHabit(listAllhabits[index].id),
                              habitId: listAllhabits[index].id,
                              duration:
                                  "${(listAllhabits[index].data() as Map<String, dynamic>)["duration"]}"
                                      .toString(),
                              note:
                                  "${(listAllhabits[index].data() as Map<String, dynamic>)["note"]}"
                                      .toString(),
                              onCancel: () {
                                Navigator.of(context).pop();
                              },
                              selectedCategory: parseDifficultyString(
                                  "${(listAllhabits[index].data() as Map<String, dynamic>)["category"]}"
                                      .toString()),
                              selectedDifficulty: parseDifficultyString(
                                  "${(listAllhabits[index].data() as Map<String, dynamic>)["difficulty"]}"
                                      .toString()),
                            );
                          },
                        ),
                      ],
                    ),
                    Positioned(
                      bottom:
                          20.0, // Adjust the value to position the button as per your requirement
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FloatingActionButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          backgroundColor: Colors.orange,
                          onPressed: () {
                            createNewHabit(context);
                          },
                          child: Icon(
                            Icons.add,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
