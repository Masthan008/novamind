import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../../widgets/glass_container.dart';

/// Assignment Tracker — Track assignments with subtasks, priority, and completion
class AssignmentTrackerScreen extends StatefulWidget {
  const AssignmentTrackerScreen({super.key});

  @override
  State<AssignmentTrackerScreen> createState() => _AssignmentTrackerScreenState();
}

class _AssignmentTrackerScreenState extends State<AssignmentTrackerScreen> {
  late Box _assignBox;
  List<Map<String, dynamic>> _assignments = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, pending, overdue, completed

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _assignBox = Hive.box('assignments_data');
    final saved = _assignBox.get('assignments');
    if (saved != null) {
      _assignments = List<Map<String, dynamic>>.from(
        (saved as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }
    setState(() => _isLoading = false);
  }

  void _saveData() => _assignBox.put('assignments', _assignments);

  bool _isOverdue(Map<String, dynamic> a) {
    if (a['completed'] == true) return false;
    final due = DateTime.tryParse(a['dueDate'] ?? '');
    return due != null && due.isBefore(DateTime.now());
  }

  double _completionPercent(Map<String, dynamic> a) {
    final subtasks = List<Map<String, dynamic>>.from(a['subtasks'] ?? []);
    if (subtasks.isEmpty) return a['completed'] == true ? 1.0 : 0.0;
    final done = subtasks.where((s) => s['done'] == true).length;
    return done / subtasks.length;
  }

  List<Map<String, dynamic>> get _filteredAssignments {
    var list = List<Map<String, dynamic>>.from(_assignments);
    switch (_filter) {
      case 'pending': list = list.where((a) => a['completed'] != true && !_isOverdue(a)).toList(); break;
      case 'overdue': list = list.where((a) => _isOverdue(a)).toList(); break;
      case 'completed': list = list.where((a) => a['completed'] == true).toList(); break;
    }
    list.sort((a, b) {
      // Overdue first, then by priority, then by date
      if (_isOverdue(a) && !_isOverdue(b)) return -1;
      if (!_isOverdue(a) && _isOverdue(b)) return 1;
      final pa = a['priority'] ?? 'medium';
      final pb = b['priority'] ?? 'medium';
      final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      final diff = (priorityOrder[pa] ?? 1) - (priorityOrder[pb] ?? 1);
      if (diff != 0) return diff;
      return (a['dueDate'] ?? '').compareTo(b['dueDate'] ?? '');
    });
    return list;
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high': return Colors.redAccent;
      case 'low': return Colors.greenAccent;
      default: return Colors.amberAccent;
    }
  }

