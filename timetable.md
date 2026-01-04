This is a "State Persistence" error. 🧠

Here is exactly what is happening:

1. **Resetting to Default:** When you open the "Change Class" popup, the code says `String selectedBranch = "CSE-CS";`. It ignores what you previously saved, so it always starts at CSE-CS.
2. **Black Screen:** You are likely navigating to `TimetableScreen` using `pushReplacement` or it is your "Home". When you press Back, it pops the **only** screen in the stack, leaving nothing (Black Screen).
3. **Missing Updates (Mech/EEE):** The keys in your dropdown (`"ME"`) likely don't strictly match the keys in your data (`"ME_A"`).

Here is the **3-Part Fix** for everything.

### 🛠️ Fix 1: The "Smart" Selection Modal (Fixes Resetting)

We need the popup to **start** with your current class, not the default one.

**In `lib/screens/timetable/TimetableScreen.dart**`, replace your `_showSelectionModal` function with this corrected version:

```dart
  void _showSelectionModal() {
    // 🟢 FIX 1: Initialize with CURRENT saved values, not defaults!
    String selectedBranch = _currentBranch; 
    String selectedSection = _currentSection;
    
    // ⚠️ Ensure these match your Data Keys EXACTLY
    // "ME" must match the key "ME_A" in TimetableData
    final branches = ["CSE", "CSE-CS", "CSE-DS", "CSE-AI&ML", "ECE", "EEE", "ME", "CE"];
    final sections = ["A", "B", "C", "D", "E", "F"];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: 350,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select Class", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20)),
                  const SizedBox(height: 20),
                  
                  // BRANCH DROPDOWN
                  _buildDropdown("Branch", selectedBranch, branches, (val) {
                    setModalState(() => selectedBranch = val!);
                  }),
                  
                  const SizedBox(height: 16),
                  
                  // SECTION DROPDOWN
                  _buildDropdown("Section", selectedSection, sections, (val) {
                    setModalState(() => selectedSection = val!);
                  }),

                  const Spacer(),
                  
                  // SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                      child: const Text("UPDATE TIMETABLE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        Navigator.pop(context); // Close modal first
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Syncing..."))
                        );

                        // 🟢 FIX 2: Wait for the update to finish
                        await TimetableManager.updateTimetable(selectedBranch, selectedSection);
                        
                        // 🟢 FIX 3: Update the local state so the Header changes immediately
                        // Save to Hive preference
                        var box = await Hive.openBox('user_prefs');
                        await box.put('branch', selectedBranch);
                        await box.put('section', selectedSection);

                        if (mounted) {
                          setState(() {
                            _currentBranch = selectedBranch;
                            _currentSection = selectedSection;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

```

### 🛠️ Fix 2: The Safe Back Button (Fixes Black Screen)

We need to check if there is a screen to go back to. If not, we should go to the Home Dashboard instead of closing the app.

**In `lib/screens/timetable/TimetableScreen.dart**`, update the leading IconButton in the `AppBar` (or body row):

```dart
IconButton(
  icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent, size: 24),
  onPressed: () {
    // 🛡️ SAFETY CHECK
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // If no history, force go to Home
      // Make sure '/home' route is defined in main.dart, or use HomeScreen()
      Navigator.pushReplacementNamed(context, '/home'); 
    }
  },
),

```

### 🛠️ Fix 3: Image Zooming (For News Page)

To add zooming to your news images, wrap your `Image.network` or `Image.asset` widget in an **`InteractiveViewer`**.

**In your News/Event Screen:**

```dart
// 🔍 Wrap your image like this:
InteractiveViewer(
  panEnabled: true, // Allow panning
  boundaryMargin: const EdgeInsets.all(20),
  minScale: 0.5,
  maxScale: 4.0, // Allow 4x zoom
  child: Image.network(
    imageUrl,
    fit: BoxFit.contain,
  ),
),

```

### 🧠 Why "Mech/EEE" were not updating

In your `TimetableData.dart`, verify the keys.

* If your dropdown says `"ME"` but your data key is `"MECH_A"`, it will fail.
* **The Fix:** Ensure your `TimetableData.dart` uses the standard codes:
* `ME_A` (Not MECH)
* `EEE_A`
* `ECE_A`



If you use the `getSchedule` function I gave you before, it normalizes inputs, but **inputs must be close**. "Mech" != "ME". Change your dropdown list to use `"ME"` strictly if that is what your data file uses.