import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Table/models/table_thread.dart';
import '../Table/services/table_service.dart';

class ThreadCreateScreen extends StatefulWidget {
  final String tableId;
  final TableService tableService;

  const ThreadCreateScreen({
    super.key,
    required this.tableId,
    required this.tableService,
  });

  @override
  State<ThreadCreateScreen> createState() => _ThreadCreateScreenState();
}

class _ThreadCreateScreenState extends State<ThreadCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  bool _isCreating = false;

  bool get _canCreate =>
      _titleController.text.trim().isNotEmpty &&
      _questionController.text.trim().isNotEmpty &&
      !_isCreating;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_refresh);
    _questionController.addListener(_refresh);
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_refresh)
      ..dispose();
    _questionController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _createThread() async {
    if (!_canCreate) return;

    setState(() => _isCreating = true);

    try {
      final thread = await widget.tableService.createThread(
        tableId: widget.tableId,
        title: _titleController.text.trim(),
        starterMessage: _questionController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop<TableThread>(context, thread);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final double px = w / 393;
    final double py = h / 852;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 11 * px, top: 24 * py),
                  child: IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: Icon(Icons.arrow_back_ios_new, size: 24 * px),
                    color: const Color(0xFF222222),
                    tooltip: 'Back',
                  ),
                ),
                SizedBox(height: 20 * py),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22 * px),
                  child: Container(
                    height: 56 * py,
                    padding: EdgeInsets.symmetric(horizontal: 14 * px),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(28 * px),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30 * px,
                          height: 30 * px,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEDEDED),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.crop_square,
                            size: 17 * px,
                            color: const Color(0xFF8F8F8F),
                          ),
                        ),
                        SizedBox(width: 14 * px),
                        Expanded(
                          child: TextField(
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Title',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13 * px,
                                color: const Color(0xFF555555),
                              ),
                            ),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13 * px,
                              color: const Color(0xFF222222),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 79 * px,
                    right: 22 * px,
                    top: 18 * py,
                  ),
                  child: TextField(
                    controller: _questionController,
                    minLines: 1,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Open with a question',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13 * px,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13 * px,
                      height: 1.35,
                      color: const Color(0xFF222222),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: (bottomInset > 0 ? bottomInset + 44 * py : 72 * py),
              child: Center(
                child: GestureDetector(
                  onTap: _canCreate ? _createThread : null,
                  child: SizedBox(
                    width: 48 * px,
                    height: 48 * px,
                    child: _isCreating
                        ? const CircularProgressIndicator(
                            color: Color(0xFF8EC8FF),
                          )
                        : SvgPicture.asset(
                            _canCreate
                                ? 'assets/icons/send_glow.svg'
                                : 'assets/icons/send_faded.svg',
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
