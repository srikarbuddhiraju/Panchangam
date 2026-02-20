import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/calculations/panchangam_engine.dart';
import '../../../core/utils/app_strings.dart';
import '../../../app/theme.dart';

/// Card showing inauspicious periods (Rahu Kalam, Gulika, Yamaganda)
/// as colored time bars with exact times.
class KalamCard extends StatelessWidget {
  final PanchangamData data;
  final bool use24h;

  const KalamCard({super.key, required this.data, required this.use24h});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.isTelugu ? 'అశుభ కాలాలు' : 'Inauspicious Periods',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.kSaffron,
                  ),
            ),
            const SizedBox(height: 12),
            _KalamRow(
              label: S.rahuKalam,
              start: data.rahuKalamStart,
              end: data.rahuKalamEnd,
              sunrise: data.sunrise,
              sunset: data.sunset,
              color: AppTheme.kRahuKalamRed,
              use24h: use24h,
            ),
            const SizedBox(height: 8),
            _KalamRow(
              label: S.gulikaKalam,
              start: data.gulikaKalamStart,
              end: data.gulikaKalamEnd,
              sunrise: data.sunrise,
              sunset: data.sunset,
              color: Colors.deepOrange.shade700,
              use24h: use24h,
            ),
            const SizedBox(height: 8),
            _KalamRow(
              label: S.yamaganda,
              start: data.yamagandaStart,
              end: data.yamagandaEnd,
              sunrise: data.sunrise,
              sunset: data.sunset,
              color: Colors.purple.shade700,
              use24h: use24h,
            ),
          ],
        ),
      ),
    );
  }
}

class _KalamRow extends StatelessWidget {
  final String label;
  final DateTime start;
  final DateTime end;
  final DateTime sunrise;
  final DateTime sunset;
  final Color color;
  final bool use24h;

  const _KalamRow({
    required this.label,
    required this.start,
    required this.end,
    required this.sunrise,
    required this.sunset,
    required this.color,
    required this.use24h,
  });

  String _fmt(DateTime dt) =>
      use24h ? DateFormat('HH:mm').format(dt) : DateFormat('h:mm a').format(dt);

  @override
  Widget build(BuildContext context) {
    final int dayDuration = sunset.difference(sunrise).inMinutes;
    final int startOffset = start.difference(sunrise).inMinutes;
    final int duration = end.difference(start).inMinutes;

    final double startFraction =
        dayDuration > 0 ? startOffset / dayDuration : 0;
    final double widthFraction = dayDuration > 0 ? duration / dayDuration : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              '${_fmt(start)} – ${_fmt(end)}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Time bar
        LayoutBuilder(
          builder: (context, constraints) {
            final double totalWidth = constraints.maxWidth;
            return Stack(
              children: [
                // Background bar (full day)
                Container(
                  height: 8,
                  width: totalWidth,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Kalam period
                Positioned(
                  left: (startFraction * totalWidth).clamp(0, totalWidth),
                  child: Container(
                    height: 8,
                    width: (widthFraction * totalWidth).clamp(4, totalWidth),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
