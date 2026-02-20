import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/calculations/panchangam_engine.dart';
import '../../../core/utils/app_strings.dart';
import '../../../app/theme.dart';

/// Card showing all five Panchangam limbs with end times.
class FiveLimbsCard extends StatelessWidget {
  final PanchangamData data;
  final bool use24h;

  const FiveLimbsCard({super.key, required this.data, required this.use24h});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.isTelugu ? 'పంచాంగ అంగాలు' : 'Five Limbs (Pancha Anga)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.kSaffron,
                  ),
            ),
            const SizedBox(height: 12),
            _LimbRow(
              icon: Icons.water_drop_outlined,
              label: S.tithi,
              value: S.isTelugu ? data.tithiNameTe : data.tithiNameEn,
              subtitle: data.pakshaTe,
              endTime: data.tithiEndTime,
              use24h: use24h,
            ),
            _LimbRow(
              icon: Icons.calendar_today,
              label: S.vara,
              value: S.isTelugu ? data.varaNameTe : data.varaNameEn,
              subtitle: null,
              endTime: null,
              use24h: use24h,
            ),
            _LimbRow(
              icon: Icons.star_outline,
              label: S.nakshatra,
              value: S.isTelugu
                  ? data.nakshatraNameTe
                  : data.nakshatraNameEn,
              subtitle: null,
              endTime: data.nakshatraEndTime,
              use24h: use24h,
            ),
            _LimbRow(
              icon: Icons.brightness_5_outlined,
              label: S.yoga,
              value: S.isTelugu ? data.yogaNameTe : data.yogaNameEn,
              subtitle: null,
              endTime: data.yogaEndTime,
              use24h: use24h,
            ),
            _LimbRow(
              icon: Icons.timelapse,
              label: S.karana,
              value: S.isTelugu ? data.karanaNameTe : data.karanaNameEn,
              subtitle: null,
              endTime: data.karanaEndTime,
              use24h: use24h,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _LimbRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final DateTime? endTime;
  final bool use24h;
  final bool isLast;

  const _LimbRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.endTime,
    required this.use24h,
    this.isLast = false,
  });

  String _fmt(DateTime dt) {
    return use24h
        ? DateFormat('HH:mm').format(dt)
        : DateFormat('h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.kSaffron),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    Text(
                      value,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                  ],
                ),
              ),
              if (endTime != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      S.endTime,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey, fontSize: 10),
                    ),
                    Text(
                      _fmt(endTime!),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 28),
      ],
    );
  }
}
