import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/calculations/panchangam_engine.dart';
import '../../../core/utils/app_strings.dart';
import '../../../app/theme.dart';

/// Card showing Abhijit Muhurtha, Dur Muhurta, and Amrit Kalam.
class MuhurthaCard extends StatelessWidget {
  final PanchangamData data;
  final bool use24h;

  const MuhurthaCard({super.key, required this.data, required this.use24h});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.isTelugu ? 'ముహూర్తాలు' : 'Muhurthas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.kSaffron,
                  ),
            ),
            const SizedBox(height: 12),

            // Abhijit Muhurtha
            _MuhurthaRow(
              label: S.abhijit,
              start: data.abhijitStart,
              end: data.abhijitEnd,
              valid: data.abhijitValid,
              color: AppTheme.kGold,
              icon: Icons.star,
              use24h: use24h,
            ),
            const Divider(height: 16),

            // Dur Muhurta
            _MuhurthaRow(
              label: S.durMuhurta,
              start: data.durMuhurtaStart,
              end: data.durMuhurtaEnd,
              valid: true,
              color: AppTheme.kRahuKalamRed,
              icon: Icons.block,
              use24h: use24h,
            ),
            const Divider(height: 16),

            // Amrit Kalam
            _MuhurthaRow(
              label: S.amritKalam,
              start: data.amritKalamStart,
              end: data.amritKalamEnd,
              valid: true,
              color: AppTheme.kAuspiciousGreen,
              icon: Icons.water_drop,
              use24h: use24h,
            ),
          ],
        ),
      ),
    );
  }
}

class _MuhurthaRow extends StatelessWidget {
  final String label;
  final DateTime? start;
  final DateTime? end;
  final bool valid;
  final Color color;
  final IconData icon;
  final bool use24h;

  const _MuhurthaRow({
    required this.label,
    required this.start,
    required this.end,
    required this.valid,
    required this.color,
    required this.icon,
    required this.use24h,
  });

  String _fmt(DateTime dt) =>
      use24h ? DateFormat('HH:mm').format(dt) : DateFormat('h:mm a').format(dt);

  @override
  Widget build(BuildContext context) {
    final String timeStr = !valid
        ? (S.isTelugu ? 'బుధవారం వర్తించదు' : 'Not valid on Wednesday')
        : (start != null && end != null)
            ? '${_fmt(start!)} – ${_fmt(end!)}'
            : S.notAvailable;

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Text(
          timeStr,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valid ? null : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
