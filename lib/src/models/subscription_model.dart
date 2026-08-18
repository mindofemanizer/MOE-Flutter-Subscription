import 'package:equatable/equatable.dart';

import 'package:moe_flutter_subscription/src/models/subscription_status.dart';

/// Active subscription held by user.
class SubscriptionModel extends Equatable {
  final String id;
  final String userId;
  final String planId;
  final String planName;
  final SubscriptionStatus status;
  final DateTime startedAt;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? trialEndsAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final String paymentMethod;
  final String customerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.status,
    required this.startedAt,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.trialEndsAt,
    this.cancelledAt,
    this.cancelReason,
    required this.paymentMethod,
    required this.customerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      planId: json['plan_id'] as String,
      planName: json['plan_name'] as String,
      status: SubscriptionStatus.fromValue(json['status']),
      startedAt: DateTime.parse(json['started_at'] as String),
      currentPeriodStart: json['current_period_start'] != null
          ? DateTime.parse(json['current_period_start'] as String)
          : null,
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'] as String)
          : null,
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancelReason: json['cancel_reason'] as String?,
      paymentMethod: json['payment_method'] as String,
      customerId: json['customer_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'plan_name': planName,
      'status': status.value,
      'started_at': startedAt.toIso8601String(),
      if (currentPeriodStart != null) 'current_period_start': currentPeriodStart!.toIso8601String(),
      if (currentPeriodEnd != null) 'current_period_end': currentPeriodEnd!.toIso8601String(),
      if (trialEndsAt != null) 'trial_ends_at': trialEndsAt!.toIso8601String(),
      if (cancelledAt != null) 'cancelled_at': cancelledAt!.toIso8601String(),
      if (cancelReason != null) 'cancel_reason': cancelReason,
      'payment_method': paymentMethod,
      'customer_id': customerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Is subscription active or in trial?
  bool get isActive => status.isStarted;

  /// Check if trial is ongoing.
  bool get isInTrial => status == SubscriptionStatus.trial && trialEndsAt != null;

  /// Check if trial is about to end (within 24 hours).
  bool get trialEndingSoon => isInTrial && 
    (trialEndsAt!.difference(DateTime.now()).inHours <= 24);

  /// Check if subscription has expired.
  bool get isExpired => status == SubscriptionStatus.expired || 
    (currentPeriodEnd != null && currentPeriodEnd!.isBefore(DateTime.now()));

  @override
  List<Object?> get props => [
        id,
        userId,
        planId,
        planName,
        status,
        startedAt,
        currentPeriodStart,
        currentPeriodEnd,
        trialEndsAt,
        cancelledAt,
        cancelReason,
        paymentMethod,
        customerId,
        createdAt,
        updatedAt,
      ];
}
