import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _notificationBoxKey = 'notification_settings';
  late Box _notificationBox;
  
  // Notification Settings
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _volume = 0.7;
  
  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  double get volume => _volume;

  NotificationProvider() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      _notificationBox = await Hive.openBox(_notificationBoxKey);
      _loadNotificationSettings();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  void _loadNotificationSettings() {
    _notificationsEnabled = _notificationBox.get('notificationsEnabled', defaultValue: true);
    _soundEnabled = _notificationBox.get('soundEnabled', defaultValue: true);
    _vibrationEnabled = _notificationBox.get('vibrationEnabled', defaultValue: true);
    _volume = _notificationBox.get('volume', defaultValue: 0.7);
    notifyListeners();
  }

  Future<void> _saveNotificationSettings() async {
    try {
      await _notificationBox.put('notificationsEnabled', _notificationsEnabled);
      await _notificationBox.put('soundEnabled', _soundEnabled);
      await _notificationBox.put('vibrationEnabled', _vibrationEnabled);
      await _notificationBox.put('volume', _volume);
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  // Settings Management
  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    _saveNotificationSettings();
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    _saveNotificationSettings();
    notifyListeners();
  }

  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    _saveNotificationSettings();
    notifyListeners();
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _saveNotificationSettings();
    notifyListeners();
  }

  // Sound Playback
  Future<void> playNotificationSound({String? soundId}) async {
    if (!_soundEnabled || !_notificationsEnabled) return;
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      debugPrint('Error playing notification sound: $e');
    }
  }

  // Vibration
  Future<void> triggerVibration({int duration = 100}) async {
    if (!_vibrationEnabled || !_notificationsEnabled) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error triggering vibration: $e');
    }
  }

  // Combined Notification
  Future<void> showNotification({
    String? soundId,
    bool vibrate = true,
    int vibrationDuration = 100,
  }) async {
    if (!_notificationsEnabled) return;
    
    // Play sound
    if (_soundEnabled) {
      await playNotificationSound(soundId: soundId);
    }
    
    // Trigger vibration
    if (_vibrationEnabled && vibrate) {
      await triggerVibration(duration: vibrationDuration);
    }
  }

  // Specific notification types
  Future<void> showSuccessNotification() async {
    await showNotification();
  }

  Future<void> showErrorNotification() async {
    await showNotification(vibrationDuration: 200);
  }

  Future<void> showAlertNotification() async {
    await showNotification(vibrationDuration: 150);
  }

  Future<void> showGentleNotification() async {
    await showNotification(vibrationDuration: 50);
  }

  @override
  void dispose() {
    super.dispose();
  }
}