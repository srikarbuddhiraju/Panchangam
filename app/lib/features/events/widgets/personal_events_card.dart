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

class _EventEntry extends StatelessWidget {
  final UserTithiEvent event;
  final ColorScheme cs;

  const _EventEntry({required this.event, required this.cs});

  @override
  Widget build(BuildContext context) {
    final String name =
        S.isTelugu && event.nameTe != null ? event.nameTe! : event.nameEn;

    final String subtitle = event.teluguMonth != null
        ? (S.isTelugu ? 'వార్షిక' : 'Yearly')
        : (S.isTelugu ? 'ప్రతి పక్షం' : 'Every paksha');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gold dot
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.kGold,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Name + recurrence label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),

          // Edit icon → go to edit form
          GestureDetector(
            onTap: () => context.push('/events/${event.id}'),
            child: Icon(Icons.edit_outlined, size: 16, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
