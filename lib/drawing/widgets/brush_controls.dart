import 'package:flutter/material.dart';

import '../controller/canvas_controller.dart';
import '../model/drawing_stroke.dart';

class BrushControls extends StatelessWidget {
  const BrushControls({
    super.key,
    required this.controller,
    required this.colors,
    this.showColors = true,
  });

  final CanvasController controller;
  final List<Color> colors;
  final bool showColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showColors)
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final color = colors[index];
                final selected = controller.selectedMode == StrokeMode.draw &&
                    controller.selectedColor == color;

                return _ColorSwatch(
                  color: color,
                  selected: selected,
                  onTap: () => controller.setColor(color),
                );
              },
            ),
          ),
        Row(
          children: <Widget>[
            const Icon(
              Icons.line_weight_rounded,
              size: 20,
              color: Colors.white,
            ),
            Expanded(
              child: Slider(
                min: 2,
                max: 18,
                value: controller.selectedStrokeWidth,
                activeColor: Colors.white,
                inactiveColor: const Color(0xFF383838),
                onChanged: controller.setStrokeWidth,
              ),
            ),
            SizedBox(
              width: 32,
              child: Text(
                controller.selectedStrokeWidth.toStringAsFixed(0),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 34,
        height: 34,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
