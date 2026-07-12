import 'dart:async';

import 'package:flutter/material.dart';

import '../Class_Entrance/models/squarle_join_result.dart';
import '../Class_Entrance/services/squarle_service.dart';
import '../services/socket_service.dart';
import '../Table/table_screen.dart';
import 'models/squarle_table.dart';
import 'widgets/squarle_bottom_controls.dart';
import 'widgets/squarle_notice_dialog.dart';
import 'widgets/squarle_table_field.dart';

class SquarleEntranceScreen extends StatefulWidget {
  final SquarleJoinResult joinResult;
  final String? notificationMessage;
  final SquarleNoticeTone? notificationTone;

  const SquarleEntranceScreen({
    super.key,
    required this.joinResult,
    this.notificationMessage,
    this.notificationTone,
  });

  @override
  State<SquarleEntranceScreen> createState() => _SquarleEntranceScreenState();
}

class _SquarleEntranceScreenState extends State<SquarleEntranceScreen> {
  final SquarleService _squarleService = SquarleService();
  final SocketService _socketService = SocketService();

  bool _isLeaving = false;

  /// Mutable assigned table number — starts from joinResult and gets
  /// updated when the user is regrouped (auto or manual) so the glow
  /// moves to the new table.
  late int _assignedTableNumber;

  StreamSubscription<RegroupEvent>? _regroupSub;

  @override
  void initState() {
    super.initState();
    _assignedTableNumber = widget.joinResult.tableNumber ?? 0;

    // Show initial notification if passed (e.g. on first entry after join)
    if (widget.notificationMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNotice(
          widget.notificationMessage!,
          widget.notificationTone ?? SquarleNoticeTone.green,
        );
      });
    }

    // Listen for live regroup events while on this screen
    _regroupSub = _socketService.regroupStream.listen(_handleRegroup);
  }

  void _handleRegroup(RegroupEvent event) {
    if (!mounted) return;
    setState(() {
      if (event.newTableNumber > 0) {
        _assignedTableNumber = event.newTableNumber;
      }
    });
    _showNotice(event.message, SquarleNoticeTone.green);
  }

  void _showNotice(String message, SquarleNoticeTone tone) {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final px = size.width / 393;
    final py = size.height / 852;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return SquarleNoticeDialog(
          message: message,
          tone: tone,
          px: px,
          py: py,
        );
      },
    );
  }

  void _handleTableTap(SquarleTable table) {
    final sessionId = widget.joinResult.sessionId;
    final tableId = table.id.trim();
    final isPlaceholder =
        tableId.isEmpty ||
        tableId.startsWith('fallback_') ||
        tableId.startsWith('table_');

    if (sessionId == null || sessionId.isEmpty || isPlaceholder) {
      _showNotice('Table is not available yet.', SquarleNoticeTone.orange);
      return;
    }

    Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => TableScreen(
          sessionId: sessionId,
          tableId: table.id,
          tableNumber: table.tableNumber,
        ),
      ),
    ).then((result) {
      if (result == null || !mounted) return;
      final message = result['notificationMessage'] as String?;
      final tone = result['notificationTone'] as SquarleNoticeTone?;
      final newTableNumber = result['newTableNumber'] as int?;

      // Update the glow to the new table
      if (newTableNumber != null && newTableNumber > 0) {
        setState(() {
          _assignedTableNumber = newTableNumber;
        });
      }

      if (message != null) {
        _showNotice(message, tone ?? SquarleNoticeTone.green);
      }
    });
  }

  Future<void> _leaveSquarle() async {
    final sessionId = widget.joinResult.sessionId;
    if (sessionId == null || sessionId.isEmpty || _isLeaving) return;

    setState(() => _isLeaving = true);

    try {
      await _squarleService.leaveSquarle(sessionId);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLeaving = false);
      _showNotice(error.toString(), SquarleNoticeTone.orange);
    }
  }

  List<SquarleTable> _visibleTables() {
    if (widget.joinResult.visibleTables.isNotEmpty) {
      return widget.joinResult.visibleTables;
    }

    final view = widget.joinResult.view ?? 1;
    final start = switch (view) {
      1 => 1,
      2 => 10,
      3 => 19,
      _ => 28,
    };
    final end = switch (view) {
      1 => 13,
      2 => 22,
      3 => 31,
      _ => 40,
    };

    return List.generate(end - start + 1, (index) {
      final tableNumber = start + index;
      return SquarleTable(
        id: 'fallback_$tableNumber',
        tableNumber: tableNumber,
        occupancy: tableNumber == _assignedTableNumber ? 1 : 0,
      );
    });
  }

  @override
  void dispose() {
    _regroupSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final double px = w / 393;
    final double py = h / 852;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SquarleTableField(
                tables: _visibleTables(),
                assignedTableNumber: _assignedTableNumber,
                px: px,
                py: py,
                onTableTap: _handleTableTap,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 28 * py,
              child: Center(
                child: SquarleBottomControls(
                  px: px,
                  py: py,
                  isLoading: _isLeaving,
                  onSlideOut: _leaveSquarle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
