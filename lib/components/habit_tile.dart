import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final bool habitCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? settingsTapped;
  final Function(BuildContext)? deleteTapped;
  final String habitId;

  const HabitTile({
    Key? key,
    required this.habitName,
    required this.habitCompleted,
    required this.onChanged,
    required this.settingsTapped,
    required this.deleteTapped,
    required this.habitId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color cardColor = habitCompleted
        ? Color.fromARGB(255, 225, 255, 226)
        : const Color.fromARGB(255, 157, 157, 157);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.0),
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
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Colors.green,
                        value: habitCompleted,
                        onChanged: onChanged,
                      ),
                      Text(habitName),
                    ],
                  ),
                ),
              ),
              Container(
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
