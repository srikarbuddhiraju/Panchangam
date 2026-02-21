import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/calculations/eclipse.dart';
import '../../../core/utils/app_strings.dart';
import '../../../app/theme.dart';

/// Card showing details of a single eclipse — type, sparsha/moksha times,
/// and sutak timings for general public and for vulnerable groups.
class EclipseCard extends StatelessWidget {
  final EclipseData eclipse;

  const EclipseCard({super.key, required this.eclipse});

  @override
  Widget build(BuildContext context) {
    final bool isSolar = eclipse.type.isSolar;
    final Color color = isSolar ? Colors.orange.shade800 : Colors.indigo;
    final bool isTelugu = S.isTelugu;

    final String typeName = isTelugu ? eclipse.type.nameTe : eclipse.type.nameEn;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Row(
              children: [
                Icon(
                  isSolar ? Icons.wb_sunny : Icons.nightlight_round,
                  color: color,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    typeName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ),
                if (eclipse.isVisibleInIndia)
                  Chip(
                    label: Text(
                      isTelugu ? 'భారత్‌లో కనిపిస్తుంది' : 'Visible in India',
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: AppTheme.kAuspiciousGreen.withValues(alpha: 0.1),
                    side: const BorderSide(color: AppTheme.kAuspiciousGreen),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Eclipse timings ───────────────────────────────────────────
            _TimingRow(
              label: isTelugu ? 'స్పర్శ (ప్రారంభం)' : 'Sparsha (First contact)',
              time: eclipse.sparsha,
              color: color,
            ),
            const SizedBox(height: 4),
            _TimingRow(
              label: isTelugu ? 'మోక్షం (విముక్తి)' : 'Moksha (Last contact)',
              time: eclipse.moksha,
              color: color,
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Sutak timings ─────────────────────────────────────────────
            Text(
              isTelugu ? 'సూతక కాలం' : 'Sutak Period',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 6),

            // General sutak
            _SutakRow(
              label: isTelugu ? 'సామాన్య సూతకం' : 'General',
              start: eclipse.sutakStart,
              end: eclipse.moksha,
            ),
            const SizedBox(height: 4),

            // Vulnerable sutak
            _SutakRow(
              label: isTelugu
                  ? 'పిల్లలు / వయోధికులు / రోగులు'
                  : 'Children / Elderly / Sick',
              start: eclipse.sutakStartVulnerable,
              end: eclipse.moksha,
            ),
            const SizedBox(height: 8),

            // Rule note
            Text(
              isTelugu
                  ? (isSolar
                      ? 'సూతకం: స్పర్శకు 12 గంటల ముందు నుండి మోక్షం వరకు'
                      : 'సూతకం: స్పర్శకు 9 గంటల ముందు నుండి మోక్షం వరకు')
                  : (isSolar
                      ? 'Sutak: 12 hours before sparsha until moksha'
                      : 'Sutak: 9 hours before sparsha until moksha'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimingRow extends StatelessWidget {
  final String label;
  final DateTime time;
  final Color color;

  const _TimingRow({required this.label, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ),
        Text(
          DateFormat('h:mm a').format(time),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
        ),
      ],
    );
  }
}

class _SutakRow extends StatelessWidget {
  final String label;
  final DateTime start;
  final DateTime end;

  const _SutakRow({required this.label, required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    final String timeRange =
        '${DateFormat('h:mm a').format(start)} – ${DateFormat('h:mm a').format(end)}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ),
        Text(
          timeRange,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
