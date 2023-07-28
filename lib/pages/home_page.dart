import 'package:flutter/material.dart';
import 'package:zenith/models/actions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zenith/auth.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zenith/class/level.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zenith/datetime/date_time.dart';

//line 406

final List<Actions1> finishedActions = [
  // put it outside of the class so it is accessable from home page
  Actions1(
      title: 'study CS2030S',
      duration: 60,
      difficulty: Difficulty.easy,
      category: Category.study,
      note: 'Learning about asynchronous programming'),
];

class HomePage extends StatefulWidget {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomePage(this._firebaseAuth, this._firestore);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool isAnimationRunning = false;
  WebViewController? _animationController;
  String currentAction = 'No activity';
  String animation = 'Category.others';
  static TextEditingController _titleController = TextEditingController();
  static TextEditingController _timeController = TextEditingController();
  static TextEditingController _noteController = TextEditingController();
  static Category _selectedCategory = Category.study;
  static Difficulty _selectedDifficulty = Difficulty.easy;
  late User? user = Auth(widget._firebaseAuth).currentUser;
  late int _level;
  late int _exp;
  late int _totalExperience;
  late Level acc;
  late String room;

  final Map<String, String> animationMap = {
    'Category.others': 'others.html',
    'Category.rest': 'sleep.html',
    'Category.workout': 'walk.html',
    'Category.study': 'study.html'
  };

