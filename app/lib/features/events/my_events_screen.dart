import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/utils/app_strings.dart';
import '../../core/calculations/tithi.dart';
import '../../core/calculations/telugu_calendar.dart';
import 'user_tithi_event.dart';
import 'user_event_provider.dart';

/// Lists all personal tithi events; lets the user add, edit, toggle, and delete.
/// Shown in the Family tab when the user has Pro.
class MyEventsScreen extends ConsumerWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(userEventProvider);
    final isTelugu = S.isTelugu;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(isTelugu ? 'నా సందర్భాలు' : 'My Events'),
        centerTitle: true,
      ),
      body: events.isEmpty
          ? _EmptyState(isTelugu: isTelugu)
          : _EventList(events: events),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/events/new'),
        backgroundColor: AppTheme.kGold,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(isTelugu ? 'కొత్తది' : 'New Event'),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isTelugu;
  const _EmptyState({required this.isTelugu});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_add_outlined,
                size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: 20),
            Text(
              isTelugu ? 'ఇంకా సందర్భాలు లేవు' : 'No events yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isTelugu
                  ? 'గురువు పుట్టినరోజు, వర్ధంతి, కుటుంబ సందర్భాలను '
                      'జోడించండి — ఆ తిథి వచ్చినప్పుడు క్యాలెండర్‌లో కనిపిస్తాయి'
                  : 'Add birthdays, anniversaries, and family occasions — '
                      'they appear on the calendar each time that tithi comes around.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 80), // space for FAB
          ],
        ),
      ),
    );
  }
}

// ── Event list ─────────────────────────────────────────────────────────────────

class _EventList extends ConsumerWidget {
  final List<UserTithiEvent> events;
  const _EventList({required this.events});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Active first, then inactive
    final sorted = [
      ...events.where((e) => e.isActive),
      ...events.where((e) => !e.isActive),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // 96 for FAB
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _EventTile(event: sorted[i]),
    );
  }
}

class _EventTile extends ConsumerWidget {
  final UserTithiEvent event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isTelugu = S.isTelugu;
    final notifier = ref.read(userEventProvider.notifier);

    final String name =
        isTelugu && event.nameTe != null ? event.nameTe! : event.nameEn;
    final String tithiLabel = _tithiLabel(event.tithi, isTelugu);
    final String monthLabel = _monthLabel(event.teluguMonth, isTelugu);

    return Dismissible(
      key: ValueKey(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context, isTelugu),
      onDismissed: (_) => notifier.delete(event.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: event.isActive
                ? AppTheme.kGold.withValues(alpha: 0.35)
                : cs.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Color dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: event.isActive
                    ? AppTheme.kGold
                    : cs.onSurfaceVariant.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // Name + tithi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: event.isActive
                              ? null
                              : cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$tithiLabel · $monthLabel',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),

            // Active toggle
            Switch(
              value: event.isActive,
              onChanged: (_) => notifier.toggleActive(event.id),
              activeColor: AppTheme.kGold,
            ),

            // Edit
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 18, color: cs.onSurfaceVariant),
              onPressed: () => context.push('/events/${event.id}'),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, bool isTelugu) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isTelugu ? 'తొలగించాలా?' : 'Delete event?'),
        content: Text(
          isTelugu
              ? 'ఈ సందర్భాన్ని శాశ్వతంగా తొలగిస్తారు.'
              : 'This event will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isTelugu ? 'రద్దు' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isTelugu ? 'తొలగించు' : 'Delete'),
          ),
        ],
      ),
    );
  }

  String _tithiLabel(int tithi, bool isTelugu) {
    final name = isTelugu
        ? Tithi.namesTe[tithi - 1]
        : Tithi.namesEn[tithi - 1];
    final paksha = tithi <= 15
        ? (isTelugu ? 'శు.పక్ష' : 'Shukla')
        : (isTelugu ? 'కృ.పక్ష' : 'Krishna');
    return '$paksha $name';
  }

  String _monthLabel(int? month, bool isTelugu) {
    if (month == null) {
      return isTelugu ? 'ప్రతి పక్షం' : 'Every paksha';
    }
    return isTelugu
        ? TeluguCalendar.monthNamesTe[month - 1]
        : TeluguCalendar.monthNamesEn[month - 1];
  }
}
