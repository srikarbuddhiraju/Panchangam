import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../core/utils/app_strings.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../shared/widgets/city_picker_dialog.dart';
import '../../shared/widgets/language_toggle.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(S.settings)),
      body: ListView(
        children: [
          // ── Account ───────────────────────────────────────────────────────
          if (user != null) ...[
            _AccountTile(user: user),
            const Divider(height: 1),
          ] else ...[
            _SignInTile(),
            const Divider(height: 1),
          ],

          // ── Language ──────────────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(S.languageLabel),
            trailing: const LanguageToggle(),
          ),
          const Divider(height: 1),

          // ── City ──────────────────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.location_city),
            title: Text(S.city),
            subtitle: Text(settings.cityName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final city = await CityPickerDialog.show(context);
              if (city != null) await notifier.setCity(city);
            },
          ),
          const Divider(height: 1),

          // ── Theme ─────────────────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(S.theme),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(S.isTelugu ? 'ఆటో' : 'Auto'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(S.isTelugu ? 'లైట్' : 'Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(S.isTelugu ? 'డార్క్' : 'Dark'),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) notifier.setThemeMode(mode);
              },
            ),
          ),
          const Divider(height: 1),

          // ── Time format ───────────────────────────────────────────────────
          SwitchListTile(
            secondary: const Icon(Icons.access_time),
            title: Text(S.timeFormat),
            subtitle:
                Text(settings.use24h ? '24-hour clock' : '12-hour clock'),
            value: settings.use24h,
            onChanged: (v) => notifier.setTimeFormat(v),
          ),
          const Divider(height: 1),

          // ── Location info ─────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              '${settings.cityName} · ${settings.lat.toStringAsFixed(4)}°N, '
              '${settings.lng.toStringAsFixed(4)}°E',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ),

          const Divider(height: 1),

          // ── Notifications ─────────────────────────────────────────────────
          const _NotificationSettingsTile(),
          const Divider(height: 1),

          // ── App version ───────────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(S.isTelugu ? 'వెర్షన్' : 'Version'),
            trailing: const Text('1.0.0'),
          ),
          const Divider(height: 1),

          // ── Disclaimer ────────────────────────────────────────────────────
          const _DisclaimerTile(),
        ],
      ),
    );
  }
}

// ── Notifications tile ────────────────────────────────────────────────────────

class _NotificationSettingsTile extends StatefulWidget {
  const _NotificationSettingsTile();

  @override
  State<_NotificationSettingsTile> createState() =>
      _NotificationSettingsTileState();
}

class _NotificationSettingsTileState
    extends State<_NotificationSettingsTile> {
  bool? _enabled; // null = loading

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final enabled = await NotificationService.instance.areNotificationsEnabled();
    if (mounted) setState(() => _enabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = S.isTelugu;
    final cs = Theme.of(context).colorScheme;
    final enabled = _enabled;

    if (enabled == null) {
      return ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: Text(isTelugu ? 'నోటిఫికేషన్లు' : 'Notifications'),
        trailing: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (!enabled) {
      // Notifications blocked — show warning banner
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_off_outlined,
                color: cs.onErrorContainer, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTelugu
                        ? 'నోటిఫికేషన్లు నిలిపివేయబడ్డాయి'
                        : 'Notifications are disabled',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cs.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTelugu
                        ? 'Settings → Apps → Panchangam → Notifications లో ఆన్ చేయండి'
                        : 'Go to Settings → Apps → Panchangam → Notifications to enable',
                    style: TextStyle(
                        fontSize: 12, color: cs.onErrorContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Notifications enabled — show status only
    return ListTile(
      leading: const Icon(Icons.notifications_active_outlined,
          color: AppTheme.kGold),
      title: Text(isTelugu ? 'నోటిఫికేషన్లు' : 'Notifications'),
      subtitle: Text(isTelugu ? 'అనుమతి ఇవ్వబడింది' : 'Permission granted'),
      trailing: const Icon(Icons.check_circle_outline_rounded,
          color: AppTheme.kAuspiciousGreen),
    );
  }
}

// ── Sign-in tile (shown when logged out) ──────────────────────────────────────

class _SignInTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.account_circle_outlined),
      title: Text(S.isTelugu ? 'సైన్ ఇన్ చేయండి' : 'Sign in'),
      subtitle: Text(
        S.isTelugu
            ? 'మీ సందర్భాలు మరియు రిమైండర్‌లను యాక్సెస్ చేయండి'
            : 'Access your personal events and reminders',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _LoginSheet(),
      ),
    );
  }
}

class _LoginSheet extends StatelessWidget {
  const _LoginSheet();
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: LoginScreen(onSuccess: () => Navigator.of(context).pop()),
      ),
    );
  }
}

// ── Account tile ──────────────────────────────────────────────────────────────

class _AccountTile extends StatelessWidget {
  final User user;
  const _AccountTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final isPro = AuthService.isProEmail(user.email);
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            user.photoURL != null ? NetworkImage(user.photoURL!) : null,
        backgroundColor: AppTheme.kGold.withValues(alpha: 0.15),
        child: user.photoURL == null
            ? Text(
                (user.displayName ?? user.email ?? '?')[0].toUpperCase(),
                style: const TextStyle(color: AppTheme.kGold),
              )
            : null,
      ),
      title: Text(user.displayName ?? user.email ?? ''),
      subtitle: Row(
        children: [
          if (isPro) ...[
            const Icon(Icons.star_rounded, size: 13, color: AppTheme.kGold),
            const SizedBox(width: 3),
            const Text('Pro', style: TextStyle(color: AppTheme.kGold)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              user.email ?? '',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ),
        ],
      ),
      trailing: TextButton(
        onPressed: () => AuthService.instance.signOut(),
        child: Text(
          S.isTelugu ? 'లాగ్ అవుట్' : 'Sign Out',
          style: TextStyle(color: cs.error),
        ),
      ),
    );
  }
}

// ── Disclaimer tile ────────────────────────────────────────────────────────────

class _DisclaimerTile extends StatelessWidget {
  const _DisclaimerTile();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTelugu = S.isTelugu;

    return ExpansionTile(
      leading: const Icon(Icons.gavel_outlined),
      title: Text(isTelugu ? 'నిరాకరణ' : 'Disclaimer'),
      initiallyExpanded: false,
      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: [
        Text(
          isTelugu
              ? 'ఈ యాప్‌లోని పంచాంగ గణనలు సంప్రదాయ సూర్యసిద్ధాంత పద్ధతులపై '
                'ఆధారపడి ఉంటాయి. శృంగేరి పీఠం ప్రచురించే శ్రీ శారదా పీఠం '
                'పంచాంగం ప్రాథమిక సూచన మూలం. '
                'గ్రహస్థితులు, తిథి, నక్షత్రాదుల సమయాలు స్థానిక '
                'ఖగోళ స్థానం ఆధారంగా లెక్కించబడతాయి. '
                'ముఖ్యమైన ధార్మిక కార్యక్రమాలకు స్థానిక పండితులతో '
                'నిర్ధారించుకోండి.'
              : 'Panchangam calculations in this app are based on traditional '
                'Suryasiddhanta astronomical methods. The primary reference is '
                'the Sri Sharada Peetham Panchangam published by Sringeri Matha. '
                'Timings for tithi, nakshatra, and planetary positions are '
                'computed for your configured location. '
                'For important religious occasions, please verify with a '
                'local pandit.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.6,
              ),
        ),
      ],
    );
  }
}
