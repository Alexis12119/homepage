import 'dart:async';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonDisabled = false;
  String _buttonText = "Send OTP";
  String _timerText = ""; // Timer text to indicate remaining time
  int _remainingTime = 10; // 10 seconds countdown

  void _sendOtp() {
    // Disable button and start timer for 10 seconds
    setState(() {
      _isButtonDisabled = true;
      _buttonText = "Resend";
      _timerText = "Resend in $_remainingTime s";
    });

    // Start a timer that counts down every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 1) {
        setState(() {
          _remainingTime--;
          _timerText = "Resend in $_remainingTime s";
        });
      } else {
        timer.cancel(); // Stop the timer
        setState(() {
          _isButtonDisabled = false;
          _buttonText = "Send OTP";
          _timerText = ""; // Clear the timer text
          _remainingTime = 10; // Reset the remaining time
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FC),
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(), // Updated header
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Container(
                      width: 400, // Shortened container width
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20.0),
                          const Center(
                            child: Text(
                              'Forgot Password',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          const Text(
                            'Email Address',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          // Shortened input field width
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                hintText: 'Enter your email address',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 12.0), // Smaller padding
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _isButtonDisabled ? null : _sendOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C9B44),
                                ),
                                child: Text(
                                  _buttonText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // Displaying the timer text
                              if (_timerText.isNotEmpty)
                                Text(
                                  _timerText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C9B44),
                                ),
                                onPressed: () {
                                  // Handle the submit action here
                                },
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 20.0), // Spacing for the back link
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Go back to login page
                              },
                              child: const Text(
                                'Back to Login',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      color: const Color(0xFFF2F8FC),
      padding: const EdgeInsets.all(16.0),
      child: const Center(
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }
}
