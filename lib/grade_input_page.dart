import 'package:flutter/material.dart';
import 'package:lms_homepage/archive_class.dart';
import 'package:lms_homepage/edit_profile_page.dart';
import 'package:lms_homepage/login_page.dart';
import 'package:lms_homepage/upload_grade.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GradeInputPage extends StatefulWidget {
  final String teacherId;
  final String className;
  final String yearNumber;
  final String progamName;
  final String courseName;

  const GradeInputPage(
      {Key? key,
      required this.className,
      required this.courseName,
      required this.teacherId,
      required this.yearNumber,
      required this.progamName})
      : super(key: key);

  @override
  _GradeInputPageState createState() => _GradeInputPageState();
}

class _GradeInputPageState extends State<GradeInputPage> {
  bool isSidebarExpanded = false;
  bool isHovering = false;
  bool isHoveringUpload = false;
  bool isHoveringArchive = false;
  bool isHoveringLogout = false;

  final List<TextEditingController> _midtermGradeControllers = [];
  final List<TextEditingController> _finalsGradeControllers = [];
  final List<bool> _isLocked = [];
  final List<bool> _isSaved = [];
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    fetchStudentData(); // Fetch student data on initialization
    for (int i = 0; i < 5; i++) {
      _midtermGradeControllers.add(TextEditingController());
      _finalsGradeControllers.add(TextEditingController());
      _isLocked.add(false);
      _isSaved.add(false);
    }
  }

  Future<void> fetchStudentData() async {
    try {
      // Fetch the course ID based on the course name, year number, and program name
      final courseData = await Supabase.instance.client
          .from('college_course')
          .select('id')
          .eq('name', widget.courseName)
          .single();

      final courseId = courseData['id'];

      // Fetch students enrolled in the selected course, including course_id
      final studentData = await Supabase.instance.client
          .from('student_courses')
          .select(
              'student_id, course_id, midterm_grade') // Include course_id here
          .eq('course_id', courseId);

      print("Fetched Student Data: $studentData");

      if (studentData.isEmpty) {
        print('No students found for this course.');
        return;
      }

      // Fetch student details
      List<Map<String, dynamic>> enrolledStudents = [];
      for (var student in studentData) {
        final studentDetails = await Supabase.instance.client
            .from('students')
            .select('id, first_name, last_name')
            .eq('id', student['student_id'])
            .single();

        print("Fetched Student Details: $studentDetails");

        enrolledStudents.add({
          'student_id': studentDetails['id'],
          'course_id': student['course_id'], // Include course_id here
          'first_name': studentDetails['first_name'],
          'last_name': studentDetails['last_name'],
          'midterm_grade': student['midterm_grade'],
        });

        print("Current Enrolled Students List: $enrolledStudents");
      }

      setState(() {
        students = enrolledStudents; // Update the state with fetched students
        for (int i = 0; i < students.length; i++) {
          _midtermGradeControllers.add(TextEditingController(
              text: students[i]['midterm_grade']?.toString() ?? ''));
          _finalsGradeControllers.add(TextEditingController());
          _isLocked.add(false);
          _isSaved.add(false);
        }
      });
      print("Updated Students List: $students"); // Print the updated list
    } catch (e) {
      print('Error fetching student data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 70, // Fixed width for the sidebar
            color: const Color.fromARGB(
                255, 44, 155, 68), // Fixed color for the sidebar
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Picture with GestureDetector for navigation
                    Tooltip(
                      message: 'Edit Profile',
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EditProfilePage(teacherId: ''),
                            ),
                          );
                        },
                        child: const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('assets/aliceg.jpg'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Upload Grades Button
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          isHoveringUpload = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          isHoveringUpload = false;
                        });
                      },
                      child: Tooltip(
                        message: 'Upload Grades',
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UploadGradePage(
                                    teacherId: 'teacherId'),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.upload,
                            size: 40,
                            color: isHoveringUpload
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : const Color.fromARGB(255, 0, 0, 0),
                            shadows: isHoveringUpload
                                ? [
                                    const BoxShadow(
                                        color:
                                            Color.fromARGB(255, 69, 238, 106),
                                        blurRadius: 10)
                                  ]
                                : [],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Archive Courses Button
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          isHoveringArchive = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          isHoveringArchive = false;
                        });
                      },
                      child: Tooltip(
                        message: 'Archive Courses',
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ArchiveClassScreen(teacherId: ''),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.archive,
                            size: 40,
                            color: isHoveringArchive
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : const Color.fromARGB(255, 0, 0, 0),
                            shadows: isHoveringArchive
                                ? [
                                    const BoxShadow(
                                        color:
                                            Color.fromARGB(255, 69, 238, 106),
                                        blurRadius: 10)
                                  ]
                                : [],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        isHoveringLogout = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        isHoveringLogout = false;
                      });
                    },
                    child: Tooltip(
                      message: 'Log Out',
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.logout,
                          size: 40,
                          color: isHoveringLogout
                              ? Colors.white
                              : const Color.fromARGB(255, 0, 0, 0),
                          shadows: isHoveringLogout
                              ? [
                                  const BoxShadow(
                                      color: Color.fromARGB(255, 69, 238, 106),
                                      blurRadius: 10)
                                ]
                              : [],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundImage: AssetImage('assets/plsp.png'),
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pamantasan ng Lungsod ng San Pablo",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Brgy. San Jose, San Pablo City',
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(
                                  'Tel No: (049) 536-7830',
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(
                                  'Email Address: plspofficial@plsp.edu.ph',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UploadGradePage(teacherId: widget.teacherId),
                            ),
                          );
                        },
                        color: const Color.fromRGBO(44, 155, 68, 1),
                        tooltip: 'Go back',
                        iconSize: 40,
                      ),
                    ],
                  )),
                  const SizedBox(height: 10),

                  // Class Details
                  Text(
                    widget.courseName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${widget.progamName}-${widget.yearNumber}${widget.className}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Midterm Labels
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(width: 100),
                      Text(
                        "Midterm",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 255),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        return _buildStudentGradeTable(index);
                      },
                    ),
                  ),

                  // Save and Submit Buttons
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _saveGrades,
                          icon:
                              const Icon(Icons.save, color: Color(0xFF2C9B44)),
                          label: const Text(
                            "Save All Grades",
                            style: TextStyle(color: Color(0xFF2C9B44)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _submitGrades,
                          icon:
                              const Icon(Icons.send, color: Color(0xFF2C9B44)),
                          label: const Text(
                            "Submit Grades",
                            style: TextStyle(color: Color(0xFF2C9B44)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentGradeTable(int index) {
    var student = students[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Table(
        children: [
          TableRow(
            children: [
              // Student Image and Name
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          AssetImage('assets/aliceg.jpg'), // Placeholder image
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${student['last_name']} ${student['first_name']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              // Midterm Grade Dropdown
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: _midtermGradeControllers[index].text.isEmpty
                      ? null
                      : _midtermGradeControllers[index].text,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  items: [
                    '1.00',
                    '1.25',
                    '1.50',
                    '1.75',
                    '2.00',
                    '2.25',
                    '2.50',
                    '2.75',
                    '3.00',
                    '3.25',
                    '3.50',
                    '3.75',
                    '4.00',
                    '5.00',
                    'FAILED',
                    'INC',
                    'UW',
                    'OW'
                  ].map((String grade) {
                    return DropdownMenuItem<String>(
                      value: grade,
                      child: Text(grade),
                    );
                  }).toList(),
                  onChanged:
                      !_isLocked[index] // Only allow change if not locked
                          ? (value) {
                              setState(() {
                                _midtermGradeControllers[index].text =
                                    value ?? '';
                              });
                            }
                          : null,
                  isExpanded: true,
                ),
              ),
            ],
          ),
        ],
        border: const TableBorder.symmetric(
          inside: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
      ),
    );
  }

  void _saveGrades() async {
    print("student list: $students");
    int minLength = _midtermGradeControllers.length < students.length
        ? _midtermGradeControllers.length
        : students.length;

    for (int i = 0; i < minLength; i++) {
      String midtermGrade = _midtermGradeControllers[i].text.trim();

      var student = students[i];
      var studentId = student['student_id'];
      var courseId = student['course_id'];

      await Supabase.instance.client.from('student_courses').upsert({
        'student_id': studentId,
        'course_id': courseId,
        'midterm_grade': midtermGrade
      }) // Use upsert to insert or update
          .single();
    }

    // Show confirmation dialog for saving grades
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Grades Saved"),
        content: const Text("All grades have been successfully saved."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _submitGrades() async {
    // Show confirmation dialog for submitting grades
    bool confirmSubmit = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Submission"),
          content: const Text(
              "Are you sure you want to submit all grades for approval? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel submission
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm submission
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );

    if (confirmSubmit) {
      // Proceed with grade submission if confirmed
      for (int i = 0; i < _midtermGradeControllers.length; i++) {
        String studentId = students[i]['student_id']; // Get student ID

        // Here you can implement any logic to mark grades as submitted for approval
        // For example, you might want to update a status field in the database
        await Supabase.instance.client
            .from('student_courses')
            .update(
                {'submitted': true}) // Assuming you have a 'submitted' field
            .eq('student_id', studentId) // Where student_id matches
            .single();

        // Print confirmation
        print(
            "Submitted Student ${students[i]['first_name']} ${students[i]['last_name']} for approval.");
      }

      // Show confirmation dialog for successful submission
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Grades Submitted"),
          content: const Text(
              "All grades have been successfully submitted for approval."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(
                    context); // Optional: Navigate back after submission
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }
}
