import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/calculations/panchangam_engine.dart';
import '../../../core/utils/app_strings.dart';
import '../../../app/theme.dart';
import 'day_cell.dart';

/// Transposed calendar grid.
///
/// Rows  = days of the week (Sun → Sat), 7 rows.
/// Columns = weeks in the month (4–6 columns).
///
/// This gives roughly square cells on a portrait phone, unlike the traditional
/// 7-column layout where cells are very tall and narrow.
class CalendarGrid extends ConsumerWidget {
  final List<DayData> days;
  final DateTime month; // first day of the displayed month

  const CalendarGrid({
    super.key,
    required this.days,
    required this.month,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime today = DateTime.now();

    // 0 = Sunday, 1 = Monday, … 6 = Saturday  (weekday % 7 maps Dart's Mon=1…Sun=7)
    final int firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final int numWeeks = ((firstWeekday + days.length) / 7).ceil();

    // grid[dow][week] = DayData or null
    // dow  : 0=Sun … 6=Sat
    // week : 0 = first week of month
    final List<List<DayData?>> grid = List.generate(7, (dow) {
      return List.generate(numWeeks, (week) {
        final int dayIndex = week * 7 + dow - firstWeekday;
        if (dayIndex < 0 || dayIndex >= days.length) return null;
        return days[dayIndex];
      });
    });

    final List<String> dowLabels = S.weekdayHeaders; // Sun…Sat
    const double labelWidth = 36.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cellWidth =
            (constraints.maxWidth - labelWidth - 1) / numWeeks;
        final double cellHeight = constraints.maxHeight / 7;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Day-of-week label column ──────────────────────────────────
            SizedBox(
              width: labelWidth,
              child: Column(
                children: List.generate(7, (dow) {
                  final bool isWeekend = dow == 0 || dow == 6;
                  return SizedBox(
                    height: cellHeight,
                    child: Center(
                      child: Text(
                        dowLabels[dow],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isWeekend ? AppTheme.kKumkum : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Thin vertical divider separating labels from cells
            const VerticalDivider(width: 1, thickness: 0.5),

            // ── Week columns ─────────────────────────────────────────────
            Expanded(
              child: Column(
                children: List.generate(7, (dow) {
                  return SizedBox(
                    height: cellHeight,
                    child: Row(
                      children: List.generate(numWeeks, (week) {
                        final DayData? data = grid[dow][week];

                        // Empty slot (before day 1 or after last day)
                        if (data == null) {
                          return SizedBox(
                            width: cellWidth,
                            height: cellHeight,
                          );
                        }

                        final bool isToday =
                            data.date.year == today.year &&
                            data.date.month == today.month &&
                            data.date.day == today.day;

                        return SizedBox(
                          width: cellWidth,
                          height: cellHeight,
                          child: DayCell(
                            data: data,
                            isToday: isToday,
                            onTap: () {
                              final String dateStr =
                                  DateFormat('yyyy-MM-dd').format(data.date);
                              context.push('/panchangam/$dateStr');
                            },
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}
