import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../core/calculations/telugu_calendar.dart';
import '../../core/calculations/tithi.dart';
import '../../core/utils/app_strings.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../events/user_event_provider.dart';
import '../events/user_tithi_event.dart';
import '../settings/settings_provider.dart';

/// The Pro tab — premium hub for Panchangam Pro features.
///
/// Uses the app's theme colors so it looks correct in both light and dark mode.
/// Signed-in Pro users see feature cards + a live events list.
/// Free and signed-out users see a polished upgrade prompt.
class ProScreen extends ConsumerWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final isPremium = ref.watch(settingsProvider).isPremium;
    final isTelugu = S.isTelugu;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroSection(user: user, isPremium: isPremium, isTelugu: isTelugu),
              const SizedBox(height: 8),
              if (isPremium) ...[
                _ProFeatureSection(context: context, isTelugu: isTelugu),
                const SizedBox(height: 20),
                _EventsPreviewSection(context: context, isTelugu: isTelugu),
              ] else
                _UpgradeSection(user: user, isTelugu: isTelugu),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final User? user;
  final bool isPremium;
  final bool isTelugu;

  const _HeroSection({
    required this.user,
    required this.isPremium,
    required this.isTelugu,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(color: cs.primaryContainer),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      child: Column(
        children: [
          _UserAvatar(user: user, isPremium: isPremium),
          const SizedBox(height: 14),
          Text(
            'Panchangam Pro',
            style: GoogleFonts.notoSansTelugu(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          _StatusBadge(isPremium: isPremium, cs: cs),
          const SizedBox(height: 10),
          if (user != null)
            Text(
              user!.displayName ?? user!.email ?? '',
              style: GoogleFonts.notoSansTelugu(
                fontSize: 13,
                color: cs.onPrimaryContainer.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              isTelugu
                  ? 'మీ సందర్భాలు మరియు రిమైండర్‌లను యాక్సెస్ చేయడానికి సైన్ ఇన్ చేయండి'
                  : 'Sign in to access your events and reminders',
              style: GoogleFonts.notoSansTelugu(
                fontSize: 13,
                color: cs.onPrimaryContainer.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final User? user;
  final bool isPremium;

  const _UserAvatar({required this.user, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final photoUrl = user?.photoURL;
    final initials = _initials(user);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isPremium
                  ? AppTheme.kGold
                  : cs.outline.withValues(alpha: 0.4),
              width: 2.5,
            ),
            color: user == null ? const Color(0xFF0B1437) : cs.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: photoUrl != null
              ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, err, stack) => _InitialsAvatar(initials, cs),
                )
              : user == null
                  ? Image.asset('assets/icon.png', fit: BoxFit.cover)
                  : _InitialsAvatar(initials, cs),
        ),
        if (isPremium)
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.kGold,
              border: Border.all(color: cs.surface, width: 2),
            ),
            child: const Icon(Icons.star_rounded, size: 12, color: Colors.white),
          ),
      ],
    );
  }

  static String _initials(User? user) {
    final name = user?.displayName;
    if (name != null && name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return parts[0][0].toUpperCase();
    }
    final email = user?.email;
    if (email != null && email.isNotEmpty) return email[0].toUpperCase();
    return '✦';
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  final ColorScheme cs;
  const _InitialsAvatar(this.initials, this.cs);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.notoSansTelugu(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: cs.primary,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPremium;
  final ColorScheme cs;
  const _StatusBadge({required this.isPremium, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isPremium
            ? AppTheme.kGold.withValues(alpha: 0.2)
            : cs.onPrimaryContainer.withValues(alpha: 0.1),
        border: Border.all(
          color: isPremium
              ? AppTheme.kGold.withValues(alpha: 0.7)
              : cs.onPrimaryContainer.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        isPremium ? '✦  Pro' : 'Free',
        style: GoogleFonts.notoSansTelugu(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isPremium
              ? AppTheme.kGold
              : cs.onPrimaryContainer.withValues(alpha: 0.6),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Pro feature cards ─────────────────────────────────────────────────────────

class _ProFeatureSection extends StatelessWidget {
  final BuildContext context;
  final bool isTelugu;
  const _ProFeatureSection({required this.context, required this.isTelugu});

  @override
  Widget build(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              isTelugu ? 'మీ ప్రో ఫీచర్లు' : 'YOUR PRO FEATURES',
              style: GoogleFonts.notoSansTelugu(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.1,
              ),
            ),
          ),
          _FeatureCard(
            cs: cs,
            icon: Icons.event_rounded,
            iconColor: cs.primary,
            title: isTelugu ? 'వ్యక్తిగత సందర్భాలు' : 'Personal Events',
            subtitle: isTelugu
                ? 'పుట్టినరోజులు, వర్ధంతులు — ఒకసారి సెట్ చేయండి, ప్రతి సంవత్సరం సరైన తిథిన పునరావృతమవుతాయి'
                : 'Birthdays & anniversaries — set once, repeat on the correct tithi every year',
            onTap: () => context.push('/my-events?tab=0'),
          ),
          const SizedBox(height: 10),
          _FeatureCard(
            cs: cs,
            icon: Icons.checklist_rounded,
            iconColor: cs.tertiary,
            title: isTelugu ? 'టు-డూలు' : 'To-Dos',
            subtitle: isTelugu
                ? 'తిథికి అనుగుణమైన పనులు — ఏకాదశిన దానం, పంచమిన దేవాలయం'
                : 'Tasks tied to a tithi — donate on Ekadashi, visit temple on Panchami',
            onTap: () => context.push('/my-events?tab=1'),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final ColorScheme cs;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.cs,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSansTelugu(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.notoSansTelugu(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Events preview ────────────────────────────────────────────────────────────

class _EventsPreviewSection extends ConsumerWidget {
  final BuildContext context;
  final bool isTelugu;
  const _EventsPreviewSection(
      {required this.context, required this.isTelugu});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final cs = Theme.of(ctx).colorScheme;
    final events = ref.watch(userEventProvider);

    // Show at most 5 events; active first
    final sorted = [
      ...events.where((e) => e.isActive),
      ...events.where((e) => !e.isActive),
    ];
    final preview = sorted.take(5).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  isTelugu ? 'సందర్భాలు' : 'EVENTS',
                  style: GoogleFonts.notoSansTelugu(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const Spacer(),
              if (events.isNotEmpty)
                TextButton(
                  onPressed: () => context.push('/my-events?tab=0'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isTelugu ? 'అన్నీ చూడండి' : 'See all',
                    style: GoogleFonts.notoSansTelugu(
                      fontSize: 12,
                      color: cs.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (preview.isEmpty)
            // Empty state
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_available_outlined,
                      color: cs.onSurfaceVariant, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      isTelugu
                          ? 'ఇంకా సందర్భాలు లేవు — "వ్యక్తిగత సందర్భాలు" నొక్కి జోడించండి'
                          : 'No events yet — tap Personal Events above to add one',
                      style: GoogleFonts.notoSansTelugu(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Event tiles
            Column(
              children: preview
                  .map((e) => _EventPreviewTile(
                        event: e,
                        isTelugu: isTelugu,
                        cs: cs,
                        onTap: () => context.push('/events/${e.id}'),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _EventPreviewTile extends StatelessWidget {
  final UserTithiEvent event;
  final bool isTelugu;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _EventPreviewTile({
    required this.event,
    required this.isTelugu,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        isTelugu && event.nameTe != null ? event.nameTe! : event.nameEn;

    final paksha = event.tithi <= 15
        ? (isTelugu ? 'శు.పక్ష' : 'Shukla')
        : (isTelugu ? 'కృ.పక్ష' : 'Krishna');
    final tithiName = isTelugu
        ? Tithi.namesTe[event.tithi - 1]
        : Tithi.namesEn[event.tithi - 1];
    final monthName = event.teluguMonth != null
        ? (isTelugu
            ? TeluguCalendar.monthNamesTe[event.teluguMonth! - 1]
            : TeluguCalendar.monthNamesEn[event.teluguMonth! - 1])
        : (isTelugu ? 'ప్రతి మాసం' : 'Every month');

    // Reminder/alarm indicator
    final hasReminder = event.reminderHour != null;
    final isAlarm = event.reminderType == ReminderType.alarm;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: event.isActive
                    ? AppTheme.kGold.withValues(alpha: 0.3)
                    : cs.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                // Colour dot
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: event.isActive
                        ? AppTheme.kGold
                        : cs.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                ),

                // Name + tithi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.notoSansTelugu(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: event.isActive
                              ? cs.onSurface
                              : cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$paksha $tithiName · $monthName',
                        style: GoogleFonts.notoSansTelugu(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Reminder / alarm badge
                if (hasReminder) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isAlarm
                          ? AppTheme.kSaffron.withValues(alpha: 0.12)
                          : AppTheme.kGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAlarm
                              ? Icons.alarm_rounded
                              : Icons.notifications_rounded,
                          size: 13,
                          color: isAlarm ? AppTheme.kSaffron : AppTheme.kGold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isAlarm
                              ? (isTelugu ? 'అలారం' : 'Alarm')
                              : (isTelugu ? 'రిమైండర్' : 'Reminder'),
                          style: GoogleFonts.notoSansTelugu(
                            fontSize: 10,
                            color:
                                isAlarm ? AppTheme.kSaffron : AppTheme.kGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Edit chevron
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded,
                    size: 16, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Upgrade section ───────────────────────────────────────────────────────────

class _UpgradeSection extends ConsumerWidget {
  final User? user;
  final bool isTelugu;
  const _UpgradeSection({required this.user, required this.isTelugu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isTelugu
                ? 'పంచాంగం ప్రో అన్‌లాక్ చేయండి'
                : 'Unlock Panchangam Pro',
            style: GoogleFonts.notoSansTelugu(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isTelugu
                ? 'మీ పూర్తి తిథి-ఆధారిత జీవిత సహచరుడు'
                : 'Your complete tithi-based life companion',
            style: GoogleFonts.notoSansTelugu(
              fontSize: 14,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          _UpgradeFeatureItem(
            cs: cs,
            icon: Icons.event_rounded,
            iconColor: cs.primary,
            title: isTelugu ? 'వ్యక్తిగత సందర్భాలు' : 'Personal Events',
            subtitle: isTelugu
                ? 'పుట్టినరోజులు, వర్ధంతులు ఒకసారి సెట్ చేయండి — ప్రతి సంవత్సరం సరైన తిథిన వస్తాయి.'
                : 'Set birthdays and anniversaries once — they recur on the correct tithi every year.',
          ),
          const SizedBox(height: 18),
          _UpgradeFeatureItem(
            cs: cs,
            icon: Icons.checklist_rounded,
            iconColor: cs.tertiary,
            title: isTelugu ? 'తిథి-ఆధారిత టు-డూలు' : 'To-Dos by Tithi',
            subtitle: isTelugu
                ? 'పంచాంగం చుట్టూ పనులు ప్లాన్ చేయండి — శుభ దినాన పూర్తి చేయండి.'
                : 'Plan tasks around the Panchangam — complete them on the auspicious day.',
          ),
          const SizedBox(height: 18),
          _UpgradeFeatureItem(
            cs: cs,
            icon: Icons.notifications_active_rounded,
            iconColor: AppTheme.kGold,
            title: isTelugu ? 'రిమైండర్లు & అలారాలు' : 'Reminders & Alarms',
            subtitle: isTelugu
                ? 'ప్రతి సందర్భానికి ముందే హెచ్చరించు — రిమైండర్ లేదా అలారం టోన్ ఎంచుకోండి.'
                : 'Never miss an event — get reminders or alarm-tone alerts before each one.',
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.star_rounded),
            label: Text(isTelugu ? 'సబ్‌స్క్రైబ్ — త్వరలో' : 'Subscribe — Coming Soon'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.kGold,
              foregroundColor: const Color(0xFF1A1200),
              disabledBackgroundColor: AppTheme.kGold.withValues(alpha: 0.3),
              disabledForegroundColor: cs.onSurface.withValues(alpha: 0.4),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.notoSansTelugu(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (user == null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                final nav = Navigator.of(context);
                nav.push(
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(
                      onSuccess: nav.pop,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.login_rounded, size: 18),
              label: Text(isTelugu ? 'సైన్ ఇన్' : 'Sign In'),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.primary,
                side: BorderSide(color: cs.outline),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.notoSansTelugu(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UpgradeFeatureItem extends StatelessWidget {
  final ColorScheme cs;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _UpgradeFeatureItem({
    required this.cs,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withValues(alpha: 0.12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.notoSansTelugu(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.notoSansTelugu(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
