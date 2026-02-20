import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/calculations/panchangam_engine.dart';
import '../../../core/utils/app_strings.dart';
import '../../../app/theme.dart';

/// Card showing sunrise, sunset, moonrise, moonset.
class TimingsCard extends StatelessWidget {
  final PanchangamData data;
  final bool use24h;

  const TimingsCard({super.key, required this.data, required this.use24h});

  String _fmt(DateTime? dt) {
    if (dt == null) return S.notAvailable;
    return use24h
        ? DateFormat('HH:mm').format(dt)
        : DateFormat('h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.isTelugu ? 'కాల వివరాలు' : 'Daily Timings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.kSaffron,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TimingTile(
                  icon: Icons.wb_sunny,
                  label: S.sunrise,
                  time: _fmt(data.sunrise),
                  color: Colors.orange.shade700,
                ),
                _TimingTile(
                  icon: Icons.wb_twilight,
                  label: S.sunset,
                  time: _fmt(data.sunset),
                  color: Colors.deepOrange.shade800,
                ),
                _TimingTile(
                  icon: Icons.nightlight_round,
                  label: S.moonrise,
                  time: _fmt(data.moonrise),
                  color: Colors.indigo.shade300,
                ),
                _TimingTile(
                  icon: Icons.nights_stay_outlined,
                  label: S.moonset,
                  time: _fmt(data.moonset),
                  color: Colors.blueGrey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color color;

  const _TimingTile({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            time,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
