import 'package:flutter/material.dart';

import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/models/gastromic_map_marker.dart';

/// Hafif harita önizlemesi — Google Maps platform view kullanmaz.
class MapPreviewPlaceholder extends StatelessWidget {
  const MapPreviewPlaceholder({
    super.key,
    this.markers = const [],
  });

  final List<GastromicMapMarker> markers;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.cPrimary.withValues(alpha: 0.15),
            context.cSecondary.withValues(alpha: 0.12),
            context.cBackground,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _GridPainter(
              color: context.cTextPrimary.withValues(alpha: 0.06),
            ),
          ),
          ..._markerPositions(markers.length).asMap().entries.map((entry) {
            final index = entry.key;
            final alignment = entry.value;
            final title = index < markers.length ? markers[index].title : '';
            return Align(
              alignment: alignment,
              child: Tooltip(
                message: title,
                child: Icon(
                  Icons.location_on,
                  size: 22,
                  color: context.cPrimary.withValues(alpha: 0.85),
                ),
              ),
            );
          }),
          Center(
            child: Icon(
              Icons.map_outlined,
              size: 48,
              color: context.cPrimary.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  List<Alignment> _markerPositions(int count) {
    const slots = [
      Alignment(-0.55, -0.35),
      Alignment(0.45, -0.15),
      Alignment(-0.2, 0.25),
      Alignment(0.6, 0.4),
      Alignment(-0.65, 0.45),
      Alignment(0.15, -0.5),
    ];
    if (count <= 0) return const [];
    return slots.take(count.clamp(1, slots.length)).toList();
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 36.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.color != color;
}
