import 'package:flutter/material.dart';
import 'upload.dart';  // Import Upload screen
import 'view.dart';   // Import View screen

class QuestionBankScreen extends StatelessWidget {
  const QuestionBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.fromRGBO(194, 227, 207, 1),
                  Color.fromRGBO(140, 238, 173, 0.9),
                ],
              ),
            ),
          ),

          // Faded logo in background
          Center(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/lu.png',
                width: MediaQuery.of(context).size.width * 0.8,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top logo
                  Center(
                    child: Image.asset(
                      'assets/lu.png',
                      height: 120,
                      width: 200,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    "Question Bank",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontFamily: 'inter',
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Upload button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UploadScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromRGBO(173, 238, 217, 0.95),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                        elevation: 3,
                      ),
                      child: const Text(
                        "Upload",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(0, 0, 0, 1),
                          fontFamily: 'inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // View button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ViewScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromRGBO(173, 238, 217, 0.95),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                        elevation: 3,
                      ),
                      child: const Text(
                        "View",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(0,0,0, 1),
                          fontFamily: 'inter',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 300),

                  // Bottom quote
                  const Center(
                    child: Text(
                      "“It's never too late to be what you might\nhave been.”",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'instrumentsans',
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
}
