import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user.dart';

class VerificationSuccessfulScreen extends StatelessWidget {
  final String fullName;
  final String email;

  const VerificationSuccessfulScreen({
    super.key,
    required this.fullName,
    required this.email,
  });

  Future<void> _handleExplore(BuildContext context) async {
    // ✅ Get current user
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // ✅ Refresh token to ensure session time is updated
      await user.getIdToken(true);

      // ✅ This value is now updated and can be used anywhere in the app
      final DateTime? sessionStart = user.metadata.lastSignInTime;
      debugPrint("Session started at: $sessionStart"); 
      // (You don’t display it, just stored internally by Firebase)
    }

    // ✅ Navigate to UserScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 50),
                          Image.asset('assets/lu.png', height: 90, width: 95),
                          const SizedBox(height: 215),
                          const Text(
                            'Verification Successful',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'instrumentsans',
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 180,
                            child: ElevatedButton(
                              onPressed: () => _handleExplore(context),
                              style: ElevatedButton.styleFrom(
                                elevation: 2,
                                backgroundColor: const Color.fromRGBO(173, 238, 217, 0.68),
                                padding: const EdgeInsets.symmetric(vertical: 15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                              child: const Text(
                                'Explore App',
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
                            child: Text(
                              "“It's never too late to be what you might\nhave been.”",
                              style: const TextStyle(
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
