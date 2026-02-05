import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 9,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F0F0F),
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
              ],
            ),
          ),
          child: Column(
            children: [
              // Custom Glass AppBar
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            'Quantum Calc',
                            style: GoogleFonts.orbitron(
                              color: Colors.cyanAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10)],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      isScrollable: true,
                      indicatorColor: Colors.cyanAccent,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 3,
                      labelColor: Colors.cyanAccent,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                      unselectedLabelStyle: GoogleFonts.montserrat(),
                      tabs: const [
                        Tab(icon: Icon(Icons.calculate), text: 'Calc'),
                        Tab(icon: Icon(Icons.school), text: 'CGPA'),
                        Tab(icon: Icon(Icons.monitor_weight), text: 'BMI'),
                        Tab(icon: Icon(Icons.cake), text: 'Age'),
                        Tab(icon: Icon(Icons.functions), text: 'Equation'),
                        Tab(icon: Icon(Icons.percent), text: 'Percent'),
                        Tab(icon: Icon(Icons.local_offer), text: 'Discount'),
                        Tab(icon: Icon(Icons.restaurant), text: 'Tip'),
                        Tab(icon: Icon(Icons.account_balance), text: 'Loan'),
                      ],
                    ),
                  ],
                ),
              ),
              // Body
              const Expanded(
                child: TabBarView(
                  children: [
                    _ScientificCalculatorTab(),
                    _CGPATab(),
                    _BMITab(),
                    _AgeCalculatorTab(),
                    _EquationSolverTab(),
                    _PercentageTab(),
                    _DiscountCalculatorTab(),
                    _TipCalculatorTab(),
                    _LoanCalculatorTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// TAB 1: Scientific Calculator
// ============================================
class _ScientificCalculatorTab extends StatefulWidget {
  const _ScientificCalculatorTab();

  @override
  State<_ScientificCalculatorTab> createState() => _ScientificCalculatorTabState();
}

class _ScientificCalculatorTabState extends State<_ScientificCalculatorTab> {
  String _expression = '';
  String _result = '0';
  bool _isDegrees = true;
  List<String> _history = [];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'AC') {
        _expression = '';
        _result = '0';
      } else if (value == 'DEL') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        _evaluateExpression();
      } else if (value == 'DEG/RAD') {
        _isDegrees = !_isDegrees;
      } else if (value == '√') {
        _expression += 'sqrt(';
      } else if (value == 'sin') {
        _expression += 'sin(';
      } else if (value == 'cos') {
        _expression += 'cos(';
      } else if (value == 'tan') {
        _expression += 'tan(';
      } else if (value == 'log') {
        _expression += 'log(';
      } else if (value == 'ln') {
        _expression += 'ln(';
      } else if (value == '^') {
        _expression += '^';
      } else if (value == 'π') {
        _expression += 'π';
      } else if (value == 'e') {
        _expression += 'e';
      } else {
        _expression += value;
      }
    });
  }

  void _evaluateExpression() {
    try {
      String expr = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', math.pi.toString())
          .replaceAll('e', math.e.toString());
      
      if (_isDegrees) {
        expr = _convertDegreesToRadians(expr);
      }
      
      Parser parser = Parser();
      Expression exp = parser.parse(expr);
      ContextModel contextModel = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, contextModel);
      
      if (eval % 1 == 0) {
        _result = eval.toInt().toString();
      } else {
        _result = eval.toStringAsFixed(8).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
      }
      
      _history.insert(0, '$_expression = $_result');
      if (_history.length > 10) _history.removeLast();
    } catch (e) {
      _result = 'Error';
    }
  }

  String _convertDegreesToRadians(String expr) {
    final degToRad = math.pi / 180;
    expr = expr.replaceAllMapped(
      RegExp(r'sin\(([^)]+)\)'),
      (match) => 'sin((${match.group(1)})*$degToRad)',
    );
    expr = expr.replaceAllMapped(
      RegExp(r'cos\(([^)]+)\)'),
      (match) => 'cos((${match.group(1)})*$degToRad)',
    );
    expr = expr.replaceAllMapped(
      RegExp(r'tan\(([^)]+)\)'),
      (match) => 'tan((${match.group(1)})*$degToRad)',
    );
    return expr;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        // LCD Screen
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 120, maxHeight: 160),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F).withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'QUANTUM MATH OS',
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        color: Colors.cyanAccent.withOpacity(0.5),
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _isDegrees ? 'DEG' : 'RAD',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    _expression.isEmpty ? '0' : _expression,
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      color: Colors.white54,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _result,
                    style: GoogleFonts.orbitron(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Keypad
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Column(
                children: [
                  _buildRow(['sin', 'cos', 'tan', 'DEG/RAD'], isScientific: true),
                  const SizedBox(height: 12),
                  _buildRow(['log', 'ln', '√', '^'], isScientific: true),
                  const SizedBox(height: 12),
                  _buildRow(['π', 'e', '(', ')'], isScientific: true),
                  const SizedBox(height: 12),
                  _buildRow(['AC', 'DEL', '%', '÷'], isFunction: true),
                  const SizedBox(height: 12),
                  _buildRow(['7', '8', '9', '×']),
                  const SizedBox(height: 12),
                  _buildRow(['4', '5', '6', '-']),
                  const SizedBox(height: 12),
                  _buildRow(['1', '2', '3', '+']),
                  const SizedBox(height: 12),
                  _buildRow(['0', '.', '=', '=']),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> labels, {bool isScientific = false, bool isFunction = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.map((label) {
        return _buildButton(label, isScientific: isScientific, isFunction: isFunction);
      }).toList(),
    );
  }

  Widget _buildButton(String label, {bool isScientific = false, bool isFunction = false}) {
    bool isOperator = ['÷', '×', '-', '+', '%'].contains(label);
    bool isEquals = label == '=';
    bool isSpecialFunction = ['AC', 'DEL'].contains(label);
    
    Color textColor;
    if (isEquals) {
      textColor = Colors.black;
    } else if (isScientific) {
      textColor = Colors.cyanAccent;
    } else if (isSpecialFunction) {
      textColor = Colors.redAccent;
    } else if (isFunction || isOperator) {
      textColor = Colors.orangeAccent;
    } else {
      textColor = Colors.white;
    }

    double width = (MediaQuery.of(context).size.width - 70) / 4;
    
    return InkWell(
      onTap: () {
        _onButtonPressed(label);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        height: 60,
        decoration: BoxDecoration(
          color: isEquals ? Colors.cyanAccent : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEquals ? Colors.cyanAccent : Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: isEquals ? [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: label.length > 3 ? 12 : 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// TAB 2: CGPA Calculator
// ============================================
class _CGPATab extends StatefulWidget {
  const _CGPATab();

  @override
  State<_CGPATab> createState() => _CGPATabState();
}

class _CGPATabState extends State<_CGPATab> {
  final List<Map<String, dynamic>> _subjects = [];

  final Map<String, int> _gradePoints = {
    'O': 10,
    'A+': 9,
    'A': 8,
    'B+': 7,
    'B': 6,
    'C': 5,
    'F': 0,
  };

  void _addSubject() {
    setState(() {
      _subjects.add({
        'name': 'Subject ${_subjects.length + 1}',
        'credits': 3,
        'grade': 'A',
      });
    });
  }

  double _calculateSGPA() {
    if (_subjects.isEmpty) return 0.0;
    
    double totalPoints = 0;
    int totalCredits = 0;

    for (var subject in _subjects) {
      final credits = subject['credits'] as int;
      final grade = subject['grade'] as String;
      final points = _gradePoints[grade] ?? 0;
      
      totalPoints += credits * points;
      totalCredits += credits;
    }

    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final sgpa = _calculateSGPA();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyanAccent.withOpacity(0.3), Colors.blueAccent.withOpacity(0.3)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.cyanAccent),
          ),
          child: Column(
            children: [
              Text(
                'Your SGPA',
                style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                sgpa.toStringAsFixed(2),
                style: GoogleFonts.orbitron(
                  color: Colors.cyanAccent,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _subjects.isEmpty
              ? Center(
                  child: Text(
                    'Add subjects to calculate SGPA',
                    style: GoogleFonts.montserrat(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    return Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Subject Name',
                                  hintStyle: TextStyle(color: Colors.grey.shade600),
                                  border: InputBorder.none,
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    subject['name'] = val;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<int>(
                              value: subject['credits'],
                              dropdownColor: Colors.grey.shade800,
                              underline: const SizedBox(),
                              items: [1, 2, 3, 4, 5]
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text('$c', style: const TextStyle(color: Colors.white)),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  subject['credits'] = val!;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: subject['grade'],
                              dropdownColor: Colors.grey.shade800,
                              underline: const SizedBox(),
                              items: _gradePoints.keys
                                  .map((g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g, style: const TextStyle(color: Colors.cyanAccent)),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  subject['grade'] = val!;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _subjects.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            onPressed: _addSubject,
            icon: const Icon(Icons.add),
            label: const Text('Add Subject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// Placeholder classes for other tabs - keeping them minimal
class _BMITab extends StatefulWidget {
  const _BMITab();
  @override
  State<_BMITab> createState() => _BMITabState();
}

class _BMITabState extends State<_BMITab> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double _bmi = 0.0;
  String _category = '';
  String _advice = '';

  void _calculateBMI() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    
    if (height != null && weight != null && height > 0) {
      final heightInMeters = height / 100; // Convert cm to meters
      setState(() {
        _bmi = weight / (heightInMeters * heightInMeters);
        _updateCategory();
      });
    }
  }

  void _updateCategory() {
    if (_bmi < 18.5) {
      _category = 'Underweight';
      _advice = 'Consider gaining weight through healthy diet';
    } else if (_bmi < 25) {
      _category = 'Normal';
      _advice = 'Maintain your current healthy lifestyle';
    } else if (_bmi < 30) {
      _category = 'Overweight';
      _advice = 'Consider losing weight through diet and exercise';
    } else {
      _category = 'Obese';
      _advice = 'Consult a healthcare professional';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'BMI Calculator',
            style: GoogleFonts.orbitron(
              color: Colors.cyanAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          
          // Height Input
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Height (cm)',
              labelStyle: const TextStyle(color: Colors.cyanAccent),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.cyanAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Weight Input
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Weight (kg)',
              labelStyle: const TextStyle(color: Colors.cyanAccent),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.cyanAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Calculate Button
          ElevatedButton(
            onPressed: _calculateBMI,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Calculate BMI',
              style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          
          // Results
          if (_bmi > 0) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Your BMI',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _bmi.toStringAsFixed(1),
                    style: GoogleFonts.orbitron(
                      color: Colors.cyanAccent,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _category,
                    style: GoogleFonts.orbitron(
                      color: _getCategoryColor(),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _advice,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (_category) {
      case 'Underweight':
        return Colors.blue;
      case 'Normal':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}

class _AgeCalculatorTab extends StatefulWidget {
  const _AgeCalculatorTab();
  @override
  State<_AgeCalculatorTab> createState() => _AgeCalculatorTabState();
}

class _AgeCalculatorTabState extends State<_AgeCalculatorTab> {
  DateTime? _selectedDate;
  String _ageResult = '';

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.cyanAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _calculateAge();
      });
    }
  }

  void _calculateAge() {
    if (_selectedDate == null) return;
    
    final now = DateTime.now();
    final difference = now.difference(_selectedDate!);
    
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();
    final days = (difference.inDays % 365) % 30;
    
    setState(() {
      _ageResult = '$years years, $months months, $days days';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Age Calculator',
            style: GoogleFonts.orbitron(
              color: Colors.cyanAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 50),
          
          // Date Selection
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Select Your Birth Date',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                
                ElevatedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _selectedDate == null 
                        ? 'Choose Date' 
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Results
          if (_ageResult.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.cyanAccent.withOpacity(0.1),
                    Colors.blue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.cyanAccent),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Age',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _ageResult,
                    style: GoogleFonts.orbitron(
                      color: Colors.cyanAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Total Days: ${DateTime.now().difference(_selectedDate!).inDays}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EquationSolverTab extends StatelessWidget {
  const _EquationSolverTab();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Equation Solver', style: TextStyle(color: Colors.white)));
  }
}

class _PercentageTab extends StatefulWidget {
  const _PercentageTab();
  @override
  State<_PercentageTab> createState() => _PercentageTabState();
}

class _PercentageTabState extends State<_PercentageTab> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _percentController = TextEditingController();
  String _result = '';

  void _calculatePercentage() {
    final value = double.tryParse(_valueController.text);
    final total = double.tryParse(_totalController.text);
    
    if (value != null && total != null && total != 0) {
      final percentage = (value / total) * 100;
      setState(() {
        _result = '${percentage.toStringAsFixed(2)}%';
      });
    }
  }

  void _calculateValue() {
    final percent = double.tryParse(_percentController.text);
    final total = double.tryParse(_totalController.text);
    
    if (percent != null && total != null) {
      final value = (percent / 100) * total;
      setState(() {
        _result = value.toStringAsFixed(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Percentage Calculator',
              style: GoogleFonts.orbitron(
                color: Colors.cyanAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            
            // Calculate Percentage
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Percentage',
                    style: GoogleFonts.orbitron(
                      color: Colors.cyanAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Value',
                      labelStyle: const TextStyle(color: Colors.cyanAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  TextField(
                    controller: _totalController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Total',
                      labelStyle: const TextStyle(color: Colors.cyanAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculatePercentage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Calculate Percentage',
                        style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Calculate Value from Percentage
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Value from Percentage',
                    style: GoogleFonts.orbitron(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: _percentController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Percentage (%)',
                      labelStyle: const TextStyle(color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculateValue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Calculate Value',
                        style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Result
            if (_result.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.1),
                      Colors.blue.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Text(
                      'Result',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _result,
                      style: GoogleFonts.orbitron(
                        color: Colors.green,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _totalController.dispose();
    _percentController.dispose();
    super.dispose();
  }
}

class _DiscountCalculatorTab extends StatelessWidget {
  const _DiscountCalculatorTab();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Discount Calculator', style: TextStyle(color: Colors.white)));
  }
}

class _TipCalculatorTab extends StatelessWidget {
  const _TipCalculatorTab();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tip Calculator', style: TextStyle(color: Colors.white)));
  }
}

class _LoanCalculatorTab extends StatelessWidget {
  const _LoanCalculatorTab();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Loan Calculator', style: TextStyle(color: Colors.white)));
  }
}