import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Table/models/table_thread.dart';
import '../Table/services/table_service.dart';
import 'thread_create_screen.dart';
import 'widgets/new_thread_button.dart';
import 'widgets/thread_list_item.dart';

class ThreadScreen extends StatelessWidget {
  final List<TableThread> threads;
  final String? selectedThreadId;
  final String tableId;
  final String currentUserId;
  final TableService tableService;

  const ThreadScreen({
    super.key,
    required this.threads,
    required this.tableId,
    required this.tableService,
    this.selectedThreadId,
    this.currentUserId = '',
  });

  Future<void> _openCreateThread(BuildContext context) async {
    final thread = await Navigator.push<TableThread>(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadCreateScreen(
          tableId: tableId,
          tableService: tableService,
        ),
      ),
    );

    if (thread != null && context.mounted) {
      Navigator.pop(context, thread);
    }
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
            Column(
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
                SizedBox(height: 12 * py),
                Expanded(
                  child: threads.isEmpty
                      ? Center(
                          child: Text(
                            'No threads yet.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13 * px,
                              color: const Color(0xFF8F8F8F),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            22 * px,
                            0,
                            22 * px,
                            96 * py,
                          ),
                          itemCount: threads.length,
                          itemBuilder: (context, index) {
                            final thread = threads[index];
                            return ThreadListItem(
                              thread: thread,
                              selected: thread.threadId == selectedThreadId,
                              currentUserId: currentUserId,
                              px: px,
                              py: py,
                              onTap: () => Navigator.pop(context, thread),
                            );
                          },
                        ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 52 * py,
              child: Center(
                child: NewThreadButton(
                  px: px,
                  py: py,
                  onPressed: () => _openCreateThread(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
