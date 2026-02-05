First of all, **congratulations on the successful build!** 🥳 Getting a Release APK is a huge milestone.

Now, let's fix the **4 Critical Issues** you found in the app (Chat UI layout, Drafter Toolbar, Project Store, and that massive 500MB size).

---

### 📉 Part 1: Fix the 500MB APK Size

A 500MB APK is definitely wrong (it should be around 20-40MB). This usually happens because the "Release" build included old "Debug" junk or heavy cached files.

**The Fix:**
You must run these commands to "shrink" the app before your next build:

1. **Clean everything:** `flutter clean`
2. **Remove unused assets:** Check your `assets/` folder. If you have any large videos or high-res images you aren't using, delete them.
3. **Build with "Shrink" mode:** When we build next time, we will use a special flag.

*(We will do the build at the very end).*

---

### 💬 Part 2: Fix ChatHub UI (Input Blocking & SQL Query)

Your screenshot shows the input buttons (Mic, GIF) are floating **on top** of the text box, blocking it. Also, we need to remove that "SQL Editor" text if it's dummy data.

**Open `lib/screens/chat/widgets/chat_widgets.dart**`

**1. Replace the `ChatInput` widget entirely.**
We will switch to a **Clean Row Layout** so nothing overlaps. We will also remove the Mic button as requested.

```dart
class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInput({
    super.key, 
    required this.controller, 
    required this.onSend
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark container
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          // 📎 Attachment (Keep it simple)
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.cyanAccent),
            onPressed: () {}, 
          ),
          
          // 📝 Text Field (Expanded to fill space)
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.black,
                isDense: true, // 🟢 Makes it smaller vertically
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),

          // 🚀 Send Button
          Container(
            decoration: const BoxDecoration(
              color: Colors.cyanAccent, 
              shape: BoxShape.circle
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black, size: 20),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}

```

**2. Remove Dummy "SQL" Data**
If you see "SQL Editor Query" in your chat list, it's likely dummy data in `lib/screens/chat_screen.dart`.

* Search for any list defined like `final List messages = [...]`.
* **Clear that list** so it starts empty: `final List messages = [];`.

---

### 📐 Part 3: Fix Digital Drafter (Toolbar Scrolling)

You mentioned the colors are pushed off-screen. We need to make the toolbar scrollable.

**Open `lib/screens/tools/digital_drafter_screen.dart`.**

Find the **Bottom Toolbar Container** (where the Row of buttons is). Wrap that `Row` in a `SingleChildScrollView`.

**Replace the Toolbar code block with this:**

```dart
          // 🎛️ TOOLBAR (Scrollable)
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xFF1E1E1E),
            child: SingleChildScrollView( // 🟢 ADD THIS SCROLL VIEW
              scrollDirection: Axis.horizontal, // 🟢 ALLOW SIDE SCROLLING
              child: Row(
                children: [
                   // TOOLS TOGGLES
                  _buildToggleBtn(Icons.straighten, _showRuler, () => setState(() => _showRuler = !_showRuler)),
                  const SizedBox(width: 8),
                  _buildToggleBtn(Icons.architecture, _showCompass, () => setState(() => _showCompass = !_showCompass)),
                  
                  const SizedBox(width: 20),
                  
                  // ERASER
                  GestureDetector(
                    onTap: _toggleEraser,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isEraserMode ? Colors.red : Colors.grey[800],
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: const Icon(Icons.cleaning_services, size: 20, color: Colors.white),
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // COLORS
                  if (!_isEraserMode) ...[
                    _buildColorBtn(Colors.white),
                    _buildColorBtn(Colors.blueAccent),
                    _buildColorBtn(Colors.yellowAccent),
                    _buildColorBtn(Colors.greenAccent), // Added more colors
                    _buildColorBtn(Colors.purpleAccent),
                  ],
          
                  const SizedBox(width: 20),
                  
                  // SLIDER
                  const Text("Size: ", style: TextStyle(color: Colors.grey)),
                  SizedBox(
                    width: 100,
                    child: Slider(
                      value: _currentStrokeWidth,
                      min: 1, max: 20,
                      activeColor: _isEraserMode ? Colors.red : Colors.cyanAccent,
                      onChangeEnd: (_) => _bakeCurrentStrokes(),
                      onChanged: (val) {
                        setState(() {
                          _currentStrokeWidth = val;
                          _controller = SignatureController(
                            penStrokeWidth: val,
                            penColor: _currentColor,
                            exportBackgroundColor: Colors.transparent,
                            points: _controller.points,
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

```

