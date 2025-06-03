class NotificationSetupResult {
  final bool hasPermission;
  final bool hasFCMToken;
  final bool success;

  const NotificationSetupResult({
    required this.hasPermission,
    required this.hasFCMToken,
    required this.success,
  });

  bool get isComplete => hasPermission && hasFCMToken && success;
}
