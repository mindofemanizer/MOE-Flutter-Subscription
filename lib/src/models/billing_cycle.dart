/// Billing cycle frequency.
sealed class BillingCycle {
  const BillingCycle();

  String get stringValue;
  int get days;

  factory BillingCycle.fromString(String value) {
    switch (value) {
      case 'daily':
        return daily;
      case 'weekly':
        return weekly;
      case 'monthly':
        return monthly;
      case 'yearly':
        return yearly;
      default:
        throw Exception('Unknown billing cycle: $value');
    }
  }

  static const daily = _BillingCycleDaily();
  static const weekly = _BillingCycleWeekly();
  static const monthly = _BillingCycleMonthly();
  static const yearly = _BillingCycleYearly();
}

class _BillingCycleDaily extends BillingCycle {
  const _BillingCycleDaily();
  @override
  String get stringValue => 'daily';
  @override
  int get days => 1;
}

class _BillingCycleWeekly extends BillingCycle {
  const _BillingCycleWeekly();
  @override
  String get stringValue => 'weekly';
  @override
  int get days => 7;
}

class _BillingCycleMonthly extends BillingCycle {
  const _BillingCycleMonthly();
  @override
  String get stringValue => 'monthly';
  @override
  int get days => 30;
}

class _BillingCycleYearly extends BillingCycle {
  const _BillingCycleYearly();
  @override
  String get stringValue => 'yearly';
  @override
  int get days => 365;
}
