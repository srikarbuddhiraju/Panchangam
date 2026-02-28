import 'package:flutter/material.dart';
import '../../../core/calculations/panchangam_engine.dart';
import '../../../core/utils/app_strings.dart';
import '../../../app/theme.dart';

/// Summary header card: Vara, Paksha·Tithi, Telugu month, Samvatsara.
/// Shown at the top of both the Today tab and the day-detail view.
class DateHeaderCard extends StatelessWidget {
  final PanchangamData data;

  const DateHeaderCard({super.key, required this.data});

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
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
