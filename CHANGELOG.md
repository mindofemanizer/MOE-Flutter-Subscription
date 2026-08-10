# Changelog

## 1.0.0 — 2026-08-10

### Added
- Initial release
- `BillingCycle` — daily/weekly/monthly/yearly with days calculation
- `SubscriptionStatus` — active/trial/paused/cancelled/expired/lifecycle
- `SubscriptionPlanModel` — plans with features, pricing, trial days
- `SubscriptionModel` — active subscription with period tracking
- `SubscriptionRepository` — list plans, manage subscriptions, upgrade/downgrade
- `PlansNotifier` — auto-find cheapest plan, trial plan detection
- `SubscriptionsNotifier` — create/cancel/resume subscriptions, period management
- `MoeSubscriptionConfig` — configurable API URL + trial support

### Features
- Monthly price equivalent calculation for comparison
- Trial period tracking (starts/end dates)
- Upgrade/downgrade plans with proration ready
- Subscription history logging
- Cancel with reason tracking
- Resume paused subscriptions
- Feature-based access control (`hasFeature()`)
