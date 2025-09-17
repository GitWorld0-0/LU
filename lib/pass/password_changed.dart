import 'package:flutter/material.dart';
import 'package:lu_new/home.dart';
// Adjust import as needed

class PasswordChangedScreen extends StatelessWidget {
  const PasswordChangedScreen({super.key, required String phoneNumber});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard if somehow open
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
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
          child: SafeArea(
            child: Stack(
              children: [
                // Background watermark/logo
                Center(
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.asset(
                      'assets/lu.png',
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 280,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Foreground content with scroll
                SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 50),
                          Image.asset(
                            'assets/lu.png',
                            height: 90,
                            width: 95,
                          ),
                          const SizedBox(height: 115),
                          const Text(
                            'Checked Email',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'instrumentsans',
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 180,
                            child: ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus(); // Hide keyboard before navigation
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 2,
                                backgroundColor: const Color.fromRGBO(173, 238, 217, 0.68),
                                padding: const EdgeInsets.symmetric(vertical: 15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                              child: const Text(
                                'Go To Home',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color.fromRGBO(86, 82, 82, 0.7),
                                  fontFamily: 'instrumentsans',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 250),
                            Center(
                              child:  Text(
                                "“It's never too late to be what you might\nhave been.”",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'instrumentsans',
                                ),
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
