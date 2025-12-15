// lib/features/home/widgets/date_time_card.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 날짜 & 시간 카드 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 현재 날짜 표시 + 아날로그 시계
/// ═══════════════════════════════════════════════════════════════════════════

class DateTimeCard extends StatelessWidget {
  const DateTimeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Row(
        children: [
          // 날짜 표시
          Expanded(flex: 3, child: _buildDateSection(now)),
          // 아날로그 시계
          Expanded(flex: 2, child: _buildClockSection()),
        ],
      ),
    );
  }

  Widget _buildDateSection(DateTime now) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 월
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: AppDecorations.accentBadge(
                AppColors.accentBlue,
                borderRadius: AppSizes.radiusM,
              ),
              child: Text(
                '${now.month.toString().padLeft(2, '0')}',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.accentBlue,
                ),
              ),
            ),
            // 일
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSizes.paddingS,
                left: AppSizes.spaceXS,
              ),
              child: Text(
                '/${now.day.toString().padLeft(2, '0')}',
                style: AppTextStyles.heading1.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceS),
        // 요일
        Text(AppStrings.getWeekday(now.weekday), style: AppTextStyles.labelM),
      ],
    );
  }

  Widget _buildClockSection() {
    return NeumorphicContainer(
      width: 100,
      height: 100,
      borderRadius: 50,
      child: CustomPaint(painter: _ClockPainter(), size: const Size(100, 100)),
    );
  }
}

/// 아날로그 시계 페인터
class _ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final now = DateTime.now();

    // 시침
    final hourAngle =
        (now.hour % 12 + now.minute / 60) * 30 * 3.14159 / 180 - 3.14159 / 2;
    final hourHand = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.5 * _cos(hourAngle),
        center.dy + radius * 0.5 * _sin(hourAngle),
      ),
      hourHand,
    );

    // 분침
    final minuteAngle = now.minute * 6 * 3.14159 / 180 - 3.14159 / 2;
    final minuteHand = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.7 * _cos(minuteAngle),
        center.dy + radius * 0.7 * _sin(minuteAngle),
      ),
      minuteHand,
    );

    // 중앙 점
    final centerDot = Paint()
      ..color = AppColors.accentBlue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerDot);

    // 시간 마커 (12, 3, 6, 9)
    _drawTimeMarkers(canvas, center, radius);
  }

  void _drawTimeMarkers(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final markers = [
      {'text': '12', 'angle': -90.0},
      {'text': '3', 'angle': 0.0},
      {'text': '6', 'angle': 90.0},
      {'text': '9', 'angle': 180.0},
    ];

    for (var marker in markers) {
      final angle = marker['angle'] as double;
      final text = marker['text'] as String;
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      final radians = angle * 3.14159 / 180;
      final offset = Offset(
        center.dx + radius * 0.85 * _cos(radians) - textPainter.width / 2,
        center.dy + radius * 0.85 * _sin(radians) - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  double _cos(double radians) {
    double result = 1;
    double term = 1;
    for (int i = 1; i <= 10; i++) {
      term *= -radians * radians / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _sin(double radians) {
    double result = radians;
    double term = radians;
    for (int i = 1; i <= 10; i++) {
      term *= -radians * radians / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
