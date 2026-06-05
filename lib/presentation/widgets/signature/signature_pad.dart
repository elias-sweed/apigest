import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SignaturePad extends StatefulWidget {
  final ValueChanged<Uint8List?>? onChanged;

  const SignaturePad({super.key, this.onChanged});

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final List<Offset?> _points = [];

  bool get hasSignature => _points.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RepaintBoundary(
          child: _SignatureCanvas(points: _points),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.refresh),
              label: const Text('Rehacer'),
            ),
          ],
        ),
      ],
    );
  }

  void _clear() {
    _points.clear();
    setState(() {});
    widget.onChanged?.call(null);
  }

  Future<Uint8List?> capturePng() async {
    if (_points.isEmpty) return null;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(480, 200);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
    final painter = _SignaturePainter(_points);
    painter.paint(canvas, size);
    final picture = recorder.endRecording();
    final img = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}

class _SignatureCanvas extends StatefulWidget {
  final List<Offset?> points;

  const _SignatureCanvas({required this.points});

  @override
  State<_SignatureCanvas> createState() => _SignatureCanvasState();
}

class _SignatureCanvasState extends State<_SignatureCanvas> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: GestureDetector(
          onPanStart: (d) =>
              setState(() => widget.points.add(d.localPosition)),
          onPanUpdate: (d) =>
              setState(() => widget.points.add(d.localPosition)),
          onPanEnd: (_) => setState(() => widget.points.add(null)),
          child: CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _SignaturePainter(widget.points),
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: 'Firma aquí',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 20),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2),
      );
      return;
    }

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
