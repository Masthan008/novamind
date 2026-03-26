import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

/// LabMesh Service
/// Wraps nearby_connections for P2P text/file sharing between students
class LabMeshService {
  static final Nearby _nearby = Nearby();
  static const String _serviceId = 'com.zerno.labmesh';
  static const Strategy _strategy = Strategy.P2P_STAR;

  // === Callbacks (set these from the UI) ===
  static Function(String endpointId, String name)? onEndpointFound;
  static Function(String endpointId)? onEndpointLost;
  static Function(String endpointId, ConnectionInfo info)? onConnectionInitiated;
  static Function(String endpointId)? onConnectionAccepted;
  static Function(String endpointId)? onDisconnected;
  static Function(String endpointId, String message)? onMessageReceived;
  static Function(String endpointId, String filePath, String fileName)? onFileReceived;
  static Function(String endpointId, int bytesTransferred, int totalBytes)? onFileProgress;
  static Function(String error)? onError;

  // Track pending file transfers: payloadId -> tempFilePath
  static final Map<int, String> _pendingFiles = {};

  /// Request all permissions needed for P2P
  static Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.nearbyWifiDevices,
    ].request();

    // Check if location is granted (mandatory)
    final locationGranted = statuses[Permission.location]?.isGranted ?? false;
    debugPrint('LabMesh: Location permission: $locationGranted');
    
    // Also check if location services are enabled
    if (locationGranted) {
      final serviceEnabled = await Permission.location.serviceStatus.isEnabled;
      debugPrint('LabMesh: Location services enabled: $serviceEnabled');
      if (!serviceEnabled) {
        onError?.call('Please enable Location services (GPS)');
        return false;
      }
    }
    
    return locationGranted;
  }

  /// Start advertising (Sender mode)
  static Future<bool> startAdvertising(String userName) async {
    try {
      debugPrint('LabMesh: Starting advertising as "$userName"');
      final result = await _nearby.startAdvertising(
        userName,
        _strategy,
        onConnectionInitiated: (endpointId, info) {
          debugPrint('LabMesh: Connection initiated from ${info.endpointName}');
          onConnectionInitiated?.call(endpointId, info);
          // Auto-accept and register payload listener
          _acceptAndListen(endpointId);
        },
        onConnectionResult: (endpointId, status) {
          debugPrint('LabMesh: Connection result: $status');
          if (status == Status.CONNECTED) {
            onConnectionAccepted?.call(endpointId);
          } else {
            onError?.call('Connection rejected or failed');
          }
        },
        onDisconnected: (endpointId) {
          debugPrint('LabMesh: Disconnected from $endpointId');
          onDisconnected?.call(endpointId);
        },
        serviceId: _serviceId,
      );
      debugPrint('LabMesh: Advertising started: $result');
      return result;
    } catch (e) {
      debugPrint('LabMesh: Failed to start advertising: $e');
      onError?.call('Failed to broadcast: $e');
      return false;
    }
  }

  /// Start discovery (Receiver mode)
  static Future<bool> startDiscovery(String userName) async {
    try {
      debugPrint('LabMesh: Starting discovery as "$userName"');
      final result = await _nearby.startDiscovery(
        userName,
        _strategy,
        onEndpointFound: (endpointId, name, serviceId) {
          debugPrint('LabMesh: Found endpoint: $name ($endpointId)');
          onEndpointFound?.call(endpointId, name);
        },
        onEndpointLost: (endpointId) {
          debugPrint('LabMesh: Lost endpoint: $endpointId');
          if (endpointId != null) {
            onEndpointLost?.call(endpointId);
          }
        },
        serviceId: _serviceId,
      );
      debugPrint('LabMesh: Discovery started: $result');
      return result;
    } catch (e) {
      debugPrint('LabMesh: Failed to start discovery: $e');
      onError?.call('Failed to scan: $e');
      return false;
    }
  }

  /// Connect to a discovered endpoint
  static Future<bool> connectToEndpoint(String endpointId, String userName) async {
    try {
      debugPrint('LabMesh: Requesting connection to $endpointId');
      await _nearby.requestConnection(
        userName,
        endpointId,
        onConnectionInitiated: (endpointId, info) {
          debugPrint('LabMesh: Connection initiated with ${info.endpointName}');
          onConnectionInitiated?.call(endpointId, info);
          _acceptAndListen(endpointId);
        },
        onConnectionResult: (endpointId, status) {
          debugPrint('LabMesh: Connection result: $status');
          if (status == Status.CONNECTED) {
            onConnectionAccepted?.call(endpointId);
          } else {
            onError?.call('Peer rejected the connection');
          }
        },
        onDisconnected: (endpointId) {
          debugPrint('LabMesh: Disconnected from $endpointId');
          onDisconnected?.call(endpointId);
        },
      );
      return true;
    } catch (e) {
      debugPrint('LabMesh: Failed to connect: $e');
      onError?.call('Connection failed: $e');
      return false;
    }
  }

  /// Accept connection and set up payload listener
  static void _acceptAndListen(String endpointId) {
    try {
      _nearby.acceptConnection(
        endpointId,
        onPayLoadRecieved: (endpointId, payload) {
          debugPrint('LabMesh: Payload received from $endpointId, type: ${payload.type}');
          _handlePayload(endpointId, payload);
        },
        onPayloadTransferUpdate: (endpointId, update) {
          debugPrint('LabMesh: Transfer update - ${update.status}, bytes: ${update.bytesTransferred}/${update.totalBytes}');
          
          // Report progress for file transfers
          onFileProgress?.call(endpointId, update.bytesTransferred, update.totalBytes);
          
          // When file transfer is complete, notify the listener
          if (update.status == PayloadStatus.SUCCESS) {
            final tempPath = _pendingFiles.remove(update.id);
            if (tempPath != null && tempPath.isNotEmpty) {
              final fileName = _pendingFileNames.remove(endpointId) ?? 'received_file';
              _moveReceivedFile(tempPath, fileName, endpointId);
            }
          } else if (update.status == PayloadStatus.FAILURE) {
            _pendingFiles.remove(update.id);
            _pendingFileNames.remove(endpointId);
            onError?.call('File transfer failed');
          }
        },
      );
    } catch (e) {
      debugPrint('LabMesh: Failed to accept connection: $e');
      onError?.call('Failed to accept connection: $e');
    }
  }

  /// Move received file from temp location to Downloads
  static Future<void> _moveReceivedFile(String tempPath, String fileName, String endpointId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final labMeshDir = Directory('${dir.path}/LabMesh');
      if (!await labMeshDir.exists()) {
        await labMeshDir.create(recursive: true);
      }
      final destPath = '${labMeshDir.path}/$fileName';
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.copy(destPath);
        await tempFile.delete();
        debugPrint('LabMesh: File saved to $destPath');
        onFileReceived?.call(endpointId, destPath, fileName);
      } else {
        debugPrint('LabMesh: Temp file not found at $tempPath');
        onError?.call('Received file not found');
      }
    } catch (e) {
      debugPrint('LabMesh: Error saving received file: $e');
      onError?.call('Error saving file: $e');
    }
  }

  /// Send a text message to a connected peer
  static Future<bool> sendText(String endpointId, String text) async {
    try {
      debugPrint('LabMesh: Sending text to $endpointId: "${text.substring(0, text.length > 30 ? 30 : text.length)}"');
      // Prefix text messages with 'T:' to distinguish from file metadata
      await _nearby.sendBytesPayload(
        endpointId,
        Uint8List.fromList('T:$text'.codeUnits),
      );
      debugPrint('LabMesh: Text sent successfully');
      return true;
    } catch (e) {
      debugPrint('LabMesh: Failed to send text: $e');
      onError?.call('Failed to send message: $e');
      return false;
    }
  }

  /// Send a file to a connected peer
  static Future<bool> sendFile(String endpointId, String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        onError?.call('File not found');
        return false;
      }

      final fileName = filePath.split(Platform.pathSeparator).last;
      final fileSize = await file.length();

      debugPrint('LabMesh: Sending file "$fileName" ($fileSize bytes) to $endpointId');

      // First send file metadata as bytes so receiver knows the file name
      await _nearby.sendBytesPayload(
        endpointId,
        Uint8List.fromList('F:$fileName'.codeUnits),
      );

      // Then send the file payload
      final payloadId = await _nearby.sendFilePayload(endpointId, filePath);
      debugPrint('LabMesh: File payload sent, id: $payloadId');
      return true;
    } catch (e) {
      debugPrint('LabMesh: Failed to send file: $e');
      onError?.call('Failed to send file: $e');
      return false;
    }
  }

  /// Handle incoming payloads
  static void _handlePayload(String endpointId, Payload payload) {
    try {
      if (payload.type == PayloadType.BYTES && payload.bytes != null) {
        final raw = String.fromCharCodes(payload.bytes!);
        if (raw.startsWith('T:')) {
          // Text message
          final message = raw.substring(2);
          debugPrint('LabMesh: Received message: "$message"');
          onMessageReceived?.call(endpointId, message);
        } else if (raw.startsWith('F:')) {
          // File metadata — store for the next file payload
          final fileName = raw.substring(2);
          debugPrint('LabMesh: Expecting file: $fileName');
          // Store the expected file name keyed by endpointId temporarily
          _pendingFileNames[endpointId] = fileName;
        } else {
          // Legacy text (no prefix) — treat as text
          debugPrint('LabMesh: Received message (legacy): "$raw"');
          onMessageReceived?.call(endpointId, raw);
        }
      } else if (payload.type == PayloadType.FILE) {
        // File received — will be completed via onPayloadTransferUpdate
        if (payload.id != null) {
          final tempPath = payload.uri ?? '';
          _pendingFiles[payload.id!] = tempPath;
          debugPrint('LabMesh: File payload started, id: ${payload.id}, uri: $tempPath');
        }
      } else {
        debugPrint('LabMesh: Received unknown payload type: ${payload.type}');
      }
    } catch (e) {
      debugPrint('LabMesh: Error handling payload: $e');
    }
  }

  // Track expected file names from metadata bytes
  static final Map<String, String> _pendingFileNames = {};

  /// Stop all services
  static Future<void> stopAll() async {
    try {
      await _nearby.stopAdvertising();
      await _nearby.stopDiscovery();
      await _nearby.stopAllEndpoints();
      debugPrint('LabMesh: All services stopped');
    } catch (e) {
      debugPrint('LabMesh: Error stopping services: $e');
    }

    // Clear callbacks
    onEndpointFound = null;
    onEndpointLost = null;
    onConnectionInitiated = null;
    onConnectionAccepted = null;
    onDisconnected = null;
    onMessageReceived = null;
    onFileReceived = null;
    onFileProgress = null;
    onError = null;
    _pendingFiles.clear();
    _pendingFileNames.clear();
  }
}
