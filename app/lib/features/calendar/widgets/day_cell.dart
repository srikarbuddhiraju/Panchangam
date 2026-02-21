import 'package:flutter/material.dart';
import '../../../core/calculations/panchangam_engine.dart';
import '../../../core/utils/app_strings.dart';
import '../../../app/theme.dart';

/// Single calendar day cell.
///
/// Shows: day number + moon icon (Purnima/Amavasya) + tithi + nakshatra
///        + festival name + Grahanam label when applicable.
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
    final bool isTelugu = S.isTelugu;
    final String tithiName = isTelugu ? data.tithiNameTe : data.tithiNameEn;
    final String nakshatraName =
        isTelugu ? data.nakshatraNameTe : data.nakshatraNameEn;

    // Moon phase icon
    final bool isPurnima = data.tithiNumber == 15;
    final bool isAmavasya = data.tithiNumber == 30;

    // First festival name (if any)
    final String? festivalName = data.isFestival
        ? (isTelugu
            ? data.festivalNamesTe.firstOrNull
            : data.festivalNamesEn.firstOrNull)
        : null;

    // Eclipse label
    final String? eclipseLabel =
        data.hasEclipse ? (isTelugu ? 'గ్రహణం' : 'Grahanam') : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: data.isFestival
              ? Border.all(color: AppTheme.kFestivalAmber, width: 1.5)
              : data.hasEclipse
                  ? Border.all(
                      color: AppTheme.kKumkum.withValues(alpha: 0.6),
                      width: 1.5)
                  : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 3),

            // Day number with today circle
            Container(
              width: 28,
              height: 28,
              decoration: isToday
                  ? const BoxDecoration(
                      color: AppTheme.kSaffron,
                      shape: BoxShape.circle,
                    )
                  : null,
              alignment: Alignment.center,
              child: Text(
                '${data.date.day}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Colors.white : null,
                ),
              ),
            ),

            // Moon phase icon (Purnima / Amavasya)
            if (isPurnima || isAmavasya)
              Text(
                isPurnima ? '🌕' : '🌑',
                style: const TextStyle(fontSize: 10, height: 1.1),
              ),

            const SizedBox(height: 1),

            // Tithi name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                tithiName,
                style: const TextStyle(fontSize: 9),
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
                style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),

            // Festival name (amber)
            if (festivalName != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  festivalName,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppTheme.kFestivalAmber,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),

            // Grahanam label (red)
            if (eclipseLabel != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  eclipseLabel,
                  style: TextStyle(
                    fontSize: 8,
                    color: AppTheme.kKumkum,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
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
