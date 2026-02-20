import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/app_strings.dart';
import '../../app/theme.dart';
import '../settings/settings_provider.dart';
import 'panchangam_provider.dart';
import 'widgets/five_limbs_card.dart';
import 'widgets/timings_card.dart';
import 'widgets/kalam_card.dart';
import 'widgets/muhurtha_card.dart';
import 'widgets/context_card.dart';

/// Full-screen Panchangam detail view for a single date.
class PanchangamScreen extends ConsumerWidget {
  final DateTime date;

  const PanchangamScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(panchangamForDateProvider(date));
    final settings = ref.watch(settingsProvider);

    final String dateLabel = S.isTelugu
        ? DateFormat('d MMMM y', 'te').format(date)
        : DateFormat('d MMMM y').format(date);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateLabel, style: const TextStyle(fontSize: 15)),
            Text(
              settings.cityName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: share Panchangam as text/image
            },
          ),
        ],
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Calculation error: $e'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(panchangamForDateProvider(date)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => _PanchangamContent(
          data: data,
          use24h: settings.use24h,
        ),
      ),
    );
  }
}

class _PanchangamContent extends StatelessWidget {
  final dynamic data; // PanchangamData
  final bool use24h;

  const _PanchangamContent({required this.data, required this.use24h});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // ── Date header ───────────────────────────────────────────────────
        _DateHeader(data: data, use24h: use24h),
        const SizedBox(height: 12),

        // ── Five limbs ────────────────────────────────────────────────────
        FiveLimbsCard(data: data, use24h: use24h),
        const SizedBox(height: 8),

        // ── Daily timings ─────────────────────────────────────────────────
        TimingsCard(data: data, use24h: use24h),
        const SizedBox(height: 8),

        // ── Kalam ─────────────────────────────────────────────────────────
        KalamCard(data: data, use24h: use24h),
        const SizedBox(height: 8),

        // ── Muhurthas ─────────────────────────────────────────────────────
        MuhurthaCard(data: data, use24h: use24h),
        const SizedBox(height: 8),

        // ── Calendar context ──────────────────────────────────────────────
        ContextCard(data: data),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DateHeader extends StatelessWidget {
  final dynamic data;
  final bool use24h;

  const _DateHeader({required this.data, required this.use24h});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.kSaffron.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.kSaffron.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.isTelugu ? data.varaNameTe : data.varaNameEn,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.kSaffron,
                      ),
                ),
                Text(
                  S.isTelugu
                      ? '${data.pakshaTe} · ${data.tithiNameTe}'
                      : '${data.paksha} Paksha · ${data.tithiNameEn}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                S.isTelugu ? data.teluguMonthTe : data.teluguMonthEn,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                S.isTelugu ? data.samvatsaraTe : data.samvatsaraEn,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
