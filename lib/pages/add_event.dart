import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zenith/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEvent extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? selectedDate;

  const AddEvent({
    Key? key,
    required this.firstDate,
    required this.lastDate,
    this.selectedDate,
  }) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final User? user = Auth(FirebaseAuth.instance).currentUser;
  late DateTime _selectedDate;
  static String _type = 'Class';
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _startHController = TextEditingController();
  final _startMController = TextEditingController();
  final _endHController = TextEditingController();
  final _endMController = TextEditingController();
  final _startHMController = TextEditingController();
  final _endHMController = TextEditingController();
  List<String> TypeMode = [
    'Class',
    'Test',
    'Refreshing',
    'Assignment',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
  }

  void _selectTime(
      TextEditingController controller,
      TextEditingController controller2,
      TextEditingController controller3) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      controller.text = pickedTime.hour.toString().padLeft(2, '0');
      controller2.text = pickedTime.minute.toString().padLeft(2, '0');
      controller3.text =
          "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Event")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey, // Outline color
                width: 2, // Outline width
              ),
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _titleController,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: 'Enter Event Title',
                  border: InputBorder.none, // Hide the default underline
                ),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey, // Outline color
                      width: 2, // Outline width
                    ),
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  child: TextField(
                    controller: _startHMController,
                    decoration: InputDecoration(
                      labelText: 'Start Time',
                      border: InputBorder.none, // Hide the default underline
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    readOnly: true,
                    onTap: () => _selectTime(_startHController,
                        _startMController, _startHMController),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey, // Outline color
                      width: 2, // Outline width
                    ),
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  child: TextField(
                    controller: _endHMController,
                    decoration: InputDecoration(
                      labelText: 'End Time',
                      border: InputBorder.none, // Hide the default underline
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    readOnly: true,
                    onTap: () => _selectTime(
                        _endHController, _endMController, _endHMController),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 9),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey,
                width: 2,
              ),
            ),
            child: DropdownButton(
              value: _type,
              items: TypeMode.map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(
                    category,
                  ),
                ),
              ).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _type = value;
                });
              },
              isDense: false,
              itemHeight: 50,
              dropdownColor: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.orange, // Set the border color to orange
                  width: 2.0, // Set the border width
                ),
                borderRadius: BorderRadius.circular(
                    8), // Add rounded corners to the border
              ),
              // Optional: You can add padding to the input field if desired
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _addEvent();
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.orange, // Set the background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12), // Add padding
            ),
            child: Text(
              "Save",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Set the text color
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _newTime(DateTime dTime) {
    return DateTime(dTime.year, dTime.month, dTime.day, 0, 0, 0, 0, 0);
  }

  void _addEvent() async {
    // save event to Firestore
    final title = _titleController.text;
    final description = _descController.text;
    final startH = _startHController.text;
    final startM = _startMController.text;
    final endH = _endHController.text;
    final endM = _endMController.text;
    final type = _type;
    if (title.isEmpty) {
      print('title cannot be empty');
      // you can use snackbar to display error to the user
      return;
    }
    if (startH.isEmpty || startM.isEmpty || endH.isEmpty || endM.isEmpty) {
      print('time cannot be empty');
      // you can use snackbar to display error to the user
      return;
    }
    await FirebaseFirestore.instance.collection('events').add({
      "title": title,
      "description": description,
      "date": Timestamp.fromDate(_newTime(_selectedDate)),
      "startH": int.parse(startH),
      "startM": int.parse(startM),
      "endH": int.parse(endH),
      "endM": int.parse(endM),
      "type": type,
      "email": user?.email ?? 'User email',
    });
    if (mounted) {
      Navigator.pop<bool>(context, true);
    }
  }
}
