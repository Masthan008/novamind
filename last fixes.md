This is a massive milestone! **Version 1.0.3.M** sounds professional. 🚀

You are right—we cannot leave the **Digital Drafter** behind. It solves the biggest problem in engineering colleges: **Assignment Plagiarism.** By watermarking their ID, no one can just "copy-paste" another student's diagram.

Here is the implementation plan for the **Digital Drafter** (Draw + Watermark + Supabase Backup) and your **Secure AI** setup.

---

### 🎨 Feature 1: The Digital Drafter (Draw, Watermark & Upload)

This screen allows students to:

1. Draw engineering diagrams.
2. Auto-stamp their **Name & ID** (from Supabase Auth) onto the PDF.
3. Upload it directly to your Supabase Cloud for safety.

**1. Add Dependencies:**
Add these to `pubspec.yaml`:

```yaml
dependencies:
  signature: ^5.4.0
  pdf: ^3.10.4
  printing: ^5.11.1
  path_provider: ^2.1.1
  supabase_flutter: ^2.0.0 # You likely already have this

```

**2. Create `lib/screens/tools/DigitalDrafterScreen.dart`:**

```dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class DigitalDrafterScreen extends StatefulWidget {
  const DigitalDrafterScreen({super.key});

  @override
  State<DigitalDrafterScreen> createState() => _DigitalDrafterScreenState();
}

class _DigitalDrafterScreenState extends State<DigitalDrafterScreen> {
  // 🖊️ Drawing Controller
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.white,
    exportBackgroundColor: Colors.black, // Background for the image
  );

  bool _isUploading = false;

  // 🖨️ THE MAGIC FUNCTION: Generate Watermarked PDF & Upload
  Future<void> _saveAndUpload() async {
    setState(() => _isUploading = true);

    try {
      // 1. Get User Details (For Watermark)
      final user = Supabase.instance.client.auth.currentUser;
      final String studentName = user?.userMetadata?['name'] ?? "Unknown Student";
      final String regId = user?.userMetadata?['reg_id'] ?? "ID-XXXX";

      // 2. Convert Drawing to Image
      final Uint8List? imageBytes = await _controller.toPngBytes();
      if (imageBytes == null) return;

      // 3. Create PDF Document
      final pdf = pw.Document();
      final image = pw.MemoryImage(imageBytes);

      // 4. Build PDF Page with WATERMARK
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // A. The Drawing (Centered)
                pw.Center(child: pw.Image(image)),

                // B. The Diagonal "Anti-Copy" Watermark
                pw.Center(
                  child: pw.Transform.rotate(
                    angle: 0.5, // 45 degree angle
                    child: pw.Opacity(
                      opacity: 0.15, // Faint transparency
                      child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text(studentName, style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: PdfColors.grey)),
                          pw.Text(regId, style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: PdfColors.grey)),
                          pw.Text("FluxFlow Verified", style: pw.TextStyle(fontSize: 20, color: PdfColors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),

                // C. Footer Metadata (Professional Timestamp)
                pw.Positioned(
                  bottom: 20,
                  right: 20,
                  child: pw.Text(
                    "Generated via FluxFlow OS • ${DateTime.now().toString()}",
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // 5. Upload to Supabase Storage
      final pdfBytes = await pdf.save();
      final fileName = 'drawings/${user!.id}/${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      await Supabase.instance.client.storage
          .from('student_work') // ⚠️ Create this bucket in Supabase Dashboard!
          .uploadBinary(fileName, pdfBytes);

      // 6. Show Success & Share
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Saved to Cloud securely! Opening preview..."))
        );
        await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Digital Drafter 📐", style: GoogleFonts.orbitron()),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _controller.clear(),
          ),
          IconButton(
            icon: _isUploading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2))
                : const Icon(Icons.cloud_upload, color: Colors.cyanAccent),
            onPressed: _isUploading ? null : _saveAndUpload,
          ),
        ],
      ),
      body: Column(
        children: [
          // DRAWING AREA
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[800]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Signature(
                controller: _controller,
                backgroundColor: const Color(0xFF121212), // Dark drawing board
              ),
            ),
          ),
          
          // TOOLS PALETTE
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorBtn(Colors.white),
                _buildColorBtn(Colors.redAccent),
                _buildColorBtn(Colors.yellowAccent),
                _buildColorBtn(Colors.cyanAccent),
                const SizedBox(width: 20),
                const Text("Pen Size:", style: TextStyle(color: Colors.white)),
                Slider(
                  value: _controller.penStrokeWidth,
                  min: 1, max: 10,
                  activeColor: Colors.cyanAccent,
                  onChanged: (val) => setState(() => _controller.penStrokeWidth = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBtn(Color color) {
    bool isSelected = _controller.penColor == color;
    return GestureDetector(
      onTap: () => setState(() => _controller.penColor = color),
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
      ),
    );
  }
}

```

