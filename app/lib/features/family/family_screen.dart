import 'package:flutter/material.dart';
import '../../core/utils/app_strings.dart';
import '../../shared/widgets/paywall_screen.dart';

/// Family tab — placeholder paywall screen. Family features in v2.
class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaywallScreen(
      featureName: S.isTelugu
          ? 'రిమైండర్లు · అలారంలు · జన్మ తిథి · కుటుంబ వేడుకలు'
          : 'Reminders · Alarms · Tithi Birthdays · Family Occasions',
    );
  }
}