  final Map<String, String> roomMap = {
    'Green': 'red',
    'Brown': 'white',
    'Purple': 'black',
    'Blue': 'blue'
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _level = 0;
    _exp = 0;
    _totalExperience = 0;
    room = 'blue';
    _loadFirestoreLevel();
    String roomCol = 'Brown';

    // Define a function to initialize the WebViewController and load the request
    void initializeWebView(String roomCol) {
      _animationController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              setState(() {
                isLoading = progress < 100;
              });
            },
            onPageStarted: (String url) {
              setState(() {
                isLoading = true;
                isAnimationRunning = true;
              });

              Future.delayed(Duration(seconds: 1), () {
                if (!mounted)
                  return; // Avoid calling setState if the widget is disposed
                setState(() {
                  isAnimationRunning = true;
                });
              });
            },
            onPageFinished: (String url) {
              setState(() {
                isLoading = false;
                isAnimationRunning = true;
              });
            },
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(
            'https://gerardjm018.github.io/animationproto/' +
                roomMap[roomCol]! +
                animationMap[Category.others.toString()]!));
    }

    // Call _getRoomC() and wait for the result before initializing the WebView
    _getRoomC().then((String result) {
      setState(() {
        roomCol = result; // Set the state variable roomCol
        initializeWebView(
            roomCol); // Initialize WebView with the obtained roomCol value
      });
    });
  }

  _loadFirestoreLevel() async {
    final snap = await FirebaseFirestore.instance
        .collection('level')
        .where('email', isEqualTo: user?.email ?? 'User email')
        .withConverter(
            fromFirestore: Level.fromFirestore,
            toFirestore: (level, options) => level.toFirestore())
        .get();
    if (snap.docs.isEmpty) {
      _createLevel();
      return _loadFirestoreLevel();
    }
    for (var doc in snap.docs) {
      final level = doc.data();
      final totalExp = level.experience;
      _totalExperience = totalExp;
      if (totalExp <= 90) {
        _level = 1 + (totalExp / 10).floorToDouble().round();
      } else {
        _level = ((totalExp - 90) / 100).floorToDouble().round() + 10;
      }
      if (totalExp > 90) {
        _exp = (totalExp - 90) - 100 * (_level - 10);
      } else {
        _exp = totalExp - 10 * (_level - 1);
      }
      acc = level;
      room = level.room;
    }
    setState(() {});
  }

  Future<String> _getRoomC() async {
    final snap = await widget._firestore
        .collection('level')
        .where('email', isEqualTo: user?.email ?? 'User email')
        .withConverter(
            fromFirestore: Level.fromFirestore,
            toFirestore: (level, options) => level.toFirestore())
        .get();

    String abc = 'Brown';
    for (var doc in snap.docs) {
      final level = doc.data();
      abc = level.room;
    }
    return abc;
  }

  void _createLevel() async {
    await FirebaseFirestore.instance.collection('level').add({
      "experience": 0,
      "email": user?.email ?? 'User email',
      "room": "Brown",
    });
  }

  void _editExperience(int gainedExp) async {
    await FirebaseFirestore.instance.collection('level').doc(acc.id).update({
      "experience": _totalExperience + gainedExp,
      "email": user?.email ?? 'User email',
      "room": room,
    });
    _loadFirestoreLevel();
  }

  double getShapeHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight;
  }

  double getShapeWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth;
  }

  void activitySet(TextEditingController title) {
    _titleController = title;
  }

  double progressPercentage =
      0; // 1st bug+ the timer keeps getting faster 2nd = the bar doesnt reset -> fixed
  // when add new action, reset to 0, no wsolve timer getting faster
  Timer? timer;

  void startProgressTimer(int menit) {
    double increment = 1.0 / ((menit));
    const duration = Duration(seconds: 1);
    Timer.periodic(duration, (timer) {
      setState(() {
        if (progressPercentage >= 1.0) {
          timer.cancel();
          setState(() {
            currentAction = 'finished';
          });
        } else if (progressPercentage <= -1.0) {
          timer.cancel();
        } else {
          progressPercentage += increment;
        }
      }); //here
    });
  }

  void _cancelActivity() {
    setState(() {
      currentAction = 'No activity';
      progressPercentage = 0.0;
      TimerController timerController = Get.find<TimerController>();
      timerController.startTimer(0);
      progressPercentage = -1.0;
      _animationController!.loadRequest(Uri.parse(
          'https://gerardjm018.github.io/animationproto/' +
              roomMap[room]! +
              animationMap[Category.others.toString()]!));
    });
    _titleController.clear();
  }

  int _categoryToInt(Category category) {
    if (category == Category.rest) {
      return 0;
    } else if (category == Category.study) {
      return 1;
    } else {
      return 1;
    }
  }

  int _dificultyToInt(Difficulty difficulty) {
    if (difficulty == Difficulty.easy) {
      return 1;
    } else if (difficulty == Difficulty.hard) {
      return 3;
    } else {
      return 2;
    }
  }

  void _finishActivity() {
    int selectedCat = _categoryToInt(finishedActions.last.category);
    int selectedDif = _dificultyToInt(finishedActions.last.difficulty);
    int selectedDur = finishedActions.last.duration;
    _editExperience(selectedDur * selectedDif * selectedCat);
    setState(() {
      currentAction = 'No activity';
      progressPercentage = 0.0;
      _animationController!.loadRequest(Uri.parse(
          'https://gerardjm018.github.io/animationproto/' +
              roomMap[room]! +
              animationMap[Category.others.toString()]!));
    });
    _titleController.clear();
  }

  void _addActions(Actions1 actions) {
    setState(() {
      currentAction = 'loading';
      progressPercentage = 0;
      finishedActions.add(actions);
      TimerController timerController = Get.find<TimerController>();
      timerController.startTimer(actions.duration * 60);
      startProgressTimer(actions.duration * 60);
      _animationController!.loadRequest(Uri.parse(
          'https://gerardjm018.github.io/animationproto/' +
              roomMap[room]! +
              animationMap[actions.category.toString()]!));
    });
  }

  void _changeRoom(String rooms) {
    String act;

    if (currentAction == 'No activity') {
      act = Category.others.toString();
    } else {
      act = finishedActions.last.category.toString();
    }

    setState(() {
      room = rooms;
      _animationController!.loadRequest(Uri.parse(
          'https://gerardjm018.github.io/animationproto/' +
              roomMap[rooms]! +
              animationMap[act]!));
    });
  }

  void _openAddActionsOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return NewAction(onAddAction: _addActions);
      },
    );
  }

  Widget _activityBar(BuildContext context) {
    final bool isActionFinished = currentAction == 'finished';

    return Container(
      height: getShapeHeight(context) * 0.0625,
      width: getShapeWidth(context) * 0.97,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            Color(0xFFCED3C4),
            Color(0xFFD8D8D8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _titleController.text.isEmpty
                ? currentAction
                : finishedActions.last.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActionFinished ? Colors.green : Colors.black,
            ),
          ),
          SizedBox(
            width: 100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFCED3C4),
                    Color(0xFFD8D8D8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: TimerClass(isActionFinished: isActionFinished),
            ),
          ),
        ],
      ),
    );
  }

  void _OpenRoomOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return MyRoom(
          onAddAction: _changeRoom,
        );
      },
    );
  }

  Widget _refresh() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF9F59),
            Color(0xFFF98A4F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          _loadFirestoreLevel();

          setState(() {
            if (currentAction == 'loading' || currentAction == 'finished') {
              _animationController!.loadRequest(Uri.parse(
                'https://gerardjm018.github.io/animationproto/' +
                    roomMap[room]! +
                    animationMap[finishedActions.last.category.toString()]!,
              ));
            } else {
              _animationController!.loadRequest(Uri.parse(
                'https://gerardjm018.github.io/animationproto/' +
                    roomMap[room]! +
                    animationMap[Category.others.toString()]!,
              ));
            }
          });
        },
        icon: Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _room(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(right: 2, left: 4),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF9F59), Color(0xFFF98A4F)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _OpenRoomOverlay,
              icon: Icon(
                Icons.chair,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          Text('Room',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ))
        ],
      ),
    );
  }

  Widget _pointsWidget(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber,
          ),
          child: Center(
            child: Text(
              _level.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Text('level',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  Widget _refreshButton(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 45,
          height: 45,
          child: AdvancedCircularProgressIndicator(
            value: _level < 10 ? _exp / 10 : _exp / 100,
            strokeWidth: 3.0,
            backgroundColor: const Color.fromARGB(255, 199, 200, 196),
            progressColor: Colors.green, // Choose the progress color you desire
            radius: 20, // Adjust the radius to match your preferred style
            padding: 8,
          ),
        ),
        Text('Exp %',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ))
      ],
    );
  }

  Widget _refreshAndPoint(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pointsWidget(context),
        SizedBox(width: 15),
        _refreshButton(context),
        SizedBox(width: 15),
        _room(context)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isActionLoading = currentAction == 'loading';
    Get.put(TimerController());
    Widget progress = Container(
      height: getShapeHeight(context) * 0.020,
      width: getShapeWidth(context) * 0.50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: Color.fromARGB(255, 250, 249, 249),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.0),
        child: AdvancedLinearProgressIndicator(
          value: progressPercentage,
          minHeight: 20,
          backgroundColor: const Color.fromARGB(255, 199, 200, 196),
          progressGradientColors: [
            const Color.fromARGB(255, 11, 122, 68), // Start Color
            const Color.fromARGB(255, 0, 175, 88), // End Color
          ],
        ),
      ),
    );
    return MaterialApp(
      title: 'Home Page',
      color: Colors.black,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 219, 221, 220),
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Home Page',
              style: TextStyle(color: Colors.black),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Container(
              child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    children: [
                      _activityBar(context),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _titleController.text == '' ? SizedBox() : progress,
                          Row(
                            children: [
                              _refreshAndPoint(context),
                              //_room(context),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          Container(
                            width: 390,
                            height: 430,
                            child: _animationController == null
                                ? Center(
                                    child: Transform.scale(
                                      scale:
                                          3, // Adjust the scale to make the indicator smaller or larger
                                      child: CircularProgressIndicator(
                                        strokeWidth: 5,
                                      ),
                                    ),
                                  )
                                : WebViewWidget(
                                    controller: _animationController!),
                          ),
                        ],
                      ) // Show loading indicator while WebView is loading
                    ],
                  ))),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "home",
          onPressed: () {
            if (currentAction == 'No activity') {
              _openAddActionsOverlay();
            } else if (isActionLoading) {
              _cancelActivity();
            } else {
              _finishActivity();
            }
          },
          backgroundColor: isActionLoading
              ? Color.fromARGB(255, 37, 50, 226)
              : Colors.orange,
          elevation: 8.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: EdgeInsets.all(isActionLoading ? 6.0 : 10.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                isActionLoading
                    ? SquareCircularProgressIndicator(
                        size: 50.0, // Replace this with your desired size
                        color: Colors.white,
                      )
                    : Icon(
                        // Conditionally set the icon here
                        currentAction == 'No activity'
                            ? Icons.add
                            : Icons.check,
                        size: 30,
                        color: Colors.white,
                      ),
                if (isActionLoading)
                  Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class TimerController extends GetxController {
  Timer? _timer;
  int remainingSeconds = 0;
  final time = '00.00'.obs;

  @override
  void onClose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.onClose();
  }

  startTimer(int menit) {
    const duration = Duration(milliseconds: 1000);
    remainingSeconds = menit;
    _timer = Timer.periodic(duration, (Timer timer) {
      if (remainingSeconds == -1) {
        timer.cancel();
      } else {
        int minutes = remainingSeconds ~/ 60;
        int seconds = (remainingSeconds % 60);
        time.value = minutes.toString().padLeft(2, "0") +
            ":" +
            seconds.toString().padLeft(2, "0");
        remainingSeconds--;
      }
    });
  }
}

