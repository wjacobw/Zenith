import 'package:cloud_firestore/cloud_firestore.dart';

class Level {
  final String id;
  final String email;
  final int experience;
  final String room;
  Level({
    required this.id,
    required this.email,
    required this.experience,
    required this.room,
  });

  factory Level.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      [SnapshotOptions? options]) {
    final data = snapshot.data()!;
    return Level(
      id: snapshot.id,
      email: data['email'],
      experience: data['experience'],
      room: data['room'],
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      "email":  email,
      "experience": experience,
      "room": room,
    };
  }
}