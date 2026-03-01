import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../core/utils/app_strings.dart';
import '../../features/auth/auth_provider.dart';
import '../../services/auth_service.dart';
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

          // ── App version ───────────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(S.isTelugu ? 'వెర్షన్' : 'Version'),
            trailing: const Text('1.0.0'),
          ),
        ],
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
