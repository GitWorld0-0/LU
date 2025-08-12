import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import
import 'package:lu_new/home.dart'; // Your WelcomeScreen import

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController searchController = TextEditingController();

  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser; // Get current user on init
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.displayName ?? "Username";
    final photoUrl = _user?.photoURL;

    return WillPopScope(
      onWillPop: () async => false, // Disable Android back button
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
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
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/lu.png',
                          height: 90,
                          width: 95,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Username with profile photo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (photoUrl != null)
                                CircleAvatar(
                                  radius: 15,
                                  backgroundImage: NetworkImage(photoUrl),
                                )
                              else
                                const CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey,
                                  child: Icon(Icons.person, size: 18),
                                ),
                              const SizedBox(width: 8),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(86, 82, 82, 0.9),
                                  fontFamily: 'inter',
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                                (route) => false,
                              );
                            },
                            child: const Text(
                              'Log Out',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(86, 82, 82, 0.7),
                                fontFamily: 'inter',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Search row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'search by course-name',
                                filled: true,
                                fillColor: const Color.fromRGBO(173, 238, 217, 0.58),
                                hintStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Color.fromRGBO(86, 82, 82, 0.7),
                                  fontFamily: 'inter',
                                  fontWeight: FontWeight.w600,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                  horizontal: 20.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                final query = searchController.text.trim();
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Search Result"),
                                    content: Text(
                                      query.isEmpty
                                          ? "Search field is empty!"
                                          : "You searched for: $query",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(173, 238, 217, 0.95),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                              ),
                              child: const Text(
                                'Search',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color.fromRGBO(86, 82, 82, 0.7),
                                  fontFamily: 'instrumentsans',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 455),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
