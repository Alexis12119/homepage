import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// College Course table
// INSERT INTO "public"."college_course" ("id", "name", "year_number", "code", "semester") VALUES ('1', 'Networking 2', '2', 'NET212', '2'), ('2', 'Advanced Software Development', '3', 'ITProfEL1', '1'), ('3', 'Computer Programming 1', '1', 'CC111', '2'), ('4', 'Computer Programming 2', '1', 'CC112', '2'), ('5', 'Computer Programming 3', '2', 'CC123', '1'), ('6', 'Capstone 1', '3', 'CP111', '2'), ('7', 'Teleportation 1', '4', 'TP111', '1'), ('8', 'Teleportation 2', '4', 'TP222', '2'), ('9', 'Living in the IT Era', '1', 'LITE', '1');

// Student Courses table
// INSERT INTO "public"."student_courses" ("student_id", "course_id", "midterm_grade", "status", "id") VALUES ('2', '3', '5.00', 'Pending', '3'), ('2', '4', '5.00', 'Approved', '2'), ('2', '9', '5.00', 'Pending', '1');

// Students Table
// INSERT INTO "public"."students" ("id", "email", "password", "last_name", "section_id", "program_id", "department_id", "grade_status", "first_name") VALUES ('1', 'test@gmail.com', 'test123', 'Manalo', '2', '1', '1', 'Pending', 'Jiro'), ('2', 'corporal461@gmail.com', 'Alexis-121', 'Corporal ', '1', '1', '1', 'Pending', 'Alexis'), ('3', 'kim@gmail.com', 'kim123', 'Caguite', '1', '1', '1', 'Pending', 'Kim'), ('5', 'hello@gmail.com', '123', 'World', '1', '1', '1', 'Pending', 'Hello'), ('6', 'dugong@gmail.com', '123', 'Black', '2', '1', '1', 'Pending', 'Dugong'), ('7', 'john@gmail.com', '123', 'Doe', '3', '1', '1', 'Pending', 'John');

// Tasks table
// INSERT INTO "public"."tasks" ("id", "due_date", "description", "url", "student_id", "course_id", "drive", "youtube", "file", "status", "grade") VALUES ('1', '2024-11-23', 'This is the description', 'jiro', '2', '3', null, null, null, '', ''), ('2', '2024-11-30', 'This is the second description', 'haha', '2', '4', null, null, null, '', ''), ('3', '2024-11-21', 'This is the description', 'google.com', '2', '9', null, null, null, '', ''), ('4', '2024-11-30', 'Bad Description', 'sir hensonn beke nemen', '5', '3', null, null, null, '', ''), ('5', '2024-11-30', 'test', null, null, '6', null, null, null, '', ''), ('6', '2024-11-30', 'test 101', 'test.link', null, '3', 'test.google', 'test.yt', null, '', ''), ('7', '2024-11-30', 'Testing lang magdamag maghapon', 'linkpapuntasalangit', null, '3', 'testulit.drive', 'testmoto.yt', null, '', ''), ('8', '2024-12-31', 'asdasdasdas', 'rere', null, '6', 'test', 'resr', null, '', '');
class ActivityDetailsPage extends StatefulWidget {
  // Props passed to this page
  final String teacherId;
  final String className;
  final String section;
  final String courseName;
  final String programName;
  final String departmentName;
  final String yearNumber;

  const ActivityDetailsPage({
    super.key,
    required this.teacherId,
    required this.className,
    required this.section,
    required this.courseName,
    required this.programName,
    required this.departmentName,
    required this.yearNumber,
  });

  @override
  ActivityDetailsPageState createState() => ActivityDetailsPageState();
}

class ActivityDetailsPageState extends State<ActivityDetailsPage> {
  int selectedCourseId = -1;
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchCourses().then((_) {
      if (selectedCourseId != -1) {
        fetchTasks();
      }
    });
  }

  Future<void> fetchCourses() async {
    try {
      final data = await Supabase.instance.client
          .from('college_course')
          .select('id')
          .eq('name', widget.courseName);

      setState(() {
        if (data.isNotEmpty) {
          selectedCourseId = data[0]['id'];
        }
      });
    } catch (e) {
      print("Error fetching courses: $e");
    }
  }

  Future<void> fetchTasks() async {
    try {
      final taskData = await Supabase.instance.client
          .from('tasks')
          .select('id, description, due_date, url, grade')
          .eq('course_id', selectedCourseId);

      setState(() {
        tasks = List<Map<String, dynamic>>.from(taskData);
      });
    } catch (e) {
      print("Error fetching tasks: $e");
    }
  }

  Future<void> updateGrade(int taskId, String newGrade) async {
    try {
      await Supabase.instance.client
          .from('tasks')
          .update({'grade': newGrade}).eq('id', taskId);

      setState(() {
        final task = tasks.firstWhere((task) => task['id'] == taskId);
        task['grade'] = newGrade;
      });
    } catch (e) {
      print("Error updating grade: $e");
    }
  }

  String calculateStatus(DateTime dueDate, String? url, String? grade) {
    final currentDate = DateTime.now();

    if (dueDate.isAfter(currentDate) && (url == null || url.isEmpty)) {
      return 'Missing';
    } else if (dueDate.isBefore(currentDate) && url != null && url.isNotEmpty) {
      return grade != null && grade.isNotEmpty ? 'Graded' : 'Submitted';
    } else {
      return 'Missing';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Details'),
      ),
      body: tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Due Date')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Grade')),
                  ],
                  rows: tasks.map((task) {
                    final status = calculateStatus(
                      DateTime.parse(task['due_date']),
                      task['url'],
                      task['grade'],
                    );

                    return DataRow(
                      cells: [
                        DataCell(Text(task['description'])),
                        DataCell(Text(task['due_date'])),
                        DataCell(Text(calculateStatus(
                          DateTime.parse(task['due_date']),
                          task['url'],
                          task['grade'],
                        ))),
                        DataCell(
                          calculateStatus(
                                    DateTime.parse(task['due_date']),
                                    task['url'],
                                    task['grade'],
                                  ) ==
                                  'Graded'
                              ? TextField(
                                  controller: TextEditingController(
                                      text: task['grade']),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 4.0),
                                  ),
                                  onSubmitted: (value) {
                                    updateGrade(task['id'], value);
                                  },
                                )
                              : const Text('N/A'),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
