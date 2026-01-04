import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/flowchart_data.dart';

class FlowchartsScreen extends StatelessWidget {
  const FlowchartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.account_tree, color: Colors.cyanAccent),
            const SizedBox(width: 10),
            Text(
              'C Programming Flowcharts',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade900.withOpacity(0.5),
                  Colors.blue.shade900.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 Master Problem Solving',
                  style: GoogleFonts.poppins(
                    color: Colors.cyanAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Learn algorithms through visual flowcharts with real-world applications',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.2, end: 0),

          const SizedBox(height: 25),

          // Difficulty Sections
          _buildDifficultySection(context, 'Easy', Colors.green, FlowchartData.easyTopics, 0),
          const SizedBox(height: 20),
          _buildDifficultySection(context, 'Medium', Colors.orange, FlowchartData.mediumTopics, 100),
          const SizedBox(height: 20),
          _buildDifficultySection(context, 'Hard', Colors.red, FlowchartData.hardTopics, 200),
        ],
      ),
    );
  }

  Widget _buildDifficultySection(
    BuildContext context,
    String difficulty,
    Color color,
    List<FlowchartTopic> topics,
    int delay,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color, width: 2),
              ),
              child: Row(
                children: [
                  Icon(
                    difficulty == 'Easy'
                        ? Icons.star
                        : difficulty == 'Medium'
                            ? Icons.stars
                            : Icons.auto_awesome,
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    difficulty.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${topics.length} Topics',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        )
          .animate()
          .fadeIn(delay: delay.ms, duration: 400.ms)
          .slideX(begin: -0.2, end: 0),

        const SizedBox(height: 12),

        ...topics.asMap().entries.map((entry) {
          final index = entry.key;
          final topic = entry.value;
          return _buildTopicCard(context, topic, color, delay + (index * 50));
        }).toList(),
      ],
    );
  }

  Widget _buildTopicCard(BuildContext context, FlowchartTopic topic, Color color, int delay) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlowchartDetailScreen(topic: topic),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.account_tree, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topic.problem,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color, size: 16),
              ],
            ),
          ),
        ),
      ),
    )
      .animate()
      .fadeIn(delay: delay.ms, duration: 400.ms)
      .slideX(begin: 0.2, end: 0);
  }
}

// Detail Screen with Zoom Functionality
class FlowchartDetailScreen extends StatefulWidget {
  final FlowchartTopic topic;

  const FlowchartDetailScreen({super.key, required this.topic});

  @override
  State<FlowchartDetailScreen> createState() => _FlowchartDetailScreenState();
}

class _FlowchartDetailScreenState extends State<FlowchartDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        title: Text(
          widget.topic.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.account_tree), text: 'Flowchart'),
            Tab(icon: Icon(Icons.list), text: 'Algorithm'),
            Tab(icon: Icon(Icons.code), text: 'Code'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Real-World'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFlowchartTab(),
          _buildAlgorithmTab(),
          _buildCodeTab(),
          _buildRealWorldTab(),
        ],
      ),
    );
  }

  Widget _buildFlowchartTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade900,
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.cyanAccent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pinch to zoom • Double tap to reset',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.cyanAccent),
                onPressed: () {
                  _transformationController.value = Matrix4.identity();
                },
                tooltip: 'Reset Zoom',
              ),
            ],
          ),
        ),
        Expanded(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.asset(
                widget.topic.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, color: Colors.white38, size: 80),
                        const SizedBox(height: 20),
                        Text(
                          'Flowchart image not found',
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Generate and add: ${widget.topic.imagePath}',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlgorithmTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Problem Statement',
          style: GoogleFonts.orbitron(
            color: Colors.cyanAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
          ),
          child: Text(
            widget.topic.problem,
            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),
        ),
        const SizedBox(height: 25),
        Text(
          'Algorithm Steps',
          style: GoogleFonts.orbitron(
            color: Colors.cyanAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...widget.topic.algorithm.map((step) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Text(
              step,
              style: GoogleFonts.firaCode(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCodeTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey.shade900,
          child: Row(
            children: [
              Icon(Icons.code, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'C Programming Code',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.topic.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.greenAccent),
                          const SizedBox(width: 8),
                          Text('Code copied to clipboard!'),
                        ],
                      ),
                      backgroundColor: Colors.grey.shade800,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: Icon(Icons.copy, size: 16),
                label: Text('Copy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: SelectableText(
                widget.topic.code,
                style: GoogleFonts.firaCode(
                  color: Colors.greenAccent,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealWorldTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(Icons.lightbulb, color: Colors.amber, size: 60),
        const SizedBox(height: 20),
        Text(
          'Real-World Applications',
          style: GoogleFonts.orbitron(
            color: Colors.amber,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade900.withOpacity(0.3),
                Colors.orange.shade900.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.amber.withOpacity(0.5)),
          ),
          child: Text(
            widget.topic.realWorldUse,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💡 Why This Matters',
                style: GoogleFonts.poppins(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Understanding this algorithm helps you solve real problems in software development, data analysis, and system design. These concepts are used daily by engineers at companies like Google, Amazon, and Microsoft.',
                style: TextStyle(color: Colors.white70, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
