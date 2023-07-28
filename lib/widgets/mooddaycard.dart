import 'package:flutter/material.dart';
import 'package:zenith/models/moodcard.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        CircularProgressIndicator(),
        Container(
          margin: EdgeInsets.only(left: 5),
          child: Text("Deleting entry..."),
        ),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class MoodDay extends StatefulWidget {
  final String userId;
  final String docId;
  final String date;
  final GlobalKey<_MoodDayState> moodDayKey = GlobalKey<_MoodDayState>();

  final String mood;
  final String image;
  final List<String> a;
  final List<String> b;

  MoodDay(this.userId, this.docId, this.image, this.date, this.mood, this.a,
      this.b);

  bool _isMounted = false;

  @override
  _MoodDayState createState() => _MoodDayState();
}

class _MoodDayState extends State<MoodDay> {
  @override
  void initState() {
    super.initState();
    // Set the flag to true when the widget is mounted
    widget._isMounted = true;
  }

  @override
  void dispose() {
    // Set the flag to false when the widget is disposed
    widget._isMounted = false;
    super.dispose();
  }

  String formatReadableDate(String dateString) {
    DateTime date = DateTime.parse(dateString);

    String formattedDate = DateFormat.yMMMMd().format(date);
    String period = '';

    int hour = date.hour;

    if (hour >= 0 && hour < 12) {
      period = 'Morning';
    } else if (hour >= 12 && hour < 18) {
      period = 'Afternoon';
    } else {
      period = 'Night';
    }

    return '$formattedDate $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 80,
      child: Card(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    child: Image.asset(widget.image),
                    height: 45,
                    width: 45,
                  ),
                  SizedBox(width: 15),
                  Text(
                    widget.mood,
                    style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    formatReadableDate(widget.date),
                    style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Spacer(),
                  SizedBox(width: 30),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      // Show the loader dialog
                      await Provider.of<MoodCard>(context, listen: false)
                          .deletePlaces(widget.userId, widget.docId);

                      // Check if the widget is still mounted before calling setState
                      if (widget._isMounted) {
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 80),
                    ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.a.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: <Widget>[
                            Image.asset(widget.a[index]),
                            SizedBox(width: 25),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 50),
              Expanded(
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 80),
                    ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.b.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: <Widget>[
                            Text(
                              widget.b[index] ?? 'nothing',
                              style: TextStyle(
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
