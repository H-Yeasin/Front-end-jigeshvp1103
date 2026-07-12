import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/socket_service.dart';
import '../Squarle_Entrance/widgets/squarle_notice_dialog.dart';
import '../Thread/thread_screen.dart';
import '../drawing/drawing.dart';
import 'models/chat_message.dart';
import 'models/chat_thread_detail.dart';
import 'models/table_detail.dart';
import 'models/table_thread.dart';
import 'services/table_service.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/table_message_input.dart';
import 'widgets/table_thread_header.dart';

class TableScreen extends StatefulWidget {
  final String sessionId;
  final String tableId;
  final int? tableNumber;

  const TableScreen({
    super.key,
    required this.sessionId,
    required this.tableId,
    this.tableNumber,
  });

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  final TableService _tableService = TableService();
  final SocketService _socketService = SocketService();

  TableDetail? _tableDetail;
  TableThread? _selectedThread;
  ChatThreadDetail? _threadDetail;
  List<ChatMessage> _messages = const [];
  bool _isLoadingTable = true;
  bool _isLoadingThread = false;
  bool _isSending = false;

  StreamSubscription<RegroupEvent>? _regroupSub;
  StreamSubscription<RemovalEvent>? _removalSub;
  StreamSubscription<WarningEvent>? _warningSub;

  bool _isNavigatingAway = false;

  @override
  void initState() {
    super.initState();
    _setupSocket();
    _loadTable();
  }

  // ── Socket listeners ──────────────────────────────────────────────────

  void _setupSocket() {
    _socketService.joinSquarle(widget.sessionId);

    _regroupSub = _socketService.regroupStream.listen(_handleRegroup);
    _removalSub = _socketService.removalStream.listen(_handleRemoval);
    _warningSub = _socketService.warningStream.listen(_handleWarning);
  }

  void _handleRegroup(RegroupEvent event) {
    if (!mounted || _isNavigatingAway) return;

    _isNavigatingAway = true;

    // Dismiss keyboard first to avoid IME flash
    FocusManager.instance.primaryFocus?.unfocus();

    // Pop back to SquarleEntranceScreen with notification result.
    // The .then() callback on SquarleEntranceScreen's push() will read the
    // result and show the centered SquarleNoticeDialog.
    if (mounted) {
      Navigator.of(context).pop({
        'notificationMessage': event.message,
        'notificationTone': SquarleNoticeTone.green,
      });
    }
  }

  void _handleRemoval(RemovalEvent event) {
    if (!mounted || _isNavigatingAway) return;

    _isNavigatingAway = true;
    FocusManager.instance.primaryFocus?.unfocus();

    // Pop all the way back — SquarleEntranceScreen is not guaranteed to be
    // the immediate parent if the user navigated into ThreadScreen first.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  void _handleWarning(WarningEvent event) {
    if (!mounted || _isNavigatingAway) return;

    // Show the centered notice dialog directly on the TableScreen.
    _showCenteredNotice(
      event.message,
      SquarleNoticeTone.orange,
    );
  }

  // ── Centered notice dialog (reuses SquarleNoticeDialog) ───────────────

