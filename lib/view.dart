import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchLink(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No link available for this question")),
      );
      return;
    }

    try {
      String fixedUrl = url.trim();

      // Ensure the URL has a proper scheme
      if (!fixedUrl.startsWith(RegExp(r'https?://'))) {
        fixedUrl = "https://$fixedUrl";
      }

      final uri = Uri.parse(fixedUrl);

      // Try opening in external app (Google Drive)
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication)
            .catchError((_) async {
          // Fallback to browser if external app fails
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        });
      } else {
        // Fallback to browser if canLaunchUrl fails
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Could not open link: $e")),
      );
    }
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
                    "Question Bank",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontFamily: 'inter',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search box
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search questions...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.95),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // List of questions
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("questionbank")
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No questions found",
                            style: TextStyle(fontSize: 16, fontFamily: 'inter'),
                          ),
                        );
                      }

                      // Filter locally for partial & case-insensitive search
                      final docs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final questionName =
                            (data["questionName"] ?? "").toString().toLowerCase();
                        return questionName.contains(_searchQuery);
                      }).toList();

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No questions match your search",
                            style: TextStyle(fontSize: 16, fontFamily: 'inter'),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final questionName = data["questionName"] ?? "No Name";
                          final link = data["questionLink"] ?? "";

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Material(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              child: ListTile(
                                title: Text(
                                  questionName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'inter',
                                  ),
                                ),
                                trailing: const Icon(Icons.open_in_new),
                                onTap: () => _launchLink(link),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),

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
