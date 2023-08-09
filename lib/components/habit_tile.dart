import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import "package:zenith/models/actions.dart";

class HabitTile extends StatelessWidget {
  final String habitName;
  final bool habitCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? settingsTapped;
  final Function(BuildContext)? deleteTapped;
  final String habitId;
  final String duration;
  final String note;
  final VoidCallback onCancel;
  final String selectedCategory;
  final String selectedDifficulty;

  const HabitTile(
      {Key? key,
      required this.habitName,
      required this.habitCompleted,
      required this.onChanged,
      required this.settingsTapped,
      required this.deleteTapped,
      required this.habitId,
      required this.duration,
      required this.note,
      required this.onCancel,
      required this.selectedCategory,
      required this.selectedDifficulty})
      : super(key: key);

  AlertDialog nameAlertDialog(BuildContext context, VoidCallback onCancel) {
    return AlertDialog(
      backgroundColor: Color.fromARGB(255, 224, 223, 223),
      title: Text(
        'Note',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Container(
        child: Text(
          note.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: onCancel,
          child: Text(
            'Close',
            style: TextStyle(color: Colors.black),
          ),
          color: Color.fromARGB(255, 219, 116, 116),
        ),
      ],
    );
  }

  VoidCallback _showNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return nameAlertDialog(context, onCancel);
      },
    );

    return () {}; // Return an empty function in case the context is null
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor = habitCompleted
        ? Color.fromARGB(255, 225, 255, 226)
        : Color.fromARGB(255, 255, 255, 255);

    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 7),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Slidable(
            endActionPane: ActionPane(
              motion: StretchMotion(),
              children: [
                SlidableAction(
                  onPressed: settingsTapped,
                  backgroundColor: Colors.white,
                  icon: Icons.settings,
                  borderRadius: BorderRadius.circular(12),
                ),
                SlidableAction(
                  onPressed: deleteTapped,
                  backgroundColor: Colors.red.shade400,
                  icon: Icons.delete,
                  borderRadius: BorderRadius.circular(12),
                ),
                SlidableAction(
                  onPressed: (BuildContext) {
                    _showNoteDialog(context);
                  },
                  backgroundColor: Colors.white,
                  icon: Icons.note,
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              activeColor: Colors.green,
                              value: habitCompleted,
                              onChanged: onChanged,
                            ),
                            SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                habitName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.green,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 24,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 79, 79, 79),
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'minutes',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 85, 84, 84),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 32,
                  right: 24,
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 4),
                      Text(
                       (selectedDifficulty).toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 79, 79, 79),
                        ),
                      ),
                      SizedBox(width: 5),
                    ],
                  ),
                ),
                Positioned(
                    top: 55,
                    right: 24,
                    child: Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 16,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 4),
                        Text(
                         selectedCategory,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 79, 79, 79),
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Normal';
      case Difficulty.hard:
        return 'Hard';
      default:
        return 'Unknown';
    }
  }

  String getCategoryText(Category category) {
    switch (category) {
      case Category.study:
        return 'Study';
      case Category.others:
        return 'Others';
      case Category.workout:
        return 'Workout';
      case Category.rest:
        return 'Rest';

      default:
        return 'Unknown';
    }
  }
}
