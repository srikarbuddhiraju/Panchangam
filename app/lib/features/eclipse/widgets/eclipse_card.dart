import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/calculations/eclipse.dart';
import '../../../core/utils/app_strings.dart';
import '../../../app/theme.dart';

/// Card showing details of a single eclipse.
class EclipseCard extends StatelessWidget {
  final EclipseData eclipse;

  const EclipseCard({super.key, required this.eclipse});

  @override
  Widget build(BuildContext context) {
    final bool isSolar = eclipse.type.isSolar;
    final Color color = isSolar ? Colors.orange.shade800 : Colors.indigo;

    final String dateLabel =
        DateFormat('d MMMM y').format(eclipse.date);
    final String typeName =
        S.isTelugu ? eclipse.type.nameTe : eclipse.type.nameEn;

    final String sutakLabel = S.isTelugu
        ? 'సూతక ప్రారంభం: ${DateFormat('d MMM, HH:mm').format(eclipse.sutakStart)}'
        : 'Sutak starts: ${DateFormat('d MMM, HH:mm').format(eclipse.sutakStart)}';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSolar ? Icons.wb_sunny : Icons.nightlight_round,
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                      Text(
                        dateLabel,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (eclipse.isVisibleInIndia)
                  Chip(
                    label: Text(
                      S.isTelugu ? 'భారత్‌లో కనిపిస్తుంది' : 'Visible in India',
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: AppTheme.kAuspiciousGreen.withValues(alpha: 0.1),
                    side: BorderSide(color: AppTheme.kAuspiciousGreen),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              sutakLabel,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              S.isTelugu
                  ? isSolar
                      ? 'సూతక కాలం: గ్రహణానికి 12 గంటల ముందు'
                      : 'సూతక కాలం: గ్రహణానికి 9 గంటల ముందు'
                  : isSolar
                      ? 'Sutak period: 12 hours before eclipse'
                      : 'Sutak period: 9 hours before eclipse',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
