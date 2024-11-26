// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:lms_homepage/activity_details.dart';
import 'package:lms_homepage/archive_class.dart';
import 'package:lms_homepage/create_post_page.dart';
import 'package:lms_homepage/edit_profile_page.dart';
import 'package:lms_homepage/login_page.dart';
import 'main.dart';
import 'upload_grade.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectPage extends StatefulWidget {
  final String teacherId;
  final String className;
  final String section;
  final String courseName;
  final String programName;
  final String departmentName;
  final String yearNumber;

  const SubjectPage({
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
  // ignore: library_private_types_in_public_api
  _SubjectPageState createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  bool isSidebarExpanded = false;
  bool isHovering = false;
  bool isHoveringUpload = false;
  bool isHoveringArchive = false;
  bool isHoveringLogout = false;
  bool isHoveringHome = false;
  int selectedCourseId = -1;
  bool isAddingLink = false;
  bool showLeftArrow = false;
  bool showRightArrow = true;
  bool isLoading = true;

  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> modules = [];
  List<Map<String, dynamic>> weeks = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchCourses();
    fetchWeeks();
  }

  void _scrollListener() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    setState(() {
      // Show Left Arrow if not at the start
      showLeftArrow = currentScroll > 0;
      // Show Right Arrow if not at the end
      showRightArrow = currentScroll < maxScroll;
    });
  }

  void _scrollToLeft() {
    _scrollController.animateTo(
      _scrollController.position.pixels - 200, // Adjust the amount to scroll
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _scrollToRight() {
    _scrollController.animateTo(
      _scrollController.position.pixels + 200, // Adjust the amount to scroll
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> insertLinkToDatabase(
      String moduleName, String link, int courseId, int weekId) async {
    await Supabase.instance.client.from('modules').insert({
      'name': moduleName,
      'course_id': courseId,
      'url': link,
      'teacher_id': widget.teacherId,
      'week': weekId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Module uploaded successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> fetchWeeks() async {
    final data = await Supabase.instance.client
        .from('week')
        .select()
        .order('id', ascending: true);

    weeks = List<Map<String, dynamic>>.from(data as List);
    isLoading = false;

    setState(() {});
  }

  Future<void> fetchCourses() async {
    try {
      final data = await Supabase.instance.client
          .from('college_course')
          .select('id, name')
          .eq('name', widget.programName);

      setState(() {
        courses = List<Map<String, dynamic>>.from(data);

        if (courses.isNotEmpty) {
          selectedCourseId = courses.first['id'];
          print("Selected Course ID: $selectedCourseId");
        } else {
          selectedCourseId = -1;
          print("No course found matching the name: ${widget.programName}");
        }
      });
    } catch (e) {
      print("Error fetching courses: $e");
      setState(() {
        selectedCourseId = -1;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchModules(String weekName) async {
    if (selectedCourseId == -1) {
      print("Invalid Course ID. Cannot fetch modules.");
      return [];
    }

    try {
      int weekId = weeks.indexWhere((week) => week['name'] == weekName) + 1;

      final data = await Supabase.instance.client
          .from('modules')
          .select('name, url, course_id, week')
          .eq('teacher_id', widget.teacherId)
          .eq('course_id', selectedCourseId)
          .eq('week', weekId);

      setState(() {
        modules = List<Map<String, dynamic>>.from(data);
      });
      return modules;
    } catch (e) {
      print("Error fetching modules: $e");
      setState(() {
        modules = [];
      });
      return [];
    }
  }

  void selectCourse(int courseId) {
    setState(() {
      selectedCourseId = courseId;
    });

    print("Selected Course ID: $courseId");

    if (weeks.isNotEmpty) {
      fetchModules(weeks.first['name']);
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
                  // Title Section with Logo (Header of the Page)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Space out the items
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // Center logo and text
                              children: [
                                const CircleAvatar(
                                  radius: 26,
                                  backgroundImage:
                                      AssetImage('assets/ccst.jpg'),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center, // Center the text
                                  children: [
                                    Text(
                                      widget.departmentName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        height:
                                            1.0, // Adjust this value to reduce spacing
                                      ),
                                    ),
                                    Text(
                                      widget.programName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height:
                                            0.1, // Adjust this value to reduce spacing
                                      ),
                                    ),
                                    Text(
                                      '${widget.courseName} ${widget.yearNumber}-${widget.className}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height:
                                            2.0, // Adjust this value to reduce spacing
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Learning Materials Section and Add Content
                          const Text(
                            "Learning Materials:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          isLoading
                              ? const CircularProgressIndicator()
                              : SizedBox(
                                  height: 120,
                                  child: Row(
                                    children: [
                                      Visibility(
                                        visible: showLeftArrow,
                                        child: IconButton(
                                          icon: const Icon(Icons.arrow_left),
                                          iconSize: 30,
                                          onPressed: _scrollToLeft,
                                        ),
                                      ),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          controller: _scrollController,
                                          child: Row(
                                            children: weeks.map((week) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: GestureDetector(
                                                  onTap: () => _showWeekModal(
                                                      context, week['name']),
                                                  child: Card(
                                                    elevation: 3,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: SizedBox(
                                                      width: 140,
                                                      height: 100,
                                                      child: Center(
                                                        child: Text(
                                                          week['name'],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                      if (showRightArrow)
                                        IconButton(
                                          icon: const Icon(Icons.arrow_right),
                                          iconSize: 30,
                                          onPressed: _scrollToRight,
                                        ),
                                    ],
                                  ),
                                ),
                          const SizedBox(height: 20),
                          // Input Bar for Teacher to Upload Activity/Announcement
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreatePostPage(
                                      teacherId: widget.teacherId,
                                      className: widget
                                          .className, // Pass the className from widget
                                      section: widget.section,
                                      courseName: widget.courseName,
                                      programName: widget.programName,
                                      departmentName: widget.departmentName,
                                      yearNumber: widget.yearNumber),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color:
                                        const Color.fromRGBO(102, 102, 102, 1)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage:
                                        AssetImage('assets/aliceg.jpg'),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Post an Activity or Announcement...',
                                    style: TextStyle(
                                        color:
                                            Color.fromRGBO(102, 102, 102, 1)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Activity Post Box
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ActivityDetailsPage(
                                      teacherId: widget.teacherId,
                                      className: widget.className,
                                      section: widget.section,
                                      courseName: widget.courseName,
                                      programName: widget.programName,
                                      departmentName: widget.departmentName,
                                      yearNumber: widget.yearNumber),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color:
                                        const Color.fromRGBO(102, 102, 102, 1)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      // Teacher's Image
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage:
                                            AssetImage('assets/aliceg.jpg'),
                                      ),
                                      SizedBox(width: 10),
                                      // Teacher's Name and Date
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Alice Guo",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 4),
                                          Text("2024-10-25",
                                              style: TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Activity Details
                                  const Text(
                                    "This is a brief description of the activity posted by the teacher.",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Activity #1",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ActivityDetailsPage(
                                                    teacherId: widget.teacherId,
                                                    className: widget.className,
                                                    section: widget.section,
                                                    courseName:
                                                        widget.courseName,
                                                    programName:
                                                        widget.programName,
                                                    departmentName:
                                                        widget.departmentName,
                                                    yearNumber:
                                                        widget.yearNumber),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "See Details",
                                        style: TextStyle(
                                            color: Color.fromRGBO(
                                                102, 102, 102, 1)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  void _showWeekModal(BuildContext context, String week) {
    final TextEditingController moduleNameController = TextEditingController();
    final TextEditingController linkController = TextEditingController();

    fetchModules(week);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
              contentPadding: const EdgeInsets.all(20),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    week,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.grey),
                    onPressed: () {
                      dialogSetState(() {
                        isAddingLink = !isAddingLink;
                      });
                    },
                  ),
                ],
              ),
              content: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Stream.fromFuture(fetchModules(week)),
                builder: (context, snapshot) {
                  // Check connection state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading modules...'),
                        ],
                      ),
                    );
                  }

                  // Check if data is available
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isAddingLink)
                            _buildAddModuleSection(context, dialogSetState,
                                moduleNameController, linkController, week),
                          const SizedBox(height: 20),
                          const Center(child: Text('No modules uploaded yet')),
                        ],
                      ),
                    );
                  }

                  // Data is available
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isAddingLink)
                          _buildAddModuleSection(context, dialogSetState,
                              moduleNameController, linkController, week),
                        const SizedBox(height: 20),
                        const Text('Uploaded Modules:',
                            style: TextStyle(fontSize: 18)),
                        Column(
                          children: snapshot.data!.map((module) {
                            return ListTile(
                              title: Text(module['name']!),
                              subtitle: Text(module['url']!),
                              trailing: Text(
                                  'Course ID: ${module['course_id'] ?? 'N/A'}'),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddModuleSection(
      BuildContext context,
      StateSetter dialogSetState,
      TextEditingController moduleNameController,
      TextEditingController linkController,
      String week) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: moduleNameController,
          decoration: const InputDecoration(
            labelText: 'Enter Module Name',
            border: OutlineInputBorder(),
          ),
        ),
        TextField(
          controller: linkController,
          decoration: const InputDecoration(
            labelText: 'Enter Module Link',
            border: OutlineInputBorder(),
          ),
        ),
        Text(
          'Course: ${courses.firstWhere((course) => course['id'] == selectedCourseId)['name']}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: () {
            if (moduleNameController.text.isNotEmpty &&
                linkController.text.isNotEmpty &&
                selectedCourseId != -1) {
              int weekId = weeks.indexWhere((w) => w['name'] == week) + 1;

              insertLinkToDatabase(
                moduleNameController.text,
                linkController.text,
                selectedCourseId,
                weekId,
              );
              moduleNameController.clear();
              linkController.clear();

              // Refresh modules
              fetchModules(week);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all fields.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text('Save Module'),
        ),
      ],
    );
  }
}
