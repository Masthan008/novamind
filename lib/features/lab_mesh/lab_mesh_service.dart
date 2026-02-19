import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

/// LabMesh Service
/// Wraps nearby_connections for P2P text/file sharing between students
class LabMeshService {
  static final Nearby _nearby = Nearby();
  static const String _serviceId = 'com.sentinel.labmesh';
  static const Strategy _strategy = Strategy.P2P_STAR;

  // === Callbacks (set these from the UI) ===
  static Function(String endpointId, String name)? onEndpointFound;
  static Function(String endpointId)? onEndpointLost;
  static Function(String endpointId, ConnectionInfo info)? onConnectionInitiated;
  static Function(String endpointId)? onConnectionAccepted;
  static Function(String endpointId)? onDisconnected;
  static Function(String endpointId, String message)? onMessageReceived;
  static Function(String error)? onError;

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
          debugPrint('LabMesh: Transfer update - ${update.status}, bytes: ${update.bytesTransferred}');
        },
      );
    } catch (e) {
      debugPrint('LabMesh: Failed to accept connection: $e');
      onError?.call('Failed to accept connection: $e');
    }
  }

  /// Send a text message to a connected peer
  static Future<bool> sendText(String endpointId, String text) async {
    try {
      debugPrint('LabMesh: Sending text to $endpointId: "${text.substring(0, text.length > 30 ? 30 : text.length)}"');
      await _nearby.sendBytesPayload(
        endpointId,
        Uint8List.fromList(text.codeUnits),
      );
      debugPrint('LabMesh: Text sent successfully');
      return true;
    } catch (e) {
      debugPrint('LabMesh: Failed to send text: $e');
      onError?.call('Failed to send message: $e');
      return false;
    }
  }

  /// Handle incoming payloads
  static void _handlePayload(String endpointId, Payload payload) {
    try {
      if (payload.type == PayloadType.BYTES && payload.bytes != null) {
        final message = String.fromCharCodes(payload.bytes!);
        debugPrint('LabMesh: Received message: "$message"');
        onMessageReceived?.call(endpointId, message);
      } else {
        debugPrint('LabMesh: Received non-bytes payload type: ${payload.type}');
      }
    } catch (e) {
      debugPrint('LabMesh: Error handling payload: $e');
    }
  }

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
    onError = null;
  }
}
