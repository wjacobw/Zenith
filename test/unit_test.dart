import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:zenith/mock.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  test('sign in', () {


    final Auth mockA = Auth(MockFirebaseAuth(signedIn: false));

    mockA.signInWithEmailAndPassword(email: 'zenith.tester1@gmail.com',password: 'testing');

    print(mockA.currentUser);

    expect(mockA.currentUser, isNot(equals(null)));


  });

  test('sign out', () {


    final Auth mockA = Auth(MockFirebaseAuth(signedIn: true));

    mockA.signOut();

    print(mockA.currentUser);

    expect(mockA.currentUser, equals(null));


  });

  test('create', () {


    final Auth mockA = Auth(MockFirebaseAuth(signedIn: true));

    mockA.createUserWithEmailAndPassword(email: 'email123@gmail.com', password: 'testing');


    expect(mockA.currentUser, isNot(equals(null)));


  });

}