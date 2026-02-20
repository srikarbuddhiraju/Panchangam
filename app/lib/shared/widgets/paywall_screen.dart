import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/utils/app_strings.dart';

/// Paywall shown when a user tries to access a premium feature.
/// The Subscribe button is inactive until Firebase + in-app purchase is wired up.
class PaywallScreen extends StatelessWidget {
  final String featureName;

  const PaywallScreen({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.workspace_premium,
                size: 80,
                color: AppTheme.kGold,
              ),
              const SizedBox(height: 24),
              Text(
                S.isTelugu ? 'ప్రీమియం ఫీచర్' : 'Premium Feature',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                featureName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.kSaffron,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _PricingCard(
                label: S.isTelugu ? 'నెలవారీ' : 'Monthly',
                price: '₹99',
                period: S.isTelugu ? '/నెల' : '/month',
              ),
              const SizedBox(height: 12),
              _PricingCard(
                label: S.isTelugu ? 'వార్షిక' : 'Annual',
                price: '₹799',
                period: S.isTelugu ? '/సంవత్సరం' : '/year',
                highlight: true,
              ),
              const SizedBox(height: 12),
              _PricingCard(
                label: S.isTelugu ? 'కుటుంబ ప్లాన్' : 'Family Plan',
                price: '₹149',
                period: S.isTelugu ? '/నెల' : '/month',
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: null, // TODO: wire up in_app_purchase
                icon: const Icon(Icons.lock_open),
                label: Text(S.isTelugu ? 'సభ్యత్వం తీసుకోండి' : 'Subscribe'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.kSaffron,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                S.isTelugu
                    ? 'త్వరలో అందుబాటులోకి వస్తుంది'
                    : 'Coming soon — subscriptions launching with v2',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String label;
  final String price;
  final String period;
  final bool highlight;

  const _PricingCard({
    required this.label,
    required this.price,
    required this.period,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? AppTheme.kSaffron : Colors.grey.shade300,
          width: highlight ? 2 : 1,
        ),
        color: highlight
            ? AppTheme.kSaffron.withValues(alpha: 0.05)
            : null,
      ),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(period, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
