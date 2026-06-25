import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'controller/canvas_controller.dart';
import 'widgets/brush_controls.dart';
import 'widgets/canvas_view.dart';
import 'widgets/toolbar_controls.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  static const double _exportSize = 230;
  static const double _exportPadding = 12;

  late final CanvasController _controller;
  bool _isExporting = false;

  static const List<Color> _colors = <Color>[
    Color(0xFF202020),
    Color(0xFFE53935),
    Color(0xFFFFB300),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
  ];

  @override
  void initState() {
    super.initState();
    _controller = CanvasController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: CanvasView(controller: _controller)),
            Positioned(
              left: 16,
              top: 12,
              child: DrawingCircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _DrawingControls(
                controller: _controller,
                colors: _colors,
                isExporting: _isExporting,
                onSend: _sendDrawing,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendDrawing() async {
    if (_isExporting || !_controller.hasCompletedStrokes) {
      return;
    }

    setState(() => _isExporting = true);

    try {
      final bytes = await _exportDrawingBytes();

      if (!mounted) {
        return;
      }

      if (bytes == null || bytes.isEmpty) {
        setState(() => _isExporting = false);
        return;
      }

      Navigator.of(context).pop<Uint8List>(bytes);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to export drawing.')),
      );
    }
  }

  Future<Uint8List?> _exportDrawingBytes() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const outputSize = Size.square(_exportSize);
    final drawingBounds = _drawingBounds();

    canvas.drawRect(Offset.zero & outputSize, Paint()..color = Colors.white);

    if (drawingBounds == null) {
      final image = await recorder.endRecording().toImage(
        _exportSize.toInt(),
        _exportSize.toInt(),
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    }

    final drawableSize = _exportSize - (_exportPadding * 2);
    final boundsWidth = math.max(drawingBounds.width, 1.0);
    final boundsHeight = math.max(drawingBounds.height, 1.0);
    final scale = math.min(
      drawableSize / boundsWidth,
      drawableSize / boundsHeight,
    );
    final fittedWidth = drawingBounds.width * scale;
    final fittedHeight = drawingBounds.height * scale;
    final dx = (_exportSize - fittedWidth) / 2 - (drawingBounds.left * scale);
    final dy = (_exportSize - fittedHeight) / 2 - (drawingBounds.top * scale);

    canvas.saveLayer(Offset.zero & outputSize, Paint());
    canvas.translate(dx, dy);
    canvas.scale(scale);
    for (final stroke in _controller.completedStrokes) {
      canvas.drawPath(stroke.path, stroke.paint);
    }
    canvas.restore();

    final image = await recorder.endRecording().toImage(
      _exportSize.toInt(),
      _exportSize.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Rect? _drawingBounds() {
    Rect? bounds;

    for (final stroke in _controller.completedStrokes) {
      final strokeBounds = stroke.path.getBounds();
      if (strokeBounds.isEmpty) {
        continue;
      }

      final inflated = strokeBounds.inflate(stroke.strokeWidth / 2);
      bounds = bounds == null ? inflated : bounds.expandToInclude(inflated);
    }

    if (bounds == null || bounds.isEmpty) {
      return null;
    }

    return bounds;
  }
}

enum _OpenDrawingControl { none, pen, eraser }

class _DrawingControls extends StatefulWidget {
  const _DrawingControls({
    required this.controller,
    required this.colors,
    required this.isExporting,
    required this.onSend,
  });

  final CanvasController controller;
  final List<Color> colors;
  final bool isExporting;
  final VoidCallback onSend;

  @override
  State<_DrawingControls> createState() => _DrawingControlsState();
}

class _DrawingControlsState extends State<_DrawingControls> {
  _OpenDrawingControl _openControl = _OpenDrawingControl.none;

  void _showPenControls() {
    setState(() => _openControl = _OpenDrawingControl.pen);
  }

  void _showEraserControls() {
    setState(() => _openControl = _OpenDrawingControl.eraser);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: _openControl == _OpenDrawingControl.none
                  ? const SizedBox.shrink()
                  : Container(
                      key: ValueKey<_OpenDrawingControl>(_openControl),
                      margin: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: BrushControls(
                        controller: widget.controller,
                        colors: widget.colors,
                        showColors: _openControl == _OpenDrawingControl.pen,
                      ),
                    ),
            ),
            Container(
              height: 58,
              color: Colors.transparent,
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ToolbarControls(
                controller: widget.controller,
                isExporting: widget.isExporting,
                onSend: widget.onSend,
                onPenTap: _showPenControls,
                onEraserTap: _showEraserControls,
              ),
            ),
          ],
        );
      },
    );
  }
}
