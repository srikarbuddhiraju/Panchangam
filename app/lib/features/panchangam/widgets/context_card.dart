import 'package:flutter/material.dart';
import '../../../core/calculations/panchangam_engine.dart';
import '../../../core/utils/app_strings.dart';
import '../../../app/theme.dart';

/// Card showing calendar context: Telugu month, Paksha, Samvatsara,
/// Ayanam, Ritu, Rashi, Shaka year.
class ContextCard extends StatelessWidget {
  final PanchangamData data;

  const ContextCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.isTelugu ? 'కాల గణన' : 'Calendar Context',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.kSaffron,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ContextChip(
                  label: S.teluguMonth,
                  value: S.isTelugu
                      ? data.teluguMonthTe
                      : data.teluguMonthEn,
                ),
                _ContextChip(
                  label: S.paksha,
                  value: S.isTelugu ? data.pakshaTe : data.paksha,
                ),
                _ContextChip(
                  label: S.samvatsara,
                  value: S.isTelugu
                      ? data.samvatsaraTe
                      : data.samvatsaraEn,
                ),
                _ContextChip(
                  label: S.ayanam,
                  value:
                      S.isTelugu ? data.ayanamTe : data.ayanamEn,
                ),
                _ContextChip(
                  label: S.ritu,
                  value: S.isTelugu ? data.rituTe : data.rituEn,
                ),
                _ContextChip(
                  label: S.rashi,
                  value: S.isTelugu
                      ? data.rashiNameTe
                      : data.rashiNameEn,
                ),
                _ContextChip(
                  label: S.shakaYear,
                  value: '${data.shakaYear}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextChip extends StatelessWidget {
  final String label;
  final String value;

  const _ContextChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
