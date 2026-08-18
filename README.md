# MOE-Flutter-Subscription

Subscription management for MOE Flutter ecosystem â€” plans, billing cycles, trials.

## Installation

```yaml
dependencies:
  moe_flutter_subscription:
    git:
      url: https://github.com/mindofemanizer/MOE-Flutter-Subscription.git
      ref: v1.0.0
```

## Usage

### Setup

```dart
import 'package:moe_flutter_foundation/moe_flutter_foundation.dart';
import 'package:moe_flutter_subscription/moe_flutter_subscription.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  await MoeFoundation.setup(
    envConfig: EnvConfig.fromEnvironment(),
    sharedPreferences: prefs,
  );

  MoeSubscription.setup(
    config: MoeSubscriptionConfig(
      apiUrl: 'https://api.kioskit.com/api/subscriptions',
      enableTrialPlans: true,
    ),
  );

  runApp(MoeFoundationProviderScope(child: MyApp()));
}
```

### List Available Plans

```dart
final state = ref.watch(plansProvider.notifier);

await ref.read(plansProvider.notifier).loadPlans();

switch (state) {
  case PlansLoaded(:final plans):
    ListView.builder(
      itemCount: plans.length,
      itemBuilder: (ctx, i) => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(plans[i].name),
              subtitle: Text(plans[i].description),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(Formatters.currency(plans[i].price)),
                  Text(
                    '/ ${plans[i].billingCycle.stringValue}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Divider(),
                  // Monthly equivalent for comparison
                  Text(
                    'â‰ˆ ${Formatters.currency(plans[i].monthlyEquivalent)} / month',
                    style: TextStyle(fontSize: 12),
                  ),
                  Wrap(
                    spacing: 4,
                    children: plans[i].features.map((f) => Chip(label: Text(f))).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Find cheapest plan
    final cheapest = ref.read(plansProvider.notifier).getCheapest();
    print('Best value: ${cheapest?.name} @ Rp ${Formatters.currency(cheapest?.monthlyEquivalent ?? 0)}/month');

  default:
    CircularProgressIndicator();
}
```

### Check User's Subscription

```dart
final mySubState = ref.watch(subscriptionsProvider.notifier);

// Get current active subscription
final result = await ref.read(subscriptionsProvider.notifier).getCurrent('user_123');

if (result is Ok && result.data != null) {
  final sub = result.data!;
  
  if (sub.isActive) {
    print('âœ… Active on ${sub.planName}');
    print('Period ends: ${sub.currentPeriodEnd}');
    
    // Check if trial ending soon
    if (sub.trialEndingSoon) {
      print('âš ï¸ Trial ending in <24 hours!');
    }
    
    // Check features
    if (sub.planId == 'plan-premium') {
      // Show premium features UI
    }
  } else if (sub.isExpired) {
    print('ðŸ“… Subscription expired, please renew');
  }
} else {
  print('âŒ No active subscription - show plans');
}

// View subscription history
final historyResult = await ref
  .read(subscriptionsProvider.notifier)
  .getHistory('user_123');
```

### Create/New Subscription

```dart
// Subscribe to basic plan
final result = await ref.read(subscriptionsProvider.notifier).createSubscription(
  userId: 'user_123',
  planId: 'plan-basic-monthly',
  paymentMethod: PaymentMethod.onlineBankTransfer.code,
);

if (result is Ok) {
  final subscription = result.data;
  print('Subscription created: ${subscription.id}');
  
  // Navigate to payment gateway if needed
  // Or handle webhook callback
  
  // Success
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Berlangganan berhasil!')),
  );
}
```

### Upgrade/Downgrade

```dart
// Upgrade from basic to premium
final upgraded = await ref.read(subscriptionsProvider.notifier).upgradeSubscription(
  subscriptionId: 'sub_old',
  newPlanId: 'plan-premium-yearly',
  paymentMethod: PaymentMethod.creditCard.code,
);

if (upgraded is Ok) {
  // Handle prorated charge if backend supports it
  print('Upgraded to ${upgraded.data.planName}');
}

// Cancel subscription (keep until period end)
await ref.read(subscriptionsProvider.notifier).cancelSubscription(
  'sub_123',
  reason: 'Too expensive, looking for cheaper alternative',
);
```

### Subscription Status Indicators

```dart
Widget buildStatusIndicator(SubscriptionModel sub) {
  if (sub.isActive) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('${sub.planName} â€¢ ${sub.status.displayName}'),
        ],
      ),
    );
  } else if (sub.inTrial && sub.trialEndingSoon) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Colors.orange),
          SizedBox(width: 8),
          Text('Trial segera berakhir!'),
        ],
      ),
    );
  } else {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('Tidak aktif - ${sub.status.displayName}'),
    );
  }
}
```

## What's Included

| Module | Description |
|--------|-------------|
| `SubscriptionPlanModel` | Plan data with features, pricing, trial days |
| `SubscriptionModel` | Active subscription with period tracking |
| `BillingCycle` | Daily/weekly/monthly/yearly billing frequencies |
| `SubscriptionStatus` | Full lifecycle states |
| `SubscriptionRepository` | CRUD operations for plans & subscriptions |
| `PlansNotifier` | Load plans, find best value options |
| `SubscriptionsNotifier` | Create/manage subscriptions, check status |

## Pricing Comparison

Use `monthlyEquivalent` to compare different billing cycles:

```dart
const basicWeekly = SubscriptionPlanModel(..., price: 15000, cycle: weekly);
const basicMonthly = SubscriptionPlanModel(..., price: 50000, cycle: monthly);
const basicYearly = SubscriptionPlanModel(..., price: 480000, cycle: yearly);

// Comparison
print('Weekly â†’ ${Formatters.currency(basicWeekly.monthlyEquivalent)} / month'); // ~Rp 65,000
print('Monthly â†’ ${Formatters.currency(basicMonthly.monthlyEquivalent)} / month'); // Rp 50,000 âœ… Best
print('Yearly â†’ ${Formatters.currency(basicYearly.monthlyEquivalent)} / month'); // Rp 40,000 âœ… Cheapest
```

This helps users choose the best value option!
