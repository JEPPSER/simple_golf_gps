import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_golf_gps/course_list.dart';
import 'package:simple_golf_gps/models/coordinates.dart';

import 'models/course.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Course> courses;
  Course? selectedCourse;
  int currentHole = 0;
  String? mid;
  String? front;
  String? back;

  @override
  void initState() {
    super.initState();
    loadCoordinates();
  }

  void loadCoordinates() async {
    final jsonStr = await rootBundle.loadString('lib/assets/coordinates.json');
    setState(() {
      courses = Course.decodeJson(jsonStr);
    });
  }

  void calculateDistances() {
    final myLocation = Coordinates(
      latitude: 56.90246410845269,
      longitude: 14.867274261226886,
    );
    final hole = selectedCourse!.holes[currentHole];

    front =
        '${myLocation.distanceTo(Coordinates.parseCoordinates(hole.front)).round()} m';
    mid =
        '${myLocation.distanceTo(Coordinates.parseCoordinates(hole.mid)).round()} m';
    back =
        '${myLocation.distanceTo(Coordinates.parseCoordinates(hole.back)).round()} m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(selectedCourse?.name ?? ''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (selectedCourse != null) ...[
              Text(front!),
              Text(mid!),
              Text(back!),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final course = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CourseList(courses: courses);
            },
          );
          setState(() {
            selectedCourse = course;
            calculateDistances();
          });
        },
        tooltip: 'Välj bana',
        child: const Icon(Icons.location_on_outlined),
      ),
    );
  }
}
