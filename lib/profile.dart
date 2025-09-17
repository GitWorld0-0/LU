import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lu_new/pass/confirm_password.dart';
import 'home.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String department = "Loading...";
  User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  setState(() => isLoading = true); // show loading spinner
  try {
    // Refresh Firebase user
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          department = data['department'] ?? "No Department";
        });
      } else {
        setState(() {
          department = "No Department";
        });
      }
    }
  } finally {
    setState(() => isLoading = false); // hide loading spinner
  }
}


  void _resetPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmPasswordScreen(
          phoneNumber: user?.phoneNumber ?? '',
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  void _editProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 50),
                          Center(
                            child: Image.asset('assets/lu.png', height: 90, width: 95),
                          ),
                          const SizedBox(height: 30),
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : const AssetImage("assets/default_user.png") as ImageProvider,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  user?.displayName ?? "No Name",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'instrumentsans',
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  department,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(86, 82, 82, 0.7),
                                    fontFamily: 'inter',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  user?.email ?? "No Email",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(86, 82, 82, 0.7),
                                    fontFamily: 'inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: 160,
                            child: ElevatedButton(
                              onPressed: () => _editProfile(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(173, 238, 217, 0.95),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Edit Profile",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromRGBO(86, 82, 82, 0.7),
                                  fontFamily: 'instrumentsans',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 140,
                                child: ElevatedButton(
                                  onPressed: () => _resetPassword(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(173, 238, 217, 0.95),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    "Reset Password",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromRGBO(86, 82, 82, 0.7),
                                      fontFamily: 'instrumentsans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              SizedBox(
                                width: 140,
                                child: ElevatedButton(
                                  onPressed: () => _logout(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(173, 238, 217, 0.95),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromRGBO(86, 82, 82, 0.7),
                                      fontFamily: 'instrumentsans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 150),
                          const Text(
                            "“It's never too late to be what you might\nhave been.”",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color.fromRGBO(0, 0, 0, 0.5),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'instrumentsans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
    );
  }
}