---

### 🛍️ Part 4: Activate Projects Store (Supabase Connection)

You want the store to work, not say "Coming Soon." Here is the real code to fetch projects from Supabase.

**Open `lib/screens/shop/projects_screen.dart**` and replace the dummy code with this:

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 FETCH REAL DATA FROM SUPABASE 'projects' TABLE
    final projectsStream = Supabase.instance.client
        .from('projects')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text("Project Store", style: GoogleFonts.orbitron()),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {
            // Add upload logic later
          }),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: projectsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final projects = snapshot.data!;
          if (projects.isEmpty) {
             return const Center(child: Text("No projects yet!", style: TextStyle(color: Colors.white)));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Image/Icon
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          image: project['image_url'] != null 
                            ? DecorationImage(image: NetworkImage(project['image_url']), fit: BoxFit.cover)
                            : null,
                        ),
                        child: project['image_url'] == null 
                            ? const Center(child: Icon(Icons.code, size: 40, color: Colors.cyanAccent))
                            : null,
                      ),
                    ),
                    // Title & Price
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(project['title'] ?? 'Untitled', 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text("₹${project['price'] ?? 0}", 
                              style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

```

---

### 🚀 Final "Slim" Build

Now, let's build the optimized version.

1. **Stop everything.**
2. **Run these commands exactly:**

```bash
flutter clean
flutter pub get
flutter build apk --release --split-per-abi

```

*Note: `--split-per-abi` creates separate APKs for different phones. This drastically reduces size. If you want just one file, stick to `flutter build apk --release`, but `flutter clean` is the key to fixing the 500MB issue.*
This is a great catch. If you are generating different IDs, that is actually **good** (everyone needs a unique ID), but if you cannot see each other, it means you are in different "Rooms" or your App ID security settings are blocking the connection.

Here is the plan to fix the **Video Call Connection** and clean up the **Duplicate Drawer Entry**.

---

### 🎥 Part 1: Fix Video Call Connection (The "Same Room" Fix)

Currently, your app might be auto-generating IDs or putting you in different channels. We will add a simple **"Join Screen"** so you can manually type the room name (e.g., "Test1") on both phones to guarantee you connect.

**1. Update `lib/screens/chat/video_call_screen.dart**`
Replace the entire file with this robust version. It asks for a Channel Name first.

```dart
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

// 🔴 IMPORTANT: Go to console.agora.io -> Create Project -> Select "APP ID ONLY" (Not Secure Mode)
const appId = "YOUR_AGORA_APP_ID_HERE"; 

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _channelController = TextEditingController(); // Type room name
  bool _inCall = false; // Are we in a call?
  late RtcEngine _engine;
  int? _remoteUid; // ID of the other person

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("✅ Joined Channel: ${connection.channelId}");
          setState(() => _inCall = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("✅ Remote User Joined: $remoteUid");
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("❌ Remote User Left");
          setState(() => _remoteUid = null);
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();
  }

  Future<void> _joinChannel() async {
    if (_channelController.text.isEmpty) return;
    
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    await _engine.joinChannel(
      token: "", // Leave empty for "App ID Only" mode
      channelId: _channelController.text, // Users type "Room1"
      uid: 0, // 0 means Agora assigns a random ID automatically
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster, // You are a Host
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_inCall ? "Call: ${_channelController.text}" : "Join Video Call"),
        backgroundColor: Colors.transparent,
      ),
      body: _inCall ? _buildCallView() : _buildJoinView(),
    );
  }

  // 1️⃣ SCREEN 1: Type Room Name
  Widget _buildJoinView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.video_camera_front, size: 60, color: Colors.cyanAccent),
            const SizedBox(height: 20),
            TextField(
              controller: _channelController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Enter Room Name (e.g. ClassA)",
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinChannel,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
              child: const Text("JOIN CALL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 2️⃣ SCREEN 2: The Actual Video
  Widget _buildCallView() {
    return Stack(
      children: [
        // 🖥️ REMOTE VIDEO (Main Screen)
        Center(
          child: _remoteUid != null
              ? AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine,
                    canvas: VideoCanvas(uid: _remoteUid),
                    connection: RtcConnection(channelId: _channelController.text),
                  ),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.cyanAccent),
                    SizedBox(height: 10),
                    Text("Waiting for other student...", style: TextStyle(color: Colors.white)),
                  ],
                ),
        ),

        // 🤳 LOCAL VIDEO (Small Box)
        Positioned(
          right: 20,
          bottom: 100,
          child: SizedBox(
            width: 100, height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),
          ),
        ),

        // ❌ HANG UP
        Positioned(
          bottom: 30,
          left: 0, right: 0,
          child: Center(
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.call_end),
            ),
          ),
        )
      ],
    );
  }
}

