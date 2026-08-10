/// Subscription plan with features & pricing.
class SubscriptionPlanModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final BillingCycle billingCycle;
  final int trialDays;
  final List<String> features;
  final int maxUsers;
  final int maxProducts;
  final bool enableReports;
  final bool enableAnalytics;
  final bool enableApiAccess;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingCycle,
    this.trialDays = 14,
    required this.features,
    this.maxUsers = 1,
    this.maxProducts = 100,
    this.enableReports = true,
    this.enableAnalytics = false,
    this.enableApiAccess = false,
    required this.createdAt,
    required this.updatedAt,
  }) : assert price >= 0;

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      billingCycle: BillingCycle.fromString(json['billing_cycle'] as String),
      trialDays: json['trial_days'] as int? ?? 14,
      features: (json['features'] as List<dynamic>?)?.map((f) => f as String).toList() ?? [],
      maxUsers: json['max_users'] as int? ?? 1,
      maxProducts: json['max_products'] as int? ?? 100,
      enableReports: json['enable_reports'] as bool? ?? true,
      enableAnalytics: json['enable_analytics'] as bool? ?? false,
      enableApiAccess: json['enable_api_access'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'billing_cycle': billingCycle.stringValue,
      'trial_days': trialDays,
      'features': features,
      'max_users': maxUsers,
      'max_products': maxProducts,
      'enable_reports': enableReports,
      'enable_analytics': enableAnalytics,
      'enable_api_access': enableApiAccess,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Monthly price equivalent for comparison.
  double get monthlyEquivalent {
    return switch (billingCycle) {
      BillingCycle daily => price * 30,
      BillingCycle weekly => price * 4.33, // average weeks per month
      BillingCycle monthly => price,
      BillingCycle yearly => price / 12,
    };
  }

  /// Check if user can access a feature.
  bool hasFeature(String featureName) => features.contains(featureName);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        billingCycle,
        trialDays,
        features,
        maxUsers,
        maxProducts,
        enableReports,
        enableAnalytics,
        enableApiAccess,
        createdAt,
        updatedAt,
      ];
}
