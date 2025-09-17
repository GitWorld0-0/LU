import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noticeController = TextEditingController();

  // Formatting states for Add Notice
  bool isTitleBold = false;
  double titleFontSize = 18;
  Color titleColor = Colors.black;

  bool isNoticeBold = false;
  double noticeFontSize = 16;
  Color noticeColor = Colors.black;

  /// Add a new notice
  Future<void> _addNotice() async {
    final title = _titleController.text.trim();
    final notice = _noticeController.text.trim();
    final email = FirebaseAuth.instance.currentUser?.email ?? "unknown";

    if (title.isEmpty || notice.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Title and Notice cannot be empty")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("notices").add({
      "title": title,
      "notice": notice,
      "email": email,
      "timestamp": FieldValue.serverTimestamp(),
      "titleBold": isTitleBold,
      "titleFontSize": titleFontSize,
      "titleColor": titleColor.value,
      "noticeBold": isNoticeBold,
      "noticeFontSize": noticeFontSize,
      "noticeColor": noticeColor.value,
    });

    _titleController.clear();
    _noticeController.clear();
    setState(() {
      isTitleBold = false;
      titleFontSize = 18;
      titleColor = Colors.black;
      isNoticeBold = false;
      noticeFontSize = 16;
      noticeColor = Colors.black;
    });
  }

  /// Update a notice
  Future<void> _updateNotice(String docId, Map<String, dynamic> data) async {
    final editTitleController = TextEditingController(text: data["title"]);
    final editNoticeController = TextEditingController(text: data["notice"]);

    bool editTitleBold = data["titleBold"] ?? false;
    double editTitleFontSize = (data["titleFontSize"] ?? 18).toDouble();
    Color editTitleColor =
        Color(data["titleColor"] ?? Colors.black.value);

    bool editNoticeBold = data["noticeBold"] ?? false;
    double editNoticeFontSize = (data["noticeFontSize"] ?? 16).toDouble();
    Color editNoticeColor =
        Color(data["noticeColor"] ?? Colors.black.value);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Update Notice"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildToolbar(
                      isBold: editTitleBold,
                      fontSize: editTitleFontSize,
                      color: editTitleColor,
                      onToggleBold: () =>
                          setDialogState(() => editTitleBold = !editTitleBold),
                      onFontSizeChange: (v) =>
                          setDialogState(() => editTitleFontSize = v),
                      onPickColor: () => _pickColor(
                        true,
                        (c) => setDialogState(() => editTitleColor = c),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: editTitleController,
                      decoration: InputDecoration(
                        hintText: "Enter notice title...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      style: TextStyle(
                        fontWeight: editTitleBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: editTitleFontSize,
                        color: editTitleColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildToolbar(
                      isBold: editNoticeBold,
                      fontSize: editNoticeFontSize,
                      color: editNoticeColor,
                      onToggleBold: () =>
                          setDialogState(() => editNoticeBold = !editNoticeBold),
                      onFontSizeChange: (v) =>
                          setDialogState(() => editNoticeFontSize = v),
                      onPickColor: () => _pickColor(
                        false,
                        (c) => setDialogState(() => editNoticeColor = c),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: editNoticeController,
                      decoration: InputDecoration(
                        hintText: "Write a notice...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      maxLines: null,
                      style: TextStyle(
                        fontWeight: editNoticeBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: editNoticeFontSize,
                        color: editNoticeColor,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("notices")
                        .doc(docId)
                        .update({
                      "title": editTitleController.text.trim(),
                      "notice": editNoticeController.text.trim(),
                      "titleBold": editTitleBold,
                      "titleFontSize": editTitleFontSize,
                      "titleColor": editTitleColor.value,
                      "noticeBold": editNoticeBold,
                      "noticeFontSize": editNoticeFontSize,
                      "noticeColor": editNoticeColor.value,
                      "timestamp": FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Delete a notice
  Future<void> _deleteNotice(String docId) async {
    await FirebaseFirestore.instance.collection("notices").doc(docId).delete();
  }

  /// Color picker
  Future<void> _pickColor(bool isForTitle, Function(Color) onPicked) async {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.teal,
    ];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isForTitle ? "Pick Title Color" : "Pick Notice Color"),
        content: Wrap(
          spacing: 8,
          children: colors
              .map((c) => GestureDetector(
                    onTap: () {
                      onPicked(c);
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(backgroundColor: c, radius: 18),
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// Toolbar widget
  Widget _buildToolbar({
    required bool isBold,
    required double fontSize,
    required Color color,
    required VoidCallback onToggleBold,
    required ValueChanged<double> onFontSizeChange,
    required VoidCallback onPickColor,
  }) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.format_bold,
              color: isBold ? Colors.green : Colors.black),
          onPressed: onToggleBold,
        ),
        const SizedBox(width: 8),
        const Text("Font Size:"),
        const SizedBox(width: 5),
        DropdownButton<double>(
          value: fontSize,
          items: [14, 16, 18, 20, 24, 28, 32]
              .map((size) => DropdownMenuItem(
                    value: size.toDouble(),
                    child: Text(size.toString()),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) onFontSizeChange(value);
          },
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onPickColor,
          child: CircleAvatar(backgroundColor: color, radius: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // prevents background shifting
      body: Stack(
        children: [
          // Background
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
          Positioned.fill(
            child: Center(
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
          ),

          // Foreground
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Center(child: Image.asset('assets/lu.png', height: 90)),
                  const SizedBox(height: 15),
                  const Text(
                    "Admin Panel - Notices",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'inter'),
                  ),
                  const SizedBox(height: 20),

                  // Title editor
                  _buildToolbar(
                    isBold: isTitleBold,
                    fontSize: titleFontSize,
                    color: titleColor,
                    onToggleBold: () =>
                        setState(() => isTitleBold = !isTitleBold),
                    onFontSizeChange: (v) =>
                        setState(() => titleFontSize = v),
                    onPickColor: () => _pickColor(true, (c) {
                      setState(() => titleColor = c);
                    }),
                  ),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Enter notice title...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    style: TextStyle(
                      fontWeight:
                          isTitleBold ? FontWeight.bold : FontWeight.normal,
                      fontSize: titleFontSize,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Notice editor
                  _buildToolbar(
                    isBold: isNoticeBold,
                    fontSize: noticeFontSize,
                    color: noticeColor,
                    onToggleBold: () =>
                        setState(() => isNoticeBold = !isNoticeBold),
                    onFontSizeChange: (v) =>
                        setState(() => noticeFontSize = v),
                    onPickColor: () => _pickColor(false, (c) {
                      setState(() => noticeColor = c);
                    }),
                  ),
                  TextField(
                    controller: _noticeController,
                    decoration: InputDecoration(
                      hintText: "Write a notice...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    maxLines: null,
                    style: TextStyle(
                      fontWeight:
                          isNoticeBold ? FontWeight.bold : FontWeight.normal,
                      fontSize: noticeFontSize,
                      color: noticeColor,
                    ),
                  ),
                  const SizedBox(height: 15),

                  ElevatedButton.icon(
                    onPressed: _addNotice,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Notice"),
                  ),
                  const SizedBox(height: 20),

                  // Notice list
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("notices")
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Text("No notices yet");
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final timestamp =
                              (data["timestamp"] as Timestamp?)?.toDate();

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data["title"] ?? "",
                                    style: TextStyle(
                                      fontSize:
                                          (data["titleFontSize"] ?? 18).toDouble(),
                                      fontWeight: (data["titleBold"] ?? false)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: Color(data["titleColor"] ??
                                          Colors.black.value),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ExpandableText(
                                    text: data["notice"] ?? "",
                                    fontSize:
                                        (data["noticeFontSize"] ?? 16).toDouble(),
                                    isBold: data["noticeBold"] ?? false,
                                    color: Color(data["noticeColor"] ??
                                        Colors.black.value),
                                  ),
                                  if (timestamp != null)
                                    Text(
                                      "Date: ${timestamp.day}-${timestamp.month}-${timestamp.year}",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.orange),
                                        onPressed: () =>
                                            _updateNotice(doc.id, data),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _deleteNotice(doc.id),
                                      ),
                                    ],
                                  ),
                                ],
                                
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
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
    );
  }
}

/// ExpandableText with Show more / Show less
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
    this.trimLines = 2,
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
            child: Text(
              isExpanded ? "Show less" : "Show more",
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
