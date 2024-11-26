import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          .select(
              'id, description, due_date, url, grade, date_passed, students(first_name, last_name)')
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
        task['status'] = 'Graded'; // Change status to Graded after updating grade
      });
    } catch (e) {
      print("Error updating grade: $e");
    }
  }

  String calculateStatus(
      DateTime dueDate, String? url, String? grade, String? datePassed) {
    final submissionDate =
        datePassed != null ? DateTime.parse(datePassed) : null;

    if (submissionDate == null) {
      return 'Missing';
    } else if (submissionDate.isAfter(dueDate)) {
      return 'Late';
    } else {
      return grade != null && grade.isNotEmpty ? 'Graded' : 'Submitted';
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
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Student Name')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Due Date')),
                  DataColumn(label: Text('Task URL')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Grade')),
                ],
                rows: tasks.map<DataRow>((task) {
                  final status = calculateStatus(
                    DateTime.parse(task['due_date']),
                    task['url'],
                    task['grade'],
                    task['date_passed'],
                  );

                  final studentName = task['students'] != null
                      ? '${task['students']['first_name']} ${task['students']['last_name']}'
                      : 'Unknown';

                  return DataRow(
                    cells: [
                      DataCell(Text(studentName)),
                      DataCell(Text(task['description'])),
                      DataCell(Text(task['due_date'])),
                      DataCell(Text(task['url'])),
                      DataCell(Text(status)),
                      DataCell(
                        status == 'Submitted' || status == 'Late' || status == 'Graded'
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
    );
  }
}
