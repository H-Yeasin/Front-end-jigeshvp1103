import 'package:flutter/material.dart';

import '../models/squarle_table.dart';
import 'squarle_table_icon.dart';

class SquarleTableField extends StatefulWidget {
  final List<SquarleTable> tables;
  final int? assignedTableNumber;
  final double px;
  final double py;
  final ValueChanged<SquarleTable> onAssignedTableTap;

  const SquarleTableField({
    super.key,
    required this.tables,
    required this.assignedTableNumber,
    required this.px,
    required this.py,
    required this.onAssignedTableTap,
  });

  @override
  State<SquarleTableField> createState() => _SquarleTableFieldState();
}

class _SquarleTableFieldState extends State<SquarleTableField> {
  late final ScrollController _scrollController;
  bool _showTopBlur = false;
  bool _showBottomBlur = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_syncBlurState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncBlurState();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_syncBlurState);
    _scrollController.dispose();
    super.dispose();
  }

  void _syncBlurState() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final nextShowTopBlur = position.pixels > 4;
    final nextShowBottomBlur =
        position.pixels < position.maxScrollExtent - 4;

    if (nextShowTopBlur == _showTopBlur &&
        nextShowBottomBlur == _showBottomBlur) {
      return;
    }

    setState(() {
      _showTopBlur = nextShowTopBlur;
      _showBottomBlur = nextShowBottomBlur;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tableMap = {
      for (final table in widget.tables) table.tableNumber: table,
    };
    final px = widget.px;
    final py = widget.py;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _TableViewSection(
                start: 1,
                end: 13,
                tableMap: tableMap,
                assignedTableNumber: widget.assignedTableNumber,
                px: px,
                py: py,
                onAssignedTableTap: widget.onAssignedTableTap,
              ),
              _TableViewSection(
                start: 10,
                end: 22,
                tableMap: tableMap,
                assignedTableNumber: widget.assignedTableNumber,
                px: px,
                py: py,
                onAssignedTableTap: widget.onAssignedTableTap,
              ),
              _TableViewSection(
                start: 19,
                end: 31,
                tableMap: tableMap,
                assignedTableNumber: widget.assignedTableNumber,
                px: px,
                py: py,
                onAssignedTableTap: widget.onAssignedTableTap,
              ),
              _TableViewSection(
                start: 28,
                end: 40,
                tableMap: tableMap,
                assignedTableNumber: widget.assignedTableNumber,
                px: px,
                py: py,
                onAssignedTableTap: widget.onAssignedTableTap,
              ),
              SizedBox(height: 116 * py),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 76 * py,
          child: AnimatedOpacity(
            opacity: _showTopBlur ? 1 : 0,
            duration: const Duration(milliseconds: 160),
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 130 * py,
          child: AnimatedOpacity(
            opacity: _showBottomBlur ? 1 : 0,
            duration: const Duration(milliseconds: 160),
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TableViewSection extends StatelessWidget {
  final int start;
  final int end;
  final Map<int, SquarleTable> tableMap;
  final int? assignedTableNumber;
  final double px;
  final double py;
  final ValueChanged<SquarleTable> onAssignedTableTap;

  const _TableViewSection({
    required this.start,
    required this.end,
    required this.tableMap,
    required this.assignedTableNumber,
    required this.px,
    required this.py,
    required this.onAssignedTableTap,
  });

  static const _positions = <Offset>[
    Offset(168, 16),
    Offset(38, 94),
    Offset(298, 94),
    Offset(168, 166),
    Offset(38, 244),
    Offset(298, 244),
    Offset(168, 316),
    Offset(38, 394),
    Offset(298, 394),
    Offset(168, 466),
    Offset(38, 544),
    Offset(298, 544),
    Offset(168, 616),
  ];

  @override
  Widget build(BuildContext context) {
    final tableNumbers = List.generate(end - start + 1, (index) => start + index);

    return SizedBox(
      width: double.infinity,
      height: 704 * py,
      child: Stack(
        children: [
          for (var i = 0; i < tableNumbers.length; i++)
            Positioned(
              left: _positions[i].dx * px,
              top: _positions[i].dy * py,
              child: Builder(
                builder: (context) {
                  final tableNumber = tableNumbers[i];
                  final table = tableMap[tableNumber] ??
                      SquarleTable(
                        id: 'table_$tableNumber',
                        tableNumber: tableNumber,
                        occupancy: 0,
                      );

                  return SquarleTableIcon(
                    table: table,
                    isAssigned: tableNumber == assignedTableNumber,
                    px: px,
                    onTap: () => onAssignedTableTap(table),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
