import 'package:flutter/material.dart';

class RoadmapTrackerPage extends StatefulWidget {
  final String title;
  final String content;

  const RoadmapTrackerPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<RoadmapTrackerPage> createState() => _RoadmapTrackerPageState();
}

class _RoadmapTrackerPageState extends State<RoadmapTrackerPage> {
  bool showFullContent = false;

  @override
  Widget build(BuildContext context) {
    final String displayContent = showFullContent
        ? widget.content
        : widget.content.length > 150
            ? '${widget.content.substring(0, 150)}...'
            : widget.content;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('📌 Tracked Roadmap', style: TextStyle(color: Colors.greenAccent)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title.replaceAll('**', ''),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                displayContent,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      showFullContent = !showFullContent;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.greenAccent,
                  ),
                  child: Text(showFullContent ? 'View Less' : 'View More'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
