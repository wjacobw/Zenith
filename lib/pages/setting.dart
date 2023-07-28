import 'package:firebase_auth/firebase_auth.dart';
import 'package:zenith/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zenith/class/level.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int numberOfMoodsSaved = 0;
  String email = '';
  int numberOfHabitsDone = 0;
  late int _level;
  late int _exp;
  late int _totalExperience;
  late Level acc;
  late String room;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? user = Auth(_firebaseAuth).currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeData();
    _level = 0;
    _exp = 0;
    _totalExperience = 0;
    room = 'blue';
    _loadFirestoreLevel();
  }

  _loadFirestoreLevel() async {
    final snap = await FirebaseFirestore.instance
        .collection('level')
        .where('email', isEqualTo: user?.email ?? 'User email')
        .withConverter(
            fromFirestore: Level.fromFirestore,
            toFirestore: (level, options) => level.toFirestore())
        .get();

    for (var doc in snap.docs) {
      final level = doc.data();
      final totalExp = level.experience;
      _totalExperience = totalExp;
      if (totalExp <= 90) {
        _level = 1 + (totalExp / 10).floorToDouble().round();
      } else {
        _level = ((totalExp - 90) / 100).floorToDouble().round() + 10;
      }
      if (totalExp > 90) {
        _exp = (totalExp - 90) - 100 * (_level - 10);
      } else {
        _exp = totalExp - 10 * (_level - 1);
      }
      acc = level;
      room = level.room;
    }
    setState(() {});
  }

  Future<void> initializeData() async {
    await fetchData();
    await countHabits(); // Update the number of habits done before updating the UI
    await calculateEmotions();
    // Add other initialization tasks here if needed

    // Once all the data is fetched and initialized, trigger a rebuild of the UI
    setState(() {});
  }

  Future<void> countHabits() async {
    numberOfHabitsDone = 0; // Reset the count before calculating
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        QuerySnapshot<Map<String, dynamic>> dateSnapshots =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .collection('habits')
                .get();
        print(111);
        print(dateSnapshots.docs.length);

        for (QueryDocumentSnapshot<
                Map<String, dynamic>> dateSnapshot //datesnapshot == tanggal
            in dateSnapshots.docs) {
          CollectionReference habitsCollection =
              dateSnapshot.reference.collection('habits');
          QuerySnapshot<Map<String, dynamic>> habitsSnapshot =
              await habitsCollection.get()
                  as QuerySnapshot<Map<String, dynamic>>;
          print(habitsSnapshot.docs.toString());
          print(habitsSnapshot.docs.length);

          habitsSnapshot.docs.forEach((habitDoc) {
            Map<String, dynamic> habitData = habitDoc.data();
            List<dynamic> habitList = habitData["habit"];

            if (habitList.length >= 2) {
              bool habitCompleted = habitList[1];
              if (habitCompleted) {
                print(habitList[0]);
                numberOfHabitsDone++; // Increment the count of habits done
              }
            }
          });
        }
      } catch (e) {
        print('Error querying data: $e');
      }

      print('Number of habits done: $numberOfHabitsDone');
    }
  }

  Future<void> fetchData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

      if (userSnapshot.exists) {
        String userEmail = userSnapshot.get('email').toString();

        setState(() {
          email = userEmail;
        });
      } else {
        // User document doesn't exist, handle the error case
        setState(() {
          email = 'User not found';
        });
      }
    }
  }

  Future<void> signOut() async {
    await Auth(FirebaseAuth.instance).signOut();
  }

  Future<void> calculateEmotions() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('user_moods').get();

    setState(() {
      numberOfMoodsSaved = snapshot.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Information',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 0, 0), // Custom text color
              ),
            ),
            SizedBox(height: 20),
            _buildUserCard(Icons.email, 'Email', email),
            _buildUserCard(Icons.star, 'Level', _level.toString()),
            _buildUserCard(Icons.room, 'Room Color', room.toString()),
            _buildUserCard(
                Icons.mood, 'Number of Moods Saved', '$numberOfMoodsSaved'),
            _buildUserCard(Icons.check_circle, 'Number of Habits Done',
                '$numberOfHabitsDone'),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                child: Text('Log out'),
                onPressed: () {
                  signOut();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 4, // Add elevation for a more advanced look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.orange, // Custom icon color
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87, // Custom title color
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.black54, // Custom subtitle color
          ),
        ),
      ),
    );
  }
}
