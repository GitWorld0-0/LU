import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionNameController = TextEditingController();
  final TextEditingController _questionLinkController = TextEditingController();

  // Regex to validate question name: BATCH_DEPT_(MID|FINAL|TUTORIAL)_CODE
  final RegExp _namePattern =
      RegExp(r'^[0-9]+_[A-Z]+_(MID|FINAL|TUTORIAL)_[A-Z0-9]+$');

  // Regex to validate Google Drive links
  final RegExp _driveLinkPattern = RegExp(r'^https:\/\/drive\.google\.com\/.*$');

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    final questionName = _questionNameController.text.trim().toUpperCase();
    final questionLink = _questionLinkController.text.trim();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No logged-in user found")),
        );
        return;
      }

      // Check if question already exists
      final query = await FirebaseFirestore.instance
          .collection("questionbank")
          .where("questionName", isEqualTo: questionName)
          .get();

      if (query.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "❌ This question already exists. You cannot add it twice.")),
        );
        return;
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection("questionbank").add({
        "email": user.email ?? "unknown",
        "name": user.displayName ?? "No Name",
        "questionName": questionName,
        "questionLink": questionLink,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Question added successfully")),
      );

      _questionNameController.clear();
      _questionLinkController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    _questionNameController.dispose();
    _questionLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents background from moving
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

          // Faded background logo (fixed)
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

          // Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
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
                    "Add Question",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontFamily: 'inter',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rules box
                  

                  // Form fields
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Question Name
                        TextFormField(
                          controller: _questionNameController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: "Question Name",
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
                              return "Please enter question name";
                            }
                            if (!_namePattern.hasMatch(value.trim().toUpperCase())) {
                              return "Invalid format. Example: 60_CSE_MID_CSE2021";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Question Link
                        TextFormField(
                          controller: _questionLinkController,
                          decoration: InputDecoration(
                            hintText: "Question Link (Google Drive)",
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
                              return "Please enter question link";
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
                              backgroundColor:
                                  const Color.fromRGBO(140, 238, 173, 0.9),
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
                      "- Format: BATCH_DEPT_EXAMTYPE_CODE\n"
                      "- Example: 60_CSE_MID_CSE2021\n"
                      "- Exam types allowed: MID, FINAL, TUTORIAL\n"
                      "- Letters must be UPPERCASE\n"
                      "- Google Drive link → General Access → Viewer",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Bottom text/quote
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
