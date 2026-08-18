/// Subscription status lifecycle.
enum SubscriptionStatus {
  active('active', 'Aktif'),
  pending('pending', 'Menunggu'),
  trial('trial', 'Trial'),
  paused('paused', 'Dijeda'),
  cancelled('cancelled', 'Dibatalkan'),
  expired('expired', 'Kadaluarsa'),
  pastDue('past_due', 'Terlambat'),
  revoked('revoked', 'Dicabut');

  const SubscriptionStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  factory SubscriptionStatus.fromValue(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => pending,
    );
  }

  bool get isStarted => this == active || this == trial;
  bool get isEnded => this == cancelled || this == expired || this == revoked;
}
