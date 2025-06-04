import 'package:flutter/material.dart';
import 'package:simple_golf_gps/models/course.dart';

class CourseList extends StatefulWidget {
  final List<Course> courses;

  const CourseList({super.key, required this.courses});

  @override
  CourseListState createState() => CourseListState();
}

class CourseListState extends State<CourseList> {
  final TextEditingController _searchController = TextEditingController();
  late List<Course> _filteredCourses = [];

  @override
  void initState() {
    super.initState();
    _filteredCourses = widget.courses;
    _searchController.addListener(_filterCourses);
  }

  void _filterCourses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses = widget.courses
          .where((course) => course.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Välj bana')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Sök...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _filteredCourses.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredCourses.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(Icons.book, color: Colors.indigo),
                            title: Text(
                              _filteredCourses[index].name,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            onTap: () {
                              Navigator.pop(
                                context,
                                _filteredCourses[index],
                              ); // Return selected course
                            },
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Inga banor hittades',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
