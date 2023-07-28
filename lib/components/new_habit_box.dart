import 'package:flutter/material.dart';
import 'package:zenith/pages/statistics.dart';
import 'package:zenith/models/actions.dart';

class EnterNewHabitBox extends StatelessWidget {
  const EnterNewHabitBox({
    Key? key,
    required this.nameController,
    required this.durationController,
    required this.noteController,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  final TextEditingController nameController; // New habit name controller
  final TextEditingController durationController; // Duration controller
  final TextEditingController noteController; // Notes controller
  final VoidCallback onSave;
  final VoidCallback onCancel;
 

  @override
  Widget build(BuildContext context) {
    Category _selectedCategory = Category.study;
    Difficulty _selectedDifficulty = Difficulty.easy;
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
           Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                value: _selectedCategory,
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
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 5,
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
                value: _selectedDifficulty,
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
                    setState(() {
                      _selectedDifficulty = value;
                    });
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
          onPressed: onSave,
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
