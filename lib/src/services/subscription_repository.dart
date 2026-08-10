import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_subscription/src/config/subscription_config.dart';
import 'package:moe_flutter_subscription/src/models/subscription_plan_model.dart';
import 'package:moe_flutter_subscription/src/models/subscription_model.dart';

/// Repository for subscription operations.
class SubscriptionRepository {
  final Dio _dio;
  final MoeSubscriptionConfig _config;

  SubscriptionRepository(this._dio, this._config);

  // ── Plans ──────────────────────────────────────────────────

  /// List all available plans.
  Future<AppResult<List<SubscriptionPlanModel>>> listPlans() async {
    try {
      final response = await _dio.get('/plans');
      final data = response.data as List<dynamic>;
      final plans = data
          .whereType<Map<String, dynamic>>()
          .map((p) => SubscriptionPlanModel.fromJson(p))
          .toList();
      return Ok(plans);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Get single plan by ID.
  Future<AppResult<SubscriptionPlanModel>> getPlan(String id) async {
    try {
      final response = await _dio.get('/plans/$id');
      return Ok(SubscriptionPlanModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  // ── Subscriptions ──────────────────────────────────────────

  /// Get user's current subscription.
  Future<AppResult<SubscriptionModel?>> getCurrentSubscription(String userId) async {
    try {
      final response = await _dio.get('/subscriptions/user/$userId/active');
      if (response.statusCode == 204) {
        return const Ok(null); // No active subscription
      }
      return Ok(SubscriptionModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Ok(null);
      }
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// List user's subscription history.
  Future<AppResult<List<SubscriptionModel>>> listSubscriptions(String userId) async {
    try {
      final response = await _dio.get('/subscriptions/user/$userId');
      final data = response.data as List<dynamic>;
      final subscriptions = data
          .whereType<Map<String, dynamic>>()
          .map((s) => SubscriptionModel.fromJson(s))
          .toList();
      return Ok(subscriptions);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Create new subscription (upgrade/downgrade/cancel).
  Future<AppResult<SubscriptionModel>> createSubscription({
    required String userId,
    required String planId,
    required String paymentMethod,
    String? customerId,
  }) async {
    try {
      final response = await _dio.post('/subscriptions', data: {
        'user_id': userId,
        'plan_id': planId,
        'payment_method': paymentMethod,
        if (customerId != null) 'customer_id': customerId,
      });
      return Ok(SubscriptionModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Cancel subscription.
  Future<AppResult<void>> cancelSubscription(String id, {String? reason}) async {
    try {
      await _dio.post('/subscriptions/$id/cancel', data: {
        if (reason != null) 'reason': reason,
      });
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Resume paused subscription.
  Future<AppResult<void>> resumeSubscription(String id) async {
    try {
      await _dio.post('/subscriptions/$id/resume');
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Upgrade subscription plan.
  Future<AppResult<SubscriptionModel>> upgradeSubscription({
    required String subscriptionId,
    required String newPlanId,
    required String paymentMethod,
  }) async {
    try {
      final response = await _dio.post('/subscriptions/$subscriptionId/upgrade', data: {
        'new_plan_id': newPlanId,
        'payment_method': paymentMethod,
      });
      return Ok(SubscriptionModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }
}
