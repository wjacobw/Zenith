import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zenith/helpers/mooddata.dart';
import 'package:zenith/models/activity.dart';
import 'package:zenith/pages/screens/start.dart';

class MoodCard extends ChangeNotifier {
  List<Activity> activities = [];

  void clearSelectedActivities() {
    activities.clear();
  }

  void add(Activity activity) {
    // Check if the activity already exists in the activities list
    if (!activities.contains(activity)) {
      activities.add(activity);
      activityimage.add(activity.image);

      activityname.add(activity.name);

      notifyListeners();
    }
  }

  void delete(Activity activity) {
    activities.remove(activity);
    activityimage.remove(activity.image);
    activityname.remove(activity.name);

    notifyListeners();
  }

  String? mood;
  List<String> activityname = [];
  List<String> activityimage = [];
  String? image;
  String? actimage;
  String? actname;
  FirebaseFirestore? store = FirebaseFirestore.instance;
  MoodCard({this.actimage, this.actname, this.date, this.image, this.mood, this.store});
  late List items;
  List<MoodData> data = [];

  late String? date;
  bool isloading = false;
  List<String> actiname = [];

  Future<void> addPlace(
    String accountId, // New argument: Account ID
    String date,
    String mood,
    String image,
    String actimage,
    String actname,
  ) async {
    clearSelectedActivities();

    Activity activity = Activity(actimage, actname, false);

    add(activity);
    activityimage.clear();
    activityname.clear();

    List<String> uniqueActivityImage = activityimage.toSet().toList();
    List<String> uniqueActivityName = activityname.toSet().toList();

    // Reference the user_moods subcollection for the specific account
    final accountRef = store == null ? FirebaseFirestore.instance.collection('users').doc(accountId) :
        store!.collection('users').doc(accountId);
    final userMoodsRef = accountRef.collection('user_moods');

    await userMoodsRef.add({
      'date': date,
      'mood': mood,
      'image': image,
      'actimage': actimage,
      'actname': actname,
    });

    // Create the activity object and add it to the list

    // Clear the activity image and name lists

    // Add the unique activity images and names back to the lists
    activityimage.addAll(uniqueActivityImage);
    activityname.addAll(uniqueActivityName);

    uniqueActivityImage.clear();
    uniqueActivityName.clear();

    notifyListeners();
  }

  Future<void> deletePlaces(
    String accountId, // New argument: Account ID
    String docId,
  ) async {
    // Reference the user_moods subcollection for the specific account
    final accountRef = store == null ? FirebaseFirestore.instance.collection('users').doc(accountId) :
        store!.collection('users').doc(accountId);
    final userMoodsRef = accountRef.collection('user_moods');

    await userMoodsRef.doc(docId).delete();

    notifyListeners();
    activities.clear();
  }
}
