import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/calculations/panchangam_engine.dart';
import '../../core/utils/app_strings.dart';
import '../../app/theme.dart';
import '../settings/settings_provider.dart';
import '../panchangam/panchangam_provider.dart';
import '../panchangam/widgets/five_limbs_card.dart';
import '../panchangam/widgets/timings_card.dart';
import '../panchangam/widgets/kalam_card.dart';
import '../panchangam/widgets/muhurtha_card.dart';
import '../panchangam/widgets/context_card.dart';
import '../eclipse/eclipse_provider.dart';
import '../eclipse/widgets/eclipse_card.dart';

/// The day currently shown in the Today tab (starts at today, navigable).
final todayTabDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Today tab: shows full Panchangam for a day with prev/next day navigation.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(todayTabDateProvider);
    final settings = ref.watch(settingsProvider);
    final asyncData = ref.watch(panchangamForDateProvider(date));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.today, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(settings.cityName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          _DayNavHeader(date: date),
          const Divider(height: 1),
          Expanded(
            child: asyncData.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (data) => _TodayContent(data: data, use24h: settings.use24h),
            ),
          ),
        ],
      ),
    );
  }
}

/// Day navigation row: ← date → with a tap-to-go-to-today gesture.
class _DayNavHeader extends ConsumerWidget {
  final DateTime date;

  const _DayNavHeader({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final bool isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    final String dateLabel = S.isTelugu
        ? DateFormat('d MMMM y', 'te').format(date)
        : DateFormat('EEE, d MMMM y').format(date);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(todayTabDateProvider.notifier).state =
                date.subtract(const Duration(days: 1)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: isToday
                  ? null
                  : () {
                      final d = DateTime.now();
                      ref.read(todayTabDateProvider.notifier).state =
                          DateTime(d.year, d.month, d.day);
                    },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.kSaffron,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isToday)
                    Text(
                      S.isTelugu ? 'నేటికి వెళ్ళు' : 'Tap to go to today',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.kSaffron,
                            decoration: TextDecoration.underline,
                          ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref.read(todayTabDateProvider.notifier).state =
                date.add(const Duration(days: 1)),
          ),
        ],
      ),
    );
  }
}

class _TodayContent extends ConsumerWidget {
  final PanchangamData data;
  final bool use24h;

  const _TodayContent({required this.data, required this.use24h});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eclipseAsync = ref.watch(eclipseForDateProvider(data.date));
    final eclipse = eclipseAsync.valueOrNull;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (eclipse != null) ...[
          EclipseCard(eclipse: eclipse),
          const SizedBox(height: 8),
        ],
        FiveLimbsCard(data: data, use24h: use24h),
        const SizedBox(height: 8),
        TimingsCard(data: data, use24h: use24h),
        const SizedBox(height: 8),
        KalamCard(data: data, use24h: use24h),
        const SizedBox(height: 8),
        MuhurthaCard(data: data, use24h: use24h),
        const SizedBox(height: 8),
        ContextCard(data: data),
        const SizedBox(height: 16),
      ],
    );
  }
}
