import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/calculations/panchangam_engine.dart';
import '../../../core/utils/app_strings.dart';
import '../../../app/theme.dart';
import 'day_cell.dart';

/// 7-column grid showing all days of a month.
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
    final int firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    // firstWeekday: 0=Sunday, 1=Monday, ... 6=Saturday

    return Column(
      children: [
        // ── Weekday headers ───────────────────────────────────────────────
        _WeekdayHeader(),

        const Divider(height: 1, thickness: 0.5),

        // ── Day grid ──────────────────────────────────────────────────────
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.75,
            ),
            itemCount: firstWeekday + days.length,
            itemBuilder: (context, index) {
              if (index < firstWeekday) return const EmptyDayCell();

              final DayData data = days[index - firstWeekday];
              final bool isToday = data.date.year == today.year &&
                  data.date.month == today.month &&
                  data.date.day == today.day;

              return DayCell(
                data: data,
                isToday: isToday,
                onTap: () {
                  final String dateStr =
                      DateFormat('yyyy-MM-dd').format(data.date);
                  context.push('/panchangam/$dateStr');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> headers = S.weekdayHeaders;
    return Row(
      children: headers.map((h) {
        return Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                h,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: h == headers[0] || h == headers[6]
                      ? AppTheme.kKumkum // Sun/Sat in red
                      : null,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
