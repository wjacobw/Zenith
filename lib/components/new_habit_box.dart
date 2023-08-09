import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:zenith/pages/statistics.dart';
import 'package:zenith/models/actions.dart';

class EnterNewHabitBox extends StatelessWidget {
  EnterNewHabitBox(
      {Key? key,
      required this.nameController,
      required this.durationController,
      required this.noteController,
      required this.onSave,
      required this.onCancel,
      required this.selectedCategory,
      required this.selectedDifficulty})
      : super(key: key);

  final TextEditingController nameController; // New habit name controller
  final TextEditingController durationController; // Duration controller
  final TextEditingController noteController; // Notes controller
  final onSave;
  final VoidCallback onCancel;
  Category selectedCategory;
  Difficulty selectedDifficulty;

  AlertDialog nameAlertDialog(BuildContext context, VoidCallback onCancel) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Alert',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Container(
        child: Text(
          'Please enter your habit name',
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
        )
      ],
    );
  }

  AlertDialog durationAlertDialog(BuildContext context, VoidCallback onCancel) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Alert',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Container(
        child: Text(
          'Please enter your habit duration',
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
        )
      ],
    );
  }

  void _handleSaveButtonPressed(BuildContext context, VoidCallback onCancel) {
    if (nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return nameAlertDialog(context, onCancel);
        },
      );
    } else if (durationController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return durationAlertDialog(context, onCancel);
        },
      );
    } else {
      onSave(selectedDifficulty, selectedCategory);
      print(selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Enter habit name',
              hintStyle: TextStyle(color: Colors.grey[600]),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: durationController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Enter duration (minutes)',
              hintStyle: TextStyle(color: Colors.grey[600]),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: noteController,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Enter notes (optional)',
              hintStyle: TextStyle(color: Colors.grey[600]),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: DropdownButtonFormField<Category>(
                    value: selectedCategory,
                    items: Category.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category.name,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategory = value;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: DropdownButtonFormField<Difficulty>(
                    value: selectedDifficulty,
                    items: Difficulty.values.map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(
                          difficulty.name,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedDifficulty = value;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Difficulty',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          )
        ],
      ),
      actions: [
        MaterialButton(
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
          color: Color.fromARGB(255, 219, 116, 116),
        ),
        MaterialButton(
          onPressed: () => _handleSaveButtonPressed(context, onCancel),
          child: Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
          color: Color.fromARGB(255, 115, 239, 181),
        ),
      ],
    );
  }
}
