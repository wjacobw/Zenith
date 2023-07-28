import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String title;
  final String? description;
  final DateTime date;
  final int startH;
  final int startM;
  final int endH;
  final int endM;
  final String id;
  final String email;
  final String type;
  Event({
    required this.title,
    this.description,
    required this.date,
    required this.startH,
    required this.startM,
    required this.endH,
    required this.endM,
    required this.id,
    required this.email,
    required this.type,

  });

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      [SnapshotOptions? options]) {
    final data = snapshot.data()!;
    return Event(
      date: data['date'].toDate(),
      title: data['title'],
      description: data['description'],
      id: snapshot.id,
      email: data['email'],
      startH: data['startH'],
      startM: data['startM'],
      endH: data['endH'],
      endM: data['endM'],
      type: data['type'],
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      "date": Timestamp.fromDate(date),
      "title": title,
      "description": description,
      "email":  email,
      "startH": startH,
      "startM": startM,
      "endH": endH,
      "endM": endM,
      "type": type,
    };
  }
}