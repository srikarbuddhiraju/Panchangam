import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/utils/app_strings.dart';
import '../../festivals/festival_data.dart';

/// Card shown in the day detail view when one or more festivals fall on that day.
/// Displays festival name, tithi context, and a description from Purana/Itihasa.
class FestivalCard extends StatelessWidget {
  final List<Festival> festivals;

  const FestivalCard({super.key, required this.festivals});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.kFestivalAmber.withValues(alpha: 0.5),
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
                const Icon(Icons.auto_awesome, color: AppTheme.kFestivalAmber, size: 20),
                const SizedBox(width: 8),
                Text(
                  S.isTelugu ? 'పండుగలు' : 'Festivals',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.kFestivalAmber,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // One entry per festival
            ...festivals.map((f) => _FestivalEntry(festival: f)),
          ],
        ),
      ),
    );
  }
}

class _FestivalEntry extends StatefulWidget {
  final Festival festival;
  const _FestivalEntry({required this.festival});

  @override
  State<_FestivalEntry> createState() => _FestivalEntryState();
}

class _FestivalEntryState extends State<_FestivalEntry> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final Festival f = widget.festival;
    final bool isTelugu = S.isTelugu;

    final String name = isTelugu ? f.nameTe : f.nameEn;
    final String occasion = _occasionLabel(f, isTelugu);
    final bool hasDescription = f.descriptionEn.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Festival name + expand toggle
          GestureDetector(
            onTap: hasDescription
                ? () => setState(() => _expanded = !_expanded)
                : null,
            child: Row(
              children: [
                const Text('✦ ', style: TextStyle(color: AppTheme.kFestivalAmber, fontSize: 12)),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (hasDescription)
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),

          // Tithi/occasion label
          if (occasion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 18, top: 2),
              child: Text(
                occasion,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
            ),

          // Description (expanded)
          if (_expanded && hasDescription) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.kFestivalAmber.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                f.descriptionEn,
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

  String _occasionLabel(Festival f, bool isTelugu) {
    if (f.type == FestivalType.solar) {
      return isTelugu ? 'సౌర పండుగ' : 'Solar festival';
    }
    if (f.paksha == null || f.tithi == null) return '';

    final String paksha = f.paksha == 1
        ? (isTelugu ? 'శుక్ల పక్ష' : 'Shukla Paksha')
        : (isTelugu ? 'కృష్ణ పక్ష' : 'Krishna Paksha');

    // Tithi names (short)
    const List<String> tithiNamesEn = [
      'Paadyami', 'Vidiya', 'Tadiya', 'Chaviti', 'Panchami',
      'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
      'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Pournami / Amavasya',
    ];

    final int idx = (f.tithi! - 1).clamp(0, 14);
    final String tithiLabel = tithiNamesEn[idx];

    final String night = f.observedAtNight
        ? (isTelugu ? ' · రాత్రి వ్రతం' : ' · night observance')
        : '';

    return '$paksha · $tithiLabel$night';
  }
}
