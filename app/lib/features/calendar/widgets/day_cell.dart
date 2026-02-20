import 'package:flutter/material.dart';
import '../../../core/calculations/panchangam_engine.dart';
import '../../../core/utils/app_strings.dart';
import '../../../app/theme.dart';

/// Single calendar day cell.
///
/// Shows: Gregorian day number (large) + Tithi name (small) + Nakshatra (small).
/// Today: saffron circle. Festival days: gold border.
class DayCell extends StatelessWidget {
  final DayData data;
  final bool isToday;
  final VoidCallback onTap;

  const DayCell({
    super.key,
    required this.data,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFestival = data.isFestival;
    final String tithiName =
        S.isTelugu ? data.tithiNameTe : data.tithiNameEn;
    final String nakshatraName =
        S.isTelugu ? data.nakshatraNameTe : data.nakshatraNameEn;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isFestival
              ? Border.all(color: AppTheme.kFestivalAmber, width: 1.5)
              : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // Day number with today circle
            Container(
              width: 26,
              height: 26,
              decoration: isToday
                  ? BoxDecoration(
                      color: AppTheme.kSaffron,
                      shape: BoxShape.circle,
                    )
                  : null,
              alignment: Alignment.center,
              child: Text(
                '${data.date.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Colors.white : null,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Tithi name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                tithiName,
                style: const TextStyle(fontSize: 8),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            // Nakshatra name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                nakshatraName,
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            // Festival dot
            if (isFestival)
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(top: 2),
                decoration: const BoxDecoration(
                  color: AppTheme.kFestivalAmber,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Empty cell (for days before the 1st of the month).
class EmptyDayCell extends StatelessWidget {
  const EmptyDayCell({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
