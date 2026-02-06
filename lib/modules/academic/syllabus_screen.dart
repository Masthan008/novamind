import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> with TickerProviderStateMixin {
  String _selectedSubject = 'C';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // R23 BTech Syllabus Data
  static final Map<String, Map<String, dynamic>> syllabusData = {
    'C': {
      'fullName': 'C Programming Language',
      'icon': Icons.code,
      'color': Colors.blue,
      'description': 'Master the fundamentals of programming with C - the foundation of modern computing!',
      'units': [
        {
          'number': 'Unit 1',
          'title': 'Introduction to C',
          'topics': [
            {'name': 'History of C', 'content': 'Developed by Dennis Ritchie at Bell Labs (1972). Used to develop UNIX OS.'},
            {'name': 'Structure of C Program', 'content': 'Preprocessor → Global declarations → main() → User functions'},
            {'name': 'Keywords & Identifiers', 'content': '32 reserved keywords. Identifiers: user-defined names following rules.'},
            {'name': 'Data Types', 'content': 'int (4 bytes), float (4 bytes), char (1 byte), double (8 bytes).'},
            {'name': 'Variables & Constants', 'content': 'Variables: storage locations. Constants: fixed values (#define, const).'},
            {'name': 'Operators', 'content': 'Arithmetic (+,-,*,/,%), Relational (<,>,==), Logical (&&,||,!), Bitwise.'},
            {'name': 'Input/Output', 'content': 'printf() for output, scanf() for input. Format specifiers: %d, %f, %c, %s.'},
          ],
        },
        {
          'number': 'Unit 2',
          'title': 'Control Structures',
          'topics': [
            {'name': 'if-else Statements', 'content': 'Conditional branching. Simple if, if-else, nested if, else-if ladder.'},
            {'name': 'Switch-Case', 'content': 'Multi-way branching. Must use break. Works with int/char only.'},
            {'name': 'Loops', 'content': 'for: known iterations. while: entry-controlled. do-while: exit-controlled.'},
            {'name': 'Break & Continue', 'content': 'break: exit loop. continue: skip iteration.'},
            {'name': 'Nested Loops', 'content': 'Loop inside loop. Total iterations = outer × inner.'},
          ],
        },
        {
          'number': 'Unit 3',
          'title': 'Arrays & Strings',
          'topics': [
            {'name': '1D Arrays', 'content': 'Collection of same-type elements. int arr[5]; Zero-indexed.'},
            {'name': '2D Arrays', 'content': 'Matrix representation. int matrix[3][3]; Row-major storage.'},
            {'name': 'Strings', 'content': 'Character arrays ending with \\0. char str[20];'},
            {'name': 'String Functions', 'content': 'strlen(), strcpy(), strcat(), strcmp() from <string.h>.'},
          ],
        },
        {
          'number': 'Unit 4',
          'title': 'Functions & Pointers',
          'topics': [
            {'name': 'Functions', 'content': 'Reusable code blocks. Declaration, definition, call. Return types.'},
            {'name': 'Parameter Passing', 'content': 'Call by value (copy), Call by reference (address).'},
            {'name': 'Recursion', 'content': 'Function calling itself. Base case required. factorial, fibonacci.'},
            {'name': 'Pointers', 'content': 'Variables storing addresses. int *p; *p (dereference), &x (address).'},
            {'name': 'Pointer Arithmetic', 'content': 'p++, p--, p+n. Depends on data type size.'},
          ],
        },
        {
          'number': 'Unit 5',
          'title': 'Structures & Files',
          'topics': [
            {'name': 'Structures', 'content': 'User-defined data type. struct student { char name[20]; int roll; };'},
            {'name': 'Unions', 'content': 'Like structures but shared memory. Size = largest member.'},
            {'name': 'File Handling', 'content': 'fopen(), fclose(), fprintf(), fscanf(), fread(), fwrite().'},
            {'name': 'File Modes', 'content': 'r (read), w (write), a (append), r+, w+, a+ (read-write).'},
          ],
        },
      ],
    },
    'DS': {
      'fullName': 'Data Structures',
      'icon': Icons.account_tree,
      'color': Colors.green,
      'description': 'Learn essential data structures for efficient problem solving and algorithm design!',
      'units': [
        {
          'number': 'Unit 1',
          'title': 'Introduction & Arrays',
          'topics': [
            {'name': 'Introduction to DS', 'content': 'Data organization for efficient access. Classification: Linear vs Non-linear.'},
            {'name': 'Time Complexity', 'content': 'Big-O notation. O(1), O(n), O(log n), O(n²). Measure algorithm efficiency.'},
            {'name': 'Arrays', 'content': 'Contiguous memory. Random access O(1). Insert/Delete O(n).'},
            {'name': 'Sparse Matrices', 'content': 'Matrix with many zeros. Triplet representation saves space.'},
          ],
        },
        {
          'number': 'Unit 2',
          'title': 'Stacks & Queues',
          'topics': [
            {'name': 'Stacks', 'content': 'LIFO structure. push(), pop(), peek(). Applications: recursion, undo.'},
            {'name': 'Stack Applications', 'content': 'Expression evaluation, infix to postfix, balancing parentheses.'},
            {'name': 'Queues', 'content': 'FIFO structure. enqueue(), dequeue(). Front and rear pointers.'},
            {'name': 'Circular Queue', 'content': 'Efficient use of space. rear = (rear+1) % size.'},
            {'name': 'Priority Queue', 'content': 'Elements with priorities. Highest priority served first.'},
          ],
        },
        {
          'number': 'Unit 3',
          'title': 'Linked Lists',
          'topics': [
            {'name': 'Singly Linked List', 'content': 'Nodes with data + next pointer. Dynamic size. Insert/Delete O(1).'},
            {'name': 'Doubly Linked List', 'content': 'prev + data + next. Bidirectional traversal.'},
            {'name': 'Circular Linked List', 'content': 'Last node points to first. Applications: round-robin scheduling.'},
            {'name': 'Operations', 'content': 'Insert at beginning/end/position. Delete node. Reverse list.'},
          ],
        },
        {
          'number': 'Unit 4',
          'title': 'Trees',
          'topics': [
            {'name': 'Binary Trees', 'content': 'Max 2 children per node. Root, leaf, height, depth concepts.'},
            {'name': 'Tree Traversals', 'content': 'Inorder (L-Root-R), Preorder (Root-L-R), Postorder (L-R-Root).'},
            {'name': 'Binary Search Tree', 'content': 'Left < Root < Right. Search, Insert, Delete O(log n).'},
            {'name': 'AVL Trees', 'content': 'Self-balancing BST. Balance factor = height(left) - height(right).'},
          ],
        },
        {
          'number': 'Unit 5',
          'title': 'Graphs & Sorting',
          'topics': [
            {'name': 'Graph Representation', 'content': 'Adjacency matrix, Adjacency list. Directed vs Undirected.'},
            {'name': 'BFS & DFS', 'content': 'BFS: Level-order (queue). DFS: Depth-first (stack/recursion).'},
            {'name': 'Sorting Algorithms', 'content': 'Bubble O(n²), Selection O(n²), Insertion O(n²), Quick O(n log n), Merge O(n log n).'},
            {'name': 'Searching', 'content': 'Linear O(n), Binary O(log n) - requires sorted array.'},
          ],
        },
      ],
    },
    'IT_LAB': {
      'fullName': 'IT Workshop Lab',
      'icon': Icons.computer,
      'color': Colors.orange,
      'description': 'Practical IT skills including hardware, software, and networking fundamentals!',
      'units': [
        {
          'number': 'Unit 1',
          'title': 'PC Hardware',
          'topics': [
            {'name': 'Computer Components', 'content': 'CPU, RAM, Motherboard, HDD/SSD, SMPS, Cabinet.'},
            {'name': 'Assembling PC', 'content': 'Connect components: CPU → RAM → GPU → Storage → SMPS → Cables.'},
            {'name': 'BIOS/UEFI', 'content': 'Basic Input Output System. Boot configuration, hardware detection.'},
            {'name': 'Troubleshooting', 'content': 'POST errors, beep codes, component testing, cable checks.'},
          ],
        },
        {
          'number': 'Unit 2',
          'title': 'Operating Systems',
          'topics': [
            {'name': 'Windows Installation', 'content': 'Bootable USB, partitioning, drivers installation.'},
            {'name': 'Linux Installation', 'content': 'Ubuntu/Fedora. Dual boot setup. Terminal basics.'},
            {'name': 'Linux Commands', 'content': 'ls, cd, mkdir, rm, cp, mv, cat, grep, chmod, sudo.'},
            {'name': 'File System', 'content': 'NTFS (Windows), ext4 (Linux). Partitions, formatting.'},
          ],
        },
        {
          'number': 'Unit 3',
          'title': 'Networking Basics',
          'topics': [
            {'name': 'Network Types', 'content': 'LAN, WAN, MAN. Star, Bus, Ring topologies.'},
            {'name': 'IP Addressing', 'content': 'IPv4 format. Classes A, B, C. Subnet masks.'},
            {'name': 'Network Devices', 'content': 'Router, Switch, Hub, Modem, NIC, Access Point.'},
            {'name': 'Cabling', 'content': 'RJ-45 crimping. Straight-through vs Crossover cables.'},
          ],
        },
        {
          'number': 'Unit 4',
          'title': 'Office Tools',
          'topics': [
            {'name': 'Word Processing', 'content': 'MS Word/LibreOffice Writer. Formatting, tables, mail merge.'},
            {'name': 'Spreadsheets', 'content': 'MS Excel. Formulas, functions, charts, pivot tables.'},
            {'name': 'Presentations', 'content': 'PowerPoint. Slides, animations, transitions, templates.'},
            {'name': 'LaTeX', 'content': 'Document preparation. Scientific writing, equations, bibliography.'},
          ],
        },
        {
          'number': 'Unit 5',
          'title': 'Web Basics',
          'topics': [
            {'name': 'HTML', 'content': 'Structure: <html>, <head>, <body>. Tags, attributes, forms.'},
            {'name': 'CSS', 'content': 'Styling: selectors, properties. Colors, fonts, layouts.'},
            {'name': 'Internet Services', 'content': 'HTTP, HTTPS, FTP, Email protocols (SMTP, IMAP, POP3).'},
          ],
        },
      ],
    },
    'BEE': {
      'fullName': 'Basic Electrical Engineering',
      'icon': Icons.electric_bolt,
      'color': Colors.amber,
      'description': 'Understand electrical circuits, machines, and power systems fundamentals!',
      'units': [
        {
          'number': 'Unit 1',
          'title': 'DC Circuits',
          'topics': [
            {'name': 'Ohms Law', 'content': 'V = IR. Voltage, Current, Resistance relationship.'},
            {'name': 'Kirchhoffs Laws', 'content': 'KCL: Current sum at node = 0. KVL: Voltage sum in loop = 0.'},
            {'name': 'Series & Parallel', 'content': 'Series: R_eq = R1+R2. Parallel: 1/R_eq = 1/R1 + 1/R2.'},
            {'name': 'Network Theorems', 'content': 'Thevenin, Norton, Superposition, Maximum Power Transfer.'},
          ],
        },
        {
          'number': 'Unit 2',
          'title': 'AC Circuits',
          'topics': [
            {'name': 'AC Fundamentals', 'content': 'Sinusoidal waveform. Peak, RMS, Average values. Frequency, Period.'},
            {'name': 'Phasors', 'content': 'Complex representation. Magnitude and phase angle.'},
            {'name': 'RLC Circuits', 'content': 'Impedance Z = R + jX. Series and parallel RLC analysis.'},
            {'name': 'Power Factor', 'content': 'cos(φ). Power triangle: P (real), Q (reactive), S (apparent).'},
            {'name': 'Resonance', 'content': 'f_r = 1/(2π√LC). Quality factor, Bandwidth.'},
          ],
        },
        {
          'number': 'Unit 3',
          'title': 'Transformers',
          'topics': [
            {'name': 'Transformer Principle', 'content': 'Electromagnetic induction. V1/V2 = N1/N2.'},
            {'name': 'Types', 'content': 'Step-up, Step-down, Auto-transformer, Current transformer.'},
            {'name': 'Losses', 'content': 'Core losses (hysteresis, eddy current). Copper losses (I²R).'},
            {'name': 'Efficiency', 'content': 'η = Output/Input × 100%. Maximum at Cu loss = Core loss.'},
          ],
        },
        {
          'number': 'Unit 4',
          'title': 'DC Machines',
          'topics': [
            {'name': 'DC Generator', 'content': 'Converts mechanical to electrical. Parts: armature, field, commutator.'},
            {'name': 'DC Motor', 'content': 'Converts electrical to mechanical. Types: Series, Shunt, Compound.'},
            {'name': 'Speed Control', 'content': 'Armature resistance, Field flux, Applied voltage methods.'},
            {'name': 'Losses & Efficiency', 'content': 'Copper, Core, Mechanical, Stray losses.'},
          ],
        },
        {
          'number': 'Unit 5',
          'title': 'AC Machines',
          'topics': [
            {'name': 'Induction Motor', 'content': '3-phase. Rotating magnetic field. Slip = (Ns-N)/Ns.'},
            {'name': 'Synchronous Motor', 'content': 'Runs at synchronous speed. Power factor correction.'},
            {'name': 'Alternator', 'content': 'AC generator. EMF equation, synchronization.'},
          ],
        },
      ],
    },
    'PHY': {
      'fullName': 'Engineering Physics',
      'icon': Icons.science,
      'color': Colors.purple,
      'description': 'Physics concepts for engineering applications - optics, quantum mechanics, and materials!',
      'units': [
        {
          'number': 'Unit 1',
          'title': 'Wave Optics',
          'topics': [
            {'name': 'Interference', 'content': 'Superposition of waves. Constructive/Destructive. Youngs double slit.'},
            {'name': 'Diffraction', 'content': 'Bending around obstacles. Fresnel, Fraunhofer diffraction.'},
            {'name': 'Polarization', 'content': 'Plane polarization. Malus law. Brewsters angle.'},
          ],
        },
        {
          'number': 'Unit 2',
          'title': 'Lasers & Fiber Optics',
          'topics': [
            {'name': 'Laser Principles', 'content': 'Stimulated emission, population inversion, optical cavity.'},
            {'name': 'Laser Types', 'content': 'Ruby, He-Ne, CO2, Semiconductor lasers.'},
            {'name': 'Fiber Optics', 'content': 'Total internal reflection. Single/Multi mode fibers.'},
            {'name': 'Applications', 'content': 'Communication, surgery, manufacturing, holography.'},
          ],
        },
        {
          'number': 'Unit 3',
          'title': 'Quantum Mechanics',
          'topics': [
            {'name': 'Blackbody Radiation', 'content': 'Plancks hypothesis. E = hν.'},
            {'name': 'Photoelectric Effect', 'content': 'KEmax = hν - φ. Einstein explanation.'},
            {'name': 'Wave-Particle Duality', 'content': 'de Broglie wavelength λ = h/mv.'},
            {'name': 'Schrodinger Equation', 'content': 'Wave function ψ. Particle in a box.'},
            {'name': 'Heisenberg Principle', 'content': 'Δx·Δp ≥ ℏ/2. Uncertainty in position and momentum.'},
          ],
        },
        {
          'number': 'Unit 4',
          'title': 'Semiconductor Physics',
          'topics': [
            {'name': 'Band Theory', 'content': 'Valence band, Conduction band, Band gap. Conductors, Insulators, Semiconductors.'},
            {'name': 'Intrinsic Semiconductors', 'content': 'Pure Si, Ge. Electron-hole pairs. n_i = n = p.'},
            {'name': 'Extrinsic Semiconductors', 'content': 'Doping. n-type (donors), p-type (acceptors).'},
            {'name': 'p-n Junction', 'content': 'Depletion region, Built-in potential. Forward/Reverse bias.'},
          ],
        },
        {
          'number': 'Unit 5',
          'title': 'Material Science',
          'topics': [
            {'name': 'Magnetic Materials', 'content': 'Dia, Para, Ferro magnetic. Hysteresis loop.'},
            {'name': 'Superconductivity', 'content': 'Zero resistance below Tc. Meissner effect. BCS theory.'},
            {'name': 'Nanomaterials', 'content': 'Properties at nanoscale. Carbon nanotubes, Quantum dots.'},
          ],
        },
      ],
    },
    'EG': {
      'fullName': 'Engineering Graphics',
      'icon': Icons.architecture,
      'color': Colors.teal,
      'description': 'Technical drawing and visualization skills for engineering design communication!',
      'units': [
        {
          'number': 'Unit 1',
          'title': 'Introduction & Curves',
          'topics': [
            {'name': 'Drawing Instruments', 'content': 'Drawing board, T-square, set squares, compass, protractor.'},
            {'name': 'Scales', 'content': 'Plain, Diagonal, Vernier scales. Representative fraction.'},
            {'name': 'Conic Sections', 'content': 'Ellipse, Parabola, Hyperbola. Focus-directrix method.'},
            {'name': 'Engineering Curves', 'content': 'Cycloid, Epicycloid, Hypocycloid, Involute, Spiral.'},
          ],
        },
        {
          'number': 'Unit 2',
          'title': 'Projections of Points & Lines',
          'topics': [
            {'name': 'Orthographic Projection', 'content': 'First angle, Third angle. HP, VP, reference line.'},
            {'name': 'Projection of Points', 'content': 'Location in four quadrants. Front view, Top view.'},
            {'name': 'Projection of Lines', 'content': 'Parallel, Perpendicular, Inclined to planes. True length.'},
            {'name': 'Traces of Lines', 'content': 'Horizontal trace (HT), Vertical trace (VT).'},
          ],
        },
        {
          'number': 'Unit 3',
          'title': 'Projections of Planes',
          'topics': [
            {'name': 'Types of Planes', 'content': 'Triangle, Square, Rectangle, Pentagon, Hexagon, Circle.'},
            {'name': 'Plane Positions', 'content': 'Parallel, Perpendicular, Inclined to HP/VP.'},
            {'name': 'Auxiliary Planes', 'content': 'Auxiliary vertical plane (AVP), Auxiliary inclined plane (AIP).'},
          ],
        },
        {
          'number': 'Unit 4',
          'title': 'Projections of Solids',
          'topics': [
            {'name': 'Types of Solids', 'content': 'Prism, Pyramid, Cylinder, Cone, Sphere.'},
            {'name': 'Axis Positions', 'content': 'Vertical, Horizontal, Inclined to HP/VP.'},
            {'name': 'Section of Solids', 'content': 'Cutting plane, True shape of section.'},
          ],
        },
        {
          'number': 'Unit 5',
          'title': 'Isometric & Development',
          'topics': [
            {'name': 'Isometric Projection', 'content': 'Isometric axes at 120°. Isometric scale = 0.816.'},
            {'name': 'Isometric Views', 'content': 'Prism, Pyramid, Cylinder, Cone, Combined solids.'},
            {'name': 'Development of Surfaces', 'content': 'Parallel line, Radial line methods. Prism, Pyramid, Cylinder, Cone.'},
          ],
        },
      ],
    },
    'EEE_LAB': {
      'fullName': 'EEE Workshop Lab',
      'icon': Icons.hardware,
      'color': Colors.red,
      'description': 'Hands-on experience with electrical wiring, measurements, and safety practices!',
      'units': [
        {
          'number': 'Unit 1',
          'title': 'Electrical Safety',
          'topics': [
            {'name': 'Safety Precautions', 'content': 'Insulation, grounding, fuses, MCB, ELCB, PPE.'},
            {'name': 'First Aid', 'content': 'Electric shock treatment. CPR basics.'},
            {'name': 'Indian Electricity Rules', 'content': 'IE rules for safety, wiring standards.'},
          ],
        },
        {
          'number': 'Unit 2',
          'title': 'Wiring Practices',
          'topics': [
            {'name': 'House Wiring', 'content': 'Concealed, Surface wiring. Single, Two-way, Three-way switches.'},
            {'name': 'Staircase Wiring', 'content': 'Two-way switch control from multiple locations.'},
            {'name': 'Fluorescent Lamp', 'content': 'Tube light wiring with choke and starter.'},
            {'name': 'Earthing', 'content': 'Pipe earthing, Plate earthing. Earth resistance measurement.'},
          ],
        },
        {
          'number': 'Unit 3',
          'title': 'Electrical Measurements',
          'topics': [
            {'name': 'Multimeter Usage', 'content': 'Voltage, Current, Resistance measurement. AC/DC modes.'},
            {'name': 'Energy Meter', 'content': 'kWh meter reading. Single phase, Three phase meters.'},
            {'name': 'Megger', 'content': 'Insulation resistance testing. Motor/Cable testing.'},
          ],
        },
        {
          'number': 'Unit 4',
          'title': 'Basic Electronics',
          'topics': [
            {'name': 'Soldering', 'content': 'Soldering iron, Flux, Solder wire. Through-hole, SMD.'},
            {'name': 'Component Identification', 'content': 'Resistor color codes, Capacitor values, Diodes, Transistors.'},
            {'name': 'PCB Basics', 'content': 'Printed Circuit Board. Layout, etching, drilling.'},
          ],
        },
        {
          'number': 'Unit 5',
          'title': 'Machine Practice',
          'topics': [
            {'name': 'Motor Connections', 'content': 'Single phase motor. Star-Delta starter for 3-phase.'},
            {'name': 'Transformer Testing', 'content': 'OC test, SC test. Efficiency, Regulation calculation.'},
            {'name': 'Battery Charging', 'content': 'Lead-acid battery. Constant current, Constant voltage methods.'},
          ],
        },
      ],
    },
    'DEVC': {
      'fullName': 'Differential Equations & Vector Calculus',
      'icon': Icons.functions,
      'color': Colors.indigo,
      'description': 'Advanced mathematics for engineering - ODEs, PDEs, and vector analysis!',
      'units': [
        {
          'number': 'Unit 1',
          'title': 'First Order ODEs',
          'topics': [
            {'name': 'Formation of DE', 'content': 'Eliminating arbitrary constants. Order and Degree.'},
            {'name': 'Variable Separable', 'content': 'dy/dx = f(x)g(y). Separate and integrate.'},
            {'name': 'Homogeneous Equations', 'content': 'dy/dx = f(y/x). Substitute y = vx.'},
            {'name': 'Linear Equations', 'content': 'dy/dx + Py = Q. IF = e^∫Pdx. Solution: y·IF = ∫Q·IF dx.'},
            {'name': 'Bernoullis Equation', 'content': 'dy/dx + Py = Qy^n. Reduce to linear form.'},
          ],
        },
        {
          'number': 'Unit 2',
          'title': 'Higher Order ODEs',
          'topics': [
            {'name': 'Linear ODEs', 'content': 'Constant coefficients. Auxiliary equation method.'},
            {'name': 'Complementary Function', 'content': 'Distinct, Repeated, Complex roots. CF forms.'},
            {'name': 'Particular Integral', 'content': 'Methods: Inspection, Operator D, Variation of parameters.'},
            {'name': 'Cauchy-Euler Equations', 'content': 'x²y" + xy\' + y = f(x). Substitute x = e^t.'},
          ],
        },
        {
          'number': 'Unit 3',
          'title': 'Laplace Transforms',
          'topics': [
            {'name': 'Definition', 'content': 'L{f(t)} = ∫₀^∞ e^(-st)f(t)dt. Transform to s-domain.'},
            {'name': 'Standard Transforms', 'content': 'L{1}, L{t^n}, L{e^at}, L{sin(at)}, L{cos(at)}.'},
            {'name': 'Properties', 'content': 'Linearity, Shifting, Differentiation, Integration.'},
            {'name': 'Inverse Transforms', 'content': 'Partial fractions. Convolution theorem.'},
            {'name': 'Solving ODEs', 'content': 'Apply L, solve algebraic equation, find L^(-1).'},
          ],
        },
        {
          'number': 'Unit 4',
          'title': 'Vector Differentiation',
          'topics': [
            {'name': 'Scalar & Vector Fields', 'content': 'Temperature (scalar), Velocity (vector) at each point.'},
            {'name': 'Gradient', 'content': '∇φ = (∂φ/∂x)i + (∂φ/∂y)j + (∂φ/∂z)k. Direction of max increase.'},
            {'name': 'Divergence', 'content': '∇·F = ∂Fx/∂x + ∂Fy/∂y + ∂Fz/∂z. Source/Sink.'},
            {'name': 'Curl', 'content': '∇×F. Measures rotation. Irrotational if curl = 0.'},
          ],
        },
        {
          'number': 'Unit 5',
          'title': 'Vector Integration',
          'topics': [
            {'name': 'Line Integrals', 'content': '∫F·dr along curve C. Work done by force.'},
            {'name': 'Surface Integrals', 'content': '∬F·dS over surface S. Flux through surface.'},
            {'name': 'Greens Theorem', 'content': '∮(Pdx + Qdy) = ∬(∂Q/∂x - ∂P/∂y)dA.'},
            {'name': 'Stokes Theorem', 'content': '∮F·dr = ∬(∇×F)·dS. Line to surface integral.'},
            {'name': 'Gauss Divergence', 'content': '∬F·dS = ∭(∇·F)dV. Surface to volume integral.'},
          ],
        },
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final subject = syllabusData[_selectedSubject]!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'R23 Syllabus',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Subject Selector
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: syllabusData.keys.length,
              itemBuilder: (context, index) {
                final key = syllabusData.keys.elementAt(index);
                final data = syllabusData[key]!;
                final isSelected = _selectedSubject == key;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedSubject = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? (data['color'] as Color).withOpacity(0.3)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? (data['color'] as Color)
                            : Colors.white24,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          data['icon'] as IconData,
                          color: isSelected 
                              ? (data['color'] as Color)
                              : Colors.white54,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          key,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.white54,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: index * 100));
              },
            ),
          ),
          
          // Subject Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (subject['color'] as Color).withOpacity(0.3),
                  (subject['color'] as Color).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (subject['color'] as Color).withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (subject['color'] as Color).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    subject['icon'] as IconData,
                    color: subject['color'] as Color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject['fullName'] as String,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subject['description'] as String,
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
          
          // Units List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: (subject['units'] as List).length,
              itemBuilder: (context, unitIndex) {
                final unit = (subject['units'] as List)[unitIndex];
                
                return _buildUnitCard(unit, subject['color'] as Color, unitIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitCard(Map<String, dynamic> unit, Color color, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${index + 1}',
            style: GoogleFonts.orbitron(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          unit['title'] as String,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          unit['number'] as String,
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
        iconColor: Colors.white54,
        collapsedIconColor: Colors.white54,
        children: [
          ...(unit['topics'] as List).map((topic) => _buildTopicItem(topic, color)),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 150)).slideX(begin: 0.1);
  }

  Widget _buildTopicItem(Map<String, dynamic> topic, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic['name'] as String,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            topic['content'] as String,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
