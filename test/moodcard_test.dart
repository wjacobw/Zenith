import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:zenith/mock.dart';
import 'package:zenith/models/moodcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  test('Add place', () async {

    final fAuth = MockFirebaseAuth(signedIn: true);

    final fStore = FakeFirebaseFirestore();

    fStore.collection('users').doc(fAuth.currentUser!.uid);

    MoodCard mCard = MoodCard(actimage: 'a', actname: 'b', date: 'c', image: 'd', mood: 'e', store: fStore );

    mCard.addPlace(fAuth.currentUser!.uid, mCard.date!, mCard.mood!, mCard.image!, mCard.actimage!, mCard.actname!);

    final snaps = await fStore.collection('users').doc(fAuth.currentUser!.uid).collection('user_moods').get();

    expect(snaps.docs, isNotEmpty);



  });

  test('delete place', () async {

    final fAuth = MockFirebaseAuth(signedIn: true);

    final fStore = FakeFirebaseFirestore();

    fStore.collection('users').doc(fAuth.currentUser!.uid);

    MoodCard mCard = MoodCard(actimage: 'a', actname: 'b', date: 'c', image: 'd', mood: 'e', store: fStore );

    mCard.addPlace(fAuth.currentUser!.uid, mCard.date!, mCard.mood!, mCard.image!, mCard.actimage!, mCard.actname!);

    final snap = await fStore.collection('users').doc(fAuth.currentUser!.uid)
                  .collection('user_moods')
                  .get();

    String id = 'as';

    for (var doc in snap.docs)  { 
      id = doc.id;
      mCard.deletePlaces( fAuth.currentUser!.uid, id);
    }

    final snaps = await fStore.collection('users').doc(fAuth.currentUser!.uid)
                  .collection('user_moods')
                  .get();


    expect(snaps.docs, isEmpty);

  });


}