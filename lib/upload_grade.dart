import 'package:flutter/material.dart';
import 'package:lms_homepage/archive_class.dart';
import 'package:lms_homepage/edit_profile_page.dart';
import 'package:lms_homepage/login_page.dart';
import 'package:lms_homepage/main.dart';
import 'grade_input_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadGradePage extends StatefulWidget {
  final String teacherId;
  const UploadGradePage({super.key, required this.teacherId});

  @override
  // ignore: library_private_types_in_public_api
  _UploadGradePageState createState() => _UploadGradePageState();
}

class _UploadGradePageState extends State<UploadGradePage> {
  bool isSidebarExpanded = false;
  bool isHovering = false;
  bool isHoveringUpload = false;
  bool isHoveringArchive = false;
  bool isHoveringLogout = false;
  bool isHoveringHome = false;
  List<Map<String, dynamic>> classDataList = [];

  @override
  void initState() {
    super.initState();
    print("dashboard is initialized with the ID: ${widget.teacherId}");
    fetchClassData();
  }

  Future<void> fetchClassData() async {
    try {
      // Fetch the teacher's course IDs
      final teacherCourses = await Supabase.instance.client
          .from('teacher_courses')
          .select('course_id')
          .eq('teacher_id', widget.teacherId);

      if (teacherCourses.isEmpty) {
        print('No course found for the teacher.');
        return;
      }

      // List to store all filtered class data
      List<Map<String, dynamic>> allFilteredData = [];

      // Loop through all courses associated with the teacher
      for (var course in teacherCourses) {
        final teacherCourseId = course['course_id'];

        // Fetch course details for each course
        final courseData = await Supabase.instance.client
            .from('college_course')
            .select('name, year_number, semester')
            .eq('id', teacherCourseId)
            .single();

        if (courseData['name'] == null) {
          print("Course not found for course_id: $teacherCourseId.");
          continue; // Skip if course not found
        }

        final courseName = courseData['name'];
        final courseYearNumber = courseData['year_number'];
        final courseSemester = courseData['semester'];

        // Fetch sections associated with the course
        final data = await Supabase.instance.client.from('section').select(
            'name, year_number, semester, college_program(name, college_department(name))');

        if (data.isEmpty) {
          print("No sections found for course_id: $teacherCourseId");
          continue; // Skip if no sections are found
        }

        // Filter sections based on course details
        final filteredData = data.where((item) {
          return item['year_number'].toString().trim() ==
                  courseYearNumber.toString().trim() &&
              item['semester'].toString().trim() ==
                  courseSemester.toString().trim();
        }).map((item) {
          return {
            'class_name': item['name'],
            'year_number': item['year_number'],
            'program_name': item['college_program']['name'],
            'department_name': item['college_program']['college_department']
                ['name'],
            'course_name': courseName,
          };
        }).toList();

        // Add the filtered data for this course to the overall list
        allFilteredData.addAll(filteredData);
      }

      if (allFilteredData.isEmpty) {
        print('No matching classes found.');
        return;
      }

      // Update state with all filtered class data
      setState(() {
        classDataList = allFilteredData;
      });
    } catch (e) {
      print('Error fetching class data: $e');
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
            width: 70,
            color: const Color.fromARGB(255, 44, 155, 68),
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
                                  EditProfilePage(teacherId: widget.teacherId),
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
                                builder: (context) => UploadGradePage(
                                    teacherId: widget.teacherId),
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
                                builder: (context) => ArchiveClassScreen(
                                    teacherId: widget.teacherId),
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
                    const SizedBox(height: 20),
                    //Home
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          isHoveringHome = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          isHoveringHome = false;
                        });
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DashboardScreen(teacherId: widget.teacherId),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.arrow_back,
                          size: 40,
                          color: isHoveringHome
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : const Color.fromARGB(255, 0, 0, 0),
                          shadows: isHoveringHome
                              ? [
                                  const BoxShadow(
                                    color: Color.fromARGB(255, 69, 238, 106),
                                    blurRadius: 10,
                                  ),
                                ]
                              : [],
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
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear();

                          print(
                              "User  has logged out and session data cleared.");
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
                  const Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centers the content horizontally
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Vertically centers the content
                    children: [
                      // This will center the photo and text in the row
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centers photo and text
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Centers photo and text vertically
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundImage: AssetImage('assets/plsp.png'),
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Left-aligns the text
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
                    ],
                  )),

                  const SizedBox(height: 20),

                  // Title for Upload Grades
                  const Text(
                    "Upload Grades",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Select Course:",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Class Cards for selecting courses to upload grades
                  Expanded(
                    child: ListView.builder(
                      itemCount: classDataList.length,
                      itemBuilder: (context, index) {
                        final classData = classDataList[index];
                        return classCard(
                          classData['course_name']!, // Course Name
                          classData['program_name']!, // Program Name
                          classData['class_name']!, // Class Name
                          classData['year_number']!, // Year Number
                          classData['department_name']!, // Department Name
                        );
                      },
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

  Widget classCard(String courseName, String programName, String className,
      String yearNumber, String departmentName) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GradeInputPage(
                  className: className,
                  yearNumber: yearNumber,
                  progamName: programName,
                  courseName: courseName,
                  teacherId: widget.teacherId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/ccst.jpg'),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      departmentName, // Display department name
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      courseName, //  Display course name
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$programName $yearNumber$className", // Display year number and class name
                      style: const TextStyle(fontSize: 10),
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
