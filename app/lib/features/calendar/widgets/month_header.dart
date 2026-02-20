import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/calculations/telugu_calendar.dart';
import '../../../core/calculations/julian_day.dart';
import '../../../core/utils/app_strings.dart';
import '../../../app/theme.dart';
import '../calendar_provider.dart';

/// Month navigation header: Telugu month + Samvatsara, prev/next arrows, today button.
class MonthHeader extends ConsumerWidget {
  const MonthHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayed = ref.watch(displayedMonthProvider);
    final int shakaYr = TeluguCalendar.shakaYear(displayed);

    // Get Telugu month name from the middle of the month (15th)
    final double jdMid = JulianDay.fromDateTime(
      displayed.year, displayed.month, 15, 6, 0, 0,
    );
    final int monthNum = TeluguCalendar.monthNumber(jdMid);
    final String teluguMonthTe =
        TeluguCalendar.monthNamesTe[monthNum - 1];
    final String samvatsara = TeluguCalendar.samvatsaraTe(shakaYr);

    final String gregorianLabel =
        DateFormat('MMMM yyyy').format(displayed);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Previous month
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(displayedMonthProvider.notifier).state = DateTime(
                displayed.year,
                displayed.month - 1,
              );
            },
          ),

          // Month title
          Expanded(
            child: Column(
              children: [
                Text(
                  S.isTelugu
                      ? '$teluguMonthTe — $samvatsara'
                      : gregorianLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.kSaffron,
                      ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  S.isTelugu ? gregorianLabel : '$teluguMonthTe · $samvatsara',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Next month
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(displayedMonthProvider.notifier).state = DateTime(
                displayed.year,
                displayed.month + 1,
              );
            },
          ),
        ],
      ),
    );
  }
}