class SquareCircularProgressIndicator extends StatelessWidget {
  final double size;
  final Color color;

  SquareCircularProgressIndicator({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3.0,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class TimerClass extends GetView<TimerController> {
  const TimerClass({required this.isActionFinished, Key? key})
      : super(key: key);
  final bool isActionFinished;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFCED3C4),
                Color(0xFFD8D8D8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Container(
            height: 70,
            width: 100,
            child: Obx(
              () => Center(
                child: Text(
                  controller.time.value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isActionFinished ? Colors.green : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NewAction extends StatefulWidget {
  const NewAction(
      {required this.onAddAction,
      super.key}); // called at page controller line 44
  final void Function(Actions1 actions) onAddAction;

  @override
  _NewActionState createState() => _NewActionState();
}

enum NewActionMode {
  ChooseHabit,
  InputManually,
}

class _NewActionState extends State<NewAction> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _noteController = TextEditingController();
  Category _selectedCategory = Category.study;
  Difficulty _selectedDifficulty = Difficulty.easy;

  NewActionMode _currentMode = NewActionMode.ChooseHabit;

  void _onChooseHabitButtonPressed() {
    setState(() {
      _currentMode = NewActionMode.ChooseHabit;
    });
  }

  void _onInputManuallyButtonPressed() {
    setState(() {
      _currentMode = NewActionMode.InputManually;
    });
  }

  String getUserId() {
    // new change
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    // If the user is not authenticated or null, handle the case accordingly
    // For example, you can return a default or empty string
    return '';
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamData() {
    String userID = getUserId();
    // Get the current date in "yyyy-mm-dd" format
    String currentDateStr = convertDateTimeToString(DateTime.now());

    CollectionReference habits =
        firestore.collection("users").doc(userID).collection("habits");

    // Listen to the "habits" subcollection for the current date only
    return habits.doc(currentDateStr).collection("habits").snapshots();
  }

  void _submitActionData() {
    final enteredDuration = int.tryParse(_timeController.text);
    final amountIsInvalid = enteredDuration == null || enteredDuration <= 0;
    if (_titleController.text.trim().isEmpty || amountIsInvalid) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text('Invalid Input'),
                content: const Text(
                    'Please make sure a valid title, amount, difficulty level, and category was entered'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: const Text('Okay'))
                ],
              ));
      return;
    }
    widget.onAddAction(Actions1(
        // onAddAction at line 6
        title: _titleController.text,
        duration: enteredDuration,
        difficulty: _selectedDifficulty,
        category: _selectedCategory,
        note: _noteController.text));
    _HomePageState().activitySet(_titleController);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // or SizedBox(height: 96) for spacing
          height: 28, // Adjust the height to move the app bar down
        ),
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: Text('New Action'),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: ListView(
                  children: _currentMode == NewActionMode.ChooseHabit
                      ? _buildChooseHabitView()
                      : _buildInputManuallyView(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChooseHabitView() {
    return [
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _onChooseHabitButtonPressed,
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  "Habit Tracker",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: _onInputManuallyButtonPressed,
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  "Input Manually",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildInputManuallyView() {
    return [
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _onChooseHabitButtonPressed,
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  "Habit Tracker",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: _onInputManuallyButtonPressed,
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  "Input Manually",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 10,
      ),
      TextField(
        controller: _titleController,
        maxLength: 20,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          labelText: 'Title',
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey, // Outline color
              width: 2, // Outline width
            ),
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
        ),
      ),
      TextField(
        controller: _timeController,
        maxLength: 50,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            suffixText: 'minutes ',
            labelText: 'Duration',
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey, // Outline color
                width: 2, // Outline width
              ),
              borderRadius: BorderRadius.circular(8),
              // Rounded corners
            )),
      ),
      TextField(
        controller: _noteController,
        maxLength: 100,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
            suffixText: ' ',
            labelText: 'Note',
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey, // Outline color
                width: 2, // Outline width
              ),
              borderRadius: BorderRadius.circular(8),
              // Rounded corners
            )),
      ),
      const SizedBox(
        height: 16,
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
      ),
      SizedBox(
        height: 10,
      ),
      ElevatedButton(
        onPressed: _submitActionData,
        style: ElevatedButton.styleFrom(
          primary: Colors.orange, // Set the background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          padding:
              EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Add padding
        ),
        child: const Text(
          "Save",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set the text color
          ),
        ),
      ),

