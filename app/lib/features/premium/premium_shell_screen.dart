import 'package:flutter/material.dart';
import '../../core/utils/app_strings.dart';
import '../../shared/widgets/paywall_screen.dart';

/// Premium tab — shows paywall. Features will be added in v2.
class PremiumShellScreen extends StatelessWidget {
  const PremiumShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaywallScreen(
      featureName: S.isTelugu
          ? 'రిమైండర్లు · అలారంలు · జన్మ తిథి · కుటుంబ వేడుకలు'
          : 'Reminders · Alarms · Tithi Birthdays · Family Occasions',
    );
  }
}
