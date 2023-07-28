import 'package:flutter/material.dart';
import 'package:zenith/models/activity.dart';
import 'package:zenith/models/mood.dart';
import 'package:zenith/models/moodcard.dart';
import 'package:zenith/widgets/activity.dart';
import 'package:zenith/widgets/moodicon.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  int numberOfDays = 0;
  Timer? consecutiveDaysTimer;
  String? selectedMood;
  String? selectedMoodImage;
  bool canSaveMood = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    calculateConsecutiveDays(); // Call the function whenever the dependencies change (e.g., when coming back to this page)
    calculateWeekly();
  }

  @override
  void initState() {
    calculateConsecutiveDays();
    calculateWeekly();
    updateConsecutiveDays();
    super.initState();
    moodCard = Provider.of<MoodCard>(context, listen: false);
    consecutiveDaysTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      // Call the updateConsecutiveDays method every 10 seconds
      updateConsecutiveDays();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to avoid memory leaks
    consecutiveDaysTimer?.cancel();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return date.toString().substring(0, 10);
  }

  void updateConsecutiveDays() async {
    String userId = getCurrentUserId();
    // Get the reference to the user's mood data collection
    CollectionReference userMoodsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('user_moods');

    // Fetch data and cast to the correct type
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await userMoodsRef.get() as QuerySnapshot<Map<String, dynamic>>;

    List<QueryDocumentSnapshot<Map<String, dynamic>>> moodDocs = snapshot.docs;
    List<String> uniqueDates = [];

    for (var moodDoc in moodDocs) {
      DateTime currentDate = DateTime.parse(moodDoc['date']);
      uniqueDates.add(_formatDate(currentDate));
    }
    uniqueDates.sort();

    int consecutiveDays = 1;
    if (uniqueDates.length == 0) {
      consecutiveDays = 0;
    } else if (DateTime.now()
            .difference(DateTime.parse(uniqueDates[uniqueDates.length - 1]))
            .inDays >=
        2) {
      consecutiveDays = 0;
    } else {
      for (int i = uniqueDates.length - 1; i > 0; i--) {
        DateTime currentDate = DateTime.parse(uniqueDates[i]);
        DateTime previousDate = DateTime.parse(uniqueDates[i - 1]);

        // Check if the current date is consecutive to the previous date
        if (currentDate.difference(previousDate).inDays == -1 ||
            currentDate.difference(previousDate).inDays == 1) {
          consecutiveDays++;
        } else if (currentDate.difference(previousDate).inDays == 0) {
          continue;
        } else {
          break;
        }
      }
    }
    setState(() {
      numberOfDays = consecutiveDays;
    });
  }

  void calculateWeekly() async {
    String userId = getCurrentUserId();

    // Get the reference to the user's mood data collection
    CollectionReference userMoodsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('user_moods');

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await userMoodsRef.get() as QuerySnapshot<Map<String, dynamic>>;

    List<QueryDocumentSnapshot<Map<String, dynamic>>> moodDocs = snapshot.docs;
    DateTime currentDate = DateTime.now();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> weeklyMood = [];

    for (var moodDoc in moodDocs) {
      DateTime moodDate = DateTime.parse(moodDoc['date']);
      // Check if the mood date is within the last 7 days from the current date
      if (currentDate.difference(moodDate).inDays <= 7) {
        weeklyMood.add(moodDoc);
      }
    }

    List<String> moodString = [];
    for (var moodDoc in weeklyMood) {
      String mood = moodDoc['mood'];
      moodString.add(mood);
    }

    int happy = 0;
    int sad = 0;
    int angry = 0;
    int surprised = 0;
    int loving = 0;
    int scared = 0;

    for (String mood in moodString) {
      if (mood == 'Happy') {
        happy++;
      } else if (mood == 'Sad') {
        sad++;
      } else if (mood == 'Angry') {
        angry++;
      } else if (mood == 'Surprised') {
        surprised++;
      } else if (mood == 'Loving') {
        loving++;
      } else {
        scared++;
      }
    }

    String highestMood;
    if (happy >= sad &&
        happy >= angry &&
        happy >= surprised &&
        happy >= loving &&
        happy >= scared) {
      highestMood = 'happy';
    } else if (sad >= angry &&
        sad >= surprised &&
        sad >= loving &&
        sad >= scared) {
      highestMood = 'sad';
    } else if (angry >= surprised && angry >= loving && angry >= scared) {
      highestMood = 'angry';
    } else if (surprised >= loving && surprised >= scared) {
      highestMood = 'surprised';
    } else if (loving >= scared) {
      highestMood = 'loving';
    } else {
      highestMood = 'scared';
    }

    if (highestMood == 'happy') {
      currentLottie = happyLottie;
    } else if (highestMood == 'sad') {
      currentLottie = sadLottie;
    } else if (highestMood == 'angry') {
      currentLottie = angryLottie;
    } else if (highestMood == 'surprised') {
      currentLottie = surprisedLottie;
    } else if (highestMood == 'loving') {
      currentLottie = lovingLottie;
    } else {
      currentLottie = scaredLottie;
    }
  }

  LottieBuilder happyLottie = Lottie.network(
      'https://assets4.lottiefiles.com/private_files/lf30_xpbapt6u.json',
      animate: true);
  LottieBuilder sadLottie = Lottie.asset('assets/sad.json', animate: true);
  LottieBuilder angryLottie = Lottie.asset('assets/angry.json', animate: true);
  LottieBuilder surprisedLottie =
      Lottie.asset('assets/surprised.json', animate: true);
  LottieBuilder lovingLottie = Lottie.asset('assets/love.json', animate: true);
  LottieBuilder scaredLottie =
      Lottie.asset('assets/scared.json', animate: true);

  LottieBuilder currentLottie =
      Lottie.asset('assets/surprised.json', animate: true);

  String getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      // If the user is not authenticated, handle the case accordingly
      // For example, you might return a default or guest user ID.
      return 'guest_user';
    }
  }

  void calculateConsecutiveDays() async {
    String userId = getCurrentUserId();
    // Get the reference to the user's mood data collection
    CollectionReference userMoodsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('user_moods');

    // Fetch data and cast to the correct type
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await userMoodsRef.get() as QuerySnapshot<Map<String, dynamic>>;

    List<QueryDocumentSnapshot<Map<String, dynamic>>> moodDocs = snapshot.docs;
    List<String> uniqueDates = [];

    for (var moodDoc in moodDocs) {
      DateTime currentDate = DateTime.parse(moodDoc['date']);
      uniqueDates.add(_formatDate(currentDate));
    }
    uniqueDates.sort();

    int consecutiveDays = 1;
    if (uniqueDates.length == 0) {
      consecutiveDays = 0;
    } else if (DateTime.now()
            .difference(DateTime.parse(uniqueDates[uniqueDates.length - 1]))
            .inDays >=
        2) {
      print(222222);
      consecutiveDays = 0;
    } else {
      for (int i = uniqueDates.length - 1; i > 0; i--) {
        print(11111);
        //[2023-07-10, 2023-07-10, 2023-07-10, 2023-07-12, 2023-07-13, 2023-07-13, 2023-07-14, 2023-07-14]
        DateTime currentDate = DateTime.parse(uniqueDates[i]);
        DateTime previousDate = DateTime.parse(uniqueDates[i - 1]);

        // Check if the current date is consecutive to the previous date

        if (currentDate.difference(previousDate).inDays == -1 ||
            currentDate.difference(previousDate).inDays == 1) {
          consecutiveDays++;
          print(consecutiveDays);
          print(22);

          // Update the longest consecutive streak if necessary
        } else if (currentDate.difference(previousDate).inDays == 0) {
          print(consecutiveDays);
          print(33);
          continue;
        } else {
          print(44);
          break;
        }
      }
    }
    setState(() {
      numberOfDays = consecutiveDays;
    });

    // Now, you can save the `consecutiveDays` value to the user's data, or use it as required.
    // For example, if you have a User object representing the user's data, you can do:
    // user.consecutiveDays = consecutiveDays;

    // The setState() is not needed here since this function is not part of the UI.
  }

  bool isConsecutiveDay(DateTime currentDate, DateTime previousDate) {
    // Compare only the dates without considering the time
    DateTime currentDateWithoutTime =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    DateTime previousDateWithoutTime =
        DateTime(previousDate.year, previousDate.month, previousDate.day);

    // Check if the difference between the dates is 1 day
    return currentDateWithoutTime.difference(previousDateWithoutTime).inDays ==
        1;
  }

  List<Activity> selectedActivities =
      []; // Temporary list to store selected activities
  MoodCard moodCard = MoodCard();
  String? mood = '';
  String? image = '';

  int ontapcount = 0;
  void _toggleActivitySelection(int index) {
    bool isSelected = act[index].selected;
    bool reachedMaxActivities = selectedActivities.length >= 5;

    setState(() {
      if (!isSelected && !reachedMaxActivities) {
        act[index].selected = true;
        selectedActivities.add(act[index]);
        moodCard.add(act[index]); // uses the add from moodcard
      } else if (isSelected) {
        act[index].selected = false;
        selectedActivities.remove(act[index]);
        moodCard.delete(act[index]);
      }

      // Update the mood and activity selections
      bool moodSelected = moods.any((mood) => mood.iselected);
      bool activitiesSelected = selectedActivities.isNotEmpty;
      canSaveMood = moodSelected && activitiesSelected;

      // Reset the ontapcount when no mood is selected
      if (!moodSelected) {
        ontapcount = 0;
      }
    });

    calculateConsecutiveDays();
    calculateWeekly();
  }

  List<Mood> moods = [
    Mood('assets/smile.png', 'Happy', false),
    Mood('assets/sad.png', 'Sad', false),
    Mood('assets/angry.png', 'Angry', false),
    Mood('assets/surprised.png', 'Surprised', false),
    Mood('assets/loving.png', 'Loving', false),
    Mood('assets/scared.png', 'Scared', false)
  ];

  List<Activity> act = [
    Activity('assets/sports.png', 'Sports', false),
    Activity('assets/sleeping.png', 'Sleep', false),
    Activity('assets/shop.png', 'Shop', false),
    Activity('assets/relax.png', 'Relax', false),
    Activity('assets/reading.png', 'Read', false),
    Activity('assets/movies.png', 'Movies', false),
    Activity('assets/gaming.png', 'Gaming', false),
    Activity('assets/friends.png', 'Friends', false),
    Activity('assets/family.png', 'Family', false),
    Activity('assets/excercise.png', 'Excercise', false),
    Activity('assets/eat.png', 'Eat', false),
    Activity('assets/date.png', 'Date', false),
    Activity('assets/clean.png', 'Clean', false)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.06,
            ),
            Container(
              // Add padding for better spacing
              child: Row(
                children: [
                  Expanded(
                    flex:
                        1, // Flex factor 1 to occupy the remaining space on the left
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/home_screen');
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 27,
                            child: CircleAvatar(
                              child: Icon(Icons.dashboard,
                                  color: const Color.fromARGB(255, 56, 62, 56),
                                  size: 30),
                              radius: 25,
                              backgroundColor: Colors.white,
                            ),
                            backgroundColor: Colors.green,
                          ),
                          SizedBox(height: 2.5),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex:
                        2, // Flex factor 2 to occupy the remaining space in the middle
                    child: Text(
                      "MOODFIT",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex:
                        1, // Flex factor 1 to occupy the remaining space on the right
                    child: Container(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: 150,
                child: currentLottie,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: currentLottie == happyLottie
                    ? Colors.yellow
                    : currentLottie == sadLottie
                        ? Colors.blue
                        : currentLottie == angryLottie
                            ? Colors.red
                            : currentLottie == surprisedLottie
                                ? Colors.purple
                                : currentLottie == lovingLottie
                                    ? Colors.pink
                                    : Colors.green,
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'MOOD SAVED:',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 9, 9, 9),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '$numberOfDays',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 9, 9, 9),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'days in a row',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: const Color.fromARGB(255, 9, 9, 9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
              width: 400,
            ),
            Text(
              'How are you feeling?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3),
            Container(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: moods.length,
                  itemExtent: MediaQuery.of(context).size.width / 4.5,
                  itemBuilder: (context, index) {
                    return Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(
                              4), // Add margin for spacing between items
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors
                                .white, // Set the background color of the container
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            child: MoodIcon(
                              image: moods[index].moodimage,
                              name: moods[index].name,
                              colour: moods[index].iselected
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            onTap: () {
                              if (ontapcount == 0) {
                                setState(() {
                                  mood = moods[index].name;
                                  image = moods[index].moodimage;
                                  selectedMood = moods[index].name;
                                  selectedMoodImage = moods[index].moodimage;
                                  moods[index].iselected = true;
                                  ontapcount = ontapcount + 1;
                                  if (selectedActivities.isNotEmpty) {
                                    canSaveMood = true;
                                  }
                                });
                              } else if (moods[index].iselected) {
                                setState(() {
                                  moods[index].iselected = false;
                                  selectedMood = null;
                                  selectedMoodImage = null;
                                  ontapcount = 0;
                                  canSaveMood = false;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                )),
            SizedBox(height: 10),
            Text(
              'What have you been doing?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 85,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: act.length,
                itemExtent: MediaQuery.of(context).size.width / 4.5,
                itemBuilder: (context, index) {
                  return Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(
                            4), // Add margin for spacing between items
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors
                              .white, // Set the background color of the container
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          child: ActivityIcon(
                            act[index].image,
                            act[index].name,
                            act[index].selected ? Colors.black : Colors.white,
                          ),
                          onTap: () {
                            _toggleActivitySelection(index);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/home_screen');
                    },
                    child: Column(
                      children: [],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Retrieve the current user and user ID
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        // Handle case when the user is not authenticated
                        return;
                      }
                      final userId = user.uid;

                      if (canSaveMood) {
                        try {
                          // The rest of the data saving process...
                          // Save the mood data under the "user_moods" collection with the user's ID as the document ID

                          moodCard.addPlace(
                            userId,
                            DateTime.now().toString(),
                            mood!,
                            image!,
                            moodCard.activityimage.toSet().join('_'),
                            moodCard.activityname.toSet().join('_'),
                          );

                          // Navigate to the home screen after saving
                          Navigator.of(context).pushNamed('/home_screen');
                          for (int i = 0; i < act.length; i++) {
                            act[i].selected = false;
                          }

                          for (int i = 0; i < moods.length; i++) {
                            moods[i].iselected = false;
                          }
                          ontapcount = 0;
                          selectedMood = null;
                          selectedMoodImage = null;
                          canSaveMood = false;
                          setState(() {
                            selectedActivities.clear();
                          });

                          calculateConsecutiveDays();
                          calculateWeekly();
                        } catch (e) {
                          // Handle any errors that occur during the data saving process
                          print('Error saving mood data: $e');
                        }
                      } else {
                        // Show a friendly instruction using SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Please pick a mood and at least one activity!"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: canSaveMood
                                ? Colors.orange
                                : Colors
                                    .grey, // Disable the button if canSaveMood is false
                          ),
                          child: Center(
                            child: Icon(
                              Icons.save_alt,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }
}
