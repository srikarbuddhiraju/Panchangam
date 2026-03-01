import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/app_strings.dart';
import '../user_tithi_event.dart';

/// Card shown in Today and Panchangam detail screens
/// when one or more personal tithi events fall on that day.
///
/// Mirrors the style of FestivalCard but uses gold instead of amber.
class PersonalEventsCard extends StatelessWidget {
  final List<UserTithiEvent> events;

  const PersonalEventsCard({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.kGold.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                const Icon(Icons.bookmark_rounded,
                    color: AppTheme.kGold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.isTelugu ? 'నా సందర్భాలు' : 'My Events',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.kGold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // One entry per event
            ...events.map((e) => _EventEntry(event: e, cs: cs)),
          ],
        ),
      ),
    );
  }
}

class _EventEntry extends StatefulWidget {
  final UserTithiEvent event;
  final ColorScheme cs;

  const _EventEntry({required this.event, required this.cs});

  @override
  State<_EventEntry> createState() => _EventEntryState();
}

class _EventEntryState extends State<_EventEntry> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final UserTithiEvent event = widget.event;
    final ColorScheme cs = widget.cs;
    final bool isTelugu = S.isTelugu;

    final String name =
        isTelugu && event.nameTe != null ? event.nameTe! : event.nameEn;
    final String subtitle = event.teluguMonth != null
        ? (isTelugu ? 'వార్షిక' : 'Yearly')
        : (isTelugu ? 'ప్రతి పక్షం' : 'Every paksha');
    final bool hasNotes = event.notes != null && event.notes!.isNotEmpty;
    final String reminder = _reminderLabel(event, isTelugu);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gold dot
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 8),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.kGold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Name + recurrence + reminder
              Expanded(
                child: GestureDetector(
                  onTap: hasNotes
                      ? () => setState(() => _expanded = !_expanded)
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                      ),
                      if (reminder.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          reminder,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Expand chevron (only when notes exist)
              if (hasNotes)
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),

              // Edit button — large tap target
              GestureDetector(
                onTap: () => context.push('/events/${event.id}'),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.edit_outlined,
                      size: 20, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),

          // Expanded notes — same style as FestivalCard description
          if (hasNotes && _expanded) ...[
            const SizedBox(height: 6),
            Container(
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.kGold.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                event.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Shared reminder label helper ───────────────────────────────────────────────

String _reminderLabel(UserTithiEvent event, bool isTelugu) {
  if (event.reminderHour == null) return '';
  final h = event.reminderHour! % 12 == 0 ? 12 : event.reminderHour! % 12;
  final m = event.reminderMinute.toString().padLeft(2, '0');
  final period = event.reminderHour! < 12 ? 'AM' : 'PM';
  final time = '$h:$m $period';
  final when = switch (event.reminderDaysBefore) {
    0 => isTelugu ? 'అదే రోజు' : 'same day',
    1 => isTelugu ? '1 రోజు ముందు' : '1 day before',
    7 => isTelugu ? '1 వారం ముందు' : '1 week before',
    _ => isTelugu
        ? '${event.reminderDaysBefore} రోజులు ముందు'
        : '${event.reminderDaysBefore} days before',
  };
  final icon = event.reminderType == ReminderType.alarm ? '⏰' : '🔔';
  return '$icon $time · $when';
}
