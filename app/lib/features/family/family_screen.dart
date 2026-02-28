import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/utils/app_strings.dart';

/// Family tab — Coming Soon teaser. Full implementation in v2.
class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTelugu = S.isTelugu;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'కుటుంబం' : 'Family'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.kSaffron.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_rounded,
                  size: 36,
                  color: AppTheme.kSaffron,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                isTelugu ? 'త్వరలో వస్తోంది' : 'Coming Soon',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.kGold,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                isTelugu
                    ? 'కుటుంబ అవసరాలకు తయారవుతున్నాం'
                    : 'We\'re building something special for your family',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 40),

              // Feature cards
              _FeatureCard(
                icon: Icons.cake_rounded,
                iconColor: AppTheme.kSaffron,
                title: isTelugu ? 'తిథి పుట్టినరోజులు' : 'Tithi Birthdays',
                subtitle: isTelugu
                    ? 'కుటుంబ సభ్యుల తిథి పుట్టినరోజులపై నోటిఫికేషన్లు పొందండి'
                    : 'Get notified on every family member\'s tithi birthday',
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: Icons.event_rounded,
                iconColor: AppTheme.kGold,
                title: isTelugu ? 'కుటుంబ వేడుకలు' : 'Family Occasions',
                subtitle: isTelugu
                    ? 'వివాహాలు, నామకరణాలు, మరిన్ని ప్రత్యేక తేదీలను ట్రాక్ చేయండి'
                    : 'Track weddings, naming ceremonies, and special dates',
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: Icons.notifications_active_rounded,
                iconColor: AppTheme.kAuspiciousGreen,
                title: isTelugu ? 'స్మార్ట్ రిమైండర్లు' : 'Smart Reminders',
                subtitle: isTelugu
                    ? 'ప్రతి కుటుంబ కార్యక్రమానికి ముందే అలర్ట్‌లు స్వయంచాలకంగా'
                    : 'Alerts ahead of every family event, automatically',
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: Icons.sync_rounded,
                iconColor: cs.primary,
                title: isTelugu ? 'క్రాస్-డివైస్ సింక్' : 'Cross-device Sync',
                subtitle: isTelugu
                    ? 'ఒకే కుటుంబ క్యాలెండర్, అన్ని ఫోన్‌లలో పంచుకోండి'
                    : 'One family calendar, shared across all phones',
              ),

              const Spacer(),

              // Bottom tagline
              Text(
                isTelugu
                    ? 'తదుపరి అప్‌డేట్‌లో వస్తుంది'
                    : 'Coming in the next update',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