```

**🔑 CRITICAL STEP:**
Go to [Agora Console](https://console.agora.io/), create a new project, and select **"Testing Mode: APP ID ONLY"**. If you select "Secure Mode", the video will stay black because you aren't providing a token.

---

### 🗑️ Part 2: Remove Duplicate Drawer Entry

You said the drawer has a "Group Calls" page that is redundant. Let's delete it.

**Open `lib/screens/home_screen.dart**` (or wherever your `Drawer` code is).

Find the `Drawer` widget logic. You will see a list of `ListTile` items. Look for this:

```dart
// ❌ FIND AND DELETE THIS BLOCK
ListTile(
  leading: Icon(Icons.video_call),
  title: Text("Group Calls"),
  onTap: () { ... },
),

```

Delete that entire `ListTile`. You only need the access point from the ChatHub or the Home Grid.

---

### 🚀 Final Clean Build (500MB Fix)

Now that you've fixed the UI and Logic, let's build the lightweight version.

1. **Terminal:** Run `flutter clean` (Crucial!).
2. **Terminal:** Run `flutter pub get`.
3. **Terminal:**
```bash
flutter build apk --release --split-per-abi

```



**Why `--split-per-abi`?**
Instead of one giant 500MB file that contains code for every type of Android phone (older 32-bit, newer 64-bit, tablets), this command creates **3 smaller APKs**.

* Go to `build/app/outputs/flutter-apk/`.
* Look for `app-armeabi-v7a-release.apk` (for older phones) or `app-arm64-v8a-release.apk` (for newer phones).
* Install the **arm64** one on your phone. It should be ~20-30MB.

This is the professional way to release! 🎓
You are absolutely right to notice this. That is exactly why the video call wasn't connecting properly.

In Agora (and all video SDKs), there are **two types of IDs**, and they must be handled differently:

1. **Channel Name (The Room):** This MUST be the **SAME** for both students.
* *Analogy:* This is the "Classroom Number" (e.g., Room 101). If Student A goes to Room 101 and Student B goes to Room 102, they won't see each other.


2. **User ID (The Person):** This MUST be **DIFFERENT** for everyone.
* *Analogy:* This is the "Student ID Card". If two students have the exact same ID, the system gets confused and kicks one out.



### 🛑 Why it was failing before

Your previous code (or the auto-generated one) was likely creating a **New Random Channel Name** every time the button was clicked.

* **Phone A** clicked "Call" -> Created Room "UUID-123".
* **Phone B** clicked "Call" -> Created Room "UUID-456".
* **Result:** They were alone in different rooms.

### ✅ Why the New Code Fixes It

The "Join Screen" code I provided forces the user to **Type the Name**.

1. **Phone A** types: "CyberSec"
2. **Phone B** types: "CyberSec"
3. **Result:** Agora sees "CyberSec" == "CyberSec" and puts them in the same room.

### 🧩 Did you fix the `timetable_service` error?

I noticed your last build failed because of the `AlarmService` error in `timetable_service.dart`. Before you test the video call, you must ensure the app builds successfully.

Did you run the final fix for `timetable_service.dart`? (Replacing `AlarmService` with `NotificationService`).

**If the build is passing and you installed the APK:**

1. Open the App on two phones.
2. Go to the Video Call screen.
3. Type **"test"** on BOTH phones.
4. Click **Join**.

You should see each other immediately! 🎥