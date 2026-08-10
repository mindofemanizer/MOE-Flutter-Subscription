import 'package:equatable/equatable.dart';

/// Configuration for MOE Subscription module.
class MoeSubscriptionConfig extends Equatable {
  final String apiUrl;
  final String? apiKey;
  final bool enableTrialPlans;

  const MoeSubscriptionConfig({
    required this.apiUrl,
    this.apiKey,
    this.enableTrialPlans = true,
  });

  @override
  List<Object?> get props => [apiUrl, apiKey, enableTrialPlans];
}
