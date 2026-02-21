import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_strings.dart';
import '../../shared/widgets/language_toggle.dart';
import '../../features/settings/settings_provider.dart';
import 'calendar_provider.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/month_header.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late PageController _pageController;
  static const int _initialPage = 1000; // large offset for infinite scroll feel

  DateTime _pageToMonth(int page) {
    final DateTime now = DateTime.now();
    final int delta = page - _initialPage;
    final int totalMonths = now.year * 12 + now.month - 1 + delta;
    return DateTime(totalMonths ~/ 12, totalMonths % 12 + 1);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.calendar),
        actions: [
          // Today button
          TextButton(
            onPressed: () {
              ref.read(displayedMonthProvider.notifier).state = DateTime.now();
              _pageController.animateToPage(
                _initialPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Text(S.today),
          ),
          // City indicator
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                settings.cityName,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const LanguageToggle(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const MonthHeader(),
          const Divider(height: 1),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                ref.read(displayedMonthProvider.notifier).state =
                    _pageToMonth(page);
              },
              itemBuilder: (context, page) {
                final DateTime month = _pageToMonth(page);
                return _MonthPage(month: month);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthPage extends ConsumerWidget {
  final DateTime month;

  const _MonthPage({required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(
      monthDataProvider((year: month.year, month: month.month)),
    );

    return asyncData.when(
      skipLoadingOnReload: true,
      data: (days) => CalendarGrid(days: days, month: month),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error: $e'),
          ],
        ),
      ),
    );
  }
}
