import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../core/utils/app_strings.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/premium/premium_guard.dart';
import '../events/user_tithi_event.dart';
import '../events/user_event_calculator.dart';
import '../events/user_event_provider.dart';
import '../events/widgets/personal_events_card.dart';
import '../settings/settings_provider.dart';
import 'panchangam_provider.dart';
import 'widgets/five_limbs_card.dart';
import 'widgets/timings_card.dart';
import 'widgets/kalam_card.dart';
import 'widgets/muhurtha_card.dart';
import 'widgets/context_card.dart';
import '../../core/calculations/panchangam_engine.dart';
import '../eclipse/eclipse_provider.dart';
import '../eclipse/widgets/eclipse_card.dart';
import '../festivals/festival_provider.dart';
import 'widgets/festival_card.dart';
import 'widgets/date_header_card.dart';

/// Full-screen Panchangam detail view for a single date.
class PanchangamScreen extends ConsumerWidget {
  final DateTime date;

  const PanchangamScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(panchangamForDateProvider(date));
    final settings = ref.watch(settingsProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

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
      // "Mark this tithi" FAB — visible to all users when data is loaded.
      // Tapping redirects based on auth + pro state.
      floatingActionButton: asyncData.valueOrNull != null
          ? FloatingActionButton.extended(
              onPressed: () => _onMarkThisTithi(
                context,
                tithiNumber: asyncData.valueOrNull!.tithiNumber,
                user: user,
                isPremium: settings.isPremium,
              ),
              backgroundColor: settings.isPremium
                  ? AppTheme.kGold
                  : AppTheme.kGold.withValues(alpha: 0.55),
              foregroundColor: Colors.white,
              icon: Icon(
                settings.isPremium
                    ? Icons.bookmark_add_outlined
                    : Icons.lock_outline_rounded,
              ),
              label: Text(S.isTelugu ? 'ఈ తిథి గుర్తించు' : 'Mark this tithi'),
            )
          : null,
    );
  }

  void _onMarkThisTithi(
    BuildContext context, {
    required int tithiNumber,
    required Object? user,
    required bool isPremium,
  }) {
    // Not signed in → show login sheet
    if (user == null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _BottomSheet(
          height: 0.6,
          child: LoginScreen(onSuccess: () => Navigator.of(context).pop()),
        ),
      );
      return;
    }

    // Signed in but not Pro → show Pro teaser
    if (!isPremium) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _BottomSheet(
          height: 0.65,
          child: PremiumTeaser(),
        ),
      );
      return;
    }

    // Pro user → show action picker
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MarkTithiSheet(
        tithiNumber: tithiNumber,
        parentContext: context,
      ),
    );
  }
}

// ── Bottom-sheet wrapper ───────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  final double height; // fraction of screen height
  final Widget child;

  const _BottomSheet({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * height,
        child: child,
      ),
    );
  }
}

// ── Action picker for Pro users ────────────────────────────────────────────────

class _MarkTithiSheet extends StatelessWidget {
  final int tithiNumber;
  final BuildContext parentContext; // used for navigation after sheet closes

  const _MarkTithiSheet({
    required this.tithiNumber,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        color: cs.surface,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  S.isTelugu ? 'ఈ తిథిని గుర్తించు' : 'Mark this Tithi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(height: 1),

              // Event option
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.kGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bookmark_add_outlined,
                      color: AppTheme.kGold),
                ),
                title: Text(S.isTelugu ? 'ఈవెంట్' : 'Event'),
                subtitle: Text(
                  S.isTelugu
                      ? 'పుట్టినరోజు, పండుగ లేదా సంప్రదాయాన్ని గుర్తు పెట్టుకోండి'
                      : 'Birthday, festival, or family tradition',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  parentContext.push('/events/new?tithi=$tithiNumber');
                },
              ),

              // To-Do option
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.kGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.checklist_rounded,
                      color: AppTheme.kGold),
                ),
                title: Text(S.isTelugu ? 'చేయవలసినవి' : 'To-Do'),
                subtitle: Text(
                  S.isTelugu
                      ? 'ఈ తిథికి చెకిస్ట్ లేదా పని జాబితా'
                      : 'Checklist or task list for this tithi',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  parentContext.push('/todos/new?tithi=$tithiNumber');
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PanchangamContent extends ConsumerWidget {
  final PanchangamData data;
  final bool use24h;

  const _PanchangamContent({required this.data, required this.use24h});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eclipse = ref.watch(eclipseForDateProvider(data.date)).valueOrNull;
    final festivals = ref.watch(festivalsForDateProvider(data.date));

    // Personal events: only for Pro users
    final isPremium = ref.watch(settingsProvider).isPremium;
    final allUserEvents =
        isPremium ? ref.watch(userEventProvider) : <UserTithiEvent>[];
    final personalEvents = UserEventCalculator.matchingEvents(
      events: allUserEvents,
      tithi: data.tithiNumber,
      teluguMonth: data.teluguMonthNumber,
      isAdhikaMaasa: data.isAdhikaMaasa,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88), // bottom padding for FAB
      children: [
        // ── Date header ───────────────────────────────────────────────────
        DateHeaderCard(data: data),
        const SizedBox(height: 12),

        // ── Eclipse alert (shown only on eclipse days) ────────────────────
        if (eclipse != null) ...[
          EclipseCard(eclipse: eclipse, use24h: use24h),
          const SizedBox(height: 8),
        ],

        // ── Festivals (shown only on festival days) ───────────────────────
        if (festivals.isNotEmpty) ...[
          FestivalCard(festivals: festivals),
          const SizedBox(height: 8),
        ],

        // ── Personal events (Pro users only) ─────────────────────────────
        if (personalEvents.isNotEmpty) ...[
          PersonalEventsCard(events: personalEvents),
          const SizedBox(height: 8),
        ],

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
