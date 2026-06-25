import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../model/drawing_stroke.dart';

class CanvasController extends ChangeNotifier {
  static const int maxHistoryActions = 50;

  final List<DrawingStroke> _completedStrokes = <DrawingStroke>[];
  final List<DrawingStroke> _undoStack = <DrawingStroke>[];
  final List<DrawingStroke> _redoStack = <DrawingStroke>[];
  final ValueNotifier<int> _completedPaintRevision = ValueNotifier<int>(0);
  final ValueNotifier<int> _activePaintRevision = ValueNotifier<int>(0);

  DrawingStroke? _currentStroke;
  Color _selectedColor = const Color(0xFF202020);
  double _selectedStrokeWidth = 5;
  StrokeMode _selectedMode = StrokeMode.draw;
  Offset? _lastPoint;
  int? _lastSampleMicros;
  double? _baseStrokeWidth;

  UnmodifiableListView<DrawingStroke> get completedStrokes {
    return UnmodifiableListView<DrawingStroke>(_completedStrokes);
  }

  DrawingStroke? get currentStroke => _currentStroke;

  bool get isDrawing => _currentStroke != null;
  bool get hasCompletedStrokes => _completedStrokes.isNotEmpty;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  Listenable get completedPaintListenable => _completedPaintRevision;
  Listenable get activePaintListenable => _activePaintRevision;
  Color get selectedColor => _selectedColor;
  double get selectedStrokeWidth => _selectedStrokeWidth;
  StrokeMode get selectedMode => _selectedMode;

  void setColor(Color color) {
    if (_selectedColor == color) {
      return;
    }

    _selectedColor = color;
    _selectedMode = StrokeMode.draw;
    notifyListeners();
  }

  void setStrokeWidth(double strokeWidth) {
    if (_selectedStrokeWidth == strokeWidth) {
      return;
    }

    _selectedStrokeWidth = strokeWidth;
    notifyListeners();
  }

  void setStrokeMode(StrokeMode mode) {
    if (_selectedMode == mode) {
      return;
    }

    _selectedMode = mode;
    notifyListeners();
  }

  void toggleEraser() {
    setStrokeMode(
      _selectedMode == StrokeMode.erase ? StrokeMode.draw : StrokeMode.erase,
    );
  }

  void startStroke({
    required Offset point,
    required Color color,
    required double strokeWidth,
    StrokeMode mode = StrokeMode.draw,
  }) {
    final path = Path()..moveTo(point.dx, point.dy);

    _lastPoint = point;
    _lastSampleMicros = DateTime.now().microsecondsSinceEpoch;
    _baseStrokeWidth = strokeWidth;

    _currentStroke = DrawingStroke(
      path: path,
      color: color,
      strokeWidth: strokeWidth,
      mode: mode,
    );

    _notifyActivePaint();
    notifyListeners();
  }

  void updateStroke(Offset point) {
    final currentStroke = _currentStroke;
    if (currentStroke == null) {
      return;
    }

    final previousPoint = _lastPoint;
    if (previousPoint == null) {
      _lastPoint = point;
      _lastSampleMicros = DateTime.now().microsecondsSinceEpoch;
      return;
    }

    final nowMicros = DateTime.now().microsecondsSinceEpoch;
    final elapsedMicros = nowMicros - (_lastSampleMicros ?? nowMicros);
    final velocity = _velocityFor(
      previousPoint: previousPoint,
      currentPoint: point,
      elapsedMicros: elapsedMicros,
    );
    final smoothedWidth = _strokeWidthForVelocity(velocity);
    final smoothedPoint = Offset(
      (previousPoint.dx + point.dx) / 2,
      (previousPoint.dy + point.dy) / 2,
    );
    final path = currentStroke.path
      ..quadraticBezierTo(
        previousPoint.dx,
        previousPoint.dy,
        smoothedPoint.dx,
        smoothedPoint.dy,
      );

    _currentStroke = currentStroke.copyWith(
      path: path,
      strokeWidth: smoothedWidth,
    );
    _lastPoint = point;
    _lastSampleMicros = nowMicros;

    _notifyActivePaint();
  }

  void endStroke() {
    final currentStroke = _currentStroke;
    if (currentStroke == null) {
      return;
    }

    final finishedStroke = _finishStrokeAtLastPoint(currentStroke);

    _completedStrokes.add(finishedStroke);
    _pushHistory(_undoStack, finishedStroke);
    _redoStack.clear();
    _currentStroke = null;
    _resetCurrentStrokeTracking();

    _notifyCompletedPaint();
    _notifyActivePaint();
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isEmpty) {
      return;
    }

    final stroke = _undoStack.removeLast();
    _completedStrokes.remove(stroke);
    _pushHistory(_redoStack, stroke);
    _currentStroke = null;
    _resetCurrentStrokeTracking();

    _notifyCompletedPaint();
    _notifyActivePaint();
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) {
      return;
    }

    final stroke = _redoStack.removeLast();
    _completedStrokes.add(stroke);
    _pushHistory(_undoStack, stroke);
    _currentStroke = null;
    _resetCurrentStrokeTracking();

    _notifyCompletedPaint();
    _notifyActivePaint();
    notifyListeners();
  }

  void clear() {
    if (_completedStrokes.isEmpty &&
        _currentStroke == null &&
        _undoStack.isEmpty &&
        _redoStack.isEmpty) {
      return;
    }

    _completedStrokes.clear();
    _currentStroke = null;
    _resetCurrentStrokeTracking();
    _undoStack.clear();
    _redoStack.clear();

    _notifyCompletedPaint();
    _notifyActivePaint();
    notifyListeners();
  }

  void cancelCurrentStroke() {
    if (_currentStroke == null) {
      return;
    }

    _currentStroke = null;
    _resetCurrentStrokeTracking();
    _notifyActivePaint();
    notifyListeners();
  }

  @override
  void dispose() {
    _completedPaintRevision.dispose();
    _activePaintRevision.dispose();
    super.dispose();
  }

  void _pushHistory(List<DrawingStroke> stack, DrawingStroke stroke) {
    stack.add(stroke);
    if (stack.length > maxHistoryActions) {
      stack.removeAt(0);
    }
  }

  void _notifyCompletedPaint() {
    _completedPaintRevision.value++;
  }

  void _notifyActivePaint() {
    _activePaintRevision.value++;
  }

  double _velocityFor({
    required Offset previousPoint,
    required Offset currentPoint,
    required int elapsedMicros,
  }) {
    if (elapsedMicros <= 0) {
      return 0;
    }

    final distance = (currentPoint - previousPoint).distance;
    return distance / (elapsedMicros / 1000);
  }

  double _strokeWidthForVelocity(double velocity) {
    final baseStrokeWidth = _baseStrokeWidth ?? _currentStroke?.strokeWidth ?? 1;
    final widthScale = (1 - (velocity * 0.025)).clamp(0.65, 1.0);
    return baseStrokeWidth * widthScale;
  }

  void _resetCurrentStrokeTracking() {
    _lastPoint = null;
    _lastSampleMicros = null;
    _baseStrokeWidth = null;
  }

  DrawingStroke _finishStrokeAtLastPoint(DrawingStroke stroke) {
    final lastPoint = _lastPoint;
    if (lastPoint == null) {
      return stroke;
    }

    final path = stroke.path..lineTo(lastPoint.dx, lastPoint.dy);
    return stroke.copyWith(path: path);
  }
}
