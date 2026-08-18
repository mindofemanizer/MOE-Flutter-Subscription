import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_subscription/src/models/subscription_plan_model.dart';
import 'package:moe_flutter_subscription/src/models/subscription_model.dart';
import 'package:moe_flutter_subscription/src/services/subscription_repository.dart';

/// State for subscription plans.
sealed class PlansState {
  const PlansState();
}

final class PlansInitial extends PlansState {
  const PlansInitial();
}

final class PlansLoading extends PlansState {
  const PlansLoading();
}

final class PlansLoaded extends PlansState {
  final List<SubscriptionPlanModel> plans;
  const PlansLoaded(this.plans);
}

final class PlansError extends PlansState {
  final AppFailure failure;
  const PlansError(this.failure);
}

/// Notifier for plans.
class PlansNotifier extends StateNotifier<PlansState> {
  final SubscriptionRepository _repository;

  PlansNotifier(this._repository) : super(const PlansInitial());

  Future<void> loadPlans() async {
    state = const PlansLoading();

    final result = await _repository.listPlans();

    switch (result) {
      case Ok(:final data):
        state = PlansLoaded(data);
      case Err(:final failure):
        state = PlansError(failure);
    }
  }

  /// Get cheapest plan by monthly equivalent.
  SubscriptionPlanModel? getCheapest() {
    if (state is! PlansLoaded) return null;

    final plans = (state as PlansLoaded).plans;
    if (plans.isEmpty) return null;

    return plans.reduce(
      (a, b) => a.monthlyEquivalent < b.monthlyEquivalent ? a : b,
    );
  }

  /// Find trial plan if available.
  SubscriptionPlanModel? getTrialPlan() {
    if (state is! PlansLoaded) return null;

    final loaded = state as PlansLoaded;
    return loaded.plans.firstWhere(
      (p) => p.trialDays > 0,
      orElse: () => throw StateError('No trial plan available'),
    );
  }
}

/// State for subscriptions.
sealed class SubscriptionsState {
  const SubscriptionsState();
}

final class SubscriptionsInitial extends SubscriptionsState {
  const SubscriptionsInitial();
}

final class SubscriptionsLoading extends SubscriptionsState {
  const SubscriptionsLoading();
}

final class SubscriptionsLoaded extends SubscriptionsState {
  final SubscriptionModel? activeSubscription;
  final List<SubscriptionModel> history;
  const SubscriptionsLoaded({this.activeSubscription, required this.history});
}

final class SubscriptionsError extends SubscriptionsState {
  final AppFailure failure;
  const SubscriptionsError(this.failure);
}

/// Notifier for subscriptions.
class SubscriptionsNotifier extends StateNotifier<SubscriptionsState> {
  final SubscriptionRepository _repository;

  SubscriptionsNotifier(this._repository) : super(const SubscriptionsInitial());

  Future<AppResult<SubscriptionModel?>> getCurrent(String userId) async {
    state = const SubscriptionsLoading();

    final result = await _repository.getCurrentSubscription(userId);

    switch (result) {
      case Ok(:final data):
        state = SubscriptionsLoaded(
          activeSubscription: data,
          history: [], // Will be loaded separately
        );
      case Err(:final failure):
        state = SubscriptionsError(failure);
    }

    return result;
  }

  Future<AppResult<List<SubscriptionModel>>> getHistory(String userId) async {
    final result = await _repository.listSubscriptions(userId);

    if (result case Ok(:final data)) {
      if (state is! SubscriptionsLoaded) return result;
      final loaded = state as SubscriptionsLoaded;
      state = SubscriptionsLoaded(
        activeSubscription: loaded.activeSubscription,
        history: data,
      );
    }

    return result;
  }

  Future<AppResult<SubscriptionModel>> createSubscription({
    required String userId,
    required String planId,
    required String paymentMethod,
    String? customerId,
  }) async {
    final result = await _repository.createSubscription(
      userId: userId,
      planId: planId,
      paymentMethod: paymentMethod,
      customerId: customerId,
    );

    if (result case Ok(:final data)) {
      if (state is! SubscriptionsLoaded) return result;
      final loaded = state as SubscriptionsLoaded;
      // Update active subscription
      state = SubscriptionsLoaded(
        activeSubscription: data,
        history: [...loaded.history],
      );
    }

    return result;
  }

  Future<void> cancelSubscription(String id, {String? reason}) async {
    final result = await _repository.cancelSubscription(id, reason: reason);

    if (result is Ok && state is SubscriptionsLoaded) {
      final loaded = state as SubscriptionsLoaded;
      // Remove from active if matched
      final newActive = loaded.activeSubscription?.id == id
          ? null
          : loaded.activeSubscription;

      state = SubscriptionsLoaded(
        activeSubscription: newActive,
        history: loaded.history,
      );
    }
  }
}

/// Provider for SubscriptionRepository.
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  throw UnimplementedError(
    'MoeSubscription.setup() must be called before use.',
  );
});

/// Provider for PlansNotifier.
final plansProvider = StateNotifierProvider<PlansNotifier, PlansState>(
  (ref) => PlansNotifier(ref.watch(subscriptionRepositoryProvider)),
);

/// Provider for SubscriptionsNotifier.
final subscriptionsProvider =
    StateNotifierProvider<SubscriptionsNotifier, SubscriptionsState>(
      (ref) => SubscriptionsNotifier(ref.watch(subscriptionRepositoryProvider)),
    );