  void _addAssignment() {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'medium';
    DateTime dueDate = DateTime.now().add(const Duration(days: 3));

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Assignment', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),
              TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Assignment Title')),
              const SizedBox(height: 10),
              TextField(controller: subjectCtrl, style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Subject')),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Description (optional)'), maxLines: 2),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Priority: ', style: GoogleFonts.poppins(color: Colors.white70)),
                  ...['low', 'medium', 'high'].map((p) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ChoiceChip(
                      label: Text(p[0].toUpperCase() + p.substring(1), style: TextStyle(color: priority == p ? Colors.black : Colors.white70, fontSize: 12)),
                      selected: priority == p,
                      selectedColor: _priorityColor(p),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      onSelected: (_) => setModalState(() => priority = p),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(context: ctx, initialDate: dueDate,
                    firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (date != null) setModalState(() => dueDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.event, color: Colors.cyanAccent, size: 18),
                    const SizedBox(width: 12),
                    Text('Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}', style: GoogleFonts.poppins(color: Colors.white)),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    setState(() {
                      _assignments.add({
                        'title': titleCtrl.text.trim(),
                        'subject': subjectCtrl.text.trim(),
                        'description': descCtrl.text.trim(),
                        'priority': priority,
                        'dueDate': dueDate.toIso8601String(),
                        'completed': false,
                        'subtasks': <Map<String, dynamic>>[],
                        'createdAt': DateTime.now().toIso8601String(),
                      });
                      _saveData();
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                    foregroundColor: Colors.cyanAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Add Assignment', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint, hintStyle: TextStyle(color: Colors.white30),
    filled: true, fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  void _addSubtask(int index) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text('Add Subtask', style: GoogleFonts.poppins(color: Colors.white)),
        content: TextField(
          controller: ctrl, style: const TextStyle(color: Colors.white),
          decoration: _inputDeco('Subtask description'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isEmpty) return;
              setState(() {
                final subtasks = List<Map<String, dynamic>>.from(_assignments[index]['subtasks'] ?? []);
                subtasks.add({'text': ctrl.text.trim(), 'done': false});
                _assignments[index]['subtasks'] = subtasks;
                _saveData();
              });
              Navigator.pop(ctx);
            },
            child: Text('Add', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: const Color(0xFF0A0A0F),
        body: const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)));
    }

    final filtered = _filteredAssignments;
    final overdueCount = _assignments.where((a) => _isOverdue(a)).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [Colors.amber, Colors.deepOrangeAccent]).createShader(bounds),
          child: Text('Assignments', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAssignment,
        backgroundColor: Colors.cyanAccent.withOpacity(0.9),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip('All', 'all', Colors.cyanAccent),
                _filterChip('Pending', 'pending', Colors.amberAccent),
                _filterChip('Overdue ($overdueCount)', 'overdue', Colors.redAccent),
                _filterChip('Done', 'completed', Colors.greenAccent),
              ],
            ),
          ),

          // Assignments list
          Expanded(
            child: filtered.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.assignment_outlined, size: 64, color: Colors.white24),
                    const SizedBox(height: 16),
                    Text('No assignments', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16)),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final assignment = filtered[index];
                    final globalIdx = _assignments.indexOf(assignment);
                    return _buildAssignmentCard(assignment, globalIdx);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, Color color) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(color: selected ? Colors.black : Colors.white70, fontSize: 12)),
        selected: selected,
        selectedColor: color,
        backgroundColor: Colors.white.withOpacity(0.1),
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment, int globalIdx) {
    final completed = assignment['completed'] == true;
    final overdue = _isOverdue(assignment);
    final priority = assignment['priority'] ?? 'medium';
    final color = _priorityColor(priority);
    final percent = _completionPercent(assignment);
    final subtasks = List<Map<String, dynamic>>.from(assignment['subtasks'] ?? []);
    final dueDate = DateTime.tryParse(assignment['dueDate'] ?? '');
    final daysLeft = dueDate != null ? dueDate.difference(DateTime.now()).inDays : 0;

    return Dismissible(
      key: Key('assign_$globalIdx'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          // Swipe right = complete
          setState(() { _assignments[globalIdx]['completed'] = true; _saveData(); });
          return false;
        }
        return true; // swipe left = delete
      },
      onDismissed: (_) {
        setState(() { _assignments.removeAt(globalIdx); _saveData(); });
      },
      background: Container(
        alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.check_circle, color: Colors.greenAccent),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.redAccent),
      ),
      child: GlassContainer(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Priority dot
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)])),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(assignment['title'] ?? '',
                    style: GoogleFonts.poppins(
                      color: completed ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.w600, fontSize: 15,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    )),
                ),
                if (overdue) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text('OVERDUE', style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                if (completed) const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
              ],
            ),
            if ((assignment['subject'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(assignment['subject'], style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
            ],
            if (dueDate != null) ...[
              const SizedBox(height: 6),
              Text('Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}${daysLeft > 0 ? ' ($daysLeft days left)' : ''}',
                style: GoogleFonts.poppins(color: overdue ? Colors.redAccent : Colors.white38, fontSize: 11)),
            ],

            // Progress bar
            if (subtasks.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: percent, backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(percent >= 1.0 ? Colors.greenAccent : Colors.cyanAccent), minHeight: 5)),
                  ),
                  const SizedBox(width: 8),
                  Text('${(percent * 100).toInt()}%', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 8),
              // Subtasks
              ...subtasks.asMap().entries.map((e) {
                final st = e.value;
                return InkWell(
                  onTap: () {
                    setState(() {
                      final subs = List<Map<String, dynamic>>.from(_assignments[globalIdx]['subtasks']);
                      subs[e.key]['done'] = !(subs[e.key]['done'] ?? false);
                      _assignments[globalIdx]['subtasks'] = subs;
                      // Auto-complete if all subtasks done
                      if (subs.every((s) => s['done'] == true)) {
                        _assignments[globalIdx]['completed'] = true;
                      }
                      _saveData();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      Icon(st['done'] == true ? Icons.check_box : Icons.check_box_outline_blank,
                        color: st['done'] == true ? Colors.greenAccent : Colors.white38, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(st['text'] ?? '', style: GoogleFonts.poppins(
                        color: st['done'] == true ? Colors.white38 : Colors.white70, fontSize: 12,
                        decoration: st['done'] == true ? TextDecoration.lineThrough : null))),
                    ]),
                  ),
                );
              }),
            ],

            // Add subtask button
            const SizedBox(height: 6),
            InkWell(
              onTap: () => _addSubtask(globalIdx),
              child: Row(children: [
                Icon(Icons.add, color: Colors.cyanAccent, size: 16),
                const SizedBox(width: 4),
                Text('Add Subtask', style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 11)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