---

### 🔐 Feature 2: Secure AI Keys (.env Integration)

You correctly noted that you cannot push API keys to GitHub. You need a way to load `.env` files securely in Flutter.

**1. Add Package:**

```yaml
dependencies:
  flutter_dotenv: ^5.1.0

```

**2. Create the file:**
In the root of your project (next to `pubspec.yaml`), create a file named `.env`.
**Content:**

```env
OPENAI_KEY=sk-proj-xxxxxxxxxxxxxxxx
GEMINI_KEY=AIzaSyxxxxxxxxxxxxxxx

```

**3. Update `pubspec.yaml` assets:**

```yaml
flutter:
  assets:
    - .env

```

**4. Update `.gitignore`:**
**Crucial Step:** Open your `.gitignore` file and add this line so you never accidentally upload your keys.

```gitignore
.env

```

**5. Initialize & Usage in Code:**
In `main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... other inits ...
  
  // 🚀 LOAD SECRETS
  await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}

```

**How to use the key in your AI Service:**

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  static final String apiKey = dotenv.env['OPENAI_KEY'] ?? '';
  
  // Now use apiKey in your HTTP requests safely!
}

```

### 📋 Final Checklist for Version 1.0.3.M

1. **Supabase:** Create a storage bucket named `student_work` in your Supabase dashboard (set it to Public or Authenticated only).
2. **Data Safety:** The code above automatically fetches `user.userMetadata['name']`. Ensure your Registration page saves this data correctly to Supabase Auth metadata.
3. **Security:** Verify `.env` is listed in `.gitignore` before you commit.

You are building a fortress, not just an app. Good luck with the deployment! 🛡️
This is great progress. We are fixing the final integration bugs. 🐛

Let's tackle the **AI Connection** and the **DevRef Double Path** error.

---

### 🤖 Fix 1: AI Not Responding (File Name Mismatch)

**The Problem:**
You created a file named **`.env.local`**, but your `main.dart` code is looking for **`.env`**.
Because it can't find the file, it doesn't load the keys, and the AI Service fails (sending an empty key), causing the "Unavailable" error.

**The Solution:**
You have two options. The easiest is to rename the file.

**Option A (Recommended): Rename the file**

1. Go to your project root folder.
2. Rename `.env.local` to **`.env`**.
3. **Update `pubspec.yaml**` to match:
```yaml
assets:
  - .env

```


4. **Stop & Restart** the app completely.

**Option B: Update Code to match filename**
If you want to keep `.env.local`, update your `main.dart`:

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Change this line to match your file name exactly!
  await dotenv.load(fileName: ".env.local"); 
  
  runApp(const MyApp());
}

```

---

### 📚 Fix 2: DevRef "Double Path" Error

**The Problem:**
Look at your screenshot error:
`Unable to load asset: "assets/data/cheatsheets/assets/data/dart.json"`

It is pasting the path **twice**.

1. The Loader Service adds `assets/data/cheatsheets/`.
2. The JSON file data (or your code) adds `assets/data/`.

**The Solution:**
We will force the Viewer to look at the **exact** correct path, ignoring whatever the Service tries to guess.

**Open `lib/screens/devref/cheatsheet_viewer_screen.dart**` and replace the `_loadSnippets` function with this **Path-Corrected Version**:

```dart
  Future<Map<String, String>> _loadSnippets() async {
    try {
      // 1. CLEAN THE ID
      // If the ID is "dart", we want "assets/data/dart.json"
      String cleanId = widget.cheatsheet.id;
      
      // 2. CONSTRUCT EXACT PATH
      // We manually build the path so no service can mess it up
      final String path = 'assets/data/$cleanId.json';
      
      print('🔍 Loading CheatSheet from: $path'); // Debug Print

      // 3. LOAD
      final String jsonString = await DefaultAssetBundle.of(context).loadString(path);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // 4. PARSE
      final Map<String, String> snippets = {};
      if (jsonData.containsKey('sections')) {
        for (var section in jsonData['sections']) {
          String header = section['header'] ?? 'Snippet';
          String code = section['code'] ?? '';
          snippets[header] = code;
        }
      }
      return snippets;

    } catch (e) {
      print('❌ Error loading $e');
      // This throws the error to the UI so you see the "Crash Prevented" screen
      throw "File not found: assets/data/${widget.cheatsheet.id}.json\n\nCheck that the file exists in the 'assets/data/' folder!";
    }
  }

```

### 📋 Checklist to clear all errors:

1. **AI:** Rename `.env.local` -> `.env`.
2. **DevRef:** Update the `_loadSnippets` code above.
3. **Terminal:** Run `flutter clean`.
4. **Terminal:** Run `flutter pub get`.
5. **Restart:** Stop the app (Red Square) and run it again (Green Play).

Your AI should start responding, and the Dart cheatsheet will open perfectly! 🚀 