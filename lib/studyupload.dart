import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudyUploadScreen extends StatefulWidget {
  const StudyUploadScreen({super.key});

  @override
  State<StudyUploadScreen> createState() => _StudyUploadScreenState();
}

class _StudyUploadScreenState extends State<StudyUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _topicNameController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  // Regex to validate topic name: TopicName_CourseCode
  final RegExp _namePattern = RegExp(r'^[A-Z]+_[A-Z0-9]+$');

  // Regex to validate Google Drive links
  final RegExp _driveLinkPattern = RegExp(r'^https:\/\/drive\.google\.com\/.*$');

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    final topicName = _topicNameController.text.trim().toUpperCase();
    final link = _linkController.text.trim();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No logged-in user found")),
        );
        return;
      }

      // Check if study material already exists
      final query = await FirebaseFirestore.instance
          .collection("studymaterial")
          .where("topicName", isEqualTo: topicName)
          .get();

      if (query.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "❌ This study material already exists. You cannot add it twice.")),
        );
        return;
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection("studymaterial").add({
        "email": user.email ?? "unknown",
        "name": user.displayName ?? "No Name",
        "topicName": topicName,
        "link": link,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Study material added successfully")),
      );

      _topicNameController.clear();
      _linkController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    _topicNameController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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

          // Faded background logo
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

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Top logo
                  Center(
                    child: Image.asset(
                      'assets/lu.png',
                      height: 120,
                      width: 200,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Add Study Material",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontFamily: 'inter',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Topic name + course code
                        TextFormField(
                          controller: _topicNameController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: "TopicName_CourseCode",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.95),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 20),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter study material name";
                            }
                            if (!_namePattern.hasMatch(value.trim().toUpperCase())) {
                              return "Invalid format. Example: NETWORK_CSE101";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Google Drive link (mandatory)
                        TextFormField(
                          controller: _linkController,
                          decoration: InputDecoration(
                            hintText: "Google Drive Link (mandatory)",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.95),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 20),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please provide a Google Drive link";
                            }
                            if (!_driveLinkPattern.hasMatch(value.trim())) {
                              return "Invalid link. Only Google Drive links allowed";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(140, 238, 173, 0.9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 20),
                              elevation: 3,
                            ),
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(0,0,0,1),
                                fontFamily: 'inter',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Rules container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      "📌 Naming Rules:\n\n"
                      "- Format: TopicName_CourseCode\n"
                      "- Example: NETWORK_CSE101\n"
                      "- Letters must be UPPERCASE\n"
                      "- Google Drive link is mandatory and must be valid",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
