import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lu_new/home.dart';
import 'package:lu_new/notice.dart';
import 'package:lu_new/questionbank.dart';
import 'package:lu_new/profile.dart';
import 'package:lu_new/study.dart';


class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  User? _user;
  String? _photoUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        _user = FirebaseAuth.instance.currentUser;

        String? photoUrl;
        for (var provider in _user!.providerData) {
          if (provider.providerId == 'google.com' && provider.photoURL != null) {
            photoUrl = "${provider.photoURL}?sz=200";
            break;
          }
        }

        if (photoUrl == null) {
          final googleUser = GoogleSignIn().currentUser;
          photoUrl = googleUser?.photoUrl;
        }

        setState(() {
          _photoUrl = photoUrl;
        });
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildGridItem(String assetPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(173, 238, 217, 0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String displayName = "Username";
    String? email;

    if (_user != null) {
      email = _user!.email;
      for (var provider in _user!.providerData) {
        if (provider.providerId == 'google.com') {
          displayName = provider.displayName ?? displayName;
          break;
        }
      }
      displayName = _user!.displayName ?? displayName;
    }

    final Map<String, VoidCallback> iconActions = {
      'assets/icon1.png': () {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("In Future")));
      },
      'assets/icon2.png': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuestionBankScreen()),
        );
      },
      'assets/icon3.png': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NoticeScreen()),
        );
      },
      'assets/icon4.png': () {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("In Future")));
      },
      'assets/icon5.png': () {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("In Future")));
      },
      'assets/icon6.png': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudyMaterialScreen()),
        );
      },
      'assets/icon7.png': () {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("In Future")));
      },
      'assets/icon8.png': () {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("In Future")));
      },
      'assets/icon9.png': () {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("In Future")));
      },
    };

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
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

              // Faded logo
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

              // Main content with pull-to-refresh
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: _loadUser,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top logo
                        Center(
                          child: Image.asset('assets/lu.png', height: 120, width: 200),
                        ),
                        const SizedBox(height: 30),

                        // Username + Logout
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: _photoUrl != null
                                        ? NetworkImage(_photoUrl!)
                                        : null,
                                    child: _photoUrl == null
                                        ? const Icon(Icons.person, size: 18)
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(0, 0, 0, 1),
                                          fontFamily: 'inter',
                                        ),
                                      ),
                                      if (email != null)
                                        Text(
                                          email,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromRGBO(0, 0, 0, 1),
                                            fontFamily: 'inter',
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Logout
                            TextButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                await GoogleSignIn().signOut();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WelcomeScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: const Color.fromARGB(240, 255, 0, 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text(
                                'Log Out',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontFamily: 'inter',
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Title
                        const Center(
                          child: Text(
                            "Explore your Essential",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'inter',
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Grid icons
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: iconActions.entries
                              .map((entry) => _buildGridItem(entry.key, entry.value))
                              .toList(),
                        ),

                        const SizedBox(height: 50),

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
              ),

              // Loading spinner overlay
              if (isLoading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

