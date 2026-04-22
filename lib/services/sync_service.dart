import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'student_auth_service.dart';

/// Cross-Device Sync Engine
/// Syncs Hive local data to Supabase and manages offline queue
class SyncService {
  static final _supabase = Supabase.instance.client;
  static const String _queueBoxName = 'sync_queue';
  static const String _syncMetaBoxName = 'sync_meta';

  static bool _initialized = false;
  static DateTime? _lastSync;

  /// Initialize sync service — call from main.dart
  static Future<void> init() async {
    if (_initialized) return;

    if (!Hive.isBoxOpen(_queueBoxName)) {
      await Hive.openBox<Map>(_queueBoxName);
    }
    if (!Hive.isBoxOpen(_syncMetaBoxName)) {
      await Hive.openBox(_syncMetaBoxName);
    }

    final metaBox = Hive.box(_syncMetaBoxName);
    final lastSyncStr = metaBox.get('last_sync');
    if (lastSyncStr != null) {
      _lastSync = DateTime.tryParse(lastSyncStr);
    }

    _initialized = true;
    debugPrint('✅ SyncService initialized');

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      if (result != ConnectivityResult.none) {
        _processQueue();
      }
    });
  }

  /// Queue an operation for sync (used when offline)
  static Future<void> queueOperation({
    required String tableName,
    required String operation, // 'insert', 'update', 'delete'
    required Map<String, dynamic> data,
  }) async {
    try {
      final box = Hive.box<Map>(_queueBoxName);
      await box.add({
        'table': tableName,
        'operation': operation,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'synced': false,
      });
      debugPrint('📤 Queued: $operation on $tableName');
    } catch (e) {
      debugPrint('⚠️ Queue error: $e');
    }
  }

  /// Process the offline queue
  static Future<int> _processQueue() async {
    if (!_initialized) return 0;

    try {
      final box = Hive.box<Map>(_queueBoxName);
      int synced = 0;

      for (int i = 0; i < box.length; i++) {
        final item = box.getAt(i);
        if (item == null || item['synced'] == true) continue;

        try {
          final table = item['table'] as String;
          final operation = item['operation'] as String;
          final data = Map<String, dynamic>.from(item['data'] as Map);

          switch (operation) {
            case 'insert':
              await _supabase.from(table).insert(data);
              break;
            case 'update':
              if (data.containsKey('id')) {
                final id = data.remove('id');
                await _supabase.from(table).update(data).eq('id', id);
              }
              break;
            case 'delete':
              if (data.containsKey('id')) {
                await _supabase.from(table).delete().eq('id', data['id']);
              }
              break;
          }

          // Mark as synced
          await box.putAt(i, {...item, 'synced': true});
          synced++;
        } catch (e) {
          debugPrint('⚠️ Sync item error: $e');
        }
      }

      // Clean up synced items
      final toDelete = <int>[];
      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?['synced'] == true) toDelete.add(i);
      }
      for (final i in toDelete.reversed) {
        await box.deleteAt(i);
      }

      if (synced > 0) {
        _lastSync = DateTime.now();
        final metaBox = Hive.box(_syncMetaBoxName);
        await metaBox.put('last_sync', _lastSync!.toIso8601String());
        debugPrint('✅ Synced $synced items');
      }

      return synced;
    } catch (e) {
      debugPrint('⚠️ Process queue error: $e');
      return 0;
    }
  }

  /// Manual sync trigger
  static Future<({int synced, String? error})> syncNow() async {
    try {
      // Check connectivity
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) {
        return (synced: 0, error: 'No internet connection');
      }

      // Process offline queue
      final synced = await _processQueue();

      // Refresh student profile from server
      await StudentAuthService.refreshCurrentStudent();

      _lastSync = DateTime.now();
      final metaBox = Hive.box(_syncMetaBoxName);
      await metaBox.put('last_sync', _lastSync!.toIso8601String());

      return (synced: synced, error: null);
    } catch (e) {
      return (synced: 0, error: '$e');
    }
  }

  /// Get pending queue count
  static int get pendingCount {
    try {
      final box = Hive.box<Map>(_queueBoxName);
      return box.values.where((v) => v['synced'] != true).length;
    } catch (e) {
      return 0;
    }
  }

  /// Get last sync time
  static DateTime? get lastSyncTime => _lastSync;

  /// Get last sync time as string
  static String get lastSyncDisplay {
    if (_lastSync == null) return 'Never';
    final diff = DateTime.now().difference(_lastSync!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// Sync status for UI
  static bool get isSynced => pendingCount == 0;
}
