import 'dart:async';

import 'package:flutter/material.dart';

import '../Squarle_Entrance/squarle_entrance.dart';
import '../models/class_item.dart';
import 'models/squarle_status.dart';
import 'services/squarle_service.dart';
import 'widgets/entrance_class_tile.dart';
import 'widgets/entrance_status_text.dart';
import 'widgets/squarle_logo_button.dart';

class ClassEntranceScreen extends StatefulWidget {
  final ClassItem classItem;

  const ClassEntranceScreen({super.key, required this.classItem});

  @override
  State<ClassEntranceScreen> createState() => _ClassEntranceScreenState();
}

class _ClassEntranceScreenState extends State<ClassEntranceScreen> {
  final SquarleService _squarleService = SquarleService();

  SquarleStatus? _status;
  bool _isLoadingStatus = true;
  bool _isJoining = false;
  String? _statusMessageOverride;
  String? _errorMessage;
  Timer? _countdownTimer;
  int? _quietWarningSeconds;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _isLoadingStatus = true;
      _errorMessage = null;
      _statusMessageOverride = null;
    });

    try {
      final status = await _squarleService.getStatus(widget.classItem.id);
      if (!mounted) return;

      setState(() {
        _status = status;
        _isLoadingStatus = false;
      });
      _syncQuietWarningCountdown(status);
    } catch (error) {
      if (!mounted) return;
      _countdownTimer?.cancel();
      setState(() {
        _errorMessage = error.toString();
        _isLoadingStatus = false;
      });
    }
  }

  Future<void> _joinSquarle() async {
    final status = _status;
    if (status == null || !status.isJoinable) return;

    setState(() {
      _isJoining = true;
      _statusMessageOverride = null;
      _errorMessage = null;
    });

    try {
      final result = await _squarleService.joinSquarle(widget.classItem.id);
      if (!mounted) return;

      if (result.inQueue) {
        setState(() {
          _statusMessageOverride =
              'You have joined the squarle and will be seated shortly.';
          _isJoining = false;
        });
        return;
      }

      if (result.tableNumber != null) {
        setState(() {
          _isJoining = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SquarleEntranceScreen(joinResult: result),
          ),
        );
        return;
      }

      setState(() {
        _statusMessageOverride = result.message;
        _isJoining = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _statusMessageOverride = _friendlyJoinMessage(error.toString());
        _isJoining = false;
      });
    }
  }

  String _friendlyJoinMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('enough students')) {
      return 'The squarle opens when enough students add the class.';
    }
    if (lower.contains('quiet hours')) {
      return 'Quiet hours are active.';
    }
    return message;
  }

  void _syncQuietWarningCountdown(SquarleStatus status) {
    _countdownTimer?.cancel();
    _quietWarningSeconds = null;

    final startsAt = status.quietHoursStartsAt;
    final secondsUntilStart = startsAt?.difference(DateTime.now()).inSeconds;
    final fallbackMinutes = status.warningMinutes;
    final fallbackSeconds = fallbackMinutes == null
        ? null
        : fallbackMinutes * 60;
    final warningSeconds = secondsUntilStart != null && secondsUntilStart > 0
        ? secondsUntilStart
        : fallbackSeconds;

    if (!status.isQuietWarning ||
        warningSeconds == null ||
        warningSeconds <= 0) {
      return;
    }

    setState(() {
      _quietWarningSeconds = warningSeconds;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final seconds = _quietWarningSeconds;
      if (seconds == null || seconds <= 1) {
        timer.cancel();
        _loadStatus();
        return;
      }

      if (mounted) {
        setState(() {
          _quietWarningSeconds = seconds - 1;
        });
      }
    });
  }

  String _displayMessage() {
    if (_errorMessage != null) return _errorMessage!;
    if (_statusMessageOverride != null) return _statusMessageOverride!;

    final status = _status;
    if (status == null) return '';

    final warningSeconds = _quietWarningSeconds;
    if (status.isQuietWarning && warningSeconds != null) {
      final minutes = warningSeconds ~/ 60;
      final seconds = warningSeconds % 60;
      return 'Quiet hours will begin in $minutes:${seconds.toString().padLeft(2, '0')}.';
    }

    return status.displayMessage;
  }

  bool get _shouldShowLogo {
    final status = _status;
    if (status == null) return true;
    return status.isOpen || status.quietHours || status.isQuietWarning;
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final double px = w / 393;
    final double py = h / 852;

    final status = _status;
    final isDimmed = status?.quietHours == true;
    final canJoin = status?.isJoinable == true && _errorMessage == null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16 * py,
              left: 16 * px,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: 16 * px,
                  minHeight: 16 * px,
                ),
                icon: Image.asset(
                  'assets/icons/back.png',
                  width: 16 * px,
                  height: 16 * px,
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            Positioned(
              top: 60 * py,
              left: 16 * px,
              right: 16 * px,
              child: EntranceClassTile(
                classItem: widget.classItem,
                px: px,
                py: py,
              ),
            ),
            Positioned(
              left: 24 * px,
              right: 24 * px,
              bottom: _shouldShowLogo ? 132 * py : 126 * py,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_shouldShowLogo) ...[
                    SquarleLogoButton(
                      enabled: canJoin,
                      dimmed: isDimmed,
                      isLoading: _isLoadingStatus || _isJoining,
                      px: px,
                      onTap: _joinSquarle,
                    ),
                    SizedBox(height: 14 * py),
                  ],
                  EntranceStatusText(message: _displayMessage(), px: px),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 12 * py),
                    TextButton(
                      onPressed: _loadStatus,
                      child: const Text('Try again'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
