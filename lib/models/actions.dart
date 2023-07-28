import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

enum Category { study, workout, rest, others}

enum Difficulty { easy, medium, hard}

const uuid = Uuid();

const categoryIcons = {
  Category.study: Icons.plus_one,
  Category.workout: Icons.plus_one,
  Category.rest: Icons.plus_one,
  Category.others: Icons.plus_one
};

class Actions1 {
  Actions1({
    required this.title,
    required this.duration,
    required this.difficulty, // thinking to make it range between 1 to 5
    required this.category,
    required this.note, // I plan to make this not required, that is the user can choose to fill or not fill
  }) : id = uuid.v4();

  final String id;
  final String title;
  final int duration;
  final Difficulty difficulty;
  final Category category;
  final String note;
}

class ActionBucket {
  const ActionBucket({required this.category, required this.actions});

  ActionBucket.forCategory(List<Actions1> allActions, this.category)
      : actions =
            allActions.where((action) => action.category == category).toList();

  final Category category;
  final List<Actions1> actions;

  double get totalExpenses {
    double sum = 0;

    for (final action in actions) {
      sum += action.duration;
    }
    return sum;
  }
}
