import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:zenith/mock.dart';
import 'package:zenith/class/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String emails = 'testing12345@gmail.com';

void add_event(String title, DateTime date, int startH, int startM,
int endH, int endM, String email, String type, FirebaseFirestore store) async {

  await store.collection('events').add({
      "title": title,
      "description": '',
      "date": date,
      "startH": startH,
      "startM": startM,
      "endH": endH,
      "endM": endM,
      "type": type,
      "email":email,
    });
}

void delete_event(String id, FirebaseFirestore store) async {

  await store.collection('events').doc(id).delete();

}

void edit_event(String title, DateTime date, int startH, int startM,
int endH, int endM, String email, String type, FirebaseFirestore store, String id) async {
  

  await store.collection('events').doc(id).update({
      "title": title,
      "description": 'vc',
      "date": date,
      "startH": startH,
      "startM": startM,
      "endH": endH,
      "endM": endM,
      "type": type,
      "email": email,
  });

}


main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  test('Add event', () async {

    final fStore = FakeFirebaseFirestore();

    add_event('title', DateTime(2020,9,7,17,30), 12, 20, 13, 20, emails, 'ad', fStore);

    final snap = await fStore
      .collection('events')
      .where('email', isEqualTo: emails)
      .withConverter(
          fromFirestore: Event.fromFirestore,
          toFirestore: (event, options) => event.toFirestore())
      .get();


    expect(snap.docs, isNotEmpty);

  });

  test('delete event', () async {

    final fStore = FakeFirebaseFirestore();

    add_event('title', DateTime(2020,9,7,17,30), 12, 20, 13, 20, emails, 'ad', fStore);

    final snap = await fStore
      .collection('events')
      .where('email', isEqualTo: emails)
      .withConverter(
          fromFirestore: Event.fromFirestore,
          toFirestore: (event, options) => event.toFirestore())
      .get();

    String id = 'as';

    for (var doc in snap.docs)  { 
      id = doc.id;
      delete_event(id, fStore);
    }

    final snaps = await fStore
                  .collection('events')
                  .get();


    expect(snaps.docs, isEmpty);

  });


  test('edit event', () async {

    final fStore = FakeFirebaseFirestore();

    add_event('title', DateTime(2020,9,7,17,30), 12, 20, 13, 20, emails, 'ad', fStore);

    final snap = await fStore
      .collection('events')
      .where('email', isEqualTo: emails)
      .withConverter(
          fromFirestore: Event.fromFirestore,
          toFirestore: (event, options) => event.toFirestore())
      .get();

    String id = 'as';

    for (var doc in snap.docs)  { 
      id = doc.id;
    }

    final snapz = await fStore.collection('events').doc(id).get();

    edit_event('titles', DateTime(2020,9,7,17,30), 12, 20, 13, 20, emails, 'ad', fStore, id);

    final snaps = await fStore
                  .collection('events')
                  .doc(id)
                  .get();


    expect(snapz.data(), isNot(equals(snaps.data())));

  });


}