  void _showCenteredNotice(String message, SquarleNoticeTone tone) {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final px = size.width / 393;
    final py = size.height / 852;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => SquarleNoticeDialog(
        message: message,
        tone: tone,
        px: px,
        py: py,
      ),
    );
  }

  // ── Data loading ──────────────────────────────────────────────────────

  Future<void> _loadTable() async {
    if (_isNavigatingAway) return;
    setState(() => _isLoadingTable = true);

    try {
      final detail = await _tableService.getTable(
        widget.sessionId,
        widget.tableId,
      );
      if (!mounted || _isNavigatingAway) return;

      final firstThread = detail.threads.isNotEmpty
          ? detail.threads.first
          : null;
      setState(() {
        _tableDetail = detail;
        _selectedThread = firstThread;
        _isLoadingTable = false;
      });

      if (firstThread != null) {
        await _loadThread(firstThread);
      }
    } catch (error) {
      if (!mounted || _isNavigatingAway) return;
      setState(() => _isLoadingTable = false);
      _showError(error.toString());
    }
  }

  Future<void> _loadThread(TableThread thread) async {
    if (_isNavigatingAway) return;
    setState(() {
      _selectedThread = thread;
      _isLoadingThread = true;
    });

    try {
      final detail = await _tableService.getThread(thread.threadId);
      if (!mounted || _isNavigatingAway) return;
      setState(() {
        _threadDetail = detail;
        _messages = detail.messages;
        _isLoadingThread = false;
      });
    } catch (error) {
      if (!mounted || _isNavigatingAway) return;
      setState(() => _isLoadingThread = false);
      _showError(error.toString());
    }
  }

  Future<void> _openThreadPanel() async {
    final detail = _tableDetail;
    if (detail == null) return;

    final selected = await Navigator.push<TableThread>(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadScreen(
          threads: detail.threads,
          tableId: widget.tableId,
          tableService: _tableService,
          currentUserId: _tableService.currentUserId,
          canParticipate: detail.canParticipate,
          selectedThreadId: _selectedThread?.threadId,
        ),
      ),
    );

    if (selected == null) {
      await _loadTable();
      return;
    }

    final existingIndex = detail.threads.indexWhere(
      (thread) => thread.threadId == selected.threadId,
    );
    final updatedThreads = existingIndex == -1
        ? [selected, ...detail.threads]
        : [
            for (final thread in detail.threads)
              thread.threadId == selected.threadId ? selected : thread,
          ];

    setState(() {
      _tableDetail = detail.copyWith(threads: updatedThreads);
      if (_selectedThread?.threadId == selected.threadId) {
        _selectedThread = selected;
      }
    });

    if (selected.threadId != _selectedThread?.threadId) {
      await _loadThread(selected);
    }
  }

  Future<void> _sendMessage(String content) async {
    final thread = _selectedThread;
    if (thread == null || _isSending) return;

    setState(() => _isSending = true);

    try {
      final message = await _tableService.sendTextMessage(
        thread.threadId,
        content,
      );
      if (!mounted) return;
      setState(() {
        _messages = [..._messages, message];
        _isSending = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSending = false);
      _showError(error.toString());
    }
  }

  Future<void> _openDrawing() async {
    if (!_canSend || _isSending) return;

    final drawingBytes = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (context) => const DrawingScreen()),
    );

    if (drawingBytes == null || drawingBytes.isEmpty) return;
    await _sendDrawing(drawingBytes);
  }

  Future<void> _sendDrawing(Uint8List imageBytes) async {
    final thread = _selectedThread;
    if (thread == null || _isSending) return;

    setState(() => _isSending = true);

    try {
      final message = await _tableService.sendWhiteboardMessage(
        thread.threadId,
        imageBytes,
      );
      if (!mounted) return;
      setState(() {
        _messages = [..._messages, message];
        _isSending = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSending = false);
      _showError(error.toString());
    }
  }

  void _showError(String message) {
    // Suppress errors after we've already decided to navigate away.
    if (_isNavigatingAway) return;
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool get _canSend {
    final tableCanParticipate = _tableDetail?.canParticipate == true;
    final threadCanParticipate =
        _threadDetail?.canParticipate ?? tableCanParticipate;
    return _selectedThread != null &&
        tableCanParticipate &&
        threadCanParticipate &&
        _tableDetail?.quietHours != true;
  }

  @override
  void dispose() {
    _regroupSub?.cancel();
    _removalSub?.cancel();
    _warningSub?.cancel();
    _socketService.leaveSquarle(widget.sessionId);
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
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 0 * px, top: 0 * py),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: Icon(Icons.arrow_back_ios_new, size: 24 * px),
                  color: const Color(0xFF222222),
                  tooltip: 'Back',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16 * px, 0 * py, 16 * px, 0),
              child: _isLoadingTable
                  ? Container(
                      height: 56 * py,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: Color(0xFF2A9DF4),
                      ),
                    )
                  : TableThreadHeader(
                      thread: _selectedThread,
                      starterMessage: _threadDetail?.thread?.starterMessage,
                      currentUserId: _tableService.currentUserId,
                      px: px,
                      py: py,
                      onTap: _openThreadPanel,
                    ),
            ),
            if (_tableDetail?.quietHours == true)
              Padding(
                padding: EdgeInsets.only(top: 8 * py),
                child: Text(
                  'Quiet hours are active',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11 * px,
                    color: const Color(0xFF9B9B9B),
                  ),
                ),
              ),
            Expanded(
              child: _isLoadingTable
                  ? const SizedBox.shrink()
                  : ChatMessageList(
                      messages: _messages,
                      isLoading: _isLoadingThread,
                      starterMessage: _threadDetail?.thread?.starterMessage,
                      px: px,
                      py: py,
                    ),
            ),
            if (_canSend)
              TableMessageInput(
                enabled: true,
                isSending: _isSending,
                px: px,
                py: py,
                onSend: _sendMessage,
                onOpenDrawing: _openDrawing,
              ),
          ],
        ),
      ),
    );
  }
}
