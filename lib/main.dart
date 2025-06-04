import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:simple_golf_gps/course_list.dart';
import 'package:simple_golf_gps/models/coordinates.dart';

import 'models/course.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golfavstånd',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Golfavstånd'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
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
    _initLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      _currentPosition = await _determinePosition();

      const settings = LocationSettings(accuracy: LocationAccuracy.high);

      _positionStream = Geolocator.getPositionStream(locationSettings: settings)
          .listen((Position position) {
            setState(() {
              _currentPosition = position;
            });
          });
    } catch (e) {
      print('Error: $e');
    }
  }

  void loadCoordinates() async {
    final jsonStr = await rootBundle.loadString('lib/assets/coordinates.json');
    setState(() {
      courses = Course.decodeJson(jsonStr);
    });
  }

  void calculateDistances() {
    final myLocation = Coordinates(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
    );
    final hole = selectedCourse!.holes[currentHole];

    front =
        '${myLocation.distanceTo(Coordinates.parseCoordinates(hole.front)).round()} m';
    mid =
        '${myLocation.distanceTo(Coordinates.parseCoordinates(hole.mid)).round()} m';
    back =
        '${myLocation.distanceTo(Coordinates.parseCoordinates(hole.back)).round()} m';
  }

  void stopListeningToLocationChanges() {
    _positionStream?.cancel();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void changeHole(int value) {
    setState(() {
      currentHole += value;
      if (currentHole >= selectedCourse!.holes.length) {
        currentHole = 0;
      } else if (currentHole < 0) {
        currentHole = selectedCourse!.holes.length - 1;
      }
      calculateDistances();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(selectedCourse?.name ?? ''),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (selectedCourse != null) ...[
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      changeHole(-1);
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      "Hål ${currentHole + 1}",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      changeHole(1);
                    },
                    child: Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (selectedCourse != null) ...[
                      Text(front!),
                      Text(mid!),
                      Text(back!),
                    ],
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Välj en golfbana!', style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final course = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CourseList(courses: courses);
            },
          );
          if (course != null) {
            setState(() {
              selectedCourse = course;
              calculateDistances();
            });
          }
        },
        tooltip: 'Välj bana',
        child: const Icon(Icons.location_on_outlined),
      ),
    );
  }
}
