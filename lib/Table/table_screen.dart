import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Thread/thread_screen.dart';
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
  TableDetail? _tableDetail;
  TableThread? _selectedThread;
  ChatThreadDetail? _threadDetail;
  List<ChatMessage> _messages = const [];
  bool _isLoadingTable = true;
  bool _isLoadingThread = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadTable();
  }

  Future<void> _loadTable() async {
    setState(() => _isLoadingTable = true);

    try {
      final detail = await _tableService.getTable(widget.sessionId, widget.tableId);
      if (!mounted) return;

      final firstThread = detail.threads.isNotEmpty ? detail.threads.first : null;
      setState(() {
        _tableDetail = detail;
        _selectedThread = firstThread;
        _isLoadingTable = false;
      });

      if (firstThread != null) {
        await _loadThread(firstThread);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingTable = false);
      _showError(error.toString());
    }
  }

  Future<void> _loadThread(TableThread thread) async {
    setState(() {
      _selectedThread = thread;
      _isLoadingThread = true;
    });

    try {
      final detail = await _tableService.getThread(thread.threadId);
      if (!mounted) return;
      setState(() {
        _threadDetail = detail;
        _messages = detail.messages;
        _isLoadingThread = false;
      });
    } catch (error) {
      if (!mounted) return;
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
          selectedThreadId: _selectedThread?.threadId,
        ),
      ),
    );

    if (selected == null) return;

    if (!detail.threads.any((thread) => thread.threadId == selected.threadId)) {
      setState(() {
        _tableDetail = detail.copyWith(threads: [selected, ...detail.threads]);
      });
    }

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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool get _canSend {
    final tableCanParticipate = _tableDetail?.canParticipate == true;
    final threadCanParticipate = _threadDetail?.canParticipate ?? tableCanParticipate;
    return _selectedThread != null &&
        tableCanParticipate &&
        threadCanParticipate &&
        _tableDetail?.quietHours != true;
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 11 * px, top: 24 * py),
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
              padding: EdgeInsets.fromLTRB(22 * px, 18 * py, 22 * px, 0),
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
            TableMessageInput(
              enabled: _canSend,
              isSending: _isSending,
              px: px,
              py: py,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
