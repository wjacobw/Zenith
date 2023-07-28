import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zenith/class/event.dart';
import 'package:zenith/pages/add_event.dart';
import 'package:zenith/pages/edit_event.dart';
import 'package:zenith/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final User? user = Auth(FirebaseAuth.instance).currentUser;
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  String _calendarMode = 'Month';
  late Map<DateTime, List<Event>> _events;

  List<String> calenderMode = ['Month', 'Biweekly', 'Week'];

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _events = LinkedHashMap(
      equals: isSameDay,
      hashCode: getHashCode,
    );
    _focusedDay = DateTime.now();
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _loadFirestoreEvents();
  }

  _loadFirestoreEvents() async {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    _events = {};

    final snap = await FirebaseFirestore.instance
        .collection('events')
        .where('email', isEqualTo: user?.email ?? 'User email')
        .where('date', isGreaterThanOrEqualTo: firstDay)
        .where('date', isLessThanOrEqualTo: lastDay)
        .orderBy('date')
        .orderBy('startH')
        .orderBy('startM')
        .withConverter(
            fromFirestore: Event.fromFirestore,
            toFirestore: (event, options) => event.toFirestore())
        .get();
    for (var doc in snap.docs) {
      final event = doc.data();
      final day =
          DateTime.utc(event.date.year, event.date.month, event.date.day);
      if (_events[day] == null) {
        _events[day] = [];
      }
      _events[day]!.add(event);
    }
    setState(() {});
  }

  List _getEventsForTheDay(DateTime day) {
    return _events[day] ?? [];
  }

  Widget tableCalendar(BuildContext context) {
    return TableCalendar(
      eventLoader: _getEventsForTheDay,
      headerStyle: HeaderStyle(
          decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          titleCentered: true,
          formatButtonVisible: false,
          headerPadding: EdgeInsets.only(top: 30)),
      calendarStyle: CalendarStyle(
        tablePadding: EdgeInsets.only(top: 10),
      ),
      focusedDay: _focusedDay,
      firstDay: _firstDay,
      lastDay: _lastDay,
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        _loadFirestoreEvents();
      },
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 199, 200, 196),
        body: Padding(
            padding: EdgeInsets.all(10),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(
                height: 30,
              ),
              Container(
                width: 150,
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: DropdownButtonFormField(
                  value: _calendarMode,
                  items: calenderMode
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      if (value == 'Month') {
                        _calendarMode = value;
                        _calendarFormat = CalendarFormat.month;
                      } else if (value == 'Week') {
                        _calendarMode = value;
                        _calendarFormat = CalendarFormat.week;
                      } else {
                        _calendarMode = value;
                        _calendarFormat = CalendarFormat.twoWeeks;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    border:
                        InputBorder.none, // Remove the border around the button
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    color: Colors.white,
                  ),
                  child: tableCalendar(context)),
              Expanded(
                  child: ListView(children: [
                ..._getEventsForTheDay(_selectedDay).map(
                  (event) => Card(
                      child: EventItem(
                          event: event,
                          onTap: () async {
                            final res = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditEvent(
                                    firstDate: _firstDay,
                                    lastDate: _lastDay,
                                    event: event),
                              ),
                            );
                            if (res ?? false) {
                              _loadFirestoreEvents();
                            }
                          },
                          onDelete: () async {
                            final delete = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete Event?"),
                                content: const Text(
                                    "Are you sure you want to delete?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text("Yes"),
                                  ),
                                ],
                              ),
                            );
                            if (delete ?? false) {
                              await FirebaseFirestore.instance
                                  .collection('events')
                                  .doc(event.id)
                                  .delete();
                              _loadFirestoreEvents();
                            }
                          })),
                )
              ])),
            ])),
        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          heroTag: "schedule",
          backgroundColor: Colors.orange,
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => AddEvent(
                  firstDate: _firstDay,
                  lastDate: _lastDay,
                  selectedDate: _selectedDay,
                ),
              ),
            );
            if (result ?? false) {
              _loadFirestoreEvents();
            }
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class EventItem extends StatelessWidget {
  final Event event;
  final Function() onDelete;
  final Function()? onTap;
  const EventItem({
    Key? key,
    required this.event,
    required this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        event.title,
      ),
      subtitle: Text(
          TimeOfDay(hour: event.startH, minute: event.startM).format(context) +
              ' until ' +
              TimeOfDay(hour: event.endH, minute: event.endM).format(context)),
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}
