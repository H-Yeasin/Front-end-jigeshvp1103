import 'dart:ui';

enum StrokeMode { draw, erase }

class DrawingStroke {
  DrawingStroke({
    required Path path,
    required this.color,
    required this.strokeWidth,
    this.mode = StrokeMode.draw,
  }) : _path = Path.from(path);

  final Path _path;
  final Color color;
  final double strokeWidth;
  final StrokeMode mode;

  Path get path => Path.from(_path);

  Paint get paint {
    return Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color
      ..blendMode = mode == StrokeMode.erase ? BlendMode.clear : BlendMode.srcOver;
  }

  DrawingStroke copyWith({
    Path? path,
    Color? color,
    double? strokeWidth,
    StrokeMode? mode,
  }) {
    return DrawingStroke(
      path: path ?? _path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      mode: mode ?? this.mode,
    );
  }
}
