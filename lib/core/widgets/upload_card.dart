import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import 'dart:ui' as ui;

class UploadCard extends StatelessWidget {
  final String title;
  final String caption;
  final VoidCallback onTap;
  final String? selectedFileName;
  final IconData icon;

  const UploadCard({
    super.key,
    required this.title,
    required this.caption,
    required this.onTap,
    this.selectedFileName,
    this.icon = Icons.cloud_upload_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRectPainter(color: Colors.grey.shade400),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.grey.shade500),
              const SizedBox(height: 12),
              Text(
                selectedFileName ?? title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: selectedFileName != null ? FontWeight.bold : FontWeight.w500,
                  color: selectedFileName != null ? AppColors.navyBlue : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              if (selectedFileName == null) ...[
                const SizedBox(height: 4),
                Text(
                  caption,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;

  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));

    final dashPath = Path();
    const dashWidth = 6.0;
    const dashSpace = 6.0;
    var distance = 0.0;

    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
