import 'package:flutter/material.dart';
import 'package:zenith/helpers/mooddata.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:zenith/models/moodcard.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zenith/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodChart extends StatefulWidget {
  @override
  _MoodChartState createState() => _MoodChartState();
}

class _MoodChartState extends State<MoodChart> {
  List<Color> defaultColorList = [
    Color(0xFFff7675),
    Color(0xFF74b9ff),
    Color(0xFF55efc4),
    Color(0xFFffeaa7),
    Color(0xFFa29bfe),
    Color(0xFFfd79a8),
    Color(0xFFe17055),
    Color(0xFF00b894),
  ];

  late Map<String, double> dataMap = Map();
  Map<String, double> dataMap2 = Map();
  Map<int, int> moodCategoryCount = Map<int, int>();
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('user_moods');

  void updateEmotionCounts() async {
    // Reset count variables for emotions
    setState(() {
      dataMap = {
        'Angry': 0,
        'Happy': 0,
        'Sad': 0,
        'Surprised': 0,
        'Loving': 0,
        'Scared': 0,
      };
    });

    

    Provider.of<MoodCard>(context, listen: false).data.forEach((element) {
      if (element.moodno == 1) {
        
        dataMap['Angry'] = (dataMap['Angry'] ?? 0) + 1;
      } else if (element.moodno == 2) {
        dataMap['Happy'] = (dataMap['Happy'] ?? 0) + 1;
      } else if (element.moodno == 3) {
       
        dataMap['Sad'] = (dataMap['Sad'] ?? 0) + 1;
      } else if (element.moodno == 4) {
        dataMap['Surprised'] = (dataMap['Surprised'] ?? 0) + 1;
      } else if (element.moodno == 5) {
        dataMap['Loving'] = (dataMap['Loving'] ?? 0) + 1;
      } else {
        dataMap['Scared'] = (dataMap['Scared'] ?? 0) + 1;
      }
    });
  }

  void updateActivityCounts() {
    // Reset count variables for activities
    dataMap2.clear();

    Provider.of<MoodCard>(context, listen: false).actiname.forEach((element) {
      if (element == 'Sports')
        dataMap2['Sports'] = (dataMap2['Sports'] ?? 0) + 1;
      else if (element == 'Sleep')
        dataMap2['Sleep'] = (dataMap2['Sleep'] ?? 0) + 1;
      else if (element == 'Shop')
        dataMap2['Shop'] = (dataMap2['Shop'] ?? 0) + 1;
      else if (element == 'Relax')
        dataMap2['Relax'] = (dataMap2['Relax'] ?? 0) + 1;
      else if (element == 'Read')
        dataMap2['Read'] = (dataMap2['Read'] ?? 0) + 1;
      else if (element == 'Movies')
        dataMap2['Movies'] = (dataMap2['Movies'] ?? 0) + 1;
      else if (element == 'Gaming')
        dataMap2['Gaming'] = (dataMap2['Gaming'] ?? 0) + 1;
      else
        dataMap2['Friends'] = (dataMap2['Friends'] ?? 0) + 1;
    });
  }

  @override
  void initState() {
    super.initState();

    updateEmotionCounts();
    updateActivityCounts();
  }

  @override
  Widget build(BuildContext context) {
    List<MoodData> data = Provider.of<MoodCard>(context, listen: true).data;

    if (data.isEmpty) {
      // Set a default state when there are no moods
      return Scaffold(
        appBar: AppBar(
          title: Text('Mood Graph'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Text('No moods available'),
        ),
      );
    }

    List<charts.Series<MoodData, String>> series = [
      charts.Series(
        id: 'Moods',
        data: data,
        domainFn: (MoodData series, _) => series.date.toString(),
        measureFn: (MoodData series, _) => series.moodno,
        colorFn: (MoodData series, _) => charts.ColorUtil.fromDartColor(
          Color(0xFF74b9ff),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Graph'),
        backgroundColor: Colors.red,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        children: <Widget>[
          SizedBox(
            height: 108,
            width: 300,
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: (300 - 30) / (108 - 30),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              children: List.generate(
                6,
                (index) => MyMoodCard(
                  Text(
                    "${index + 1} - ${[
                      'Angry',
                      'Happy',
                      'Sad',
                      'Surprised',
                      'Loving',
                      'Scared'
                    ][index]}",
                    textAlign: TextAlign.center,
                  ),
                  direction: 1,
                ),
              ),
            ),
          ),
          Container(
            height: 30,
          ),
          if (dataMap.isNotEmpty)
            Container(
              width: 200,
              child: MyMoodCard(
                PieChart(
                  dataMap: dataMap,
                  animationDuration: Duration(milliseconds: 800),
                  chartLegendSpacing: 32.0,
                  chartRadius: MediaQuery.of(context).size.width / 2.7,
                  chartType: ChartType.disc,
                  legendOptions: LegendOptions(
                    showLegendsInRow: true,
                    legendPosition: LegendPosition.bottom,
                    showLegends: true,
                    legendShape: BoxShape.circle,
                    legendTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  chartValuesOptions: ChartValuesOptions(
                    showChartValueBackground: true,
                    showChartValues: true,
                    showChartValuesInPercentage: true,
                    showChartValuesOutside: false,
                    decimalPlaces: 1,
                  ),
                ),
              ),
            ),
          SizedBox(height: 20),
          if (dataMap2.isNotEmpty)
            Container(
              width: 200,
              child: MyMoodCard(
                PieChart(
                  dataMap: dataMap2,
                  animationDuration: Duration(milliseconds: 800),
                  chartLegendSpacing: 32.0,
                  chartRadius: MediaQuery.of(context).size.width / 2.7,
                  chartType: ChartType.disc,
                  legendOptions: LegendOptions(
                    showLegendsInRow: true,
                    legendPosition: LegendPosition.bottom,
                    showLegends: true,
                    legendShape: BoxShape.circle,
                    legendTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  chartValuesOptions: ChartValuesOptions(
                    showChartValueBackground: true,
                    showChartValues: true,
                    showChartValuesInPercentage: true,
                    showChartValuesOutside: false,
                    decimalPlaces: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MyMoodCard extends StatefulWidget {
  Widget w;
  int direction; //0 - Left, 1 - Right. By default 0
  MyMoodCard(this.w, {this.direction = 0});

  @override
  _MyMoodCardState createState() => _MyMoodCardState();
}

class _MyMoodCardState extends State<MyMoodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.ease));
    _animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: widget.w,
        ),
      ),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(1 - _slideAnimation.value, 0) *
              (widget.direction == 0 ? -1 : 1) *
              40,
          child: child,
        );
      },
    );
  }
}
