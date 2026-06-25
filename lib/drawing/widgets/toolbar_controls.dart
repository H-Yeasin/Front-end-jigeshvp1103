import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controller/canvas_controller.dart';
import '../model/drawing_stroke.dart';

class ToolbarControls extends StatelessWidget {
  const ToolbarControls({
    super.key,
    required this.controller,
    required this.isExporting,
    required this.onSend,
  });

  final CanvasController controller;
  final bool isExporting;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final isEraser = controller.selectedMode == StrokeMode.erase;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            DrawingCircleIconButton(
              icon: Icons.undo_rounded,
              onPressed: controller.canUndo ? controller.undo : null,
            ),
            const SizedBox(width: 10),
            DrawingCircleIconButton(
              icon: Icons.redo_rounded,
              onPressed: controller.canRedo ? controller.redo : null,
            ),
          ],
        ),
        Row(
          children: <Widget>[
            _ToolButton(
              icon: Icons.edit_rounded,
              selected: !isEraser,
              onPressed: () => controller.setStrokeMode(StrokeMode.draw),
            ),
            const SizedBox(width: 12),
            _ToolButton(
              icon: Icons.cleaning_services_rounded,
              selected: isEraser,
              onPressed: controller.toggleEraser,
            ),
          ],
        ),
        _SendDrawingButton(
          enabled: controller.hasCompletedStrokes && !isExporting,
          isLoading: isExporting,
          onPressed: onSend,
        ),
      ],
    );
  }
}

class _SendDrawingButton extends StatelessWidget {
  const _SendDrawingButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : SvgPicture.asset(
              'assets/icons/send.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                enabled ? Colors.white : const Color(0xFFB8B8B8),
                BlendMode.srcIn,
              ),
            ),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(48),
        backgroundColor:
            enabled ? const Color(0xFF2A9DF4) : const Color(0xFFF7F7F7),
        disabledBackgroundColor: const Color(0xFFF7F7F7),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: selected ? Colors.white : const Color(0xFF202020),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(46),
        backgroundColor:
            selected ? const Color(0xFF202020) : const Color(0xFFF2F2F2),
      ),
    );
  }
}

class DrawingCircleIconButton extends StatelessWidget {
  const DrawingCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: const Color(0xFF202020),
      disabledColor: const Color(0xFFB8B8B8),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(48),
        backgroundColor: const Color(0xFFF2F2F2),
        disabledBackgroundColor: const Color(0xFFF7F7F7),
      ),
    );
  }
}
