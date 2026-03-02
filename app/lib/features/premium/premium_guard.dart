import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../settings/settings_provider.dart';

/// Wraps a premium-gated widget.
///
/// If the user has Pro, [child] is shown.
/// If not, a [PremiumTeaser] is shown instead.
///
/// TODO(Session5): Replace teaser with real PaywallScreen when billing is wired.
class PremiumGuard extends ConsumerWidget {
  final Widget child;

  const PremiumGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(settingsProvider).isPremium;
    if (isPremium) return child;
    return const PremiumTeaser();
  }
}

/// Shown to non-premium users in place of gated content, or as a bottom-sheet
/// paywall when a Pro action is tapped.
class PremiumTeaser extends StatelessWidget {
  const PremiumTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.kGold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 36,
                color: AppTheme.kGold,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Panchangam Pro',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.kGold,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Feature list
            ..._features.map(
              (f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        size: 18, color: AppTheme.kGold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.4,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Subscribe button (disabled — billing coming soon)
            FilledButton.icon(
              onPressed: null, // TODO(Session5): wire to billing
              icon: const Icon(Icons.star_rounded),
              label: const Text('Subscribe — Coming Soon'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.kGold,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _features = [
    'Mark personal tithi events — birthdays, anniversaries, family traditions',
    'Events auto-appear on your calendar every year, on the correct tithi',
    'Reminders before each event',
    'Family sharing (coming soon)',
  ];
}
