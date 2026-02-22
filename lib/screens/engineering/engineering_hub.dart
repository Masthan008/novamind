import 'package:flutter/material.dart';
import 'package:sentinel/data/engineering_data.dart';
import 'package:sentinel/screens/engineering/topic_viewer_screen.dart';


class EngineeringHub extends StatelessWidget {
  const EngineeringHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.engineering, size: 24),
            SizedBox(width: 8),
            Text(
              "Engineering Hub",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade900, Colors.blue.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Master Engineering Graphics",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Offline diagrams with step-by-step procedures",
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatChip("Graphics", Colors.tealAccent, Icons.architecture),
                    const SizedBox(width: 8),
                    _buildStatChip("Civil", Colors.orange, Icons.foundation),
                    const SizedBox(width: 8),
                    _buildStatChip("CSE", Colors.blue, Icons.computer),
                  ],
                ),
              ],
            ),
          ),




          // Branch Cards
          // 📐 FIRST YEAR GRAPHICS
          _buildBranchCard(
            context,
            "Engineering Graphics (1st Year)",
            Colors.tealAccent,
            Icons.architecture,
            EngineeringData.graphicsTopics,
            "Curves, Projections & Development",
          ),
          _buildBranchCard(
            context,
            "Civil Engineering",
            Colors.orange,
            Icons.foundation,
            EngineeringData.civilTopics,
            "Structural Analysis & Design",
          ),
          _buildBranchCard(
            context,
            "Computer Science (CSE)",
            Colors.blueAccent,
            Icons.computer,
            EngineeringData.cseTopics,
            "Data Structures & Algorithms",
          ),
          _buildBranchCard(
            context,
            "Electronics (ECE/EEE)",
            Colors.purpleAccent,
            Icons.electrical_services,
            EngineeringData.eceTopics,
            "Circuit Analysis & Digital Design",
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
    List<EngineeringTopic> topics,
    String subtitle,
  ) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "$subtitle • ${topics.length} Topics",
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
        iconColor: color,
        collapsedIconColor: color.withOpacity(0.7),
        children: topics.map((topic) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[800]!, width: 0.5),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              title: Text(
                topic.title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article_outlined,
                  color: color.withOpacity(0.7),
                  size: 20,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey[600],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TopicViewerScreen(topic: topic),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
