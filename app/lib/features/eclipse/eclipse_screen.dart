import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_strings.dart';
import 'eclipse_provider.dart';
import 'widgets/eclipse_card.dart';

class EclipseScreen extends ConsumerWidget {
  const EclipseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentYear = DateTime.now().year;
    final asyncEclipses = ref.watch(eclipseProvider(currentYear));

    return Scaffold(
      appBar: AppBar(
        title: Text(S.eclipse),
        actions: [
          // Year selector — next year
          TextButton(
            onPressed: () {}, // TODO: year picker
            child: Text('$currentYear'),
          ),
        ],
      ),
      body: asyncEclipses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (eclipses) {
          if (eclipses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 56, color: Colors.green),
                  const SizedBox(height: 12),
                  Text(
                    S.isTelugu
                        ? '$currentYear లో గ్రహణాలు లేవు'
                        : 'No eclipses in $currentYear',
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text(
                S.isTelugu
                    ? '$currentYear — ${eclipses.length} గ్రహణాలు'
                    : '$currentYear — ${eclipses.length} eclipse(s)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 8),
              ...eclipses.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: EclipseCard(eclipse: e),
                  )),
              const SizedBox(height: 12),
              Text(
                S.isTelugu
                    ? '* గ్రహణ సమయాలు అంచనా. ఖచ్చితమైన సమయాల కోసం సూర్యసిద్ధాంత లేదా స్విస్ ఎఫెమెరిస్ వినియోగించండి.'
                    : '* Eclipse times are approximate. For precise timings use Swiss Ephemeris.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ],
          );
        },
      ),
    );
  }
}
