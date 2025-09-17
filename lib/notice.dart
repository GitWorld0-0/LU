import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
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

                  // Logo + Admin button
                  Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/lu.png',
                          height: 90,
                          width: 95,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.admin_panel_settings, color: Colors.black87),
                          onPressed: () {
                            if (FirebaseAuth.instance.currentUser?.email == "adminlu@gmail.com") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AdminScreen()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("❌ You are not an admin")),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Notices",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 0, 0, 0.75),
                      fontFamily: 'inter',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search box
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by Title",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.95),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Notices list
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("notices")
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No notices available",
                            style: TextStyle(fontSize: 16, fontFamily: 'inter'),
                          ),
                        );
                      }

                      // Filter notices by title
                      final docs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final title = (data["title"] ?? "").toString().toLowerCase();
                        return title.contains(_searchQuery);
                      }).toList();

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No notices match your search",
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

                          final title = data["title"] ?? "Untitled";
                          final notice = data["notice"] ?? "";
                          final timestamp = (data["timestamp"] as Timestamp?)?.toDate();

                          // Title style
                          final titleBold = data["titleBold"] ?? false;
                          final titleFontSize = (data["titleFontSize"] ?? 16).toDouble();
                          final titleColor = Color(data["titleColor"] ?? Colors.black.value);

                          // Notice style
                          final noticeBold = data["noticeBold"] ?? false;
                          final noticeFontSize = (data["noticeFontSize"] ?? 14).toDouble();
                          final noticeColor = Color(data["noticeColor"] ?? Colors.black.value);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Material(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontWeight:
                                            titleBold ? FontWeight.bold : FontWeight.normal,
                                        fontSize: titleFontSize,
                                        color: titleColor,
                                        fontFamily: 'inter',
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ExpandableText(
                                      text: notice,
                                      fontSize: noticeFontSize,
                                      isBold: noticeBold,
                                      color: noticeColor,
                                      trimLines: 10, // Show "Show more" after 10 lines
                                    ),
                                    if (timestamp != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Text(
                                          "Date: ${timestamp.day}-${timestamp.month}-${timestamp.year}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontFamily: 'inter',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),

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

/// ExpandableText widget (Show more/less after 10 lines)
class ExpandableText extends StatefulWidget {
  final String text;
  final double fontSize;
  final bool isBold;
  final Color color;
  final int trimLines;

  const ExpandableText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.isBold,
    required this.color,
    this.trimLines = 10, // Show "Show more" after 10 lines
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  bool needExpand = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTextHeight());
  }

  void _checkTextHeight() {
    if (!mounted) return;

    final maxWidth = context.size?.width ?? 300;

    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: widget.isBold ? FontWeight.bold : FontWeight.normal,
          color: widget.color,
        ),
      ),
      maxLines: widget.trimLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    if (textPainter.didExceedMaxLines) {
      setState(() => needExpand = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: widget.isBold ? FontWeight.bold : FontWeight.normal,
            color: widget.color,
          ),
          maxLines: isExpanded ? null : widget.trimLines,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (needExpand)
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                isExpanded ? "Show less" : "Show more",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
