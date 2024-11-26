// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:lms_homepage/archive_class.dart';
import 'package:lms_homepage/login_page.dart';
import 'package:lms_homepage/main.dart';
import 'package:lms_homepage/upload_grade.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final String teacherId;

  const EditProfilePage({Key? key, required this.teacherId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool isSidebarExpanded = false;
  bool isHovering = false;
  bool isHoveringUpload = false;
  bool isHoveringArchive = false;
  bool isHoveringLogout = false;
  bool isHoveringHome = false;
  String firstName = "Loading...";
  String lastName = " ";
  String? countryValue;
  String? stateValue;
  String? cityValue;
  File? _imageFile;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("Edit Profile is initialized with the ID: ${widget.teacherId}");
    fetchTeacherData();
  }

  Future<void> fetchTeacherData() async {
    final teacherData = await Supabase.instance.client
        .from('teacher')
        .select(
            'first_name, middle_name, last_name, email, phone, address, zip_code, country, state, city')
        .eq('id', widget.teacherId)
        .single();

    setState(() {
      firstNameController.text = teacherData['first_name'] ?? "";
      middleNameController.text = teacherData['middle_name'] ?? "";
      lastNameController.text = teacherData['last_name'] ?? "";
      emailController.text = teacherData['email'] ?? "";
      phoneController.text = teacherData['phone'] ?? "";
      addressController.text = teacherData['address'] ?? "";
      zipCodeController.text = teacherData['zip_code'] ?? "";
      countryValue =
          teacherData['country'] ?? ""; // Assuming you have these fields
      stateValue = teacherData['state'] ?? "";
      cityValue = teacherData['city'] ?? "";
    });

    if (teacherData.isEmpty) {
      print('No data found for the teacher.');
      return;
    }
  }

  Future<void> updateTeacherData() async {
    await Supabase.instance.client.from('teacher').update({
      'first_name': firstNameController.text,
      'middle_name': middleNameController.text,
      'last_name': lastNameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'zip_code': zipCodeController.text,
      'country': countryValue, // Add country to update
      'state': stateValue, // Add state to update
      'city': cityValue,
    }).eq('id', widget.teacherId);

    // Optionally, you can still provide feedback to the user after the update
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });

      // Upload the image to Supabase storage
      await _uploadImageToSupabase(image);
    }
  }

  Future<void> _uploadImageToSupabase(XFile image) async {
    final fileName =
        'profile/${widget.teacherId}/${image.name}'; // File path in storage
    final response = await Supabase.instance.client.storage
        .from('profile')
        .upload(fileName, File(image.path));

    // ignore: unnecessary_null_comparison
    if (response == null) {
      // Get the public URL of the uploaded image
      final publicUrl = Supabase.instance.client.storage
          .from('profile')
          .getPublicUrl(fileName);

      // Update the teacher's profile picture URL in the database
      await Supabase.instance.client.from('teacher').update({
        'profilepicture': publicUrl,
      }).eq('id', widget.teacherId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $response')),
      );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundImage:
                                      AssetImage('assets/plsp.png'),
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
                      SizedBox(height: 10),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ), // Profile Page Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  // Profile Picture Section
                                  Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundImage: _imageFile != null
                                            ? FileImage(_imageFile!)
                                            : const AssetImage(
                                                    'assets/aliceg.jpg')
                                                as ImageProvider,
                                      ),
                                      Text(
                                        "Good day! ${lastNameController.text}, ${firstNameController.text}",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      ElevatedButton(
                                        onPressed:
                                            _pickImage, // Call the image picker
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: const Text(
                                          'Change Picture',
                                          style: TextStyle(
                                            color: Color(0xFF2CB944),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: buildTextField(
                                          'First Name',
                                          controller: firstNameController,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: buildTextField(
                                          'Middle Name',
                                          controller: middleNameController,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: buildTextField(
                                          'Last Name',
                                          controller: lastNameController,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: buildTextField(
                                          'Email',
                                          controller: emailController,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: buildTextField(
                                          'Phone Number',
                                          controller: phoneController,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: buildTextField(
                                          'Address',
                                          hintText:
                                              'House/Building No., Street, Barangay',
                                          controller: addressController,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: buildTextField('Zip Code',
                                            controller: zipCodeController),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CSCPicker(
                                          layout: Layout.vertical,
                                          showCities: true,
                                          showStates: true,
                                          flagState: CountryFlag.ENABLE,
                                          dropdownDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  171, 0, 0, 0),
                                              width: 1,
                                            ),
                                          ),
                                          disabledDropdownDecoration:
                                              BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.grey.shade300,
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  171, 0, 0, 0),
                                              width: 1,
                                            ),
                                          ),
                                          countrySearchPlaceholder: "Country",
                                          stateSearchPlaceholder: "State",
                                          citySearchPlaceholder: "City",
                                          countryDropdownLabel: "*Country",
                                          stateDropdownLabel: "*State",
                                          cityDropdownLabel: "*City",
                                          onCountryChanged: (value) {
                                            print("Selected Country: $value");
                                            setState(() {
                                              countryValue = value;
                                              stateValue = "";
                                              cityValue = "";
                                            });
                                          },
                                          onStateChanged: (value) {
                                            print("Selected State: $value");
                                            setState(() {
                                              stateValue = value ?? "";
                                              cityValue = "";
                                            });
                                          },
                                          onCityChanged: (value) {
                                            print("Selected City: $value");
                                            setState(() {
                                              cityValue = value ?? "";
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Save Button
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await updateTeacherData();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 255, 255, 255),
                                      ),
                                      child: const Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          color: Color(0xFF2CB944),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
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

  Widget buildTextField(
    String labelText, {
    String hintText = '',
    double hintFontSize = 14.0,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.5),
            fontSize: hintFontSize,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
