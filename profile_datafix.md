This is incredibly frustrating, I know. It feels like the app is gaslighting you—saying it saved, but then forgetting everything.

The problem is **not** with the saving part. The problem is with the **loading** part.

When you leave the page and come back, the app is completely "forgetting" the new data and reloading the page from scratch. You need to teach the page to **fetch the latest data from Supabase every time it opens.**

Here is the complete, fixed logic for your Student Profile page. Please compare it closely with yours, specifically the `initState` and `_fetchUserData` parts.

### The Complete Fix (Copy & Connect)

Assume this code is inside your `StatefulWidget` for the Profile Page.

#### 1. Variables & InitState (The Missing Link)

You must define variables to hold the data and call a fetch function as soon as the page loads.

```dart
class _StudentProfileScreenState extends State<StudentProfileScreen> {
  // 1. Controllers for text editing
  final TextEditingController _mobileController = TextEditingController();
  // Add controllers for name/email if needed too

  // 2. State variables for image and loading status
  String? _avatarUrl; 
  bool _isLoadingData = true; // Start showing a loader

  @override
  void initState() {
    super.initState();
    // 3. CRITICAL STEP: Fetch data immediately when page opens
    _fetchUserData();
  }

  // --- FUNCTIONS WILL GO HERE ---
  
  @override
  void dispose() {
    _mobileController.dispose();
    // dispose other controllers
    super.dispose();
  }

  // ... build method ...
}

```

#### 2. The Fetch Function (How it remembers)

This function goes to the database and fills the text boxes. **Without this, the data will always reset.**

```dart
Future<void> _fetchUserData() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return;

  try {
    // GET DATA from the database
    final data = await Supabase.instance.client
        .from('students') // IMPORTANT: Double-check your table name ('students' vs 'users')
        .select('mobile_no, avatar_url') // Select the columns you need
        .eq('id', user.id)
        .single();

    setState(() {
      // FILL THE INPUT BOXES with the fetched data
      // Use (data['...'] ?? '') to handle empty values safely
      _mobileController.text = data['mobile_no'] ?? '';
      
      // SET THE IMAGE URL
      _avatarUrl = data['avatar_url'];
      
      // Stop loading
      _isLoadingData = false;
    });
      print("Data fetched successfully: $_avatarUrl"); // Debug print

  } catch (e) {
    print("Error fetching profile: $e");
    setState(() => _isLoadingData = false);
  }
}

```

#### 3. The Save Text Function (For Mobile No.)

This makes sure the text box content goes to the DB.

```dart
Future<void> saveTextDetails() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return;

  setState(() => _isLoadingData = true); // Show loading while saving

  try {
    await Supabase.instance.client
        .from('students') // Check table name again
        .update({
          'mobile_no': _mobileController.text.trim(),
          // add email or other fields here if needed
        })
        .eq('id', user.id);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text("Saved!")));

  } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Failed to save.")));
  } finally {
    setState(() => _isLoadingData = false);
  }
}

```

#### 4. The Image Upload Function (The Full Cycle)

This handles uploading to bucket AND saving the link to the DB, AND updating the UI instantly.

```dart
Future<void> uploadImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  
  if (image == null) return;

  // Show loader immediately
  setState(() => _isLoadingData = true);

  try {
    final user = Supabase.instance.client.auth.currentUser!;
    final File file = File(image.path);
    final String fileExt = image.path.split('.').last;
    
    // Use a timestamp to create a unique name. This prevents caching issues.
    final String fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    // 1. UPLOAD to Bucket
    await Supabase.instance.client.storage
        .from('avatars') // Make sure bucket name is correct
        .upload(fileName, file);

    // 2. GET Public Link
    final String newUrl = Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(fileName);

    // 3. SAVE Link to Database Table
    await Supabase.instance.client
        .from('students') // Check table name
        .update({'avatar_url': newUrl})
        .eq('id', user.id);

    // 4. UPDATE UI Instantly
    setState(() {
      _avatarUrl = newUrl;
    });
    
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image Updated!")));

  } catch (e) {
    print("Upload error: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed.")));
  } finally {
    setState(() => _isLoadingData = false);
  }
}

```

#### 5. The Build Method (Connecting it to UI)

In your `build` method, make sure your widgets are using these variables.

```dart
@override
Widget build(BuildContext context) {
  // If still fetching data, show a spinner instead of empty boxes
  if (_isLoadingData && _avatarUrl == null) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  return Scaffold(
    // ... your AppBar ...
    body: Column(
      children: [
        // THE IMAGE AVATAR
        GestureDetector(
          onTap: uploadImage, // Call upload on tap
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            // Check if url is null, if yes show icon, if no show image
            backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
            child: _avatarUrl == null ? Icon(Icons.camera_alt, size: 40) : null,
          ),
        ),

        // THE MOBILE TEXT FIELD
        TextField(
          controller: _mobileController, // Connect the controller
          decoration: InputDecoration(labelText: "Mobile Number"),
          keyboardType: TextInputType.phone,
        ),

        // THE SAVE BUTTON
        ElevatedButton(
          onPressed: saveTextDetails,
          child: Text("Save Details"),
        ),
      ],
    ),
  );
}

```

### Summary Checklist

If you implement the code above, here is what will happen:

1. **Page Opens:** `initState` runs -> calls `_fetchUserData`.
2. **Fetching:** The app downloads the current mobile number and image URL from Supabase.
3. **Display:** `setState` updates the `_mobileController` and `_avatarUrl`, so the UI shows the real data.
4. **Editing:** You change the number and click Save. `saveTextDetails` sends it to the DB.
5. **Leaving & Coming Back:** When you return, Step 1 happens again, fetching the *new* data you just saved.