import 'package:flutter_test/flutter_test.dart';
import 'package:moe_flutter_subscription/moe_flutter_subscription.dart';

void main() {
  group('BillingCycle', () {
    test('has correct days', () {
      expect(BillingCycle.daily.days, equals(1));
      expect(BillingCycle.weekly.days, equals(7));
      expect(BillingCycle.monthly.days, equals(30));
      expect(BillingCycle.yearly.days, equals(365));
    });

    test('fromString parses correctly', () {
      expect(BillingCycle.fromString('monthly'), equals(BillingCycle.monthly));
      expect(BillingCycle.fromString('yearly'), equals(BillingCycle.yearly));
    });
  });

  group('SubscriptionStatus', () {
    test('isStarted returns true for active/trial', () {
      expect(SubscriptionStatus.active.isStarted, isTrue);
      expect(SubscriptionStatus.trial.isStarted, isTrue);
      
      expect(SubscriptionStatus.cancelled.isStarted, isFalse);
      expect(SubscriptionStatus.expired.isStarted, isFalse);
    });

    test('isEnded returns true for ended statuses', () {
      expect(SubscriptionStatus.cancelled.isEnded, isTrue);
      expect(SubscriptionStatus.expired.isEnded, isTrue);
      expect(SubscriptionStatus.revoked.isEnded, isTrue);
      
      expect(SubscriptionStatus.active.isEnded, isFalse);
    });
  });

  group('SubscriptionPlanModel', () {
    test('monthlyEquivalent calculates correctly', () {
      const yearlyPlan = SubscriptionPlanModel(
        id: 'plan-yearly',
        name: 'Yearly Plan',
        description: 'Annual subscription',
        price: 1200000,
        billingCycle: BillingCycle.yearly,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        features: [],
      );

      expect(yearlyPlan.monthlyEquivalent, equals(100000));
      expect(yearlyPlan.price, equals(1200000));
    });

    test('hasFeature checks feature availability', () {
      const plan = SubscriptionPlanModel(
        id: 'plan-basic',
        name: 'Basic',
        description: 'Basic plan',
        price: 50000,
        billingCycle: BillingCycle.monthly,
        features: ['reports', 'analytics'],
        maxUsers: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(plan.hasFeature('reports'), isTrue);
      expect(plan.hasFeature('api_access'), isFalse);
    });

    test('fromJson parses all fields', () {
      final json = {
        'id': 'plan-premium',
        'name': 'Premium',
        'description': 'Full features',
        'price': 150000,
        'billing_cycle': 'monthly',
        'trial_days': 14,
        'features': ['reports', 'analytics', 'api_access'],
        'max_users': 10,
        'max_products': 1000,
        'enable_reports': true,
        'enable_analytics': true,
        'enable_api_access': true,
        'created_at': '2026-08-10T10:00:00.000Z',
        'updated_at': '2026-08-10T12:00:00.000Z',
      };

      final plan = SubscriptionPlanModel.fromJson(json);

      expect(plan.id, equals('plan-premium'));
      expect(plan.name, equals('Premium'));
      expect(plan.price, equals(150000));
      expect(plan.billingCycle, equals(BillingCycle.monthly));
      expect(plan.trialDays, equals(14));
      expect(plan.features.length, equals(3));
      expect(plan.maxUsers, equals(10));
      expect(plan.enableApiAccess, isTrue);
    });
  });

  group('SubscriptionModel', () {
    test('isActive returns true when status is active', () {
      const subscription = SubscriptionModel(
        id: 'sub1',
        userId: 'user1',
        planId: 'plan-monthly',
        planName: 'Monthly',
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
        paymentMethod: PaymentMethod.onlineBankTransfer.code,
        customerId: 'cust_123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(subscription.isActive, isTrue);
      expect(subscription.isInTrial, isFalse);
    });

    test('isInTrial returns true when in trial period', () {
      final subscription = SubscriptionModel(
        id: 'sub1',
        userId: 'user1',
        planId: 'plan-trial',
        planName: 'Trial',
        status: SubscriptionStatus.trial,
        startedAt: DateTime.now().subtract(Duration(days: 5)),
        trialEndsAt: DateTime.now().add(Duration(days: 9)),
        paymentMethod: PaymentMethod.onlineBankTransfer.code,
        customerId: 'cust_123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(subscription.isInTrial, isTrue);
      expect(subscription.isActive, isTrue);
    });

    test('trialEndingSoon detects trial ending within 24h', () {
      final subscription = SubscriptionModel(
        id: 'sub1',
        userId: 'user1',
        planId: 'plan-trial',
        planName: 'Trial',
        status: SubscriptionStatus.trial,
        startedAt: DateTime.now().subtract(Duration(hours: 479)),
        trialEndsAt: DateTime.now().add(Duration(hours: 1)),
        paymentMethod: PaymentMethod.onlineBankTransfer.code,
        customerId: 'cust_123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(subscription.trialEndingSoon, isTrue);
    });

    test('isExpired returns true when period has ended', () {
      final subscription = SubscriptionModel(
        id: 'sub1',
        userId: 'user1',
        planId: 'plan-expired',
        planName: 'Expired',
        status: SubscriptionStatus.expired,
        startedAt: DateTime.now().subtract(Duration(days: 60)),
        currentPeriodEnd: DateTime.now().subtract(Duration(days: 1)),
        paymentMethod: PaymentMethod.onlineBankTransfer.code,
        customerId: 'cust_123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(subscription.isExpired, isTrue);
      expect(subscription.isActive, isFalse);
    });

    test('fromJson parses subscription', () {
      final json = {
        'id': 'sub-123',
        'user_id': 'user-abc',
        'plan_id': 'plan-premium',
        'plan_name': 'Premium',
        'status': 'active',
        'started_at': '2026-07-10T10:00:00.000Z',
        'current_period_start': '2026-08-01T00:00:00.000Z',
        'current_period_end': '2026-09-01T00:00:00.000Z',
        'trial_ends_at': null,
        'cancelled_at': null,
        'cancel_reason': null,
        'payment_method': 'bank_transfer',
        'customer_id': 'cust_xyz',
        'created_at': '2026-07-10T10:00:00.000Z',
        'updated_at': '2026-08-10T12:00:00.000Z',
      };

      final subscription = SubscriptionModel.fromJson(json);

      expect(subscription.id, equals('sub-123'));
      expect(subscription.userId, equals('user-abc'));
      expect(subscription.status, equals(SubscriptionStatus.active));
      expect(subscription.currentPeriodStart, isNotNull);
      expect(subscription.currentPeriodEnd, isNotNull);
    });
  });

  group('MoeSubscriptionConfig', () {
    test('has required apiUrl', () {
      const config = MoeSubscriptionConfig(
        apiUrl: 'https://api.example.com/subscriptions',
      );

      expect(config.apiUrl, equals('https://api.example.com/subscriptions'));
      expect(config.enableTrialPlans, isTrue);
    });
  });
}
