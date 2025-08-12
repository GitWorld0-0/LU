import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'sign_in_screen.dart';
import 'register.dart';
import 'user.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  bool _isSigningIn = false;

  Future<void> _signInWithGoogle() async {
  setState(() => _isSigningIn = true);

  try {
    // Sign out first to clear previous session and force picker
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();

    // Now show account picker
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      setState(() => _isSigningIn = false);
      return; // user canceled
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const UserScreen()),
    );
  } catch (e) {
    setState(() => _isSigningIn = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Google Sign-In failed: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    return Scaffold(
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
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.04,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/lu.png',
                      height: 250,
                      width: 308,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const SizedBox(height: 50),
                  const Text(
                    'A promise to Lead',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'instrumentsans',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '“It’s never too late to be what you might have been.”',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'instrumentsans',
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Trust by Student of LU',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color.fromRGBO(86, 82, 82, 0.7),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'instrumentsans',
                    ),
                  ),
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Sign In Button
                      SizedBox(
                        width: 130,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignInScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(173, 238, 217, 1),
                            foregroundColor: const Color.fromRGBO(86, 82, 82, 0.7),
                            elevation: 2,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'instrumentsans',
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: const Text('Sign in'),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Register Button
                      SizedBox(
                        width: 130,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(173, 238, 217, 0.95),
                            foregroundColor: const Color.fromRGBO(86, 82, 82, 0.7),
                            elevation: 2,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'instrumentsans',
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Continue with Google Button
                  Center(
                    child: _isSigningIn
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            icon: Image.asset(
                              'assets/gl.png',
                              height: 24,
                              width: 24,
                            ),
                            label: const Text(
                              'Continue with Gmail',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'instrumentsans',
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(86, 82, 82, 0.8),
                              ),
                            ),
                            onPressed: _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(173, 238, 217, 0.95),
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              foregroundColor: const Color.fromRGBO(86, 82, 82, 0.7),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
