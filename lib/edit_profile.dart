import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  bool _isLoading = false;

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        _nameController.text = doc.data()?['fullName'] ?? user!.displayName ?? '';
        _departmentController.text = doc.data()?['department'] ?? '';
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'fullName': _nameController.text.trim(),
          'department': _departmentController.text.trim(),
          'email': user!.email,
        }, SetOptions(merge: true));

        // Optional: Update FirebaseAuth displayName
        await user!.updateDisplayName(_nameController.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully. Reload pages to see the changes.")),
        );

        Navigator.pop(context); // go back to profile screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Stack(
          children: [
            // 🔹 Faded background LU logo
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

            // 🔹 Foreground content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top small logo
                    Center(
                      child: Image.asset(
                        'assets/lu.png',
                        height: 90,
                        width: 95,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Heading
                    const Center(
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'instrumentsans',
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Form card
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Full Name
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: "Full Name",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value == null || value.isEmpty
                                  ? "Enter your full name"
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Department
                            TextFormField(
                              controller: _departmentController,
                              decoration: const InputDecoration(
                                labelText: "Department",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Enter your department"
                                      : null,
                            ),
                            const SizedBox(height: 30),

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(173, 238, 217, 0.95),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.black54,
                                      )
                                    : const Text(
                                        "Save",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(86, 82, 82, 0.9),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Bottom quote
                    const Center(
                      child: Text(
                        "“It's never too late to be what you might\nhave been.”",
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
    );
  }
}
