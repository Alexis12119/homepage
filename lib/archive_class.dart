import 'package:flutter/material.dart';
import 'package:lms_homepage/edit_profile_page.dart';
import 'package:lms_homepage/login_page.dart';
import 'package:lms_homepage/main.dart';
import 'upload_grade.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArchiveClassScreen extends StatefulWidget {
  final String teacherId;

  const ArchiveClassScreen({super.key, required this.teacherId});

  @override
  // ignore: library_private_types_in_public_api
  _ArchiveClassScreenState createState() => _ArchiveClassScreenState();
}

class _ArchiveClassScreenState extends State<ArchiveClassScreen> {
  bool isSidebarExpanded = false;
  bool isHovering = false;
  bool isHoveringUpload = false;
  bool isHoveringArchive = false;
  bool isHoveringLogout = false;
  bool isHoveringHome = false;

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

                  // Archived Class Cards
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final classData = [
                          {
                            "name": "Data Structure and Algorithm",
                            "section": "BSIT - 2C",
                            "room": "203"
                          },
                          {
                            "name": "Project Management",
                            "section": "BSIT - 3D",
                            "room": "203"
                          },
                          {
                            "name": "Living in IT Era",
                            "section": "BSIT - 1A",
                            "room": "210"
                          },
                          {
                            "name": "Introduction to Computing",
                            "section": "BSIT - 1D",
                            "room": "207"
                          }
                        ][index];

                        return classCard(classData['name']!,
                            classData['section']!, classData['room']!);
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

  Widget classCard(String className, String section, String room) {
    return GestureDetector(
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                title: const Text(
                  "Archived Class",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      className,
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      "$section\nRoom $room",
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
