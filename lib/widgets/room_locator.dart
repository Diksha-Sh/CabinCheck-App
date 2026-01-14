import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class RoomLocator extends StatelessWidget {
  final String roomInfo; // e.g. "Cabin 214"

  const RoomLocator({super.key, required this.roomInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: _FloorPlanPainter(roomNumber: _extractRoomNumber(roomInfo)),
            child: Container(),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.layers_outlined, size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text("Floor Map: $roomInfo", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _extractRoomNumber(String info) {
    // Basic extraction logic: find the first 3-digit number
    final match = RegExp(r'\d{3}').firstMatch(info);
    if (match != null) {
      return int.parse(match.group(0)!);
    }
    return 214; // Default if not found
  }
}

class _FloorPlanPainter extends CustomPainter {
  final int roomNumber;

  _FloorPlanPainter({required this.roomNumber});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final wallPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;

    const padding = 20.0;
    final w = size.width - (padding * 2);
    final h = size.height - (padding * 2);

    // Draw Main Corridor
    canvas.drawRect(Rect.fromLTWH(padding, padding + (h * 0.4), w, h * 0.2), wallPaint);
    canvas.drawRect(Rect.fromLTWH(padding, padding + (h * 0.4), w, h * 0.2), paint);

    // Draw Rooms (Top side)
    for (int i = 0; i < 4; i++) {
        final rx = padding + (i * w / 4);
        final rect = Rect.fromLTWH(rx, padding, w / 4, h * 0.4);
        
        bool isTarget = (211 + i) == roomNumber;
        
        if (isTarget) {
            canvas.drawRect(rect, Paint()..color = AppColors.primary.withOpacity(0.1));
            canvas.drawRect(rect, Paint()..color = AppColors.primary..style = PaintingStyle.stroke..strokeWidth = 3);
            
            // Draw marker
            final center = rect.center;
            canvas.drawCircle(center, 6, Paint()..color = AppColors.primary);
            canvas.drawCircle(center, 12, Paint()..color = AppColors.primary.withOpacity(0.2));
        } else {
            canvas.drawRect(rect, paint);
        }
        
        // Room numbers
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: "${211 + i}",
            style: TextStyle(color: isTarget ? AppColors.primary : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, rect.center - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    // Draw Rooms (Bottom side)
     for (int i = 0; i < 4; i++) {
        final rx = padding + (i * w / 4);
        final rect = Rect.fromLTWH(rx, padding + (h * 0.6), w / 4, h * 0.4);
        
        bool isTarget = (215 + i) == roomNumber;

        if (isTarget) {
            canvas.drawRect(rect, Paint()..color = AppColors.primary.withOpacity(0.1));
            canvas.drawRect(rect, Paint()..color = AppColors.primary..style = PaintingStyle.stroke..strokeWidth = 3);
            
            final center = rect.center;
            canvas.drawCircle(center, 6, Paint()..color = AppColors.primary);
        } else {
            canvas.drawRect(rect, paint);
        }

        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: "${215 + i}",
            style: TextStyle(color: isTarget ? AppColors.primary : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, rect.center - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
