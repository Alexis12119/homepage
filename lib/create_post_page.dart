// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:lms_homepage/archive_class.dart';
import 'package:lms_homepage/edit_profile_page.dart';
import 'package:lms_homepage/login_page.dart';
import 'package:lms_homepage/subject_page.dart';
import 'package:lms_homepage/upload_grade.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostPage extends StatefulWidget {
  final String teacherId;
  final String className;
  final String section;
  final String courseName;
  final String programName;
  final String departmentName;
  final String yearNumber;

  const CreatePostPage({
    super.key,
    required this.teacherId,
    required this.className,
    required this.section,
    required this.courseName,
    required this.programName,
    required this.departmentName,
    required this.yearNumber,
  }); // Update the constructor to accept teacherId

  @override
  // ignore: library_private_types_in_public_api
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  bool isSidebarExpanded = false;
  bool isHovering = false;
  bool isHoveringUpload = false;
  bool isHoveringArchive = false;
  bool isHoveringLogout = false;
  bool isHoveringHome = false;
  int selectedCourseId = -1;
  DateTime? selectedDueDate;
  String driveUrl = '';
  String youtubeUrl = '';
  String externalUrl = '';
  bool isDriveSet = false;
  bool isYoutubeSet = false;
  bool isUrlSet = false;
  bool isDueDateSet = false;

  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> courses = [];

  @override
  @override
  void initState() {
    super.initState();
    fetchCourses();
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

  Future<void> postActivity() async {
    if (_controller.text.isEmpty || selectedCourseId == -1) {
      print("No input or course selected");
      return;
    }

    if (selectedDueDate == null) {
      print("Please select a due date");
      setState(() {
        isDueDateSet = false; // Reset the due date indicator
      });
      return;
    }

    await Supabase.instance.client.from('tasks').insert({
      'description': _controller.text,
      'course_id': selectedCourseId,
      'due_date': selectedDueDate?.toIso8601String(),
      'drive': driveUrl.isNotEmpty ? driveUrl : null,
      'youtube': youtubeUrl.isNotEmpty ? youtubeUrl : null,
      'url': externalUrl.isNotEmpty ? externalUrl : null,
    });

    setState(() {
      // Resetting after successful posting
      _controller.clear();
      selectedDueDate = null;
      driveUrl = '';
      youtubeUrl = '';
      externalUrl = '';
      isDriveSet = driveUrl.isNotEmpty;
      isYoutubeSet = youtubeUrl.isNotEmpty;
      isUrlSet = externalUrl.isNotEmpty;
      isDueDateSet = selectedDueDate != null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity posted successfully!')),
    );
  }

  Future<void> selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDueDate) {
      setState(() {
        selectedDueDate = picked;
      });
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
                              builder: (context) => SubjectPage(
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
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Space out the items
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Center logo and text
                            children: [
                              const CircleAvatar(
                                radius: 26,
                                backgroundImage: AssetImage('assets/ccst.jpg'),
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

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Input field with teacher's image
                        Stack(
                          children: [
                            TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                labelText: 'Post an Activity or Announcement',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                contentPadding:
                                    const EdgeInsets.only(left: 60, top: 15),
                              ),
                              maxLines: 6,
                            ),
                            const Positioned(
                              left: 10,
                              top: 10,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    AssetImage('assets/aliceg.jpg'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Icons for Google Drive, YouTube, Upload, and Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Tooltip(
                              message: 'Google Drive',
                              child: Stack(
                                children: [
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/gdrive.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                    onPressed: () async {
                                      // Open Google Drive URL picker (or implementation)
                                      String? selectedDriveUrl =
                                          await showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Enter Google Drive URL'),
                                            content: TextField(
                                              onChanged: (value) {
                                                setState(() {
                                                  driveUrl = value;
                                                  isDriveSet = value.isNotEmpty;
                                                });
                                              },
                                              decoration: const InputDecoration(
                                                  hintText: "Drive URL"),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, ''),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, driveUrl),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (selectedDriveUrl != null &&
                                          selectedDriveUrl.isNotEmpty) {
                                        setState(() {
                                          driveUrl = selectedDriveUrl;
                                          isDriveSet = true;
                                        });
                                      }
                                    },
                                  ),
                                  if (isDriveSet)
                                    const Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Tooltip(
                              message: 'YouTube',
                              child: Stack(
                                children: [
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/yt.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                    onPressed: () async {
                                      // Open YouTube URL picker (or implementation)
                                      String? selectedYoutubeUrl =
                                          await showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                const Text('Enter YouTube URL'),
                                            content: TextField(
                                              onChanged: (value) {
                                                setState(() {
                                                  youtubeUrl = value;
                                                  isYoutubeSet =
                                                      value.isNotEmpty;
                                                });
                                              },
                                              decoration: const InputDecoration(
                                                  hintText: "YouTube URL"),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, ''),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, youtubeUrl),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (selectedYoutubeUrl != null &&
                                          selectedYoutubeUrl.isNotEmpty) {
                                        setState(() {
                                          youtubeUrl = selectedYoutubeUrl;
                                          isYoutubeSet = true;
                                        });
                                      }
                                    },
                                  ),
                                  if (isYoutubeSet)
                                    const Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Tooltip(
                              message: 'Link',
                              child: Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.link, size: 30),
                                    onPressed: () async {
                                      // Open URL picker
                                      String? selectedUrl =
                                          await showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Enter Link'),
                                            content: TextField(
                                              onChanged: (value) {
                                                setState(() {
                                                  externalUrl = value;
                                                  isUrlSet = value.isNotEmpty;
                                                });
                                              },
                                              decoration: const InputDecoration(
                                                  hintText: "Enter URL"),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, ''),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, externalUrl),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (selectedUrl != null &&
                                          selectedUrl.isNotEmpty) {
                                        setState(() {
                                          externalUrl = selectedUrl;
                                          isUrlSet = true;
                                        });
                                      }
                                    },
                                  ),
                                  if (isUrlSet)
                                    const Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Tooltip(
                              message: 'Upload File',
                              child: IconButton(
                                icon: const Icon(Icons.upload_file, size: 30),
                                onPressed: () {
                                  // Implement file upload functionality
                                },
                              ),
                            ),
                            Tooltip(
                              message: 'Due Date',
                              child: Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.calendar_today,
                                        size: 25),
                                    onPressed: () async {
                                      // Open Date picker
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate:
                                            selectedDueDate ?? DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                      );
                                      if (pickedDate != null &&
                                          pickedDate != selectedDueDate) {
                                        setState(() {
                                          selectedDueDate = pickedDate;
                                          isDueDateSet =
                                              selectedDueDate != null;
                                        });
                                      }
                                    },
                                  ),
                                  if (isDueDateSet)
                                    const Positioned(
                                      top: 0,
                                      right: 0,
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Publish button aligned to the right
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: postActivity,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              backgroundColor:
                                  const Color.fromRGBO(44, 155, 68, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Publish',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
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
        ],
      ),
    );
  }

  void setDriveUrl() {
    // Prompt user to input the Google Drive link
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController driveController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Google Drive URL'),
          content: TextField(
            controller: driveController,
            decoration: const InputDecoration(
              hintText: 'Paste the Google Drive URL here...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  driveUrl = driveController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  void setYoutubeUrl() {
    // Prompt user to input the YouTube URL
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController youtubeController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter YouTube URL'),
          content: TextField(
            controller: youtubeController,
            decoration: const InputDecoration(
              hintText: 'Paste the YouTube URL here...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  youtubeUrl = youtubeController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  void setExternalUrl() {
    // Prompt user to input the external URL
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController urlController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter External URL'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: 'Paste the URL here...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  externalUrl = urlController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }
}
