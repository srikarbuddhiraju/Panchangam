import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_strings.dart';
import '../../features/settings/settings_provider.dart';

/// తె | EN toggle button for the app bar or settings screen.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsProvider.select((s) => s.language));

    return SegmentedButton<AppLanguage>(
      segments: const [
        ButtonSegment(value: AppLanguage.telugu, label: Text('తె')),
        ButtonSegment(value: AppLanguage.english, label: Text('EN')),
      ],
      selected: {lang},
      onSelectionChanged: (selection) {
        ref
            .read(settingsProvider.notifier)
            .setLanguage(selection.first);
      },
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