      // Rest of the code remains the same
    ];
  }
}

class MyRoom extends StatefulWidget {
  const MyRoom(
      {required this.onAddAction,
      super.key}); // called at page controller line 44
  final void Function(String rooms) onAddAction;

  @override
  State<MyRoom> createState() => _MyRoomState();
}

class _MyRoomState extends State<MyRoom> {
  late int _level;
  late int _exp;
  late int _totalExperience;
  late Level acc;
  late String room;
  final User? user = Auth(FirebaseAuth.instance).currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _level = 0;
    _exp = 0;
    _totalExperience = 0;
    room = 'blue';
    _loadFirestoreLevel();
  }

  _loadFirestoreLevel() async {
    final snap = await FirebaseFirestore.instance
        .collection('level')
        .where('email', isEqualTo: user?.email ?? 'User email')
        .withConverter(
            fromFirestore: Level.fromFirestore,
            toFirestore: (level, options) => level.toFirestore())
        .get();
    for (var doc in snap.docs) {
      final level = doc.data();
      final totalExp = level.experience;
      _totalExperience = totalExp;
      if (totalExp <= 90) {
        _level = 1 + (totalExp / 10).floorToDouble().round();
      } else {
        _level = ((totalExp - 90) / 100).floorToDouble().round() + 10;
      }
      if (totalExp > 90) {
        _exp = (totalExp - 90) - 100 * (_level - 10);
      } else {
        _exp = totalExp - 10 * (_level - 1);
      }
      acc = level;
      room = level.room;
    }
    setState(() {});
  }

  void _editRoom(String appliedRoom) async {
    await FirebaseFirestore.instance.collection('level').doc(acc.id).update({
      "experience": _totalExperience,
      "email": user?.email ?? 'User email',
      "room": appliedRoom,
    });
  }

  Widget _cardRoom(String roomStyle, int levelC) {
    if (_level >= levelC) {
      return Card(
          child: Container(
        child: TextButton(
          child: Text(roomStyle),
          onPressed: () {
            _editRoom(roomStyle);
            widget.onAddAction(roomStyle);
            Navigator.pop(context);
          },
        ),
        height: 70,
      ));
    } else {
      return Card(
          color: Colors.grey,
          child: Container(
            child: Center(
                child: Opacity(
                    opacity: 0.8,
                    child: Text(
                      'Unlocked at level ' + levelC.toString(),
                    ))),
            height: 70,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 15,
          ),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Container(
                    child: Column(
                  children: [
                    Text("Room Customization"),
                  ],
                )),
              ),
              body: ListView(
                children: [
                  _cardRoom('Brown', 1),
                  _cardRoom('Blue', 5),
                  _cardRoom('Purple', 15),
                  _cardRoom('Green', 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdvancedLinearProgressIndicator extends StatefulWidget {
  final double value;
  final double minHeight;
  final Color backgroundColor;
  final List<Color> progressGradientColors;

  AdvancedLinearProgressIndicator({
    required this.value,
    required this.minHeight,
    required this.backgroundColor,
    required this.progressGradientColors,
  });

  @override
  _AdvancedLinearProgressIndicatorState createState() =>
      _AdvancedLinearProgressIndicatorState();
}

class _AdvancedLinearProgressIndicatorState
    extends State<AdvancedLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _progressAnimation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AdvancedLinearProgressIndicator oldWidget) {
    if (oldWidget.value != widget.value) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ),
      );
      _animationController.forward(from: 0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: widget.minHeight,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.progressGradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AdvancedCircularProgressIndicator extends StatefulWidget {
  final double value;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final double radius;
  final double padding;

  AdvancedCircularProgressIndicator({
    required this.value,
    this.strokeWidth = 3.0,
    required this.backgroundColor,
    required this.progressColor,
    this.radius = 20,
    this.padding = 8,
  });

  @override
  _AdvancedCircularProgressIndicatorState createState() =>
      _AdvancedCircularProgressIndicatorState();
}

class _AdvancedCircularProgressIndicatorState
    extends State<AdvancedCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _progressAnimation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AdvancedCircularProgressIndicator oldWidget) {
    if (oldWidget.value != widget.value) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ),
      );
      _animationController.forward(from: 0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: widget.radius * 2 + widget.padding * 2,
          height: widget.radius * 2 + widget.padding * 2,
          padding: EdgeInsets.all(widget.padding),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              Center(
                child: CircularProgressIndicator(
                  strokeWidth: widget.strokeWidth,
                  value: _progressAnimation.value,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.progressColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
