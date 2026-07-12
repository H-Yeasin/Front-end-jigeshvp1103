import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/api_config.dart';
import 'dev_auth_session.dart';

/// Events emitted by the server and exposed as typed streams.
class RegroupEvent {
  final String message;
  final String reason; // "auto-regroup" | "manual-regroup"
  final int newTableNumber;
  final String newTableId;

  const RegroupEvent({
    required this.message,
    required this.reason,
    required this.newTableNumber,
    required this.newTableId,
  });

  factory RegroupEvent.fromJson(Map<String, dynamic> json) {
    return RegroupEvent(
      message: (json['message'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      newTableNumber: int.tryParse('${json['newTableNumber']}') ?? 0,
      newTableId: (json['newTableId'] ?? '').toString(),
    );
  }
}

class RemovalEvent {
  final String message;
  final String reason;

  const RemovalEvent({required this.message, required this.reason});

  factory RemovalEvent.fromJson(Map<String, dynamic> json) {
    return RemovalEvent(
      message: (json['message'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
    );
  }
}

class WarningEvent {
  final String message;
  final int minutesRemaining;

  const WarningEvent({required this.message, required this.minutesRemaining});

  factory WarningEvent.fromJson(Map<String, dynamic> json) {
    return WarningEvent(
      message: (json['message'] ?? '').toString(),
      minutesRemaining:
          int.tryParse('${json['minutesRemaining']}') ?? 10,
    );
  }
}

/// Singleton Socket.IO client service.
///
/// Usage:
/// ```dart
/// final socketService = SocketService.instance;
/// socketService.joinSquarle(sessionId);
/// socketService.regroupStream.listen((event) { ... });
/// ```
class SocketService {
  static final SocketService _instance = SocketService._();

  factory SocketService() => _instance;

  SocketService._();

  io.Socket? _socket;

  // ── Stream controllers ─────────────────────────────────────────────────
  final StreamController<RegroupEvent> _regroupController =
      StreamController<RegroupEvent>.broadcast();
  final StreamController<RemovalEvent> _removalController =
      StreamController<RemovalEvent>.broadcast();
  final StreamController<WarningEvent> _warningController =
      StreamController<WarningEvent>.broadcast();
  final StreamController<Map<String, dynamic>> _seatChangedController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Fired when the server auto- or manually-regroups this user.
  Stream<RegroupEvent> get regroupStream => _regroupController.stream;

  /// Fired when the server removes this user due to inactivity.
  Stream<RemovalEvent> get removalStream => _removalController.stream;

  /// Fired when the server warns this user about impending inactivity removal.
  Stream<WarningEvent> get warningStream => _warningController.stream;

  /// Fired when any seat changes in the squarle room.
  Stream<Map<String, dynamic>> get seatChangedStream =>
      _seatChangedController.stream;

  // ── Connection ─────────────────────────────────────────────────────────

  /// Connect to the backend Socket.IO server and authenticate.
  void connect() {
    if (_socket != null && _socket!.connected) return;

    final token = _resolveAccessToken();
    if (token.isEmpty) return;

    final baseUrl = ApiConfig.resolveBaseUrl(null);
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setTimeout(10000)
          .build(),
    );

    _socket!.onConnect((_) {
      // Authenticate immediately
      _socket!.emit('authenticate', {'token': token});
    });

    _socket!.on('authenticated', (_) {
      // Ready — caller must call joinSquarle() to enter a room
    });

    _socket!.on('auth-error', (data) {
      // Ignore auth errors silently; the REST API will also fail if auth is bad
    });

    // ── Server → client events ──────────────────────────────────────
    _socket!.on('user-regrouped', (data) {
      if (data == null) return;
      final json = _toJson(data);
      if (json.isNotEmpty) {
        _regroupController.add(RegroupEvent.fromJson(json));
      }
    });

    _socket!.on('user-removed', (data) {
      if (data == null) return;
      final json = _toJson(data);
      if (json.isNotEmpty) {
        _removalController.add(RemovalEvent.fromJson(json));
      }
    });

    _socket!.on('inactivity-warning', (data) {
      if (data == null) return;
      final json = _toJson(data);
      if (json.isNotEmpty) {
        _warningController.add(WarningEvent.fromJson(json));
      }
    });

    _socket!.on('seat-changed', (data) {
      if (data == null) return;
      final json = _toJson(data);
      if (json.isNotEmpty) {
        _seatChangedController.add(json);
      }
    });

    _socket!.onDisconnect((_) {
      // socket_io_client will auto-reconnect.
      // On reconnect, the onConnect handler re-authenticates.
    });

    _socket!.onConnectError((err) {
      // Connection failed — caller can retry by calling connect() again
    });

    // Fire connect if not already connected
    if (!_socket!.connected) {
      _socket!.connect();
    }
  }

  /// Join a squarle session room so the socket receives targeted events.
  void joinSquarle(String sessionId) {
    connect();
    _socket?.emitWithAck('join-squarle', sessionId);
  }

  /// Leave a squarle session room.
  void leaveSquarle(String sessionId) {
    _socket?.emit('leave-squarle-room', sessionId);
  }

  /// Disconnect the socket entirely (e.g. on logout).
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  bool get isConnected => _socket?.connected == true;

  // ── Helpers ────────────────────────────────────────────────────────────

  static String _resolveAccessToken() {
    final env = String.fromEnvironment('ACCESS_TOKEN', defaultValue: '');
    if (env.isNotEmpty) return env;
    final envLower = String.fromEnvironment('access_token', defaultValue: '');
    if (envLower.isNotEmpty) return envLower;
    return DevAuthSession.accessToken;
  }

  static Map<String, dynamic> _toJson(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        final decoded = Uri.parse('?$data').queryParameters;
        if (decoded.isNotEmpty) {
          return decoded;
        }
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  /// Dispose all streams and socket (call when the app terminates).
  void dispose() {
    disconnect();
    _regroupController.close();
    _removalController.close();
    _warningController.close();
    _seatChangedController.close();
  }
}
